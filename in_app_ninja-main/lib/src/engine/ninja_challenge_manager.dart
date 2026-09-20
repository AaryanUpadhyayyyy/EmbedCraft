import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ninja_sdk_safe.dart';
import '../models/campaign.dart';
import '../models/challenge_model.dart';
import '../data/ninja_campaign_repository.dart';
import '../utils/ninja_logger.dart';

/// Helper class for pending task completion nudges
class _PendingNudge {
  final String campaignId;
  final String taskId;
  final String interfaceId;

  _PendingNudge({
    required this.campaignId,
    required this.taskId,
    required this.interfaceId,
  });
}

/// AppNinja's Challenge Execution Engine
/// Handles local progression tracking for Gamified Challenges
class NinjaChallengeManager {
  static const String _prefsKeyProgress = 'ninja_challenge_progress';
  static SharedPreferences? _prefs;

  // In-memory cache of local progress. Structure:
  // { "campaignId_taskId_eventId": 3 } (where 3 is the current evaluation count)
  static Map<String, int> _localProgress = {};

  // Queue of completion nudges waiting to be displayed
  static final List<_PendingNudge> _pendingCompletionNudges = [];

  /// Returns and drains pending task completion nudge interface IDs.
  /// Each entry contains { campaignId, taskId, interfaceId }.
  /// The caller (e.g. campaign_renderer) should use interfaceId to find
  /// the matching interface in campaign.interfaces and render it.
  static List<Map<String, String>> consumePendingCompletionNudges() {
    if (_pendingCompletionNudges.isEmpty) return [];
    final result = _pendingCompletionNudges
        .map((n) => <String, String>{
              'campaignId': n.campaignId,
              'taskId': n.taskId,
              'interfaceId': n.interfaceId,
            })
        .toList();
    _pendingCompletionNudges.clear();
    return result;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedData = _prefs?.getString(_prefsKeyProgress);
    if (savedData != null) {
      try {
        final decoded = jsonDecode(savedData) as Map<String, dynamic>;
        _localProgress =
            decoded.map((key, value) => MapEntry(key, value as int));
        _evictStaleDailyKeys();
      } catch (e) {
        NinjaLog.e('NinjaChallengeManager', 'Failed to load local progress', error: e);
      }
    }
  }

  /// Removes daily progress keys older than 48 hours to prevent SQLite/SharedPreferences memory leaks
  static void _evictStaleDailyKeys() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final key in _localProgress.keys) {
      // Daily keys end with _YYYY-MM-DD
      final parts = key.split('_');
      if (parts.isNotEmpty) {
        final possibleDateStr = parts.last;
        if (possibleDateStr.length == 10 && possibleDateStr.contains('-')) {
          final dateObj = DateTime.tryParse(possibleDateStr);
          if (dateObj != null) {
            if (now.difference(dateObj).inHours > 48) {
              keysToRemove.add(key);
            }
          }
        }
      }
    }

    if (keysToRemove.isNotEmpty) {
      for (final k in keysToRemove) {
        _localProgress.remove(k);
      }
      ninjaSdkSafeUnawaited(_saveProgress(),
          context: 'challenge garbage collect');
    }
  }

  /// Helper to generate state key respecting Task Attempt Limits
  static String _getTaskProgressKey(
      String campaignId, ChallengeTask task, String eventId) {
    final freq = task.logic.limits['attemptFrequency']?.toString();
    if (freq == 'daily') {
      // Append YYYY-MM-DD to isolate daily progress
      final today = DateTime.now().toIso8601String().split('T')[0];
      return '${campaignId}_${task.id}_${eventId}_$today';
    }
    return '${campaignId}_${task.id}_${eventId}';
  }

  /// Get the current completion count for a specific event condition in a task
  static int getEventProgress(
      String campaignId, ChallengeTask task, String eventId) {
    return _localProgress[_getTaskProgressKey(campaignId, task, eventId)] ?? 0;
  }

  /// Calculates how many full cycles have been completed for a task
  static int _getCompletedCycles(String campaignId, ChallengeTask task) {
    if (task.logic.eventGroups.isEmpty) return 0;
    return task.logic.eventGroups.map((group) {
      if (group.operator == 'OR') {
        return group.events.isEmpty ? 0 : group.events.map((e) => e.count > 0 ? getEventProgress(campaignId, task, e.eventId) ~/ e.count : 0).reduce((a, b) => a > b ? a : b);
      } else {
        return group.events.isEmpty ? 0 : group.events.map((e) => e.count > 0 ? getEventProgress(campaignId, task, e.eventId) ~/ e.count : 0).reduce((a, b) => a < b ? a : b);
      }
    }).reduce((a, b) => a < b ? a : b);
  }

  /// Determines if a task has satisfied all its logic groups and required limits
  static bool isTaskFullyComplete(String campaignId, ChallengeTask task) {
    int requiredCycles = 1;
    if (task.logic.limits['attemptFrequency'] == 'once') {
      requiredCycles = 1;
    } else if (task.logic.limits['completionLimit'] != null &&
        task.logic.limits['completionLimit'] is num) {
      requiredCycles = (task.logic.limits['completionLimit'] as num).toInt();
    }

    for (var group in task.logic.eventGroups) {
      bool groupComplete = false;
      if (group.operator == 'OR') {
        for (var condition in group.events) {
          int totalRequired = condition.count * requiredCycles;
          if (getEventProgress(campaignId, task, condition.eventId) >=
              totalRequired) {
            groupComplete = true;
            break;
          }
        }
      } else {
        groupComplete = true;
        for (var condition in group.events) {
          int totalRequired = condition.count * requiredCycles;
          if (getEventProgress(campaignId, task, condition.eventId) <
              totalRequired) {
            groupComplete = false;
            break;
          }
        }
      }
      if (!groupComplete) return false;
    }
    return true;
  }

  /// Evaluates an inbound event against active challenge campaigns
  static void evaluateEvent(String eventName,
      Map<String, dynamic> eventProperties, List<Campaign> activeCampaigns,
      {required String userId,
      required Map<String, dynamic> userProperties,
      required String baseUrl,
      required Map<String, String> headers}) {
    try {
      bool progressMade = false;

      // Filter only challenge campaigns (use challengeDetails presence, NOT type field)
      // Note: campaign.type contains the nudge widget type (e.g., 'bottomsheet'),
      // while campaignType ('challenge') is stored separately and not parsed into campaign.type
      final challenges = activeCampaigns
          .where((c) => c.status == 'active' && c.challengeDetails != null);

      for (var campaign in challenges) {
        final config = campaign.challengeDetails!;
        bool matchedInThisCampaign =
            false; // For allowMultipleSimultaneousTasks break

        for (int i = 0; i < config.tasks.length; i++) {
          var task = config.tasks[i];

          // Ensure Sequential Order Requirement
          if (config.executionOrder == 'sequential' && i > 0) {
            var prevTask = config.tasks[i - 1];

            // Check if previous task is 100% complete (ALL cycles exhausted)
            bool isPrevComplete = isTaskFullyComplete(campaign.id, prevTask);
            if (!isPrevComplete) {
              // Task is locked until previous is completed. Skip evaluation.
              continue;
            }
          }

          // Validate SDK Task-Level Segment Filters against active user metadata
          // If a task evaluates to 'locked' based on user properties, prevent progression
          if (task.logic.userFilters != null &&
              task.logic.userFilters!.isNotEmpty) {
            if (!evaluateFilters(task.logic.userFilters, userProperties)) {
              continue; // Force Block Progression
            }
          }

          // Evaluate each event group inside the task
          for (var group in task.logic.eventGroups) {
            for (var condition in group.events) {
              // Check if the tracked eventName matches the condition's eventId
              // Optionally, handle flexible naming like in AppNinja tracking
              if (condition.eventId.toLowerCase() == eventName.toLowerCase()) {
                // VERIFY METADATA FILTERS
                if (!evaluateFilters(condition.filters, eventProperties)) {
                  continue; // Skip this event condition if the metadata filters fail
                }

                final key =
                    _getTaskProgressKey(campaign.id, task, condition.eventId);
                final currentCount = _localProgress[key] ?? 0;

                // Determine absolute scale ceiling (number of repeated completion loops configured by Admin)
                int limitFactor = 1; // Default
                if (task.logic.limits['attemptFrequency'] != 'once') {
                  if (task.logic.limits['completionLimit'] != null &&
                      task.logic.limits['completionLimit'] is num) {
                    limitFactor =
                        (task.logic.limits['completionLimit'] as num).toInt();
                  } else if (task.logic.limits['attemptFrequency'] ==
                      'always') {
                    // Provide a sufficiently large ceiling allowing practically infinite cumulative iterations
                    // If no completion limit is explicitly given but behavior is 'always'
                    if (task.logic.limits['completionLimit'] == null) {
                      limitFactor = 999999;
                    }
                  }
                }

                int maxAllowedThreshold = condition.count * limitFactor;

                if (currentCount < maxAllowedThreshold) {
                  // Determine cycles before increment
                  int cyclesBefore = _getCompletedCycles(campaign.id, task);
                  final wasAlreadyComplete =
                      isTaskFullyComplete(campaign.id, task);

                  _localProgress[key] = currentCount + 1;
                  progressMade = true;
                  matchedInThisCampaign = true;

                  NinjaLog.d('NinjaChallengeManager',
                      'Progress +1 for task [${task.title}] - Event: $eventName (${_localProgress[key]}/${condition.count})');

                  // Dispatch backend sync Fire-and-Forget
                  NinjaCampaignRepository().syncChallengeProgress(
                    baseUrl: baseUrl,
                    userId: userId,
                    campaignId: campaign.id,
                    taskId: task.id,
                    eventId: condition.eventId,
                    latestCount: _localProgress[key]!,
                    headers: headers,
                  );

                  // Determine cycles after increment
                  int cyclesAfter = _getCompletedCycles(campaign.id, task);

                  // Trigger condition: Task hit its first 100% completion OR completed a new repeatable cycle
                  bool justCompletedCycle = (!wasAlreadyComplete &&
                      isTaskFullyComplete(campaign.id, task)) || (cyclesAfter > cyclesBefore);

                  if (justCompletedCycle) {
                    NinjaLog.d('NinjaChallengeManager',
                        '🏆 Task [${task.title}] Cycle Completed! Triggering Reward API...');
                    NinjaCampaignRepository().claimChallengeReward(
                      baseUrl: baseUrl,
                      userId: userId,
                      campaignId: campaign.id,
                      taskId: task.id,
                      headers: headers,
                    );

                    // Show task completion nudge if configured
                    if (task.completionNudgeId != null &&
                        task.completionNudgeId!.isNotEmpty) {
                      _pendingCompletionNudges.add(_PendingNudge(
                        campaignId: campaign.id,
                        taskId: task.id,
                        interfaceId: task.completionNudgeId!,
                      ));
                    }
                  }
                }
              }
            }
          }

          // Strictly enforce simultaneous block
          if (matchedInThisCampaign && !config.allowMultipleSimultaneousTasks) {
            break; // Stop evaluating subsequent tasks in this campaign for this specific event
          }
        }
      }

      if (progressMade) {
        ninjaSdkSafeUnawaited(_saveProgress(),
            context: 'challenge _saveProgress');
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'evaluateEvent');
    }
  }

  static Future<void> _saveProgress() async {
    try {
      if (_prefs != null) {
        await _prefs!.setString(_prefsKeyProgress, jsonEncode(_localProgress));
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaChallengeManager._saveProgress');
    }
  }

  /// Clears challenge progress from memory and storage. Called on user sign out.
  static Future<void> clearProgress() async {
    try {
      _localProgress = {};
      _pendingCompletionNudges.clear();
      if (_prefs != null) {
        await _prefs!.remove(_prefsKeyProgress);
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaChallengeManager.clearProgress');
    }
  }

  /// Explicitly sync local progress state from backend
  static void syncFromServer(Map<String, dynamic> serverProgressData) {
    try {
      bool updateNeeded = false;

      serverProgressData.forEach((key, value) {
        final localKey = key.replaceFirst('_challenge_', '');
        final incomingCount = int.tryParse(value.toString()) ?? 0;

        final currentLocalCount = _localProgress[localKey] ?? 0;

        if (incomingCount > currentLocalCount) {
          _localProgress[localKey] = incomingCount;
          updateNeeded = true;
          NinjaLog.d('NinjaChallengeManager',
              'Cross-device Sync Restored [$localKey] -> $incomingCount');
        }
      });

      if (updateNeeded) {
        ninjaSdkSafeUnawaited(_saveProgress(),
            context: 'syncFromServer _saveProgress');
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'syncFromServer');
    }
  }

  /// Bulk sync local offline progression memory map to backend API (Phase 2 Offline Recovery)
  static Future<void> pushLocalStateToServer({
    required String baseUrl,
    required String userId,
    required Map<String, String> headers,
  }) async {
    if (_localProgress.isEmpty) return;
    try {
      await NinjaCampaignRepository().bulkSyncChallengeProgress(
        baseUrl: baseUrl,
        userId: userId,
        progressMap: _localProgress,
        headers: headers,
      );
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'pushLocalStateToServer');
    }
  }

  /// Helper evaluating arbitrary JSON conditions against SDK tracked properties
  static bool evaluateFilters(
      List<dynamic>? filters, Map<String, dynamic> properties) {
    try {
      if (filters == null || filters.isEmpty) return true;
      for (var filter in filters) {
        if (filter is! Map) continue;
        final propName = filter['property'] ?? filter['field'] ?? filter['key'];
        if (propName == null) continue;

        final op = filter['operator']?.toString() ?? 'equals';
        final targetVal = filter['value'];

        final actualVal = properties[propName];

        // Handle presence operators first
        if (op == 'not_set') {
          if (actualVal != null) return false;
          continue;
        }
        if (op == 'set') {
          if (actualVal == null) return false;
          continue;
        }

        if (actualVal == null)
          return false; // Other checks require the prop to exist

        // String matching
        if (op == 'equals' &&
            actualVal.toString().toLowerCase() !=
                targetVal?.toString().toLowerCase()) return false;
        if (op == 'not_equals' &&
            actualVal.toString().toLowerCase() ==
                targetVal?.toString().toLowerCase()) return false;
        if (op == 'contains' &&
            targetVal != null &&
            !actualVal
                .toString()
                .toLowerCase()
                .contains(targetVal.toString().toLowerCase())) return false;
        if (op == 'not_contains' &&
            targetVal != null &&
            actualVal
                .toString()
                .toLowerCase()
                .contains(targetVal.toString().toLowerCase())) return false;

        // Numeric matching
        if ([
          'greater_than',
          'less_than',
          'greater_than_or_equal',
          'less_than_or_equal'
        ].contains(op)) {
          final aNum = num.tryParse(actualVal.toString());
          final tNum = num.tryParse(targetVal?.toString() ?? '');
          if (aNum == null || tNum == null)
            return false; // Fails condition if not parsable

          if (op == 'greater_than' && aNum <= tNum) return false;
          if (op == 'less_than' && aNum >= tNum) return false;
          if (op == 'greater_than_or_equal' && aNum < tNum) return false;
          if (op == 'less_than_or_equal' && aNum > tNum) return false;
        }
      }
      return true;
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'evaluateFilters');
      return false;
    }
  }
}

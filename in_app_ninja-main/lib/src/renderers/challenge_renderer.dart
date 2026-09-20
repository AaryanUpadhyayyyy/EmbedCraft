import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../models/challenge_model.dart';
import '../engine/ninja_challenge_manager.dart';
import '../app_ninja.dart'; // To access user properties
import '../utils/ninja_sdk_safe.dart';

/// Renders the Gamified Challenge UI interface natively
class NinjaChallengeRenderer extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback? onDismiss;
  final VoidCallback? onRemoveOverlay;
  final Function(String action, Map<String, dynamic>? data)? onCTAClick;
  final VoidCallback? onImpression; // FIX: Added onImpression

  const NinjaChallengeRenderer({
    Key? key,
    required this.campaign,
    this.onDismiss,
    this.onRemoveOverlay,
    this.onCTAClick,
    this.onImpression,
  }) : super(key: key);

  @override
  State<NinjaChallengeRenderer> createState() => _NinjaChallengeRendererState();
}

class _NinjaChallengeRendererState extends State<NinjaChallengeRenderer> with SingleTickerProviderStateMixin {
  late ChallengeConfig _config;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _config = widget.campaign.challengeDetails!;
    
    // Track impression
    if (widget.onImpression != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onImpression!();
      });
    }

    _slideController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
       CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    ninjaSdkSafeUnawaited(
      _slideController.reverse().then((_) {
        widget.onDismiss?.call();
        widget.onRemoveOverlay?.call();
      }),
      context: 'NinjaChallengeRenderer dismiss animation',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark Dimmed Overlay Background
          GestureDetector(
            onTap: _handleDismiss,
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          
          // Challenge Bottom Sheet Interface
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: -5)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                             Text(widget.campaign.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                             const SizedBox(height: 8),
                             if (widget.campaign.description != null && widget.campaign.description!.isNotEmpty)
                               Text(widget.campaign.description!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                             const SizedBox(height: 24),
                             
                             // List of Tasks
                             ..._config.tasks.map((task) => _buildTaskItem(task)).toList(),
                             
                             const SizedBox(height: 32),
                             ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1), // Primary indigo
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                               ),
                               onPressed: _handleDismiss,
                               child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                             )
                          ]
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      alignment: Alignment.center,
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
           color: Colors.grey.withOpacity(0.3),
           borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  /// Parses a single reward item map into a human-readable string.
  /// Works for both legacy flat items and items inside nested group.rewards[].
  String _parseRewardItem(Map<String, dynamic> rw) {
    final allowVar = rw['allowVariable'] == true;
    final rewardName = rw['name'] != null && rw['name'].toString().trim().isNotEmpty 
          ? " ${rw['name']}" 
          : "";

    if (allowVar && rw['variableConfig'] != null) {
       final varCfg = rw['variableConfig'] as Map<String, dynamic>;
       if (varCfg['type'] == 'random') {
          final min = varCfg['minAmount'] ?? 1;
          final max = varCfg['maxAmount'] ?? 10;
          return "$min-$max$rewardName";
       } else if (varCfg['type'] == 'conditional') {
          return "Variable$rewardName";
       } else if (varCfg['type'] == 'sdk_calculated') {
          return "Calculated$rewardName";
       }
    }
    final amount = rw['amount'] ?? 1;
    return "$amount$rewardName";
  }

  Widget _buildTaskItem(ChallengeTask task) {
    // 1. Evaluate Locked Constraint (User segment filtering FOMO)
    bool isLocked = false;
    if (task.logic.userFilters != null && task.logic.userFilters!.isNotEmpty) {
      if (!NinjaChallengeManager.evaluateFilters(task.logic.userFilters, AppNinja.currentUserProperties)) {
         isLocked = true;
      }
    }

    // Determine overall completion ratio for the task by aggregating all conditions
    int totalConditions = 0;
    double totalProgressRatio = 0.0;
    int displayCurrentCount = 0;
    int displayRequiredCount = 0;
    
    double totalGroupsRatio = 0.0;
    int totalGroups = task.logic.eventGroups.length;

    for (var group in task.logic.eventGroups) {
       double groupRatio = 0.0;
       int groupRequired = 0;
       int groupCurrent = 0;

       if (group.operator == 'OR') {
          // Find the condition with the HIGHEST completion ratio
          double bestRatio = 0.0;
          for (var condition in group.events) {
             int cCount = NinjaChallengeManager.getEventProgress(widget.campaign.id, task, condition.eventId);
             int rCount = condition.count > 0 ? condition.count : 1;
             
             double ratio = cCount / rCount;
             if (ratio > bestRatio) {
                bestRatio = ratio;
                groupRequired = rCount;
                groupCurrent = cCount > rCount ? rCount : cCount;
             }
          }
          // If no progress at all, default the display max to the lowest required count among options
          if (bestRatio == 0.0 && group.events.isNotEmpty) {
             groupRequired = group.events.map((e) => e.count > 0 ? e.count : 1).reduce((a, b) => a < b ? a : b);
          }
          groupRatio = bestRatio > 1.0 ? 1.0 : bestRatio;
       } else {
          // AND Operator
          double sumRatios = 0.0;
          for (var condition in group.events) {
             int cCount = NinjaChallengeManager.getEventProgress(widget.campaign.id, task, condition.eventId);
             int rCount = condition.count > 0 ? condition.count : 1;
             
             // Extract remainder against bounds if task repeats (finding the CURRENT modulo progress)
             int currentCycleProgress = cCount % rCount;

             // Only apply remainder if we haven't maxed out total permissible ceiling configuration securely
             bool isFinishedConfig = false;
             if (task.logic.limits['completionLimit'] != null && 
                 (cCount / rCount) >= (task.logic.limits['completionLimit'] as num).toInt()) {
                 isFinishedConfig = true;
             }

             int activeCount = isFinishedConfig ? rCount : currentCycleProgress;
             if (cCount > 0 && currentCycleProgress == 0 && !isFinishedConfig) {
                 // Conceptually, hitting exact boundary completes a cycle, so progress bar is temporarily full 
                 // before flipping to 0 upon next interaction. For visual feedback, maintain full status.
                 activeCount = rCount;
             }
             
             int capped = activeCount > rCount ? rCount : activeCount;
             groupRequired += rCount;
             groupCurrent += capped;
             sumRatios += (capped / rCount);
          }
          groupRatio = group.events.isNotEmpty ? (sumRatios / group.events.length) : 0.0;
       }

       totalGroupsRatio += groupRatio;
       displayRequiredCount += groupRequired;
       displayCurrentCount += groupCurrent;
    }
    
    // Calculate cumulative cycle completions 
    int totalCompletions = 99999;
    for (var group in task.logic.eventGroups) {
       int groupCompletions = group.operator == 'OR' ? 0 : 99999;
       for (var condition in group.events) {
          int cCount = NinjaChallengeManager.getEventProgress(widget.campaign.id, task, condition.eventId);
          int rCount = condition.count > 0 ? condition.count : 1;
          int cycles = (cCount / rCount).floor();
          
          if (group.operator == 'OR') {
             if (cycles > groupCompletions) groupCompletions = cycles; 
          } else {
             if (cycles < groupCompletions) groupCompletions = cycles;
          }
       }
       if (group.events.isEmpty) groupCompletions = 0;
       
       if (groupCompletions < totalCompletions) totalCompletions = groupCompletions;
    }
    if (totalCompletions == 99999) totalCompletions = 0;

    // Evaluate repetition constraint locks
    int? configuredLimit;
    if (task.logic.limits['attemptFrequency'] != 'once' && task.logic.limits['completionLimit'] is num) {
        configuredLimit = (task.logic.limits['completionLimit'] as num).toInt();
    } else if (task.logic.limits['attemptFrequency'] == 'once') {
        configuredLimit = 1;
    }
    
    // Overall completion check
    final progressRatio = totalGroups > 0 ? (totalGroupsRatio / totalGroups) : 0.0;
    bool isCompleted = configuredLimit != null && totalCompletions >= configuredLimit;
    if (configuredLimit == null && progressRatio >= 0.999) isCompleted = true; // Temporary ceiling for unbounded
    
    // Display String Modifier
    String completedText = "";
    if (configuredLimit != null && configuredLimit > 1) {
       completedText = " (Attempt $totalCompletions / $configuredLimit)";
    }

    // Safely extract reward text supporting NESTED reward groups with operators
    String rewardText = "";
    if (task.reward.rewardGroups.isNotEmpty) {
      try {
        List<String> groupStrings = [];
        
        for (var rGroup in task.reward.rewardGroups) {
           if (rGroup is Map<String, dynamic>) {
              // Check if this is the NEW nested format (has 'rewards' array)
              if (rGroup['rewards'] != null && rGroup['rewards'] is List) {
                 final rewards = rGroup['rewards'] as List;
                 final operator = rGroup['operator'] ?? 'AND';
                 List<String> itemStrings = [];
                 
                 for (var rw in rewards) {
                    if (rw is Map<String, dynamic>) {
                       itemStrings.add(_parseRewardItem(rw));
                    }
                 }
                 
                 if (itemStrings.isNotEmpty) {
                    final joiner = operator == 'OR' ? ' OR ' : ' + ';
                    groupStrings.add(itemStrings.length > 1 
                       ? "(${itemStrings.join(joiner)})" 
                       : itemStrings.first);
                 }
              } else {
                 // LEGACY flat format: { amount, rewardItemId, allowVariable, ... }
                 groupStrings.add(_parseRewardItem(rGroup));
              }
           }
        }
        
        if (groupStrings.isNotEmpty) {
           rewardText = "Rewards: " + groupStrings.join(" AND ");
        }
      } catch(e) {
        rewardText = "Rewards: Unlocked Items";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.withOpacity(0.05) : (isCompleted ? const Color(0xFF10B981).withOpacity(0.05) : Colors.white),
        border: Border.all(color: isLocked ? Colors.transparent : (isCompleted ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.2))),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 10)],
      ),
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Badge (Animated)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.withOpacity(0.2) : (isCompleted ? const Color(0xFF10B981) : const Color(0xFF6366F1).withOpacity(0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isLocked ? Icons.lock : (isCompleted ? Icons.check : Icons.flag),
                      key: ValueKey<bool>(isCompleted),
                      color: isLocked ? Colors.grey.shade600 : (isCompleted ? Colors.white : const Color(0xFF6366F1)),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Reward
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      if (rewardText.isNotEmpty)
                         Text(
                           isLocked ? "Complete specific requirements to unlock" : rewardText,
                           style: TextStyle(color: isLocked ? Colors.grey : const Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)
                         ),
                      if (completedText.isNotEmpty)
                         Text(
                           completedText.trim(),
                           style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontStyle: FontStyle.italic)
                         )
                    ],
                  ),
                ),
                // Status text
                Text(
                  isLocked ? "Locked" : "$displayCurrentCount / $displayRequiredCount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isLocked ? Colors.grey : (isCompleted ? const Color(0xFF10B981) : Colors.grey)
                  ),
                )
              ],
            ),
            if (!isLocked) const SizedBox(height: 12),
            if (!isLocked)
              // Progress Bar (Animated)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progressRatio),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xFF10B981) : const Color(0xFF6366F1)
                    ),
                    minHeight: 8,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

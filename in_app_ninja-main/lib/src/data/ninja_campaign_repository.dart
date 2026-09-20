import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import '../models/campaign.dart';
import '../app_ninja.dart';
import '../utils/ninja_sdk_safe.dart';
import '../engine/ninja_challenge_manager.dart';
import '../utils/ninja_logger.dart';

class NinjaCampaignRepository {
  static final NinjaCampaignRepository _instance = NinjaCampaignRepository._internal();
  factory NinjaCampaignRepository() => _instance;
  NinjaCampaignRepository._internal();

  // Reactive Stream of campaigns (updated on [fetchAndSync]).
  final _campaignsSubject = BehaviorSubject<List<Campaign>>.seeded([]);

  /// Maximum number of campaigns allowed to render per session (null = unlimited).
  /// Synced from Organization settings. The session counter in app_ninja.dart respects this.
  int? globalSessionLimit;

  /// Last fetched campaign list from this repository instance.
  /// Subscribe to [campaignsStream] for updates.
  Stream<List<Campaign>> get campaignsStream => _campaignsSubject.stream;

  /// Snapshot of [campaignsStream] (may be empty before first load).
  List<Campaign> get currentCampaigns => _campaignsSubject.value;

  void _emitCampaigns(List<Campaign> campaigns) {
    if (!_campaignsSubject.isClosed) {
      _campaignsSubject.add(campaigns);
    }
  }

  String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'flutter';
  }

  /// No-op loadFromCache since cache is disabled
  Future<void> loadFromCache() async {
    NinjaLog.d('NinjaRepo', '📦 [NinjaRepo] SQLite cache is disabled');
  }

  /// Fetches from API (no local cache write)
  Future<List<Campaign>> fetchAndSync({
    required String baseUrl,
    required String userId,
    String? anonymousId,
    String? screenName,
    required Map<String, String> headers,
  }) async {
    final screen = screenName ?? 'all';
    var url = '$baseUrl/api/v1/nudge/fetch?userId=${Uri.encodeComponent(userId)}&screenName=${Uri.encodeComponent(screen)}&platform=$currentPlatform';
    if (anonymousId != null) {
      url += '&anonymousId=${Uri.encodeComponent(anonymousId)}';
    }

    try {
      NinjaLog.d('NinjaRepo', '🔄 [NinjaRepo] Fetching from $url');
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (kDebugMode) {
          NinjaLog.d('AppNinja', 
            '📡 [NinjaRepo] API ok status=${response.statusCode} bytes=${response.body.length}',
          );
        }
        
        // Phase 2 Gamification: Cross-device progress restoration
        final Map<String, dynamic> serverProgress = body['challengeProgress'] ?? {};
        if (serverProgress.isNotEmpty) {
           NinjaChallengeManager.syncFromServer(serverProgress);
        }

        // Global session limit extraction
        if (body['global_session_limit'] != null) {
          globalSessionLimit = body['global_session_limit'] as int;
          NinjaLog.d('NinjaRepo', '⚙️ [NinjaRepo] Global session limit set to $globalSessionLimit');
        } else {
          globalSessionLimit = null;
        }

        List<Campaign> campaigns = [];

        if (body is Map) {
          var campaignData = body['campaigns'] ?? body['data'] ?? body['nudges'];
          
          if (campaignData is List) {
            campaigns = campaignData.map((c) => Campaign.fromJson(c)).toList();
          } else if (campaignData is Map) {
            // Single campaign object - wrap in list
            campaigns = [Campaign.fromJson(Map<String, dynamic>.from(campaignData))];
          }
        } else if (body is List) {
          campaigns = body.map((c) => Campaign.fromJson(c)).toList();
        }
        
        NinjaLog.d('NinjaRepo', '📊 [NinjaRepo] Parsed ${campaigns.length} campaigns from response');
        if (campaigns.isNotEmpty) {
          NinjaLog.d('NinjaRepo', '   🎯 First campaign: "${campaigns[0].title}" trigger="${campaigns[0].trigger}" status="${campaigns[0].status}"');
        }

        _emitCampaigns(campaigns);
        return campaigns;
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          NinjaLog.e('NinjaRepo', '🚫 Invalid API Key or Authentication Failed (Status: ${response.statusCode}). Disabling SDK.');
          AppNinja.setShouldDisableNinja(true);
          throw Exception('AUTH_ERROR');
        }
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaRepo.fetchAndSync');
      return _campaignsSubject.value;
    }
  }

  /// No-op clearCache
  Future<void> clearCache() async {
    _emitCampaigns([]);
    NinjaLog.d('NinjaRepo', '🗑️ [NinjaRepo] SQLite Cache Cleared (No-Op)');
  }

  /// Sync individual challenge task progression to backend
  Future<void> syncChallengeProgress({
    required String baseUrl,
    required String userId,
    required String campaignId,
    required String taskId,
    required String eventId,
    required int latestCount,
    required Map<String, String> headers,
  }) async {
    final url = '$baseUrl/api/v1/challenges/progress';
    try {
      final payload = {
        'userId': userId,
        'campaignId': campaignId,
        'taskId': taskId,
        'eventId': eventId,
        'count': latestCount,
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      var response = await http.post(
        Uri.parse(url),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      // Follow 307/308 redirects (Vercel proxy redirects POST requests)
      int redirectCount = 0;
      while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
        final location = response.headers['location'];
        if (location == null) break;
        NinjaLog.d('NinjaRepo', '↪️ [NinjaRepo] Following ${response.statusCode} redirect to: $location');
        final redirectUrl = Uri.parse(url).resolve(location);
        response = await http.post(
          redirectUrl,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 15));
        redirectCount++;
      }

      if (response.statusCode == 200) {
        NinjaLog.d('NinjaRepo', '🎯 [NinjaRepo] Synced challenge progress for $taskId ($latestCount)');
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          NinjaLog.e('NinjaRepo', '🚫 Invalid API Key or Authentication Failed (Status: ${response.statusCode}). Disabling SDK.');
          AppNinja.setShouldDisableNinja(true);
        }
        NinjaLog.d('NinjaRepo', '⚠️ [NinjaRepo] Failed to sync progress. Server returned: ${response.statusCode}');
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaRepo.syncChallengeProgress');
    }
  }

  /// Claim a physical reward when a Gamified Challenge task is 100% completed locally
  Future<void> claimChallengeReward({
    required String baseUrl,
    required String userId,
    required String campaignId,
    required String taskId,
    required Map<String, String> headers,
  }) async {
    final url = '$baseUrl/api/v1/challenges/reward/claim';
    try {
      final payload = {
        'userId': userId,
        'campaignId': campaignId,
        'taskId': taskId,
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      var response = await http.post(
        Uri.parse(url),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      // Follow 307/308 redirects (Vercel proxy redirects POST requests)
      int redirectCount = 0;
      while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
        final location = response.headers['location'];
        if (location == null) break;
        NinjaLog.d('NinjaRepo', '↪️ [NinjaRepo] Following ${response.statusCode} redirect to: $location');
        final redirectUrl = Uri.parse(url).resolve(location);
        response = await http.post(
          redirectUrl,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 15));
        redirectCount++;
      }

      if (response.statusCode == 200) {
        NinjaLog.d('NinjaRepo', '🎁 [NinjaRepo] Successfully claimed reward for task $taskId');
      } else {
        NinjaLog.d('NinjaRepo', '⚠️ [NinjaRepo] Failed to claim reward. Server returned: ${response.statusCode} ${response.body}');
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaRepo.claimChallengeReward');
    }
  }

  /// Bulk sync local offline progression memory map to backend API
  Future<void> bulkSyncChallengeProgress({
    required String baseUrl,
    required String userId,
    required Map<String, int> progressMap,
    required Map<String, String> headers,
  }) async {
    if (progressMap.isEmpty) return;

    final url = Uri.parse('$baseUrl/api/v1/challenges/progress/bulk');
    final payload = {
      'userId': userId,
      'progressMap': progressMap,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      // Follow 307/308 redirects (Vercel proxy redirects POST requests)
      int redirectCount = 0;
      while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
        final location = response.headers['location'];
        if (location == null) break;
        NinjaLog.d('NinjaRepo', '↪️ [NinjaRepo] Following ${response.statusCode} redirect to: $location');
        final redirectUrl = url.resolve(location);
        response = await http.post(
          redirectUrl,
          headers: {'Content-Type': 'application/json', ...headers},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 20));
        redirectCount++;
      }

      NinjaLog.d('NinjaRepo', 'NinjaCampaignRepository: Bulk Synced Challenge Progress (${response.statusCode})');
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaRepo.bulkSyncChallengeProgress');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/campaign.dart';
import 'models/ninja_region.dart';
import 'models/ninja_user.dart';
import 'renderers/campaign_renderer.dart';
import 'widgets/embed_widget_wrapper.dart'; // Import for type checking
import 'data/ninja_campaign_repository.dart';
import 'callbacks/ninja_callback_manager.dart';
import 'controllers/ninja_input_registry.dart';
import 'engine/ninja_challenge_manager.dart';
import 'utils/ninja_sdk_safe.dart';
import 'utils/capture_manager.dart';
import 'utils/ninja_logger.dart';

/// AppNinja - Main SDK class for InAppNinja
///
/// Initialize once in your app with [init], then use [track], [identify], [fetchCampaigns]
///
/// Example:
/// ```dart
/// await AppNinja.init('your_api_key', baseUrl: 'https://your-server.com');
/// AppNinja.identify({'user_id': '123', 'email': 'user@example.com'});
/// AppNinja.track('button_clicked', properties: {'button_name': 'signup'});
/// ```
class AppNinja {
  static const String _prefsKeyUserId = 'ninja_user_id';
  static const String _prefsKeyAnonymousId = 'ninja_anonymous_id';
  static const String _prefsKeyQueue = 'ninja_event_queue';
  static const String _prefsKeyColors = 'ninja_colors';
  static const String _prefsKeySpinsLeft = 'ninja_stw_spins_left';
  
  // 🚀 HYBRID CACHE SYSTEM - Config
  static const Duration _cacheRefreshInterval = Duration(minutes: 5);
  static const int _maxCachedCampaigns = 50; // Memory optimization

  static String? _apiKey;
  // Default to Production URL (AWS)
  static String _baseUrl = 'https://api.embedcraft.com';
  static String get baseUrl => _baseUrl;
  static String? getApiKey() => _apiKey;
  static bool _initialized = false;
  static bool _debugMode = false;
  static String? _currentPage;
  static BuildContext? _appContext;
  static String _locale = 'en';
  static Map<String, String> _colorTheme = {};
  static NinjaRegion? _ninjaRegion; // Region enum support
  static String?
      _region; // Region support (US, EU, IN, etc.) - kept for backward compatibility
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey? _screenshotKey; // Screenshot key
  static String? _externalId; // External user ID
  static String? _sessionId; // Session ID
  static Map<String, dynamic> _userProperties = {}; // User properties
  static NinjaUser? _currentUser; // Current user object
  
  /// Expose user properties for Gamified Engine evaluations
  static Map<String, dynamic> get currentUserProperties => _currentUser?.properties ?? _userProperties;

  static SharedPreferences? _prefs;

  // Auto-render settings
  static bool _autoRenderEnabled = true;

  // Spin The Wheel Game State (Synced with Backend)
  static BuildContext? _globalContext;
  static StreamSubscription? _autoRenderSubscription;
  static String? _lastShownPipId; // Track last shown PIP to prevent duplicates
  static Set<String> _shownCampaignsThisSession =
      {}; // Track all shown campaigns in session
  static int _sessionLimitedCampaignsShown = 0; // Track how many session-limited campaigns have been shown
  // 🚀 HYBRID CACHE STATE
  static List<Campaign> _cachedCampaigns = []; // In-memory cache
  static Timer? _backgroundRefreshTimer; // Periodic refresh timer
  static bool _isRefreshing = false; // Prevent concurrent refreshes
  static DateTime? _cacheTimestamp;
  static DateTime? _lastCampaignShownTime;

  // Spin The Wheel Game State
  // Parity: Mirrors React's window.__stwResult = { name, rewardId, sectionIndex }
  //         and window.__stwSpinsLeft / window.__stwMaxSpins
  static int _stwSpinsLeft = -1;
  static int get stwSpinsLeft => _stwSpinsLeft;
  static set stwSpinsLeft(int value) {
    _stwSpinsLeft = value;
    _prefs?.setInt(_prefsKeySpinsLeft, value);
  }
  static int stwMaxSpins = 0;
  static String stwRewardName = 'Prize';
  static Map<String, dynamic> stwRewardDetails = {}; // Track actual backend reward details
  static int stwSectionIndex = -1; // Index of last winning section (-1 = no spin yet)

  // Parity: React dispatches window.dispatchEvent(new CustomEvent('spinTheWheel')) when a button
  // with action.type='spin_wheel' is clicked. Flutter equivalent: static callback bridge.
  static Function()? stwSpinTrigger; // Set by NinjaSpinTheWheelLayer, called by NinjaButtonLayer
  static bool Function()? stwCloseOverlay; // Set by NinjaSpinTheWheelLayer, checked by close action handlers

  /// Triggers the active Spin The Wheel layer to spin (parity: window.dispatchEvent spinTheWheel)
  static void triggerSpin() {
    stwSpinTrigger?.call();
  }

  // Callbacks
  static Function(String eventName, Map<String, dynamic> properties)?
      _eventListener;
  static Function(Map<String, dynamic> properties)? _redirectListener;
  static Function(Map<String, dynamic> properties)? _notificationClickListener;
  static Function()? _initSuccessCallback;
  static Function(String error)? _initFailureCallback;
  static Function()? _refreshTokenCallback; // Token refresh callback
  static Function(String? key)? _authCallback; // Auth callback

  // Campaign stream
  static final StreamController<List<Campaign>> _campaignController =
      StreamController<List<Campaign>>.broadcast();

  // Pending stream campaigns buffer for race-condition prevention
  static final List<Campaign> _pendingStreamCampaigns = [];

  /// Stream that emits whenever campaigns are fetched or updated
  static Stream<List<Campaign>> get onCampaigns => _campaignController.stream;

  static void _safeAddCampaigns(List<Campaign> campaigns) {
    try {
      if (_autoRenderEnabled && _autoRenderSubscription == null) {
        debugLog('⏳ Auto-render listener not active yet. Buffering ${campaigns.length} campaign(s).');
        _pendingStreamCampaigns.addAll(campaigns);
        return;
      }
      _campaignController.add(campaigns);
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'campaign stream');
    }
  }

  /// Visibility tracking map for NinjaView widgets
  static Map<String, double> visibilityMap = {};

  // Configuration flags
  static bool _shouldDisableSdk = false;
  static bool _shouldDisableBackPressedListener = false;
  static bool _shouldCheckForParentWidget = true;
  static bool _shouldEnableFlutterWidgetTouch = false;

  // Element tracking
  // Navigation key for global context access
  static GlobalKey<NavigatorState>? _navigatorKey;

  // Element positions cache
  static final Map<String, dynamic> _elementPositions = {};

  // 🎯 ACTIVE NUDGES REGISTRY (For clearAllNudges)
  static final List<VoidCallback> _activeNudges = [];

  /// Registers a nudge's dismiss callback to be cleared later
  static void registerActiveNudge(VoidCallback dismissCallback) {
    _activeNudges.add(dismissCallback);
  }

  /// Unregisters a nudge's dismiss callback
  static void unregisterActiveNudge(VoidCallback dismissCallback) {
    _activeNudges.remove(dismissCallback);
  }

  /// Removes all currently active nudges for the current screen.
  /// Useful when navigating to a new screen to prevent lingering overlays.
  static void clearAllNudges() {
    // Copy to avoid concurrent modification exceptions during dismissal
    final List<VoidCallback> nudgesToClear = List.from(_activeNudges);
    _activeNudges.clear();

    // FIX: Also clear the campaign-level tracking maps so dismissed campaigns
    // are no longer considered "active on screen". Without this, the next
    // trigger of the same campaign is blocked by isAlreadyActiveOnScreen.
    final clearedIds = _activeCampaignDismissals.keys.toList();
    _activeCampaignDismissals.clear();
    _activeCampaignTypes.clear();
    _activeOverlayEntries.clear();
    _lastShownPipId = null;

    if (clearedIds.isNotEmpty) {
      debugLog('🧹 [clearAllNudges] Cleared campaign registries for: ${clearedIds.join(", ")}');
    }
    
    // Defer execution of dismissals to post-frame callback
    // to avoid Navigator.pop() assertion failures while a route transition is in progress
    // (e.g. when called from didPush/didPop in NavigatorObserver).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var dismiss in nudgesToClear) {
        try {
          dismiss();
        } catch (e, st) {
          ninjaSdkLogError(e, st, 'clearAllNudges');
        }
      }
    });
  }

  // 🎯 RACE CONDITION PREVENTION: Navigation Token System

  // Round-robin tracking for sequential campaign display
  static final Map<String, int> _roundRobinIndex = {};
  
  // Navigation token for race condition prevention
  static String _navigationToken = DateTime.now().millisecondsSinceEpoch.toString();
  static final Map<String, String> _campaignNavigationTokenMap = {};

  // Event tracking ID to prevent duplicate popups/modals in the same event occurrence lifecycle
  static String? _lastShownEventTrackingId;

  // Singleton pattern setup
  static final AppNinjaInstance _instance = AppNinjaInstance._internal();
  static final AppNinja _dummyInstance = AppNinja._internal();

  AppNinja._internal();

  /// Get singleton instance of AppNinja
  static AppNinjaInstance getInstance() {
    return _instance;
  }

  /// Initialize AppNinja SDK using constructor syntax (returns singleton instance of AppNinja).
  factory AppNinja({
    required String apiKey,
    bool debugMode = false,
    bool disableMode = false,
    bool autoRender = false,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    AppNinja.debug(debugMode);
    AppNinja.setShouldDisableNinja(disableMode);
    AppNinja.init(
      apiKey,
      autoRender: autoRender,
      navigatorKey: navigatorKey,
    );
    return _dummyInstance;
  }

  /// Initialize the SDK
  ///
  /// [apiKey] - Your InAppNinja API key
  /// [userId] - Optional initial user ID
  /// [baseUrl] - Optional custom server URL
  /// [autoRender] - Enable automatic campaign rendering (default: false)
  /// [navigatorKey] - Required for auto-rendering modals/sheets without context
  static Future<void> init(String apiKey,
      {String userId = '',
      String? baseUrl,
      bool autoRender = false,
      GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_initialized) {
      debugLog('AppNinja already initialized');
      return;
    }

    try {
      _apiKey = apiKey;
      _initialized = true; // Mark as initialized synchronously to allow early tracking
      if (navigatorKey != null) {
        AppNinja.navigatorKey = navigatorKey;
      }
      _navigatorKey = navigatorKey;
      
      // 🚀 Initialize Capture Manager (Dev Tools) IMMEDIATELY
      // This ensures we catch deep links that fire before the UI or network is ready.
      CaptureManager.init();
      
      // Override default URL only if a specific one is provided
      if (baseUrl != null && baseUrl.isNotEmpty) {
        _baseUrl = baseUrl;
      }

      _autoRenderEnabled = autoRender;

      _prefs = await SharedPreferences.getInstance();
      await NinjaChallengeManager.init();

      // Load persisted spin counter so it's available immediately on new sessions
      final persistedSpins = _prefs?.getInt(_prefsKeySpinsLeft);
      if (persistedSpins != null) {
        _stwSpinsLeft = persistedSpins;
        debugLog('Restored persisted spins_left: $persistedSpins');
      }

      if (userId.isNotEmpty) {
        await _prefs?.setString(_prefsKeyUserId, userId);
      }

      // Generate a stable anonymous ID on first init for event attribution
      if (_prefs?.getString(_prefsKeyAnonymousId) == null) {
        final anonId = '${DateTime.now().millisecondsSinceEpoch}_${userId.isNotEmpty ? userId : 'anon'}_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
        await _prefs?.setString(_prefsKeyAnonymousId, anonId);
        debugLog('Generated anonymous ID: $anonId');
      }

      _initialized = true;
      debugLog(
          'AppNinja initialized with baseUrl: $_baseUrl, autoRender: $autoRender, navigatorKey: ${_navigatorKey != null}');

      if (_shouldDisableSdk) {
        debugLog('AppNinja SDK is disabled (disableMode = true). Bypassing background operations, network queries, and rendering.');
        ninjaSdkSafeOptional(_initSuccessCallback, context: 'initSuccessCallback');
        NinjaCallbackManager.dispatchInitialised(
            sdkVersion: 'in_app_ninja_flutter_1.0.0');
        return;
      }

      // 🛑 Clear memory state on startup
      await NinjaCampaignRepository().clearCache();
      _cachedCampaigns = [];
      _cacheTimestamp = null;

      // 🆕 Start a new session when the app is opened
      await startSession();
      // 🚀 Ensure the session_start event reaches the backend BEFORE fetching campaigns
      // so the backend correctly resets session impression limits.
      await _flushEventQueue();

      // 🚀 PHASE 2: Initial fetch on startup (blocking wait to prevent race conditions)
      debugLog('⏳ Fetching campaigns on startup...');
      await _refreshCampaignsBackground();
      debugLog('✅ Initial fetch complete - ${_cachedCampaigns.length} campaigns ready');
      
      // 🚀 PHASE 3: Start periodic refresh timer
      _startSmartRefreshTimer();

      // Setup auto-rendering if enabled
      if (_autoRenderEnabled) {
        _setupAutoRendering();
      }
      
      ninjaSdkSafeOptional(_initSuccessCallback, context: 'initSuccessCallback');
      NinjaCallbackManager.dispatchInitialised(
          sdkVersion: 'in_app_ninja_flutter_1.0.0');
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'AppNinja.init');
      ninjaSdkSafeSync(
        () => _initFailureCallback?.call(e.toString()),
        context: 'initFailureCallback',
      );
    }
  }

  // TARGET REGISTRY (For Tooltips)
  static final Map<String, BuildContext> _targetRegistry = {};
  static final Map<String, LayerLink> _linkRegistry = {};

  /// Register a widget target for finding tooltips
  static void registerTarget(String id, BuildContext context, {LayerLink? link}) {
    _targetRegistry[id] = context;
    if (link != null) {
      _linkRegistry[id] = link;
    }
    debugLog('📍 Registered Target: $id (LayerLink: ${link != null})');
  }

  /// Unregister a widget target
  static void unregisterTarget(String id) {
    if (_targetRegistry.containsKey(id)) {
      _targetRegistry.remove(id);
      _linkRegistry.remove(id);
      debugLog('🗑️ Unregistered Target: $id');
    }
  }

  /// Get context for a target ID
  static BuildContext? getTargetContext(String id) {
    return _targetRegistry[id];
  }

  /// Get LayerLink for a target ID
  static LayerLink? getLink(String id) {
    return _linkRegistry[id];
  }

  /// Track an event
  ///
  /// [eventName] - Name of the event (e.g., 'button_clicked')
  /// [properties] - Optional event properties
  static Future<void> track(String eventName,
      {Map<String, dynamic> properties = const {}}) async {
    try {
      _ensureInitialized();
      if (_shouldDisableSdk) {
        return;
      }

      if (_debugMode) {
        NinjaLog.d('AppNinja', '📍 AppNinja.track("$eventName") called');
      }

      // ⚡ AUTO-DETECT PAGE VIEW (Smart Fix)
      // If user tracks "home_view" or "screen_viewed" but hasn't set a page yet,
      // automatically treat this as a page transition to fetch targeted campaigns.
      if ((eventName.contains('view') || eventName.contains('screen')) &&
          eventName != 'page_view' &&
          (_currentPage == null || _currentPage == 'all')) {
        final context = _globalContext ?? _appContext;
        if (context != null) {
          if (_debugMode) {
            NinjaLog.d('AppNinja', 
                '🧠 Auto-detecting page from event: "$eventName". Switching context to this page.');
          }
          trackPage(eventName, context, deferredEvent: eventName);
        }
      }
      final userId = _prefs?.getString(_prefsKeyUserId) ?? 'anonymous';

      // ⚡ PHASE 1.5: Gamified Challenges evaluation
      ninjaSdkSafeUnawaited(
        _getHeaders().then((headers) {
          ninjaSdkSafeSync(
            () {
              NinjaChallengeManager.evaluateEvent(
                    eventName,
                    properties,
                    _cachedCampaigns,
                    userId: userId,
                    userProperties: _currentUser?.properties ?? {},
                    baseUrl: baseUrl,
                    headers: headers,
                  );
              
              // 🔔 PHASE 1.6: Process task completion nudges
              _processCompletionNudges();
            },
            context: 'evaluateEvent',
          );
        }),
        context: 'getHeaders for evaluateEvent',
      );

      // Generate a unique tracking ID for this specific event trigger occurrence
      final eventTrackingId = '${eventName}_${DateTime.now().microsecondsSinceEpoch}';

      // 🚀 PHASE 2: Handle triggers (match and show campaigns)
      _handleEventTriggers(eventName, properties, eventTrackingId);

      // 🔥 PHASE 3: Fire-and-forget analytics (non-blocking)
      final anonymousId = _prefs?.getString(_prefsKeyAnonymousId);
      final event = {
        'event_id':
            '${userId}_${eventName}_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        if (anonymousId != null) 'anonymousId': anonymousId,
        'action': eventName,
        'metadata': properties,
        'platform': NinjaCampaignRepository().currentPlatform,
        'sdk_version': 'in_app_ninja_flutter_1.0.0',
        'page': _currentPage,
      };

      unawaited(_postAnalytics(eventName, event, eventTrackingId));

      ninjaSdkSafeSync(
        () => _eventListener?.call(eventName, properties),
        context: 'eventListener',
      );
      NinjaCallbackManager.dispatchTrackEvent(eventName, properties);
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'track');
    }
  }

  /// Process pending task completion nudges from the challenge engine
  /// Finds the matching interface in the parent campaign and renders it as an overlay
  static void _processCompletionNudges() {
    try {
      final pendingNudges = NinjaChallengeManager.consumePendingCompletionNudges();
      if (pendingNudges.isEmpty) return;

      final context = _globalContext ?? _appContext;
      if (context == null) {
        debugLog('⚠️ Cannot render completion nudges: no context available');
        return;
      }

      for (final nudge in pendingNudges) {
        final campaignId = nudge['campaignId']!;
        final interfaceId = nudge['interfaceId']!;
        final taskId = nudge['taskId']!;

        debugLog('🔔 Processing completion nudge: task=$taskId, interface=$interfaceId');

        // Find the parent campaign
        final parentCampaigns = _cachedCampaigns.where((c) => c.id == campaignId);
        final parentCampaign = parentCampaigns.isEmpty ? null : parentCampaigns.first;
        if (parentCampaign == null) {
          debugLog('⚠️ Parent campaign $campaignId not found for completion nudge');
          continue;
        }

        // Find the matching interface
        final interfaces = parentCampaign.interfaces;
        if (interfaces == null || interfaces.isEmpty) {
          debugLog('⚠️ Campaign $campaignId has no interfaces');
          continue;
        }

        final matchingInterfaces = interfaces.where((i) => i['id'] == interfaceId);
        final matchingInterface = matchingInterfaces.isEmpty ? null : matchingInterfaces.first;
        if (matchingInterface == null) {
          debugLog('⚠️ Interface $interfaceId not found in campaign $campaignId');
          continue;
        }

        // Construct a temporary Campaign from the interface data for rendering
        final nudgeType = matchingInterface['nudgeType']?.toString() ?? 'bottomsheet';
        final interfaceLayers = matchingInterface['layers'] as List<dynamic>? ?? [];
        final interfaceConfig = <String, dynamic>{
          'type': nudgeType,
        };
        // Safely merge type-specific configs from the interface
        for (final configKey in ['bottomSheetConfig', 'floaterConfig', 'fullscreenConfig', 'modalConfig', 'tooltipConfig']) {
          final configVal = matchingInterface[configKey];
          if (configVal != null && configVal is Map) {
            interfaceConfig.addAll(Map<String, dynamic>.from(configVal));
          }
        }

        final tempCampaign = Campaign(
          id: '${campaignId}_completion_${taskId}',
          title: matchingInterface['name']?.toString() ?? 'Task Completed',
          status: 'active',
          config: interfaceConfig,
          layers: interfaceLayers,
          type: nudgeType,
        );

        debugLog('🔔 Rendering completion nudge: ${tempCampaign.id} (type: $nudgeType)');

        // Small delay to let current UI settle before showing the nudge
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            final renderContext = _globalContext ?? _appContext;
            if (renderContext != null && renderContext.mounted) {
              NinjaCampaignRenderer.show(
                campaign: tempCampaign,
                context: renderContext,
              );
            }
          } catch (e, st) {
            ninjaSdkLogError(e, st, 'render completion nudge');
          }
        });
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, '_processCompletionNudges');
    }
  }

  static void _handleEventTriggers(String eventName, Map<String, dynamic> properties, [String? eventTrackingId]) {
    try {
      final trackingId = eventTrackingId ?? '${eventName}_${DateTime.now().microsecondsSinceEpoch}';

      if (_debugMode) {
        if (_cachedCampaigns.isNotEmpty) {
          NinjaLog.d('AppNinja', '   📦 Cached campaigns: ${_cachedCampaigns.length}');
          for (var c in _cachedCampaigns) {
            if (c.status == 'active') {
              NinjaLog.d('AppNinja', 
                  '   🎯 Campaign "${c.title}" trigger="${c.trigger ?? ''}" triggers=${c.triggers}');
            }
          }
        } else {
          NinjaLog.d('AppNinja', '   ⚠️ No cached campaigns to match against');
        }
      }

      final matchedCampaigns = _matchCampaignsLocally(eventName, properties);
      if (_debugMode) {
        NinjaLog.d('AppNinja', '   ✅ Matched campaigns: ${matchedCampaigns.length}');
      }

      if (matchedCampaigns.isNotEmpty) {
        final campaignToShow = _selectCampaignToRender(matchedCampaigns, eventName);
        if (campaignToShow != null) {
          final triggerToken = _navigationToken;
          _campaignNavigationTokenMap[campaignToShow.id] = triggerToken;
          _lastShownEventTrackingId = trackingId;

          _safeAddCampaigns([campaignToShow]);

          if (matchedCampaigns.length > 1) {
            final nextIndex = matchedCampaigns.indexOf(campaignToShow);
            debugLog('🔄 Round-robin: Showing campaign ${nextIndex + 1}/${matchedCampaigns.length} for "$eventName"');
            debugLog('   ✅ Current: ${campaignToShow.id}');
            debugLog('   📋 Rotation: ${matchedCampaigns.asMap().entries.map((e) => e.key == nextIndex ? "→${e.key + 1}" : "${e.key + 1}").join(" ")}');
          } else {
            debugLog('⚡ Instant match: 1 campaign for "$eventName" (0ms)');
          }
        }
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, '_handleEventTriggers');
    }
  }

  /// Match campaigns locally - INSTANT (0ms)
  static List<Campaign> _matchCampaignsLocally(
    String eventName,
    Map<String, dynamic> properties
  ) {
    try {
    if (_cachedCampaigns.isEmpty) {
      return [];
    }
    
    // Normalize event name for flexible matching
    final normalizedEventName = _normalizeEventName(eventName);
    
    return _cachedCampaigns.where((campaign) {
      // 🛑 FAIL-SAFE: Never show inactive campaigns (even if cached)
      if (campaign.status != 'active') return false;

      // ✅ FIX: Check BOTH single `trigger` string AND `triggers` array
      bool hasMatchingTrigger = false;
      
      // 1. Check single trigger string (primary - from backend)
      if (campaign.trigger != null && campaign.trigger!.isNotEmpty) {
        // ✅ NORMALIZE for flexible matching (case-insensitive, format-agnostic)
        final normalizedTrigger = _normalizeEventName(campaign.trigger!);
        hasMatchingTrigger = normalizedTrigger == normalizedEventName;
        
        // 🚀 SPECIAL CASE: 'screenviewed' matches any event ending in 'viewed' (e.g., Home_Viewed)
        if (!hasMatchingTrigger && normalizedTrigger == 'screenviewed' && normalizedEventName.endsWith('viewed')) {
          hasMatchingTrigger = true;
        }

        if (!hasMatchingTrigger && _debugMode) {
           NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" trigger mismatch: Event="$normalizedEventName" != Trigger="$normalizedTrigger"');
        }
      }
      
      // 2. Check triggers array (fallback)
      if (!hasMatchingTrigger && campaign.triggers != null && campaign.triggers!.isNotEmpty) {
        hasMatchingTrigger = campaign.triggers!.any((trigger) {
          final triggerEvent = trigger['event']?.toString() ?? '';
          return _normalizeEventName(triggerEvent) == normalizedEventName;
        });
      }
      
      if (!hasMatchingTrigger) return false;
      
      // ✅ BUG-3 FIX: Read page targeting from display_rules.pages (array of strings), NOT legacy campaign.targeting
      final displayRules = (campaign.config['displayRules'] ?? campaign.config['display_rules']) as Map<String, dynamic>?;
      if (displayRules != null && displayRules['pages'] != null && displayRules['pages'] is List) {
        final pages = List<String>.from(displayRules['pages']);
        if (pages.isNotEmpty) {
          // If pages array exists and is not empty, current page MUST be in the array
          final current = _currentPage?.toLowerCase().trim();
          final matches = pages.any((p) => p.toLowerCase().trim() == current);
          if (!matches) {
            if (_debugMode) NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" page mismatch: Event Page="$current" NOT IN ${pages}');
            return false;
          }
        }
      }

      // ✅ PLATFORM FILTER: Strictly enforce platform local matching
      if (displayRules != null && displayRules['platforms'] != null && displayRules['platforms'] is List) {
        final platforms = List<String>.from(displayRules['platforms']);
        if (platforms.isNotEmpty) {
          final currentPlatform = NinjaCampaignRepository().currentPlatform.toLowerCase();
          final targetPlatforms = platforms.map((p) => p.toLowerCase()).toList();
          final isFlutter = currentPlatform == 'flutter';
          final platformMatch = targetPlatforms.contains(currentPlatform) || 
              (isFlutter && (targetPlatforms.contains('android') || targetPlatforms.contains('ios')));
              
          if (!platformMatch) {
            if (_debugMode) NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" platform mismatch: Device="$currentPlatform" NOT IN $targetPlatforms');
            return false;
          }
        }
      }


      // ✅ Local Targeting Rules Evaluation (User Properties & Event Property Filters)
      if (campaign.targeting != null && campaign.targeting!.isNotEmpty) {
        for (final rule in campaign.targeting!) {
          if (rule is! Map) continue;
          final type = rule['type']?.toString();
          
          if (type == 'user_property') {
            final field = rule['property']?.toString() ?? rule['field']?.toString();
            if (field == null || field.isEmpty) continue;
            
            final userProperties = _currentUser?.properties ?? _userProperties;
            final userVal = _getPropertyValue(userProperties, field);
            final targetVal = rule['value'];
            final op = rule['operator']?.toString() ?? 'equals';
            
            if (!_evaluateOperator(userVal, op, targetVal)) {
              if (_debugMode) {
                NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" user_property targeting failed: $field ($userVal) $op $targetVal');
              }
              return false;
            }
          } else if (type == 'event') {
            // ✅ FIX: The backend sends event property filters in a flattened format:
            // { type: 'event', field: 'ScreenSlug', operator: '==', value: 'catnav' }
            // OR in a nested format:
            // { type: 'event', event: 'screen_views', properties: [...] }
            
            final propFilters = rule['properties'];
            if (propFilters is List && propFilters.isNotEmpty) {
              // Legacy/Nested format
              final ruleEvent = rule['event']?.toString() ?? rule['property']?.toString() ?? rule['field']?.toString();
              if (ruleEvent != null && ruleEvent.isNotEmpty) {
                if (_normalizeEventName(ruleEvent) != normalizedEventName) {
                  if (_debugMode) NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" event mismatch: $ruleEvent != $normalizedEventName');
                  return false;
                }
                for (final propFilter in propFilters) {
                  if (propFilter is! Map) continue;
                  final field = propFilter['field']?.toString() ?? propFilter['property']?.toString();
                  if (field == null || field.isEmpty) continue;
                  
                  final incomingVal = _getPropertyValue(properties, field);
                  final targetVal = propFilter['value'];
                  final op = propFilter['operator']?.toString() ?? 'equals';
                  
                  if (!_evaluateOperator(incomingVal, op, targetVal)) {
                    if (_debugMode) {
                      NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" nested event property filter failed: $field ($incomingVal) $op $targetVal');
                    }
                    return false;
                  }
                }
              }
            } else {
              // Flattened format from new dashboard
              final ruleEvent = rule['event']?.toString();
              if (ruleEvent != null && ruleEvent.isNotEmpty) {
                if (_normalizeEventName(ruleEvent) != normalizedEventName) {
                  if (_debugMode) NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" event mismatch: $ruleEvent != $normalizedEventName');
                  return false;
                }
              }

              final field = rule['field']?.toString() ?? rule['property']?.toString();
              if (field != null && field.isNotEmpty) {
                final incomingVal = _getPropertyValue(properties, field);
                final targetVal = rule['value'];
                final op = rule['operator']?.toString() ?? 'equals';
                
                if (!_evaluateOperator(incomingVal, op, targetVal)) {
                  if (_debugMode) {
                    NinjaLog.d('AppNinja', '   ❌ Campaign "${campaign.id}" flat event property filter failed: $field ($incomingVal) $op $targetVal');
                  }
                  return false;
                }
              }
            }
          }
        }
      }
      
      // Global campaign (no page targeting)
      return true;
    }).toList();
    } catch (e, st) {
      ninjaSdkLogError(e, st, '_matchCampaignsLocally');
      return [];
    }
  }

  static dynamic _getPropertyValue(Map<String, dynamic> properties, String key) {
    if (properties.containsKey(key)) {
      return properties[key];
    }
    
    // Fallback: Case-insensitive / normalize underscores lookup
    final normalizedKey = _normalizeKey(key);
    for (final entry in properties.entries) {
      if (_normalizeKey(entry.key) == normalizedKey) {
        return entry.value;
      }
    }
    return null;
  }
  
  static String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll('_', '').replaceAll('-', '').trim();
  }

  static bool _evaluateOperator(dynamic val, String op, dynamic target) {
    try {
      if (op == 'set') {
        return val != null;
      }
      if (op == 'not_set') {
        return val == null;
      }
      
      if (val == null) return false;
      
      final valStr = val.toString();
      final targetStr = target?.toString() ?? '';
      
      switch (op) {
        case 'equals':
          return valStr.toLowerCase() == targetStr.toLowerCase();
        case 'not_equals':
          return valStr.toLowerCase() != targetStr.toLowerCase();
        case 'contains':
          return valStr.toLowerCase().contains(targetStr.toLowerCase());
        case 'not_contains':
          return !valStr.toLowerCase().contains(targetStr.toLowerCase());
        case 'greater_than':
          final vNum = double.tryParse(valStr);
          final tNum = double.tryParse(targetStr);
          return vNum != null && tNum != null && vNum > tNum;
        case 'less_than':
          final vNum = double.tryParse(valStr);
          final tNum = double.tryParse(targetStr);
          return vNum != null && tNum != null && vNum < tNum;
        case 'greater_than_or_equal':
          final vNum = double.tryParse(valStr);
          final tNum = double.tryParse(targetStr);
          return vNum != null && tNum != null && vNum >= tNum;
        case 'less_than_or_equal':
          final vNum = double.tryParse(valStr);
          final tNum = double.tryParse(targetStr);
          return vNum != null && tNum != null && vNum <= tNum;
        default:
          return valStr.toLowerCase() == targetStr.toLowerCase();
      }
    } catch (e) {
      return false;
    }
  }

  /// Normalize event names for flexible matching
  /// Converts: "Checkout Step Viewed" -> "checkoutstepviewed"
  ///           "checkout_step_viewed" -> "checkoutstepviewed"
  ///           "CheckoutStepViewed" -> "checkoutstepviewed"
  static String _normalizeEventName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '') // Remove spaces, underscores, hyphens
        .trim();
  }

  /// Selects exactly one campaign to render from a matched list, respecting priority and round-robin rotation.
  static Campaign? _selectCampaignToRender(List<Campaign> campaigns, String eventName) {
    if (campaigns.isEmpty) return null;

    // Sort by priority descending (highest priority first). Treat null as 0.
    final List<Campaign> sorted = List<Campaign>.from(campaigns);
    
    // Shuffle first so stable sort keeps random order for equal priorities
    sorted.shuffle();
    
    sorted.sort((a, b) {
      final pA = a.priority ?? 0;
      final pB = b.priority ?? 0;
      return pB.compareTo(pA);
    });

    final eventKey = '$eventName:${_currentPage ?? "global"}';
    final lastIndex = _roundRobinIndex[eventKey] ?? -1;
    final nextIndex = (lastIndex + 1) % sorted.length;

    _roundRobinIndex[eventKey] = nextIndex;

    return sorted[nextIndex];
  }


  /// Send analytics to backend and process real-time targeting rules
  static Future<void> _postAnalytics(String eventName, Map<String, dynamic> event, String eventTrackingId) async {
    try {
      final response = await _post('/api/v1/nudge/track', event);
      if (response.statusCode == 200) {
        // Check if we already showed a campaign for this specific event occurrence
        if (_lastShownEventTrackingId == eventTrackingId) {
          debugLog('ℹ️ Real-time targeting ignored: campaign already shown locally for event tracking ID $eventTrackingId');
          return;
        }

        final body = jsonDecode(response.body);
        if (body['matched'] != null && body['matched'] is List) {
          final matchedList = body['matched'] as List;
          if (matchedList.isNotEmpty) {
            debugLog('🎯 Real-time targeting match: backend returned ${matchedList.length} campaigns for "$eventName"');
            final newCampaigns = matchedList.map((c) => Campaign.fromJson(Map<String, dynamic>.from(c))).toList();
            for (var c in newCampaigns) {
              debugLog('   👉 Parsed campaign: "${c.title}" id="${c.id}" status="${c.status}" priority=${c.priority}');
            }
            
            // Filter out inactive campaigns
            var activeNewCampaigns = newCampaigns.where((c) => c.status == 'active').toList();
            
            // ✅ FIX: Ensure page targeting is respected for real-time matches
            activeNewCampaigns = activeNewCampaigns.where((c) {
              final displayRules = (c.config['displayRules'] ?? c.config['display_rules']) as Map<String, dynamic>?;
              if (displayRules != null && displayRules['pages'] != null && displayRules['pages'] is List) {
                final pages = List<String>.from(displayRules['pages']);
                if (pages.isNotEmpty && !pages.any((p) => p.toLowerCase() == 'all')) {
                  final current = _currentPage?.toLowerCase().trim();
                  final matches = pages.any((p) => p.toLowerCase().trim() == current);
                  if (!matches) {
                    debugLog('   ❌ Real-time match dropped: Campaign "${c.id}" page mismatch: Event Page="$current" NOT IN $pages');
                    return false;
                  }
                }
              }
              return true;
            }).toList();
            
            debugLog('   👉 Active & targeted campaigns: ${activeNewCampaigns.length}');
            
            if (activeNewCampaigns.isNotEmpty) {
              // Update local cache with all active campaigns returned by backend
              for (final c in activeNewCampaigns) {
                if (!_cachedCampaigns.any((existing) => existing.id == c.id)) {
                  _cachedCampaigns.add(c);
                }
              }

              // Select exactly one campaign from the backend response using priority and round-robin
              final campaignToShow = _selectCampaignToRender(activeNewCampaigns, eventName);
              if (campaignToShow != null) {
                _campaignNavigationTokenMap[campaignToShow.id] = _navigationToken;
                _lastShownEventTrackingId = eventTrackingId;
                _safeAddCampaigns([campaignToShow]);
              }
            }
          }
        }
      }
    } catch (e) {
      debugLog('⚠️ Analytics send failed, queuing: $e');
      await _queueEvent({'type': 'track', 'payload': event});
    }
  }

  /// Identify a user with attributes
  ///
  /// [attributes] - User attributes (must include 'user_id' or will use existing)
  static Future<void> identify(Map<String, dynamic> attributes) async {
    try {
      _ensureInitialized();
      if (_shouldDisableSdk) {
        return;
      }

      final userId = attributes['user_id']?.toString() ??
          attributes['userId']?.toString() ??
          _prefs?.getString(_prefsKeyUserId);

      if (userId != null) {
        await _prefs?.setString(_prefsKeyUserId, userId);
      }

      _currentUser = NinjaUser(
        userId: userId,
        externalId: attributes['external_id']?.toString() ??
            attributes['externalId']?.toString(),
        name: attributes['name']?.toString(),
        email: attributes['email']?.toString(),
        phoneNumber: attributes['phone_number']?.toString() ??
            attributes['phoneNumber']?.toString(),
        referralCode: attributes['referral_code']?.toString() ??
            attributes['referralCode']?.toString(),
        properties: Map<String, dynamic>.from(attributes),
        sessionId: _sessionId,
        locale: _locale,
      );

      final anonymousId = _prefs?.getString(_prefsKeyAnonymousId);
      final payload = {
        'userId': userId ?? 'anonymous', // CamelCase
        if (anonymousId != null) 'anonymousId': anonymousId,
        'traits': attributes,
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        await _post('/api/v1/nudge/identify', payload); // Updated Endpoint
        NinjaCallbackManager.dispatchUserIdentifierSuccess(payload);
      } catch (e) {
        debugLog('Identify failed, queuing: $e');
        await _queueEvent({'type': 'identify', 'payload': payload});
        NinjaCallbackManager.dispatchUserIdentifierFailure(e.toString());
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'identify');
    }
  }

  /// Fetch campaigns from server
  ///
  /// Returns list of campaigns targeted to the current user
  /// Fetch campaigns from server with retry logic
  ///
  /// Returns list of campaigns targeted to the current user
  static Future<List<Campaign>> fetchCampaigns(
      {String? userId, bool forceRefresh = false}) async {
    _ensureInitialized();
    if (_shouldDisableSdk) {
      return [];
    }
    final uid = userId ?? _prefs?.getString(_prefsKeyUserId) ?? 'anonymous';
    final screen = _currentPage ?? 'all';

    final anonymousId = _prefs?.getString(_prefsKeyAnonymousId);
    return await NinjaCampaignRepository().fetchAndSync(
      baseUrl: _baseUrl,
      userId: uid,
      anonymousId: anonymousId,
      screenName: screen,
      headers: await _getHeaders(),
    );
  }

  static Future<void> clearCampaignCache() async {
    try {
      _ensureInitialized();
      await NinjaCampaignRepository().clearCache();
      _cachedCampaigns = [];
      _cacheTimestamp = null;
      debugLog('🗑️ Campaign cache cleared (Memory only)');
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'clearCampaignCache');
    }
  }

  /// Track page view
  ///
  /// [pageName] - Name of the page/screen
  /// [context] - BuildContext for tracking (will be stored for widget detection)
  /// [deferredEvent] - Optional event to re-check after fetching campaigns (internal use)
  static void trackPage(String pageName, BuildContext context, {String? deferredEvent}) {
    try {
      _ensureInitialized();
      if (_shouldDisableSdk) {
        return;
      }

      _navigationToken = DateTime.now().millisecondsSinceEpoch.toString();

      clearNudges();

      _currentPage = pageName;
      _appContext = context;
      debugLog('📍 trackPage: $pageName (token: $_navigationToken) - Cleared previous nudges');

      // Send the page_view event to the backend so we can auto-populate the dashboard targeting dropdown
      ninjaSdkSafeUnawaited(track('page_view', properties: {'page': pageName}), context: 'trackPage send page_view');

      ninjaSdkSafeUnawaited(
        fetchCampaigns().then((newCampaigns) {
          ninjaSdkSafeSync(
            () {
              debugLog('🔄 trackPage: Fetched ${newCampaigns.length} campaigns for page "$pageName"');

              if (newCampaigns.isNotEmpty) {
                debugLog('🔍 trackPage: Re-checking triggers for "$pageName" after fetch...');
                _handleEventTriggers('page_view', {'page': pageName});

                if (deferredEvent != null && deferredEvent != 'page_view') {
                  debugLog('🔍 trackPage: Re-checking deferred event "$deferredEvent" after fetch');
                  _handleEventTriggers(deferredEvent, {
                    'page': pageName,
                    'auto_detected': true,
                  });
                }
              }
            },
            context: 'trackPage after fetch',
          );
        }),
        context: 'trackPage fetchCampaigns',
      );
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'trackPage');
    }
  }

  /// Set user locale
  static void setLocale(String locale) {
    _ensureInitialized();
    _locale = locale;
    debugLog('Locale set to: $locale');
  }

  /// Set color theme for nudges
  ///
  /// [colors] - Map of color keys to hex values (e.g., {'background': '#ffffff'})
  static Future<void> setColor(Map<String, String> colors) async {
    _ensureInitialized();
    _colorTheme = colors;
    await _prefs?.setString(_prefsKeyColors, jsonEncode(colors));
    debugLog('Color theme updated');
  }

  /// Enable or disable debug mode.
  ///
  /// When [enable] is `true`, all SDK logs will be printed to the console
  /// in the unified format: `AppNinja: [<tag>] <message>`.
  /// Useful for diagnosing issues during development.
  static void debug(bool enable) {
    _debugMode = enable;
    // Wire NinjaLog gate to AppNinja.debugMode
    NinjaLog.configure(() => _debugMode);
    NinjaLog.d('AppNinja', 'Debug mode: $enable');
  }

  /// Whether debug logging is currently enabled.
  static bool get debugMode => _debugMode;

  /// Show mock study (for testing nudges)
  static void showMockStudy() {
    debugLog(
        'showMockStudy called (pure Flutter implementation - use fetchCampaigns)');
    // In pure Flutter, this triggers a campaign fetch
    fetchCampaigns();
  }

  /// Check if a feature is enabled
  static Future<bool> isFeatureEnabled(String featureKey) async {
    _ensureInitialized();
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/v1/features/$featureKey'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['enabled'] == true;
      }
    } catch (e) {
      debugLog('isFeatureEnabled error: $e');
    }
    return false;
  }

  /// Get feature flag value
  static Future<String?> getFeatureFlag(String featureKey) async {
    _ensureInitialized();
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/v1/features/$featureKey/value'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['value']?.toString();
      }
    } catch (e) {
      debugLog('getFeatureFlag error: $e');
    }
    return null;
  }

  /// Get feature flag payload
  static Future<String?> getFeatureFlagPayload(String featureKey) async {
    _ensureInitialized();
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/v1/features/$featureKey/payload'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugLog('getFeatureFlagPayload error: $e');
    }
    return null;
  }

  /// Logout current user and purge all local caches deeply
  static Future<void> logout() async {
    _ensureInitialized();
    
    // Identity Purge
    await _prefs?.remove(_prefsKeyUserId);
    await _prefs?.remove(_prefsKeyAnonymousId);
    _currentUser = null;
    _userProperties = {};
    _externalId = null;

    // Regenerate anonymous ID immediately so post-logout anonymous events can be tracked
    final anonId = '${DateTime.now().millisecondsSinceEpoch}_anon_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    await _prefs?.setString(_prefsKeyAnonymousId, anonId);
    NinjaLog.d('AppNinja', 'Regenerated anonymous ID post-logout: $anonId');

    // Campaign Cache Purge
    _cachedCampaigns = [];
    _cacheTimestamp = null;
    _pendingStreamCampaigns.clear();

    // UI Overlays Dismissal
    clearAllNudges();

    // Session Limits & Campaign Display State Wiped
    _shownCampaignsThisSession.clear();
    _sessionLimitedCampaignsShown = 0;
    _roundRobinIndex.clear();

    // Local Game / Deduplication Cache Wiped
    _locallyUnlockedTickets.clear();

    // Spin The Wheel State Wiped (EXCEPT stwSpinsLeft which persists via SharedPreferences)
    // stwSpinsLeft is NOT reset here — the server is the authoritative source.
    // The persisted value ensures the counter shows correctly on next session open.
    stwMaxSpins = 0;
    stwRewardName = 'Prize';
    stwRewardDetails = {};
    stwSectionIndex = -1;
    stwSpinTrigger = null;
    stwCloseOverlay = null;

    // Form inputs collected wiped
    NinjaInputRegistry.clear();

    // Challenge progressions wiped
    await NinjaChallengeManager.clearProgress();

    // Repository cache wiped
    await NinjaCampaignRepository().clearCache();

    debugLog('User logged out & local cache cleared deeply');
  }

  /// Set event listener
  static void setEventsListener(
      Function(String eventName, Map<String, dynamic> properties) callback) {
    _eventListener = callback;
  }

  /// Set redirect listener
  static void setRedirectListener(
      Function(Map<String, dynamic> properties) callback) {
    _redirectListener = callback;
  }

  /// Set notification click listener
  static void setNotificationClickListener(
      Function(Map<String, dynamic> properties) callback) {
    _notificationClickListener = callback;
  }

  /// Register init callbacks
  static void registerInitCallback(
      Function() onSuccess, Function(String error) onFailure) {
    _initSuccessCallback = onSuccess;
    _initFailureCallback = onFailure;
  }

  /// Show a specific story
  static void showStory(String storyId, String slideId) {
    debugLog('showStory: $storyId, slide: $slideId');
    ninjaSdkSafeUnawaited(
      fetchCampaigns().then((campaigns) {
        ninjaSdkSafeSync(
          () {
            final stories = campaigns
                .where((c) => c.id == storyId && c.type == 'story');
            final story = stories.isEmpty ? null : stories.first;
            if (story != null) {
              _safeAddCampaigns([story]);
            }
          },
          context: 'showStory',
        );
      }),
      context: 'showStory fetchCampaigns',
    );
  }

  /// Retry queued events
  static Future<void> retryQueuedEvents() async {
    _ensureInitialized();
    await _flushEventQueue();
  }

  // ========== NUDGECORE_V2 INSPIRED FEATURES ==========

  /// Configure SDK with navigator key and optional screenshot key
  ///
  /// Similar to nudgecore_v2's config() method
  static Future<void> config({
    required GlobalKey<NavigatorState> navigatorKey,
    GlobalKey? screenshotKey,
  }) async {
    AppNinja.navigatorKey = navigatorKey;
    _navigatorKey = navigatorKey;
    _screenshotKey = screenshotKey;
    debugLog('SDK configured with navigator key and screenshot key');
  }

  /// Identify user with enhanced attributes (nudgecore_v2 style)
  ///
  /// Similar to nudgecore_v2's userIdentifier() method
  static Future<void> userIdentifier({
    required String? externalId,
    String? name,
    String? email,
    String? phoneNumber,
    String? referralCode,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? userProperties,
  }) async {
    _externalId = externalId;
    
    final Map<String, dynamic> attributes = {
      if (externalId != null) 'user_id': externalId,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (referralCode != null) 'referral_code': referralCode,
      ...?properties,
      ...?userProperties,
    };

    _userProperties = attributes;

    await identify(attributes);
  }

  /// Get current user details
  ///
  /// Similar to nudgecore_v2's getUserDetails() method
  static Future<Map<String, dynamic>?> getUserDetails() async {
    _ensureInitialized();

    return {
      'user_id': _prefs?.getString(_prefsKeyUserId),
      'external_id': _externalId,
      'session_id': _sessionId,
      'properties': _userProperties,
      'locale': _locale,
    };
  }

  /// Sign out the current user
  ///
  /// Similar to nudgecore_v2's userSignOut() method
  static Future<void> userSignOut() async {
    await logout();
  }

  /// Set region for SDK (using enum)
  ///
  /// Regions: NinjaRegion.US, NinjaRegion.EU, NinjaRegion.IN, etc.
  static void setNinjaRegion(NinjaRegion region) {
    _ninjaRegion = region;
    _region = region.value;
    debugLog('Region set to: ${region.name} (${region.value})');
  }

  /// Set region for SDK (using string - backward compatibility)
  ///
  /// Regions: 'US', 'EU', 'IN', 'AU', etc.
  static void setRegion(String region) {
    _region = region;
    _ninjaRegion = parseNinjaRegion(region);
    debugLog('Region set to: $region');
  }

  /// Register refresh token callback
  ///
  /// Similar to nudgecore_v2's registerRefreshToken() method
  static Future<void> registerRefreshToken(Function() callback) async {
    _refreshTokenCallback = callback;
    debugLog('Refresh token callback registered');
  }

  /// Register auth callback for handling static keys
  ///
  /// Similar to nudgecore_v2's registerAuth() method
  static Future<void> registerAuth(Function(String? key) callback) async {
    _authCallback = callback;
    debugLog('Auth callback registered');
  }

  /// Clear all nudges for current screen
  ///
  /// Similar to nudgecore_v2's clearNudges() method
  /// FIX: Also dismiss all active overlay campaigns (floaters, bottomsheets, etc.)
  static Future<void> clearNudges() async {
    // Campaigns that should PERSIST across page navigations.
    // Floater/PIP widgets are designed to float above all pages — don't dismiss them.
    const persistentTypes = {'floater', 'pip'};

    // Dismiss all active modal campaign overlays (bottomsheets, fullscreens, etc.)
    if (_activeCampaignDismissals.isNotEmpty) {
      final toDismiss = _activeCampaignDismissals.entries
          .where((e) => !persistentTypes.contains(_activeCampaignTypes[e.key]))
          .toList();

      if (toDismiss.isNotEmpty) {
        debugLog('🧹 Dismissing ${toDismiss.length} modal campaign(s) on page change (${toDismiss.map((e) => e.key).join(", ")})');
        for (final e in toDismiss) {
          _activeCampaignDismissals.remove(e.key);
          _activeCampaignTypes.remove(e.key);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final entry in toDismiss) {
            try {
              entry.value.call();
              debugLog('   ❌ Dismissed campaign: ${entry.key}');
            } catch (e) {
              debugLog('   ⚠️ Failed to dismiss campaign ${entry.key}: $e');
            }
          }
        });
      }

      final persistedCount = _activeCampaignDismissals.length;
      if (persistedCount > 0) {
        debugLog('📌 Kept $persistedCount persistent campaign(s) alive across page change');
      }
    }

    // Re-insert persistent overlays to bring them to the top of the overlay stack
    if (_activeOverlayEntries.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final overlay = _navigatorKey?.currentState?.overlay;
        if (overlay != null && overlay.mounted) {
          for (final entry in List<OverlayEntry>.from(_activeOverlayEntries.values)) {
            if (entry.mounted) {
              entry.remove();
              overlay.insert(entry);
            }
          }
        }
      });
    }

    _safeAddCampaigns([]);
    debugLog('All nudges cleared');
  }

  /// Initiate Gamification Session (Zero-Trust Model)
  static Future<Map<String, dynamic>> initiateGame(String campaignId) async {
    _ensureInitialized();
    final userId = _currentUser?.userId ?? _prefs?.getString(_prefsKeyUserId);
    
    // Fallback error safely
    if (userId == null) {
       debugLog('❌ Cannot play game without a designated userId');
       return {'success': false, 'error': 'No user authenticated'};
    }
    
    try {
      final payload = {
         'userId': userId,
         'campaignId': campaignId,
         'userProperties': currentUserProperties,
      };
      
      // Use _postRaw() which handles 307/308 redirects but doesn't throw on non-200
      // (game endpoints return valid JSON for 400/403/404 rejections)
      final response = await _postRaw('/api/v1/game/initiate', payload);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      debugLog('🎲 Game Init Response [\${response.statusCode}]: $body');
      
      // Auto-refresh campaigns in background so UI gets the updated mappedState (e.g. for unscratched rewards)
      if (body['success'] == true) {
        ninjaSdkSafeUnawaited(
          _refreshCampaignsBackground(),
          context: 'Refresh campaigns after game init',
        );
      }

      return body;
    } catch(e) {
      debugLog('Game Init Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Resolve Scratch Foil State using Ledger ID
  static Future<Map<String, dynamic>> completeScratchWalletTicket(String ledgerId) async {
    _ensureInitialized();
    _locallyUnlockedTickets.add(ledgerId);
    final userId = _currentUser?.userId ?? _prefs?.getString(_prefsKeyUserId);

    if (ledgerId.isEmpty) {
        return {'success': false, 'error': 'Missing Ledger ID'};
    }

    try {
      final payload = {
         'userId': userId,
         'ledgerId': ledgerId
      };
      
      // Use _postRaw() which handles 307/308 redirects but doesn't throw on non-200
      final response = await _postRaw('/api/v1/game/ledger/scratch', payload);
      
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      debugLog('🛡️ Scratch Wallet Response [\${response.statusCode}]: $body');
      
      // Auto-refresh campaigns in background so UI (like Reward Repo) gets the updated mappedState
      ninjaSdkSafeUnawaited(
        _refreshCampaignsBackground(),
        context: 'Refresh campaigns after scratch complete',
      );

      return body;
    } catch(e) {
      debugLog('Scratch Complete Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch Data Source (Dynamic Render Context)
  static Future<List<dynamic>> fetchDataSource(String endpointStr) async {
    _ensureInitialized();
    try {
      // Append base url if it starts with /
      var url = endpointStr.startsWith('/') 
          ? '$_baseUrl$endpointStr' 
          : endpointStr;
          
      // Check if it's the system user wallet API that needs POST + body formatting vs standard GET
      if (endpointStr.contains('/api/v1/game/wallet')) {
          final userId = _currentUser?.userId ?? _prefs?.getString(_prefsKeyUserId) ?? '';
          final response = await http.post(
            Uri.parse(url),
             headers: await _getHeaders(),
             body: jsonEncode({'userId': userId}),
          ).timeout(const Duration(seconds: 15));
          if (response.statusCode == 200) {
            final json = jsonDecode(response.body);
            if (json['success'] == true && json['data'] is List) {
              return json['data'];
            }
          }
      } else {
         // Generic external GET request fallback (mock support)
         final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
         if (response.statusCode == 200) {
            final json = jsonDecode(response.body);
            if (json is List) {
              return json;
            } else if (json is Map<String, dynamic>) {
              var extracted = json['data'] ??
                  json['items'] ??
                  json['rewards'] ??
                  json['results'];
              if (extracted is List) {
                return extracted;
              }
            }
         }
      }
      return [];
    } catch (e) {
      debugLog('fetchDataSource failed for $endpointStr: $e');
      return [];
    }
  }

  /// Add referral leads
  ///
  /// Similar to nudgecore_v2's addLeads() method
  static Future<void> addLeads(
      {required List<Map<String, dynamic>> leads}) async {
    _ensureInitialized();

    try {
      await _post('/api/v1/nudge/leads', {'leads': leads});
      debugLog('Added ${leads.length} referral leads');
    } catch (e) {
      debugLog('addLeads failed: $e');
    }
  }

  /// Set context (for widget tracking)
  ///
  /// Similar to nudgecore_v2's setContext() method
  static void setContext(BuildContext context) {
    _appContext = context;
  }

  /// Start a new session
  static Future<void> startSession() async {
    _sessionId =
        '${DateTime.now().millisecondsSinceEpoch}_${_prefs?.getString(_prefsKeyUserId) ?? 'anonymous'}';
    debugLog('Session started: $_sessionId');
    track('session_start', properties: {'session_id': _sessionId});
  }

  /// End current session
  static Future<void> endSession() async {
    if (_sessionId != null) {
      track('session_end', properties: {'session_id': _sessionId});
      debugLog('Session ended: $_sessionId');
      _sessionId = null;
    }
  }

  /// Enable or disable the SDK completely
  static void setShouldDisableNinja(bool disable) {
    _shouldDisableSdk = disable;
    debugLog('SDK disabled: $disable');
  }

  /// Enable or disable back button listener
  static void setShouldDisableBackPressedListener(bool disable) {
    _shouldDisableBackPressedListener = disable;
    debugLog('Back pressed listener disabled: $disable');
  }

  /// Enable or disable parent widget check
  static void setShouldCheckForParentWidget(bool enable) {
    _shouldCheckForParentWidget = enable;
    debugLog('Check for parent widget: $enable');
  }

  /// Enable or disable Flutter widget touch
  static void setShouldEnableFlutterWidgetTouch(bool enable) {
    _shouldEnableFlutterWidgetTouch = enable;
    debugLog('Flutter widget touch enabled: $enable');
  }

  /// Request push notification permission (placeholder for pure Flutter)
  static Future<bool> requestPushPermission() async {
    debugLog(
        'requestPushPermission called (integrate firebase_messaging for real implementation)');
    // In a real app, integrate firebase_messaging:
    // final messaging = FirebaseMessaging.instance;
    // final settings = await messaging.requestPermission();
    // return settings.authorizationStatus == AuthorizationStatus.authorized;
    return false;
  }

  /// Set FCM token for push notifications
  static void setFcmToken(String token) {
    try {
      final preview = token.length > 10 ? '${token.substring(0, 10)}...' : token;
      debugLog('FCM token set: $preview');
      _prefs?.setString('ninja_fcm_token', token);
      track('fcm_token_set', properties: {'token': token});
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'setFcmToken');
    }
  }

  /// Show notification (placeholder for pure Flutter)
  static void showNotification(Map<String, dynamic> remoteMessage) {
    debugLog('showNotification: $remoteMessage');
    ninjaSdkSafeSync(
      () => _notificationClickListener?.call(remoteMessage),
      context: 'notificationClickListener',
    );
  }

  /// Get current scroll data from the primary scrollable ancestor.
  /// Used during page capture to record scroll position for tooltip scroll replay.
  static Map<String, dynamic> getActiveScrollData() {
    try {
      final ctx = _appContext ?? navigatorKey.currentContext;
      if (ctx == null) {
        debugLog('getActiveScrollData: No context available');
        return {};
      }

      // Walk up to find the nearest ScrollController
      ScrollController? controller;
      double scrollY = 0.0;
      double scrollX = 0.0;
      double maxExtentY = 0.0;
      double maxExtentX = 0.0;

      // Try to find a Scrollable via context visitor
      void findScrollable(Element element) {
        if (controller != null) return; // Already found

        final widget = element.widget;
        if (widget is Scrollable && widget.controller != null) {
          final pos = widget.controller!.position;
          if (pos.axis == Axis.vertical) {
            scrollY = pos.pixels;
            maxExtentY = pos.maxScrollExtent;
            controller = widget.controller;
          } else if (pos.axis == Axis.horizontal) {
            scrollX = pos.pixels;
            maxExtentX = pos.maxScrollExtent;
            controller = widget.controller;
          }
          return;
        }

        // Check if it's a scrollable view with a controller
        if (widget is ScrollView && widget.controller != null) {
          try {
            final pos = widget.controller!.position;
            if (pos.axis == Axis.vertical) {
              scrollY = pos.pixels;
              maxExtentY = pos.maxScrollExtent;
            } else {
              scrollX = pos.pixels;
              maxExtentX = pos.maxScrollExtent;
            }
            controller = widget.controller;
            return;
          } catch (_) {}
        }

        element.visitChildren(findScrollable);
      }

      (ctx as Element).visitChildren(findScrollable);

      // Also try PrimaryScrollController as fallback
      if (controller == null) {
        try {
          final primaryController = PrimaryScrollController.maybeOf(ctx);
          if (primaryController != null && primaryController.hasClients) {
            scrollY = primaryController.position.pixels;
            maxExtentY = primaryController.position.maxScrollExtent;
            controller = primaryController;
          }
        } catch (_) {}
      }

      final data = {
        'pageScrollY': scrollY,
        'pageScrollX': scrollX,
        'maxScrollExtentY': maxExtentY,
        'maxScrollExtentX': maxExtentX,
      };

      debugLog('getActiveScrollData: $data');
      return data;
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'getActiveScrollData');
      return {};
    }
  }

  /// Get all elements with their positions
  ///
  /// [listenerId] - Unique listener ID
  /// [pixRatio] - Device pixel ratio
  /// [screenWidth] - Screen width in pixels
  /// [screenHeight] - Screen height in pixels
  static List<Map<String, dynamic>> getAllElements(String listenerId,
      double pixRatio, double screenWidth, double screenHeight) {
    debugLog('getAllElements: Starting with listeners=$listenerId');

    if (_appContext == null) {
      debugLog('getAllElements: _appContext is NULL. Aborting.');
      return [];
    }
    debugLog('getAllElements: _appContext found.');

    final elements = <Map<String, dynamic>>[];

    try {
      debugLog('getAllElements: Visiting child elements...');
      int visitedCount = 0;
      int keyCount = 0;
      int visibleCount = 0;

      void recurse(Element element) {
        visitedCount++;
        try {
          String? foundId;
          
          // 1. Check for EmbedWidgetWrapper (User Preferred)
          if (element.widget is EmbedWidgetWrapper) {
            foundId = (element.widget as EmbedWidgetWrapper).id;
          } 
          // 2. Fallback to ValueKey (Legacy/Internal)
          else if (element.widget.key is ValueKey) {
             // Only use string keys to avoid confusion
             final val = (element.widget.key as ValueKey).value;
             if (val is String) foundId = val;
          }

          if (foundId != null) {
            final key = foundId;
            final renderObject = element.renderObject;

            if (_debugMode) {
              debugLog('🔍 Found ID: $key (${element.widget.runtimeType})');
            }

            if (renderObject is RenderBox && renderObject.hasSize) {
              final offset = renderObject.localToGlobal(Offset.zero);
              final size = renderObject.size;
              
              // 1. Check if element is on the CURRENT ROUTE
              bool isCurrentRoute = true;
              try {
                final route = ModalRoute.of(element);
                if (route != null) {
                  isCurrentRoute = route.isCurrent;
                }
              } catch (e) {
                // Ignore errors finding route
              }

              if (!isCurrentRoute) {
                if (_debugMode) {
                  debugLog('   - SKIPPED: Background Route ($key)');
                }
              } else {
                final isVisible = _isElementVisible(offset, size, screenWidth / pixRatio, screenHeight / pixRatio);
                
                // FORCE ADD if on current route, even if geometry check fails slightly
                // This ensures we capture all user-tagged elements on the active page.
                visibleCount++;
                elements.add({
                  'id': key,
                  'type': element.widget.runtimeType.toString(),
                  'rect': {
                    'x': offset.dx * pixRatio,
                    'y': offset.dy * pixRatio,
                    'width': size.width * pixRatio,
                    'height': size.height * pixRatio,
                  },
                  'inViewport': isVisible, 
                });

                _elementPositions[key] = {
                  'x': offset.dx,
                  'y': offset.dy,
                  'width': size.width,
                  'height': size.height,
                };
              }
            } else {
              if (_debugMode) {
                debugLog(
                    '   - SKIPPED: No RenderBox or No Size (RO: $renderObject)');
              }
            }
          }
          element.visitChildren(recurse);
        } catch (e) {
          debugLog('Error visiting element: $e');
        }
      }

      // Use _appContext (NinjaApp Root) if available, as it covers everything.
      // Fallback to Navigator Key (Active Page) if not.
      final rootContext = _appContext ?? navigatorKey.currentContext;
      
      if (rootContext == null) {
        debugLog('❌ getAllElements: No context available');
        return [];
      }
      
      rootContext.visitChildElements(recurse);
      debugLog('getAllElements: Scanned $visitedCount elements. Found $keyCount ValueKeys. valid & visible: $visibleCount.');
      
    } catch (e) {
      debugLog('Error in getAllElements tree traversal: $e');
    }

    return elements;
  }

  static bool _isElementVisible(Offset offset, Size size, double screenWidth, double screenHeight) {
    final centerX = offset.dx + size.width / 2;
    final centerY = offset.dy + size.height / 2;
    return centerX >= 0 && centerX <= screenWidth && centerY >= 0 && centerY <= screenHeight;
  }

  /// Check if views with given keys are present
  static bool areViewsPresent(List<String> keys) {
    for (final key in keys) {
      if (!_elementPositions.containsKey(key)) {
        return false;
      }
    }
    return true;
  }

  /// Get position of a view by key
  static Map<String, dynamic>? getViewPosition(String key) {
    return _elementPositions[key];
  }

  /// Recursively traverse widget tree and collect element positions
  ///
  /// This matches Plotline's recurseKey signature
  static List<Map<String, dynamic>> recurseKey(BuildContext element,
      double pixRatio, int screenWidth, int screenHeight) {
    List<Map<String, dynamic>> list = [];

    try {
      debugLog(
          "recurseKey called with pixRatio: $pixRatio, screenWidth: $screenWidth, screenHeight: $screenHeight");

      element.visitChildElements((element) {
        try {
          String? key = extractKeyValue(element);
          debugLog("Visited Raw Element: $key, ${element.widget.runtimeType}");

          if (key != null && key.isNotEmpty && visibilityMap[key] == 100.0) {
            debugLog("Visited Element: $key");
            RenderBox? box = element.renderObject as RenderBox?;

            if (box != null && box.hasSize) {
              Offset position = box.localToGlobal(Offset.zero);

              if (isWithinBoundsContext(
                  element, position, pixRatio, screenWidth, screenHeight)) {
                debugLog("Element within Bounds: $key");

                Map<String, dynamic> newPosition = {};
                Map<String, dynamic> elementObj = {};

                newPosition['x'] = ((position.dx * pixRatio) + 0.6).round();
                newPosition['y'] = ((position.dy * pixRatio) + 0.6).round();
                newPosition['width'] = ((box.size.width) * pixRatio).round();
                newPosition['height'] = ((box.size.height) * pixRatio).round();

                elementObj['position'] = newPosition;
                elementObj['clientElementId'] = key;
                elementObj['isWidget'] = false;

                list.add(elementObj);
              }
            }
          }

          list.addAll(recurseKey(element, pixRatio, screenWidth, screenHeight));
        } catch (e) {
          debugLog("Error in visitChildElements: $e");
        }
      });
    } catch (e) {
      debugLog("Error in recurseKey: $e");
    }

    return list;
  }

  /// Find view by key value
  static BuildContext? findViewByKey(String key, BuildContext context) {
    BuildContext? result;
    final visitedElements = <Element>{};

    void searchForWidget(Element element) {
      try {
        if (!visitedElements.contains(element)) {
          visitedElements.add(element);
          String? widgetKey = extractKeyValue(element);

          if (widgetKey != null && widgetKey == key) {
            result = element;
            return;
          }

          element.visitChildElements(searchForWidget);
        }
      } catch (e) {
        debugLog("Error in searchForWidget: $e");
      }
    }

    context.visitChildElements(searchForWidget);
    return result;
  }

  /// Extract key value from element
  static String? extractKeyValue(Element element) {
    final key = element.widget.key;
    if (key is ValueKey) {
      return key.value.toString();
    }
    return null;
  }

  /// Check if a point is within bounds (simple version)
  static bool isWithinBounds(double x, double y, double left, double top,
      double right, double bottom) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }

  /// Check if element is within screen bounds (BuildContext version)
  static bool isWithinBoundsContext(BuildContext element, Offset position,
      double pixRatio, int screenWidth, int screenHeight) {
    try {
      final renderBox = element.findRenderObject() as RenderBox?;
      if (renderBox == null) return false;

      int x = ((position.dx * pixRatio)).round();
      int y = ((position.dy * pixRatio)).round();
      int width = ((renderBox.size.width) * pixRatio).round();
      int height = ((renderBox.size.height) * pixRatio).round();

      return x >= 0 &&
          y >= 0 &&
          (x + width) <= screenWidth &&
          (y + height) <= screenHeight &&
          width > 0 &&
          height > 0;
    } catch (e) {
      debugLog("Error in isWithinBoundsContext: $e");
      return false;
    }
  }

  /// Get the topmost context from a widget tree
  static BuildContext? getTopmostContext(BuildContext context) {
    try {
      if (!_shouldCheckForParentWidget) {
        return context;
      }

      BuildContext? topmost = context;

      void findTopmost(Element element) {
        topmost = element;
        element.visitAncestorElements((ancestor) {
          topmost = ancestor;
          return true;
        });
      }

      context.visitChildElements(findTopmost);
      return topmost;
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'getTopmostContext');
      return context;
    }
  }

  // PRIVATE METHODS

  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (_apiKey != null) 'x-api-key': _apiKey!,
    };
  }

  static void _ensureInitialized() {
    if (!_initialized || _apiKey == null) {
      throw StateError('AppNinja not initialized. Call AppNinja.init() first.');
    }
  }

  static Future<http.Response> _post(
      String path, Map<String, dynamic> body) async {
    final url = '$_baseUrl$path';
    debugLog('🌐 POST Request to: $url (Timeout: 60s)');
    var response = await http
        .post(
          Uri.parse(url),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    // Follow 307/308 redirects (Vercel proxy may redirect POST requests)
    int redirectCount = 0;
    while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
      final location = response.headers['location'];
      if (location == null) break;
      debugLog('↪️ Following ${response.statusCode} redirect to: $location');
      final redirectUrl = Uri.parse(url).resolve(location);
      response = await http
          .post(
            redirectUrl,
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      redirectCount++;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugLog('🚫 Invalid API Key or Authentication Failed (Status: ${response.statusCode}). Disabling SDK.');
        AppNinja.setShouldDisableNinja(true);
        throw Exception('AUTH_ERROR');
      }
      throw Exception('POST $path failed with status ${response.statusCode}');
    }

    return response;
  }

  /// POST helper that follows 307/308 redirects but does NOT throw on non-2xx.
  /// Used by game/scratch endpoints that return structured JSON for all status codes.
  static Future<http.Response> _postRaw(
      String path, Map<String, dynamic> body) async {
    final url = '$_baseUrl$path';
    debugLog('🌐 POST Request to: $url (Timeout: 60s)');
    var response = await http
        .post(
          Uri.parse(url),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    // Follow 307/308 redirects (Vercel proxy may redirect POST requests)
    int redirectCount = 0;
    while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
      final location = response.headers['location'];
      if (location == null) break;
      debugLog('↪️ Following ${response.statusCode} redirect to: $location');
      final redirectUrl = Uri.parse(url).resolve(location);
      response = await http
          .post(
            redirectUrl,
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      redirectCount++;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      debugLog('🚫 Invalid API Key or Authentication Failed (Status: ${response.statusCode}). Disabling SDK.');
      AppNinja.setShouldDisableNinja(true);
    }

    return response;
  }

  static Future<void> _queueEvent(Map<String, dynamic> event) async {
    final queue = _prefs?.getStringList(_prefsKeyQueue) ?? <String>[];
    queue.add(jsonEncode(event));
    await _prefs?.setStringList(_prefsKeyQueue, queue);
    debugLog('Event queued, total: ${queue.length}');
  }

  static Future<void> _flushEventQueue() async {
    final queue = _prefs?.getStringList(_prefsKeyQueue) ?? <String>[];
    if (queue.isEmpty) return;

    final remaining = <String>[];
    for (final eventStr in queue) {
      try {
        final event = jsonDecode(eventStr) as Map<String, dynamic>;
        final type = event['type'];
        final payload = event['payload'] as Map<String, dynamic>;

        if (type == 'track') {
          await _post('/api/v1/nudge/track', payload);
        } else if (type == 'identify') {
          await _post('/api/v1/nudge/identify', payload);
        }
      } catch (e) {
        debugLog('Failed to flush event: $e');
        remaining.add(eventStr);
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }

    await _prefs?.setStringList(_prefsKeyQueue, remaining);
    debugLog('Event queue flushed, remaining: ${remaining.length}');
  }

  // Caching is disabled; campaigns are loaded and stored in-memory only.

  /// Background refresh (non-blocking) - PHASE 2
  static Future<void> _refreshCampaignsBackground() async {
    if (_isRefreshing) {
      debugLog('⚠️ Refresh already in progress, skipping');
      return;
    }
    
    _isRefreshing = true;
    
    try {
      debugLog('🔄 Background refresh started...');
      
      // Fetch with retry logic
      final campaigns = await _fetchCampaignsWithRetry();
      
      // Memory optimization
      final limited = campaigns.take(_maxCachedCampaigns).toList();
      
      // Update in-memory only (cache is disabled)
      
      // Update in-memory
      _cachedCampaigns = limited;
      
      // ✅ FIX: Don't emit to stream on background refresh!
      // Campaigns should only be emitted when triggered by events via track()
      // _campaignController.add(limited); // REMOVED - causes auto-show without trigger
      
      // ✅ Phase 2 Gamification: Push Offline Progression Memory Map
      unawaited(NinjaChallengeManager.pushLocalStateToServer(
         baseUrl: _baseUrl,
         userId: _currentUser?.userId ?? _prefs?.getString(_prefsKeyUserId) ?? 'anonymous',
         headers: await _getHeaders(),
      ));
      
      debugLog('✅ Background refresh complete: ${limited.length} campaigns');
      debugLog('   📦 Cache updated: ${limited.length} campaigns');
      debugLog('   ℹ️ Campaigns will show when trigger events fire');
    } catch (e) {
      debugLog('⚠️ Background refresh failed: $e');
      // Don't throw - just log. Use cached data.
    } finally {
      _isRefreshing = false;
    }
  }

  /// Fetch with exponential backoff retry - Production grade
  static Future<List<Campaign>> _fetchCampaignsWithRetry({
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500)
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxAttempts) {
      try {
        return await fetchCampaigns().timeout(const Duration(seconds: 65));
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          debugLog('❌ All $maxAttempts fetch attempts failed');
          rethrow;
        }
        
        debugLog('⚠️ Fetch attempt $attempt failed, retrying in ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    
    return [];
  }



  /// Start smart refresh timer - PHASE 3
  static void _startSmartRefreshTimer() {
    // Cancel existing timer
    _backgroundRefreshTimer?.cancel();
    
   // Periodic refresh every 5 minutes
    _backgroundRefreshTimer = Timer.periodic(_cacheRefreshInterval, (_) {
      debugLog('⏰ Periodic refresh triggered');
      unawaited(_refreshCampaignsBackground());
    });
    
    debugLog('⏰ Smart refresh timer started (interval: ${_cacheRefreshInterval.inMinutes}min)');
  }

  // ========== END HYBRID CACHE SYSTEM ==========

  /// Internal convenience wrapper — routes to [NinjaLog] with the 'AppNinja' tag.
  static void debugLog(String message) {
    NinjaLog.d('AppNinja', message);
  }

  /// Get current app context (for widget detection)
  static BuildContext? get appContext => _appContext;

  /// Get current page name
  static String? get currentPage => _currentPage;

  /// Get current locale
  static String get locale => _locale;

  /// Get color theme
  static Map<String, String> get colorTheme => _colorTheme;

  /// Check if initialized
  static bool get isInitialized => _initialized;

  /// Check if SDK is disabled
  static bool get isSdkDisabled => _shouldDisableSdk;

  /// Check if back pressed listener is disabled
  static bool get isBackPressedListenerDisabled =>
      _shouldDisableBackPressedListener;

  /// Check if should check for parent widget
  static bool get shouldCheckForParentWidget => _shouldCheckForParentWidget;

  /// Check if Flutter widget touch is enabled
  static bool get isFlutterWidgetTouchEnabled =>
      _shouldEnableFlutterWidgetTouch;

  /// Get current region
  static String? get region => _region;

  /// Get current region as enum
  static NinjaRegion? get ninjaRegion => _ninjaRegion;



  /// Get screenshot key (nudgecore_v2 compatibility)
  static GlobalKey? get screenshotKey => _screenshotKey;

  /// Get external user ID
  static String? get externalId => _externalId;

  /// Get current session ID
  static String? get sessionId => _sessionId;

  /// Get user properties
  static Map<String, dynamic> get userProperties => _userProperties;

  /// Get current user object
  static NinjaUser? get currentUser => _currentUser;

  /// Trigger redirect event
  static void triggerRedirect(Map<String, dynamic> properties) {
    ninjaSdkSafeSync(
      () => _redirectListener?.call(properties),
      context: 'redirectListener',
    );
  }

  /// Trigger refresh token callback
  static void triggerRefreshToken() {
    ninjaSdkSafeOptional(_refreshTokenCallback, context: 'refreshTokenCallback');
  }

  /// Trigger auth callback
  static void triggerAuth(String? key) {
    ninjaSdkSafeSync(
      () => _authCallback?.call(key),
      context: 'authCallback',
    );
  }

  // ========== AUTO-RENDER FEATURES ==========

  /// Set global context for auto-rendering campaigns
  ///
  /// This should be called by NinjaApp wrapper widget automatically
  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
    debugLog('🌍 Global context set for auto-rendering');
  }

  static bool isTicketLocallyUnlocked(String ledgerId) {
    return _locallyUnlockedTickets.contains(ledgerId);
  }

  /// Auto-fetch campaigns (called by NinjaApp on app resume)
  static Future<void> autoFetchCampaigns() async {
    if (!_autoRenderEnabled) return;

    try {
      debugLog('🔄 Auto-fetching campaigns...');
      await fetchCampaigns();
    } catch (e) {
      debugLog('❌ Auto-fetch campaigns failed: $e');
    }
  }

  /// Setup auto-rendering system
  ///
  /// Listens to campaign stream and automatically shows campaigns when they arrive
  static final Map<String, VoidCallback> _activeCampaignDismissals = {};

  /// Tracks the type of each active campaign — used in clearNudges() to decide
  /// whether to dismiss on page change. Floater/PIP campaigns persist across pages.
  static final Map<String, String> _activeCampaignTypes = {};
  
  static final Set<String> _locallyUnlockedTickets = {};

  /// Active overlay entries for floater/pip campaigns (to re-insert on page navigation)
  static final Map<String, OverlayEntry> _activeOverlayEntries = {};

  static void registerActiveOverlay(String campaignId, OverlayEntry entry) {
    _activeOverlayEntries[campaignId] = entry;
  }

  static void unregisterActiveOverlay(String campaignId) {
    _activeOverlayEntries.remove(campaignId);
  }

  /// Auto-show campaign (universal renderer for all types)
  static void _autoShowCampaign(Campaign campaign) {
    // ✅ FIX: Respect display rules for frequency FIRST
    // Check if campaign allows "every time" display
    // Backend may send as displayRules or display_rules
    final displayRules = (campaign.config['displayRules'] ?? campaign.config['display_rules']) as Map<String, dynamic>?;
    final frequencyType = displayRules?['frequency']?['type'] as String? ?? 'every_time';
    final interactionLimitType = displayRules?['interactionLimit']?['type'] as String? ?? 'unlimited';
    
    // ✅ BUG-2 FIX: allowRepeat should ONLY be true if frequency is every_time.
    // An unlimited interaction limit DOES NOT override a once_per_session frequency rule!
    final allowRepeat = frequencyType == 'every_time';
    
    debugLog('📋 Display rules check: frequency=$frequencyType, interactionLimit=$interactionLimitType, allowRepeat=$allowRepeat');

    // 🎯 VALIDATION: Global Session Limit
    // Rules:
    //  - Campaigns with overrideGlobal=true are ALWAYS exempt.
    //  - For every other campaign, EACH show counts against the global limit
    //    (including repeat/every_time campaigns — they don't get a free pass).
    //  - Exception: if the campaign is already active on screen (re-trigger while open),
    //    don't count it again (handled below).
    final globalSessionLimit = NinjaCampaignRepository().globalSessionLimit;
    final isAlreadyActiveOnScreen = _activeCampaignDismissals.containsKey(campaign.id);
    if (!campaign.overrideGlobal && globalSessionLimit != null && !isAlreadyActiveOnScreen) {
      if (_sessionLimitedCampaignsShown >= globalSessionLimit) {
        debugLog('⏭️ Skipping campaign "${campaign.title}" (${campaign.id}): Global session limit reached ($_sessionLimitedCampaignsShown/$globalSessionLimit)');
        return;
      }
    }

    // 🎯 VALIDATION 1: Navigation Token Check (Race Condition Prevention)
    // ONLY apply token check for campaigns that DON'T allow repeat
    // For "every time" campaigns, skip this check entirely
    if (!allowRepeat) {
      final campaignToken = _campaignNavigationTokenMap[campaign.id];
      if (campaignToken != null && campaignToken != _navigationToken) {
        // Check if tokens are within reasonable time (they're timestamps as strings)
        final campaignTs = int.tryParse(campaignToken) ?? 0;
        final currentTs = int.tryParse(_navigationToken) ?? 0;
        final timeDiff = (currentTs - campaignTs).abs();
        if (timeDiff > 1000) {
          debugLog(
              '⏭️ Skipping campaign "${campaign.title}" (${campaign.id}): '
              'User navigated away (Token mismatch: campaign=$campaignToken, current=$_navigationToken, diff=${timeDiff}ms)');
          _campaignNavigationTokenMap.remove(campaign.id); // Cleanup
          return;
        }
        debugLog('ℹ️ Token mismatch within tolerance (${timeDiff}ms), allowing campaign');
      }
    } else {
      debugLog('ℹ️ Skipping token validation - campaign allows repeat display');
    }

    // Resolve context: Prefer Navigator's OVERLAY context (child of Navigator) 
    // This ensures Navigator.of(context) finds the navigator itself, instead of looking above it.
    BuildContext? context;
    String contextSource = 'none';
    if (_navigatorKey?.currentState?.overlay?.context != null &&
        _navigatorKey!.currentState!.overlay!.context.mounted) {
      context = _navigatorKey!.currentState!.overlay!.context;
      contextSource = 'navigatorKey.overlay';
    } else if (_navigatorKey?.currentContext != null &&
        _navigatorKey!.currentContext!.mounted) {
      context = _navigatorKey!.currentContext;
      contextSource = 'navigatorKey.currentContext';
    } else if (_globalContext != null && _globalContext!.mounted) {
      context = _globalContext;
      contextSource = 'globalContext';
    } else if (_appContext != null && _appContext!.mounted) {
      context = _appContext;
      contextSource = 'appContext';
    }

    debugLog('🔑 Context resolved from: $contextSource '
        '(navOverlay: ${_navigatorKey?.currentState?.overlay?.context != null}, '
        'navKey: ${_navigatorKey?.currentContext != null}, '
        'global: ${_globalContext != null}, '
        'app: ${_appContext != null})');

    if (context == null) {
      debugLog('❌ Cannot auto-show campaign: No valid context or context is not mounted');
      return;
    }

    // Session check - only block if campaign doesn't allow repeat AND already shown
    debugLog('   📋 Already shown this session: ${_shownCampaignsThisSession.contains(campaign.id)}');
    
    if (!allowRepeat && _shownCampaignsThisSession.contains(campaign.id) && !_activeCampaignDismissals.containsKey(campaign.id)) {
      debugLog('ℹ️ Campaign ${campaign.id} already shown this session, skipping auto-render (frequency: $frequencyType)');
      return;
    }

    // If the campaign is already visible on screen, always skip.
    // This prevents deferred/repeated trigger events (e.g. from trackPage's post-fetch
    // re-check) from closing and re-opening a campaign the user is currently viewing.
    if (isAlreadyActiveOnScreen) {
      debugLog('ℹ️ Campaign ${campaign.id} is already active on screen, skipping redundant show');
      return;
    }

    final campaignType = campaign.type.toLowerCase();
    debugLog(
        '🚀 Auto-showing $campaignType campaign: ${campaign.title} (${campaign.id})');

    // Mark campaign as shown in this session
    final bool isFirstShow = !_shownCampaignsThisSession.contains(campaign.id);
    _shownCampaignsThisSession.add(campaign.id);
    _lastShownPipId = campaign.id;
    _lastCampaignShownTime = DateTime.now();

    // Global session limit check.
    // Every show of a campaign (including repeat shows) counts against the global session limit.
    // overrideGlobal campaigns never count.
    if (!campaign.overrideGlobal) {
      _sessionLimitedCampaignsShown++;
      debugLog('📊 Global session tally: $_sessionLimitedCampaignsShown/$globalSessionLimit (campaign: ${campaign.title})');
    }

    try {
      // Use NinjaCampaignRenderer to show the campaign
      final dismissCallback = NinjaCampaignRenderer.show(
        campaign: campaign,
        context: context,
        overlayState: _navigatorKey?.currentState?.overlay, // Pass direct overlay state
        onImpression: () {
          debugLog('👁️ Auto-tracked impression: ${campaign.id}');
          track('impression', properties: {
            'nudgeId': campaign.id,
            'campaignId': campaign.id,
            'campaign_name': campaign.title,
            'campaign_type': campaign.type,
            'auto_rendered': true,
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
        onDismiss: () {
          debugLog('❌ Auto-rendered campaign dismissed: \${campaign.id}');
          track('campaign_dismissed', properties: {
            'nudgeId': campaign.id,
            'campaignId': campaign.id,
            'campaign_name': campaign.title,
          });
          
          // Clean up dismissal registry
          _activeCampaignDismissals.remove(campaign.id);
          _activeCampaignTypes.remove(campaign.id);
          
          // 🎯 Cleanup navigation token map
          _campaignNavigationTokenMap.remove(campaign.id);
          
          if (_lastShownPipId == campaign.id) {
             _lastShownPipId = null;
          }
          
          // Refresh campaigns in background to sync any state changes (like auto-allocated unscratched rewards)
          ninjaSdkSafeUnawaited(
            _refreshCampaignsBackground(),
            context: 'Refresh campaigns after campaign dismissed',
          );
        },
        onCTAClick: (action, data) {
          debugLog('🎯 Auto-rendered CTA clicked: $action');
          track('click', properties: {
            'nudgeId': campaign.id,
            'campaignId': campaign.id,
            'campaign_name': campaign.title,
            'action': action,
            'button_text': data?['button_text'],
          });
        },
      );

      _activeCampaignDismissals[campaign.id] = dismissCallback;
      _activeCampaignTypes[campaign.id] = campaignType;

      debugLog('✅ Campaign auto-rendered successfully: ${campaign.title}');
    } catch (e) {
      debugLog('❌ Auto-show campaign failed: $e');
      NinjaLog.d('AppNinja', 'Auto-render error stack: ${StackTrace.current}');
    }
  }

  /// Setup auto-rendering system
  ///
  /// Listens to campaign stream and automatically shows campaigns when they arrive
  static void _setupAutoRendering() {
    debugLog('🎯 Setting up auto-rendering system');

    // Cancel existing subscription if any
    _autoRenderSubscription?.cancel();

    _autoRenderSubscription = onCampaigns.listen(
      (campaigns) {
        try {
          if (!_autoRenderEnabled) return;

          /// Check if we have a context that can actually render dialogs/overlays.
          /// In hybrid apps, RoutingPage's context is above the Navigator, so it
          /// cannot be used for showGeneralDialog or Overlay.of(). The only reliable
          /// context is from the navigatorKey's overlay (which is INSIDE the Navigator).
          bool _hasRenderableContext() {
            // Priority 1: NavigatorKey overlay context (best - inside Navigator)
            if (_navigatorKey?.currentState?.overlay?.context != null &&
                _navigatorKey!.currentState!.overlay!.context.mounted) {
              return true;
            }
            // Priority 2: NavigatorKey direct context
            if (_navigatorKey?.currentContext != null &&
                _navigatorKey!.currentContext!.mounted) {
              return true;
            }
            // Priority 3: Global/App context (may work in pure Flutter apps)
            if ((_globalContext != null && _globalContext!.mounted) ||
                (_appContext != null && _appContext!.mounted)) {
              return true;
            }
            return false;
          }

          void doRender() {
            debugLog('📦 Auto-render received ${campaigns.length} campaigns');
            for (final campaign in campaigns) {
              debugLog(
                  '🔍 Processing campaign for auto-render: ${campaign.id} - ${campaign.title}');
              _autoShowCampaign(campaign);
            }
          }

          /// Progressive retry: waits for navigatorKey to mount.
          /// In hybrid Flutter apps, the Navigator mounts AFTER the RoutingPage's
          /// postFrameCallback, so we need to poll until it's ready.
          void retryWithBackoff(int attempt, List<int> delays) {
            if (attempt >= delays.length) {
              debugLog('⚠️ Auto-render: Gave up waiting for renderable context after ${delays.length} retries');
              // Last resort: try anyway with whatever context we have
              if ((_globalContext != null && _globalContext!.mounted) ||
                  (_appContext != null && _appContext!.mounted)) {
                debugLog('🔄 Auto-render: Attempting render with fallback context');
                doRender();
              }
              return;
            }

            final delay = delays[attempt];
            debugLog('⏳ Context not renderable yet (navigatorKey.overlay: ${_navigatorKey?.currentState?.overlay?.context != null}, '
                'navigatorKey: ${_navigatorKey?.currentContext != null}, '
                'globalContext: ${_globalContext != null}, '
                'appContext: ${_appContext != null}). '
                'Retry ${attempt + 1}/${delays.length} in ${delay}ms...');

            Future.delayed(Duration(milliseconds: delay), () {
              try {
                if (_hasRenderableContext()) {
                  debugLog('✅ Renderable context found on retry ${attempt + 1}');
                  doRender();
                } else {
                  retryWithBackoff(attempt + 1, delays);
                }
              } catch (e, st) {
                ninjaSdkLogError(e, st, 'delayed auto-render retry');
              }
            });
          }

          if (_hasRenderableContext()) {
            doRender();
          } else {
            // Progressive backoff: 250ms, 500ms, 750ms, 1000ms, 1500ms, 2000ms
            // Total wait: up to ~6 seconds for the Navigator to mount
            retryWithBackoff(0, [250, 500, 750, 1000, 1500, 2000]);
          }
        } catch (e, st) {
          ninjaSdkLogError(e, st, 'auto-render listener');
        }
      },
      onError: (e, st) {
        ninjaSdkLogError(e, st, 'onCampaigns stream');
      },
    );

    // Process any buffered campaigns that were matched before the listener was ready
    if (_pendingStreamCampaigns.isNotEmpty) {
      final pending = List<Campaign>.from(_pendingStreamCampaigns);
      _pendingStreamCampaigns.clear();
      debugLog('⚡ Flushing ${pending.length} buffered campaign(s) to stream after listener registration');
      // Post to stream so all active listeners (including auto-render) receive them
      _campaignController.add(pending);
    }

    ninjaSdkSafeUnawaited(
      Future.delayed(const Duration(milliseconds: 500), autoFetchCampaigns),
      context: 'autoFetchCampaigns delayed',
    );
  }

  /// Reset local game attempts (used for testing or explicitly requested by STW)
  static Future<void> resetGameAttempts(String campaignId) async {
    // If you have a local SharedPreferences counter, reset it here.
    // For now, since we are moving to server-authoritative, we might just clear STW cache.
  }

  /// Helper for GET requests
  static Future<Map<String, dynamic>> _getRaw(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  /// Fetch authoritative remaining spins from the Gamification Engine
  static Future<Map<String, dynamic>> getSpinsRemaining(String campaignId) async {
    try {
      final userId = _prefs?.getString(_prefsKeyUserId) ?? 'anonymous';
      final qs = 'campaignId=$campaignId&userId=$userId';
      final response = await _getRaw('/api/v1/game/spins-remaining?$qs');
      if (response['success'] == true) {
        final remaining = response['remainingSpins'] as int?;
        if (remaining != null) {
          AppNinja.stwSpinsLeft = remaining;
          // Persist to SharedPreferences so it survives app restarts
          await _prefs?.setInt(_prefsKeySpinsLeft, remaining);
          return response;
        }
      }
      return response;
    } catch (e) {
      NinjaLog.d('AppNinja', 'NinjaSTW: Failed to fetch spins remaining: $e');
    }
    return {'success': false, 'error': 'Failed to fetch'}; // Unknown or error
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      _locallyUnlockedTickets.clear();
      _autoRenderSubscription?.cancel();
      _backgroundRefreshTimer?.cancel();

      await _campaignController.close();

      _initialized = false;
      _cachedCampaigns = [];
      _cacheTimestamp = null;
      _roundRobinIndex.clear();

      debugLog('🗑️ AppNinja disposed - all resources cleaned up');
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'dispose');
    }
  }
}

/// AppNinjaInstance - Wrapper class for instance methods to avoid static/instance name collisions in AppNinja.
class AppNinjaInstance {
  AppNinjaInstance._internal();

  /// Clear active campaigns / dismiss any active campaign
  void clearNudges() {
    AppNinja.clearNudges();
  }

  /// Track a page view
  /// 
  /// [name] - Name of the page/screen (e.g. 'home')
  /// [context] - Optional BuildContext for tracking
  void trackPage({required String name, BuildContext? context}) {
    final resolvedContext = context ?? 
                            AppNinja._navigatorKey?.currentState?.overlay?.context ?? 
                            AppNinja._navigatorKey?.currentContext ?? 
                            AppNinja._globalContext;
    if (resolvedContext != null) {
      AppNinja.trackPage(name, resolvedContext);
    } else {
      AppNinja._currentPage = name;
      AppNinja.debugLog('📍 trackPage instance method set page: $name');
    }
  }

  /// Track a custom event
  /// 
  /// [event] - Name of the event
  /// [properties] - Optional event properties
  Future<void> track({required String event, Map<String, dynamic> properties = const {}}) async {
    await AppNinja.track(event, properties: properties);
  }

  /// Disable SDK at any point
  void disableNudge(bool disable) {
    AppNinja.setShouldDisableNinja(disable);
  }

  /// Sign out user and clear any active cache
  Future<void> userSignOut() async {
    await AppNinja.userSignOut();
  }

  /// Identify user with externalId and userProperties (nudgecore_v2 style)
  void userIdentifier({
    required String externalId,
    Map<String, dynamic>? userProperties,
  }) {
    AppNinja.userIdentifier(
      externalId: externalId,
      userProperties: userProperties,
    );
  }
}


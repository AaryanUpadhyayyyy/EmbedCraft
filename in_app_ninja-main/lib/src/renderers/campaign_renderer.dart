import 'dart:async';
import 'dart:convert';
import '../utils/ninja_logger.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Preloading support
import '../utils/interface_handler.dart'; // Fix: Import InterfaceHandler
import '../models/campaign.dart';
import '../utilities/sharedHelper/campaign_layers.dart';
import '../utilities/sharedHelper/design_scale.dart';
import '../utilities/utilHelper/ninja_url_launcher.dart';
import '../utils/ninja_logger.dart';
// import 'nudge_renderers/modal_nudge_renderer.dart'; // Deleted

import '../callbacks/ninja_callback_manager.dart';
import '../app_ninja.dart';
import 'layers/ninja_layer_utils.dart'; // Added for mapping state
import 'layers/enterprise_font_manager.dart';

import 'nudge_renderers/tooltip_renderer_v2.dart';
import 'nudge_renderers/bottom_sheet_nudge_renderer.dart';
import '../utils/ninja_logger.dart';

import 'nudge_renderers/story_wrapper_renderer.dart';
import 'nudge_renderers/inline_nudge_renderer.dart';
import 'nudge_renderers/Floater_render_v2.dart';
import '../utils/ninja_logger.dart';
// import 'nudge_renderers/floater_renderer.dart'; // Disconnected as requested
import 'nudge_renderers/fullscreen_nudge_renderer.dart';
import '../models/nudge_model.dart';
import '../controllers/ninja_input_registry.dart';
import 'challenge_renderer.dart';
import '../engine/ninja_challenge_manager.dart';
import '../utils/ninja_sdk_safe.dart';
import '../utils/ninja_logger.dart';

/// Core Campaign Renderer
///
/// Parses campaign JSON and routes to appropriate nudge renderer
/// Handles animations, tracking, and lifecycle management
class NinjaCampaignRenderer {
  /// Render a campaign based on its type
  static Widget render({
    required Campaign campaign,
    required BuildContext context,
    VoidCallback? onImpression,
    VoidCallback? onDismiss,
    VoidCallback? onRemoveOverlay,
    Function(String action, Map<String, dynamic>? data)? onCTAClick,
  }) {
    return NinjaCampaignPreloader(
      campaign: campaign,
      builder: (innerContext) {
        return _renderInternal(
          campaign: campaign,
          context: innerContext,
          onImpression: onImpression,
          onDismiss: onDismiss,
          onRemoveOverlay: onRemoveOverlay,
          onCTAClick: onCTAClick,
        );
      },
    );
  }

  static Widget _renderInternal({
    required Campaign campaign,
    required BuildContext context,
    VoidCallback? onImpression,
    VoidCallback? onDismiss,
    VoidCallback?
        onRemoveOverlay, // NEW: Just removes overlay without user callback
    Function(String action, Map<String, dynamic>? data)? onCTAClick,
  }) {
    try {
      // Parse nudge config - give priority to root campaign type if it's a special experience like 'challenge'
      final config = campaign.config;
      
      String type = config['type']?.toString().toLowerCase() ?? 'modal';
      
      // If it's a gamified challenge, check if it has a custom Design Experience
      if (campaign.challengeDetails != null) {
        if (campaign.layers == null || campaign.layers!.isEmpty) {
          // No custom design (native gamification UI) -> force challenge renderer
          type = 'challenge';
        }
        // If it HAS layers, it's a custom design, so we keep `type` as config['type'] (e.g., bottomsheet, floater)
      }

      NinjaLog.d('CampaignRenderer', '🎨 [CampaignRenderer] Rendering campaign: ${campaign.id}');
      NinjaLog.d('AppNinja', '   Type: "$type" (Raw config type: ${config['type']})');
      NinjaLog.d('CampaignRenderer', '   Config keys: ${config.keys.toList()}');

      // DEBUG: Full campaign JSON dump for parity debugging
      if (kDebugMode) {
        try {
          final encoder = const JsonEncoder.withIndent('  ');
          final dumpData = {
            'id': campaign.id,
            'title': campaign.title,
            'type': type,
            'config': campaign.config,
            'layers': campaign.layers,
          };
          NinjaLog.d('CampaignRenderer', '🔎 [LAUNCH_JSON] === RENDERED CAMPAIGN JSON START ===');
          NinjaLog.d('AppNinja', encoder.convert(dumpData));
          NinjaLog.d('CampaignRenderer', '🔎 [LAUNCH_JSON] === RENDERED CAMPAIGN JSON END ===');
        } catch (_) {}
      }

      // Callback Wrappers with NinjaCallbackManager dispatch
      final wrappedOnImpression = () {
        onImpression?.call();
        NinjaCallbackManager.dispatchExperienceOpen(
          campaignId: campaign.id,
          displayType: type,
        );
        // Send analytics to backend with campaign ID for report tracking
        AppNinja.track(
          'impression',
          properties: {
            'nudgeId': campaign.id,
            'campaignId': campaign.id,
            'type': type,
          },
        );
      };

      final wrappedOnDismiss = () {
        onDismiss?.call();
        NinjaCallbackManager.dispatchExperienceDismiss(
          campaignId: campaign.id,
          displayType: type,
        );
      };

      late final void Function(String action, Map<String, dynamic>? data)
          wrappedOnCTAClick;

      wrappedOnCTAClick = (String action, Map<String, dynamic>? data) {
        // INTERFACE ACTION: Switch to another campaign
        if (action == 'interface' && data != null) {
          final targetId = data['interfaceId'] ??
              data['targetInterface']; // Support both keys
          if (targetId != null) {
            NinjaLog.d('CampaignRenderer', "🔀 Switching to Interface: $targetId");

            // 1. Check Internal Interfaces (Sub-Nudges)
            if (campaign.interfaces != null &&
                campaign.interfaces!.any((i) => i['id'] == targetId)) {
              NinjaLog.d('CampaignRenderer', "   ✅ Found internal interface: $targetId");
              InterfaceHandler.showWithParentDismiss(
                interfaceId: targetId,
                parentCampaign: campaign,
                context: context,
                parentDismiss: onRemoveOverlay ?? onDismiss,
                onInterfaceDismiss: onDismiss,
                onCTAClick: wrappedOnCTAClick, // Chain callbacks
              );
              return;
            }

            // 2. Fetch campaigns to find target (External/Global Link)
            ninjaSdkSafeUnawaited(
              AppNinja.fetchCampaigns().then((campaigns) {
                try {
                  final target = campaigns.firstWhere((c) => c.id == targetId);

                  onRemoveOverlay?.call();

                  NinjaCampaignRenderer.show(
                    campaign: target,
                    context: context,
                  );
                } catch (e, st) {
                  ninjaSdkLogError(
                      e, st, 'CampaignRenderer interface $targetId');
                }
              }),
              context: 'CampaignRenderer interface fetchCampaigns',
            );
          }
        }

        // DEFAULT HANDLER: Launch External Links automatically
        if ((action == 'link' || action == 'deeplink' || action == 'external_url' || action == 'open_link') && data != null && data['url'] != null) {
          unawaited(NinjaUrlLauncher.launchExternal(data['url']?.toString()));
        }

        // Submit Handler: Clear inputs and show feedback
        if (action == 'submit') {
          NinjaInputRegistry.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Submitted successfully'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Floater friendly
            ),
          );
        }

        onCTAClick?.call(action, data);
        NinjaCallbackManager.dispatchComponentCtaClick(
          campaignId: campaign.id,
          campaignName: campaign.title,
          clickType: action,
          target: data?['value']?.toString() ?? data?['url']?.toString(), // Explicitly assign TARGET
          additionalData: data,
        );
        // Send click analytics to backend with campaign ID
        AppNinja.track(
          'click',
          properties: {
            'nudgeId': campaign.id,
            'campaignId': campaign.id,
            'type': type,
            'action': action,
            ...?data,
          },
        );
      };

      // Auto-track removed from builder to prevent Loop.
      // Handled by individual renderers in initState.

      // Route to specific renderer based on type
      switch (type) {
        case 'challenge':
          // Native Challenge UI (No custom layers)
          return NinjaChallengeRenderer(
            campaign: campaign,
            onDismiss: () {
              wrappedOnDismiss();
              onRemoveOverlay?.call();
            },
            onRemoveOverlay: onRemoveOverlay,
            onCTAClick: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        case 'fullscreen':
        case 'fullpage':
        case 'spinthewheel':
          return FullScreenNudgeRenderer(
            campaign: campaign,
            onDismiss: wrappedOnDismiss,
            onCTAClick: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        case 'modal':
        case 'dialog':
          // Redirect legacy Modals to Floater V2 (which supports overlay/center)
          // Deep copy config to safely modify without side effects
          final Map<String, dynamic> modConfig =
              Map<String, dynamic>.from(campaign.config);

          // Extract global mappedState (often injected by backend for gamification wrappers)
          Map<String, dynamic>? globalMappedState;
          if (modConfig['container'] is List && (modConfig['container'] as List).isNotEmpty) {
             final containerFirst = (modConfig['container'] as List).first;
             if (containerFirst is Map && containerFirst['raw'] is Map && containerFirst['raw']['mappedState'] != null) {
                globalMappedState = Map<String, dynamic>.from(containerFirst['raw']['mappedState']);
             }
          }
          if (globalMappedState == null && modConfig['components'] is List && (modConfig['components'] as List).isNotEmpty) {
             final compFirst = (modConfig['components'] as List).first;
             if (compFirst is Map && compFirst['raw'] is Map && compFirst['raw']['mappedState'] != null) {
                globalMappedState = Map<String, dynamic>.from(compFirst['raw']['mappedState']);
             }
          }

          // 1. Ensure center position if not specified (legacy modal assumption)
          if (modConfig['position'] == null) {
            modConfig['position'] = 'center';
          }

          // 2. Hide expand button for modals (Parity: Modals don't expand like floaters)
          if (modConfig['controls'] == null)
            modConfig['controls'] = <String, dynamic>{};
          if (modConfig['controls'] is Map) {
            final controls = modConfig['controls'] as Map;
            // Safely cast or create expandButton map
            Map<String, dynamic> expandBtn = {};
            if (controls['expandButton'] is Map) {
              expandBtn = Map<String, dynamic>.from(controls['expandButton']);
            }
            expandBtn['show'] = false;

            // Write back carefully
            final newControls = Map<String, dynamic>.from(controls);
            newControls['expandButton'] = expandBtn;
            modConfig['controls'] = newControls;
          }

          final modalConfig = NudgeConfig.fromJson(modConfig);

          var modalLayers = parseCampaignLayers(campaign);
          if (globalMappedState != null) {
            modalLayers = modalLayers.map((l) => Layer.fromJson(
                NinjaLayerUtils.applyMappedData(l.raw, globalMappedState!)
            )).toList();
          }

          final modalScale = DesignScale.fromContext(context);

          return FloaterRenderV2(
            key: ValueKey(campaign.id),
            campaignId: campaign.id,
            layers: modalLayers,
            config: modalConfig,
            scale: modalScale.scaleX,
            scaleY: modalScale.scaleY,
            onDismiss: wrappedOnDismiss,
            onNavigate: (screen) =>
                wrappedOnCTAClick('navigate', {'screen': screen}),
            onInterfaceAction: (id) =>
                wrappedOnCTAClick('interface', {'interfaceId': id}),
            onAction: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );
        // Fallthrough to defaults would also work if we merged case blocks,
        // but explicit handling preserves "modal" intent for future tweaks.

        case 'bottomsheet':
        case 'banner':
        case 'top_banner':
        case 'bottom_banner':
          final bsLayers = parseCampaignLayers(campaign);
          final bsScale = DesignScale.fromContext(context);
          return BottomSheetNudgeRenderer(
            config: NudgeConfig.fromJson(campaign.config),
            layers: bsLayers,
            scale: bsScale.scaleX,
            scaleY: bsScale.scaleY,
            onDismiss: wrappedOnDismiss,
            onNavigate: (screen) => wrappedOnCTAClick('navigate', {'screen': screen}),
            onInterfaceAction: (id) => wrappedOnCTAClick('interface', {'interfaceId': id}),
            onAction: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        case 'tooltip':
          return TooltipRendererV2(
            campaign: campaign,
            onDismiss: wrappedOnDismiss,
            onRemoveOverlay: onRemoveOverlay, // NEW: For interface chaining
            onAction: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        case 'pip':
        case 'floater':
        case 'floating':
          // Reconnected FloaterRenderV2 (V2 Logic Restored)
          // Map Campaign to NudgeConfig
          final config = NudgeConfig.fromJson(campaign.config);

          // Extract global mappedState (often injected by backend for gamification wrappers)
          Map<String, dynamic>? globalMappedState;
          if (campaign.config['container'] is List && (campaign.config['container'] as List).isNotEmpty) {
             final containerFirst = (campaign.config['container'] as List).first;
             if (containerFirst is Map && containerFirst['raw'] is Map && containerFirst['raw']['mappedState'] != null) {
                globalMappedState = Map<String, dynamic>.from(containerFirst['raw']['mappedState']);
                NinjaLog.d('CampaignRenderer', "campaign_renderer: Extracted globalMappedState from container: $globalMappedState");
             }
          }
          if (globalMappedState == null && campaign.config['components'] is List && (campaign.config['components'] as List).isNotEmpty) {
             final compFirst = (campaign.config['components'] as List).first;
             NinjaLog.d('CampaignRenderer', "campaign_renderer: Checking components for globalMappedState...");
             NinjaLog.d('CampaignRenderer', "campaign_renderer: compFirst['raw']: ${compFirst['raw']}");
             if (compFirst is Map && compFirst['raw'] is Map && compFirst['raw']['mappedState'] != null) {
                globalMappedState = Map<String, dynamic>.from(compFirst['raw']['mappedState']);
                NinjaLog.d('CampaignRenderer', "campaign_renderer: Extracted globalMappedState from components: $globalMappedState");
             }
          }

          var layers = parseCampaignLayers(campaign);
          if (globalMappedState != null) {
            NinjaLog.d('CampaignRenderer', "campaign_renderer: Applying globalMappedState to ${layers.length} layers");
            layers = layers.map((l) => Layer.fromJson(
                NinjaLayerUtils.applyMappedData(l.raw, globalMappedState!)
            )).toList();
          } else {
            NinjaLog.d('CampaignRenderer', "campaign_renderer: globalMappedState is NULL! Placeholders will not be replaced.");
          }

          final floaterScale = DesignScale.fromContext(context);

          return FloaterRenderV2(
            key:
                ValueKey(campaign.id), // Fix: Stable Key for State Preservation
            campaignId: campaign.id,
            layers: layers,
            config: config,
            scale: floaterScale.scaleX,
            scaleY: floaterScale.scaleY,
            onDismiss: wrappedOnDismiss,
            onNavigate: (screen) {
              wrappedOnCTAClick('navigate', {'screen': screen});
            },
            onInterfaceAction: (interfaceId) {
              wrappedOnCTAClick('interface', {'interfaceId': interfaceId});
            },

            onAction:
                wrappedOnCTAClick, // Fix: Pass generic actions (submit) to main handler
            onImpression:
                wrappedOnImpression, // Fix: Pass impression handler for single-fire
            // Pass other bridged callbacks if needed
            onLayerSelect: (id) {
              NinjaLog.d('CampaignRenderer', 'Floater V2 Layer Selected: $id');
            },
          );

        /* // Disconnected New Renderer
        return FloaterNudgeRenderer(
          campaign: campaign,
          onDismiss: wrappedOnDismiss,
          onCTAClick: wrappedOnCTAClick,
        );
        */

        case 'story':
        case 'story_carousel':
        case 'storycarousel':
        case 'stories':
        case 'story-carousel':
          return NinjaStoryWrapperRenderer(
            campaign: campaign,
            onDismiss: wrappedOnDismiss,
            onCTAClick: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        case 'inline':
        case 'widget':
          return InlineNudgeRenderer(
            campaign: campaign,
            onDismiss: wrappedOnDismiss,
            onCTAClick: wrappedOnCTAClick,
            onImpression: wrappedOnImpression,
          );

        default:
          // Fallback to floater for unknown types (safest generic renderer)
          NinjaLog.d('CampaignRenderer', 'Unknown nudge type: $type, falling back to floater');
          // Reuse floater logic manually or recursive call? Recursive call might loop if type is mutated.
          // Best to just return empty or generic container.
          return const SizedBox();
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'CampaignRenderer.render');
      return const SizedBox.shrink();
    }
  }

  /// Show campaign as overlay
  /// Returns a function to dismiss the campaign programmatically
  static VoidCallback show({
    required Campaign campaign,
    required BuildContext context,
    OverlayState?
        overlayState, // Allow explicit overlay state for global key usage
    VoidCallback? onImpression,
    VoidCallback? onDismiss,
    Function(String action, Map<String, dynamic>? data)? onCTAClick,
  }) {
    // Determine the true logical type (phase 2 challenge vs phase 1 UI standard configs)
    final type = (campaign.challengeDetails != null)
        ? 'challenge'
        : (campaign.config['type']?.toString().toLowerCase() ?? 'modal');

    // Gamification Rules Engine Evaluator
    if (type == 'challenge' &&
        campaign.challengeDetails?.hideOnCompletion == true) {
      if (_isChallengeFullyCompleted(campaign)) {
        NinjaLog.d('AppNinja', 
            'NinjaCampaignRenderer: 🚫 Challenge [${campaign.id}] fully completed and hideOnCompletion is true. Skipping render.');
        return () {};
      }
    }

    NinjaLog.d('AppNinja', 
        'NinjaCampaignRenderer: 🎯 Resolving presentation for type: "$type"');

    // We use a late variable to hold the final dismiss function so closures can unregister it
    late VoidCallback externalDismissFn;

    // For modal/dialog/bottomsheet types
    if ([
      'bottomsheet',
      'fullscreen',
      'fullpage',
      'spinthewheel',
      'story',
      'story_carousel',
      'storycarousel',
      'stories',
      'story-carousel'
    ].contains(type)) {
      final overlayColor = _parseColor(campaign.config['overlay']?['color']);
      final overlayOpacity =
          (campaign.config['overlay']?['opacity'] as num?)?.toDouble() ?? 0.5;
      final barrierColor =
          overlayColor?.withOpacity(overlayOpacity) ?? Colors.black54;

      final navKey = AppNinja.navigatorKey;
      final NavigatorState? navState = navKey.currentState;

      if (navState != null && navState.mounted) {
        NinjaLog.d('CampaignRenderer', 'NinjaCampaignRenderer: ✅ Using direct NavigatorState.push() for $type');
        
        navState.push<void>(
          PageRouteBuilder<void>(
            opaque: false,
            barrierDismissible: campaign.config['dismissible'] != false,
            // FIX: Barrier is transparent — each renderer (BottomSheet, FullScreen)
            // handles its own overlay/backdrop with fade-in animation.
            // This prevents the dim overlay from appearing during asset preloading.
            barrierColor: Colors.transparent,
            barrierLabel: 'NinjaCampaign',
            pageBuilder: (dialogContext, animation, secondaryAnimation) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: render(
                  campaign: campaign,
                  context: dialogContext,
                  onImpression: onImpression,
                  onDismiss: () {
                    Navigator.of(dialogContext).pop();
                    onDismiss?.call();
                    AppNinja.unregisterActiveNudge(externalDismissFn);
                  },
                  onRemoveOverlay: () {
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.of(dialogContext).pop();
                    }
                    AppNinja.unregisterActiveNudge(externalDismissFn);
                  },
                  onCTAClick: onCTAClick,
                ),
              );
            },
          ),
        );

        externalDismissFn = () {
          if (navState.mounted && navState.canPop()) {
            navState.pop();
          }
          AppNinja.unregisterActiveNudge(externalDismissFn);
        };
        AppNinja.registerActiveNudge(externalDismissFn);
        return externalDismissFn;
      }

      BuildContext dialogRootContext = context;
      if (navKey.currentState?.overlay?.context != null &&
          navKey.currentState!.overlay!.context.mounted) {
        dialogRootContext = navKey.currentState!.overlay!.context;
      } else if (navKey.currentContext != null &&
          navKey.currentContext!.mounted) {
        dialogRootContext = navKey.currentContext!;
      }

      bool hasNavigator = false;
      try {
        Navigator.of(dialogRootContext);
        hasNavigator = true;
      } catch (_) {
        hasNavigator = false;
      }

      if (hasNavigator) {
        NinjaLog.d('CampaignRenderer', 'NinjaCampaignRenderer: ✅ Using showGeneralDialog for $type');
        showGeneralDialog<void>(
          context: dialogRootContext,
          barrierDismissible: campaign.config['dismissible'] != false,
          barrierLabel: 'NinjaCampaign',
          // FIX: Transparent barrier — renderers handle their own overlays
          barrierColor: Colors.transparent,
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: render(
                campaign: campaign,
                context: dialogContext,
                onImpression: onImpression,
                onDismiss: () {
                  Navigator.of(dialogContext).pop();
                  onDismiss?.call();
                  AppNinja.unregisterActiveNudge(externalDismissFn);
                },
                onRemoveOverlay: () {
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop();
                  }
                  AppNinja.unregisterActiveNudge(externalDismissFn);
                },
                onCTAClick: onCTAClick,
              ),
            );
          },
        );

        externalDismissFn = () {
          if (Navigator.canPop(dialogRootContext)) {
            Navigator.of(dialogRootContext).pop();
          }
          AppNinja.unregisterActiveNudge(externalDismissFn);
        };
        AppNinja.registerActiveNudge(externalDismissFn);
        return externalDismissFn;
      }

      NinjaLog.d('CampaignRenderer', 'NinjaCampaignRenderer: ⚠️ No Navigator found, using overlay fallback for $type');
      try {
        final overlay = overlayState ?? Overlay.of(context);
        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (overlayCtx) => Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: barrierColor,
              child: render(
                campaign: campaign,
                context: overlayCtx,
                onImpression: onImpression,
                onDismiss: () {
                  if (entry.mounted) {
                    entry.remove();
                  }
                  onDismiss?.call();
                  AppNinja.unregisterActiveNudge(externalDismissFn);
                },
                onRemoveOverlay: () {
                  if (entry.mounted) {
                    entry.remove();
                  }
                  AppNinja.unregisterActiveNudge(externalDismissFn);
                },
                onCTAClick: onCTAClick,
              ),
            ),
          ),
        );
        overlay.insert(entry);
        
        externalDismissFn = () {
          if (entry.mounted) {
            entry.remove();
          }
          AppNinja.unregisterActiveNudge(externalDismissFn);
        };
        AppNinja.registerActiveNudge(externalDismissFn);
        return externalDismissFn;
      } catch (e) {
        NinjaLog.d('CampaignRenderer', 'NinjaCampaignRenderer: ❌ All rendering strategies failed for $type: $e');
        return () {};
      }
    }
    // For floating types, use overlay (Includes Link converted Modals)
    else if ([
      'pip',
      'floater',
      'floating',
      'banner',
      'tooltip',
      'modal',
      'dialog',
      'challenge' // FIX: Allow challenge to be inserted into the overlay instead of falling through to Inline widget requirement
    ].contains(type)) {
      final overlay = overlayState ?? Overlay.of(context);

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => render(
          campaign: campaign,
          context: context,
          onImpression: onImpression,
          onDismiss: () {
            if (entry.mounted) {
              entry.remove();
            }
            onDismiss?.call();
            AppNinja.unregisterActiveOverlay(campaign.id);
            AppNinja.unregisterActiveNudge(externalDismissFn);
          },
          onRemoveOverlay: () {
            if (entry.mounted) {
              entry.remove();
            }
            AppNinja.unregisterActiveOverlay(campaign.id);
            AppNinja.unregisterActiveNudge(externalDismissFn);
          },
          onCTAClick: onCTAClick,
        ),
      );

      overlay.insert(entry);
      AppNinja.registerActiveOverlay(campaign.id, entry);

      externalDismissFn = () {
        if (entry.mounted) {
          entry.remove();
        }
        AppNinja.unregisterActiveOverlay(campaign.id);
        AppNinja.unregisterActiveNudge(externalDismissFn);
      };
      AppNinja.registerActiveNudge(externalDismissFn);
      return externalDismissFn;
    }
    // For inline types, show as widget (requires parent widget integration)
    else {
      NinjaLog.d('CampaignRenderer', 'Inline nudge type requires direct widget integration');
      return () {};
    }
  }

  static Color? _parseColor(dynamic color) {
    if (color == null) return null;
    if (color is Color) return color;
    final colorStr = color.toString();
    if (colorStr.startsWith('#')) {
      final hexColor = colorStr.replaceFirst('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    }
    return null;
  }

  /// Evaluates SDK local SQLite memory map to determine if a Challenge is functionally 100% complete
  static bool _isChallengeFullyCompleted(Campaign campaign) {
    final config = campaign.challengeDetails;
    if (config == null) return false;

    // A challenge is completed if ALL tasks have fully exhausted their completion limits.
    for (var task in config.tasks) {
      // Determine how many full cycles are required for this task
      int requiredCycles = 1;
      if (task.logic.limits['attemptFrequency'] == 'once') {
        requiredCycles = 1;
      } else if (task.logic.limits['completionLimit'] != null &&
          task.logic.limits['completionLimit'] is num) {
        requiredCycles = (task.logic.limits['completionLimit'] as num).toInt();
      } else if (task.logic.limits['attemptFrequency'] == 'always') {
        // BUG FIX: Infinite tasks can NEVER be fully completed for hideOnCompletion.
        return false;
      }

      for (var group in task.logic.eventGroups) {
        bool groupComplete = false;

        if (group.operator == 'OR') {
          // Need at least one condition to have completed ALL required cycles
          for (var condition in group.events) {
            int cCount = NinjaChallengeManager.getEventProgress(
                campaign.id, task, condition.eventId);
            int totalRequired = condition.count * requiredCycles;
            if (cCount >= totalRequired) {
              groupComplete = true;
              break;
            }
          }
        } else {
          // AND logic — all conditions must have completed ALL required cycles
          groupComplete = true;
          for (var condition in group.events) {
            int cCount = NinjaChallengeManager.getEventProgress(
                campaign.id, task, condition.eventId);
            int totalRequired = condition.count * requiredCycles;
            if (cCount < totalRequired) {
              groupComplete = false;
              break;
            }
          }
        }

        if (!groupComplete) {
          return false; // Found an incomplete group
        }
      }
    }
    return true;
  }
}

class NinjaCampaignPreloader extends StatefulWidget {
  final Campaign campaign;
  final WidgetBuilder builder;

  const NinjaCampaignPreloader({
    Key? key,
    required this.campaign,
    required this.builder,
  }) : super(key: key);

  @override
  State<NinjaCampaignPreloader> createState() => _NinjaCampaignPreloaderState();
}

class _NinjaCampaignPreloaderState extends State<NinjaCampaignPreloader> {
  bool _isLoaded = false;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _preloadAssets();
    }
  }

  Future<void> _preloadAssets() async {
    List<String> imageUrls = _extractImageUrls(widget.campaign);
    List<String> fontFamilies = _extractFontFamilies(widget.campaign);
    Map<String, String> customFonts = _extractCustomFonts(widget.campaign);
    
    NinjaLog.d('CampaignRenderer', 'InAppNinja: ⏳ Preloading ${imageUrls.length} assets and ${fontFamilies.length} fonts for campaign "${widget.campaign.title}"');

    List<Future> futures = [];

    // Add custom enterprise font preloading futures
    for (var entry in customFonts.entries) {
      futures.add(EnterpriseFontManager.loadFont(entry.key, entry.value));
    }
    
    // Add image preloading futures
    for (String url in imageUrls) {
      try {
        if (url.startsWith('http')) {
          futures.add(precacheImage(NetworkImage(url), context).catchError((e) {
            NinjaLog.d('CampaignRenderer', 'InAppNinja: ❌ Error precaching NetworkImage ($url): $e');
            return null;
          }));
        } else if (url.startsWith('data:')) {
          final base64String = url.split(',').last.replaceAll(RegExp(r'\s+'), '');
          futures.add(precacheImage(MemoryImage(base64Decode(base64String)), context).catchError((e) {
            NinjaLog.d('CampaignRenderer', 'InAppNinja: ❌ Error precaching MemoryImage: $e');
            return null;
          }));
        }
      } catch (e) {
        NinjaLog.d('CampaignRenderer', 'InAppNinja: ❌ Exception adding image preloading future: $e');
      }
    }

    // Add font preloading futures
    if (fontFamilies.isNotEmpty) {
      List<TextStyle> fontStyles = [];
      for (String font in fontFamilies) {
        if (font.toLowerCase() != 'inherit' && font.isNotEmpty && !customFonts.containsKey(font)) {
          try {
            final style = GoogleFonts.getFont(font);
            fontStyles.add(style);
          } catch (e) {
            NinjaLog.d('CampaignRenderer', 'InAppNinja: ⚠️ Font family "$font" not found in GoogleFonts: $e');
          }
        }
      }
      if (fontStyles.isNotEmpty) {
        NinjaLog.d('CampaignRenderer', 'InAppNinja: ⏳ Preloading Google Fonts: $fontFamilies');
        futures.add(GoogleFonts.pendingFonts(fontStyles).catchError((e) {
          NinjaLog.d('CampaignRenderer', 'InAppNinja: ❌ Error preloading Google Fonts: $e');
          return null;
        }));
      }
    }

    if (futures.isNotEmpty) {
      final startTime = DateTime.now();
      try {
        // Don't wait forever, max 4 seconds delay for complete loading
        await Future.any([
          Future.wait(futures),
          Future.delayed(const Duration(seconds: 4))
        ]);
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        NinjaLog.d('CampaignRenderer', 'InAppNinja: ✅ Asset and font preloading complete in ${duration}ms');
      } catch (e) {
        NinjaLog.d('CampaignRenderer', 'InAppNinja: ⚠️ Error waiting for preloading futures: $e');
      }
    } else {
      NinjaLog.d('CampaignRenderer', 'InAppNinja: ℹ️ No assets or fonts to preload for campaign "${widget.campaign.title}"');
    }

    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  Map<String, String> _extractCustomFonts(Campaign campaign) {
    Map<String, String> customFonts = {};

    void extractFromLayer(dynamic element) {
      if (element is Map) {
        final content = element['content'];
        if (content is Map && content['fontFamily'] != null && content['fontUrl'] != null) {
          final font = content['fontFamily'].toString().trim();
          final fontUrl = content['fontUrl'].toString().trim();
          // Custom fonts have a .ttf or .woff2 URL that doesn't belong to Google Fonts CDN
          if (font.isNotEmpty && fontUrl.isNotEmpty && !fontUrl.contains('fonts.googleapis.com')) {
            customFonts[font] = fontUrl;
          }
        }
        element.forEach((key, value) {
          if (value is Map || value is List) extractFromLayer(value);
        });
      } else if (element is List) {
        for (var item in element) extractFromLayer(item);
      }
    }

    extractFromLayer(campaign.config);
    if (campaign.layers != null) extractFromLayer(campaign.layers);
    if (campaign.interfaces != null) extractFromLayer(campaign.interfaces);
    if (campaign.stories != null) extractFromLayer(campaign.stories);

    return customFonts;
  }

  List<String> _extractImageUrls(Campaign campaign) {
    Set<String> urls = {};

    bool isImageUrl(String url) {
      if (url.isEmpty) return false;
      final lower = url.toLowerCase();
      // Filter out typical video formats
      if (lower.endsWith('.mp4') ||
          lower.endsWith('.webm') ||
          lower.endsWith('.avi') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.mkv') ||
          lower.endsWith('.3gp') ||
          lower.endsWith('.m4v')) {
        return false;
      }
      return true;
    }

    void extractFromLayer(dynamic element) {
      if (element is Map) {
        // 1. Look for style background images
        final style = element['style'];
        if (style is Map) {
          final bgKeys = ['backgroundImage', 'background_image'];
          for (var key in bgKeys) {
            if (style[key] != null) {
              String bg = style[key].toString().trim();
              if (bg.startsWith('url(')) {
                String url = bg.replaceAll('url(', '').replaceAll(')', '').replaceAll('"', '').replaceAll("'", "").trim();
                if (url.isNotEmpty && isImageUrl(url)) urls.add(url);
              } else if ((bg.startsWith('http') || bg.startsWith('data:')) && isImageUrl(bg)) {
                urls.add(bg);
              }
            }
          }
        }

        // 2. Look for image properties in any map keys
        final imageUrlKeys = [
          'imageUrl', 'url', 'coverImage', 'cursorImage', 
          'pointerImage', 'spinButtonImage', 'wheelImage', 
          'confettiImage', 'backgroundImageUrl', 'backgroundImage',
          'background_image', 'arrowImageUrl', 'arrow_image_url',
          'image', 'iconUrl', 'icon_url', 'icon', 'rewardImage', 'thumbnail'
        ];

        for (var key in imageUrlKeys) {
          if (element[key] != null) {
            final val = element[key].toString().trim();
            if (val.isNotEmpty && (val.startsWith('http') || val.startsWith('data:')) && isImageUrl(val)) {
              urls.add(val);
            }
          }
        }

        // 3. Special case: Spin The Wheel sections list
        if (element['sections'] is List) {
          for (var section in element['sections']) {
            if (section is Map && section['image'] != null) {
              final img = section['image'].toString().trim();
              if (img.isNotEmpty && (img.startsWith('http') || img.startsWith('data:')) && isImageUrl(img)) {
                urls.add(img);
              }
            }
          }
        }

        // Recursively traverse all entries
        element.forEach((key, value) {
          if (value is Map || value is List) {
            extractFromLayer(value);
          }
        });
      } else if (element is List) {
        for (var item in element) {
          extractFromLayer(item);
        }
      }
    }

    // Scan config directly (often contains top-level or nudge-specific config keys)
    extractFromLayer(campaign.config);

    // Scan layers recursively
    if (campaign.layers != null) {
      extractFromLayer(campaign.layers);
    }

    // Scan sub-interfaces recursively
    if (campaign.interfaces != null) {
      extractFromLayer(campaign.interfaces);
    }

    // Scan stories recursively
    if (campaign.stories != null) {
      extractFromLayer(campaign.stories);
    }

    // Scan challenge details if present
    if (campaign.challengeDetails != null) {
      extractFromLayer(campaign.challengeDetails!.toJson());
    }

    // Filter out empty and return list
    return urls.where((url) => url.isNotEmpty).toList();
  }

  List<String> _extractFontFamilies(Campaign campaign) {
    Set<String> fonts = {};

    void extractFromLayer(dynamic element) {
      if (element is Map) {
        // 1. Look for fontFamily in style or content
        final style = element['style'];
        if (style is Map && style['fontFamily'] != null) {
          final font = style['fontFamily'].toString().trim();
          if (font.isNotEmpty) fonts.add(font);
        }
        
        final content = element['content'];
        if (content is Map && content['fontFamily'] != null) {
          final font = content['fontFamily'].toString().trim();
          if (font.isNotEmpty) fonts.add(font);
        }
        
        // Also check if we have fontUrl from which we can extract font family
        if (content is Map && content['fontUrl'] != null) {
          final fontUrl = content['fontUrl'].toString().trim();
          if (fontUrl.isNotEmpty) {
            final urlFamily = NinjaLayerUtils.getFontFamilyFromUrl(fontUrl);
            if (urlFamily != null && urlFamily.isNotEmpty) {
              fonts.add(urlFamily);
            }
          }
        }

        // Recursively traverse
        element.forEach((key, value) {
          if (value is Map || value is List) {
            extractFromLayer(value);
          }
        });
      } else if (element is List) {
        for (var item in element) {
          extractFromLayer(item);
        }
      }
    }

    extractFromLayer(campaign.config);
    if (campaign.layers != null) {
      extractFromLayer(campaign.layers);
    }
    if (campaign.interfaces != null) {
      extractFromLayer(campaign.interfaces);
    }
    if (campaign.stories != null) {
      extractFromLayer(campaign.stories);
    }

    return fonts.where((f) => f.toLowerCase() != 'inherit' && f.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      // Return empty until loaded, so everything mounts together visually
      return const SizedBox.shrink();
    }
    return widget.builder(context);
  }
}

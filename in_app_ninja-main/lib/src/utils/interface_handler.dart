import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../renderers/campaign_renderer.dart';
import 'ninja_sdk_safe.dart';
import './ninja_logger.dart';

/// InterfaceHandler - Centralized handler for opening sub-interfaces
/// 
/// This utility finds an interface by ID from the parent campaign
/// and renders it as a new overlay using NinjaCampaignRenderer.
class InterfaceHandler {
  static void show({
    required String interfaceId,
    required Campaign parentCampaign,
    required BuildContext context,
    VoidCallback? onDismiss,
    Function(String action, Map<String, dynamic>? data)? onCTAClick,
  }) {
    try {
    NinjaLog.d('AppNinja', 'InAppNinja: 🎭 InterfaceHandler.show called with interfaceId: $interfaceId');
    
    final interfaces = parentCampaign.interfaces;
    NinjaLog.d('AppNinja', 'InAppNinja: 🎭 Available interfaces: ${interfaces?.length ?? 0}');
    
    if (interfaces != null) {
      for (var i = 0; i < interfaces.length; i++) {
        NinjaLog.d('AppNinja', 'InAppNinja: 🎭   Interface[$i]: id=${interfaces[i]['id']}, name=${interfaces[i]['name']}');
      }
    }
    
    if (interfaces == null || interfaces.isEmpty) {
      NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ No interfaces in campaign');
      return;
    }

    // Find interface by ID
    final interfaceData = interfaces.firstWhere(
      (i) => i['id'] == interfaceId,
      orElse: () => <String, dynamic>{},
    );

    if (interfaceData.isEmpty) {
      NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ Interface $interfaceId not found in ${interfaces.length} interfaces');
      return;
    }

    final type = interfaceData['nudgeType']?.toString() ?? 'modal';
    
    // Build config from interface's type-specific config
    Map<String, dynamic> typeConfig = {};
    switch (type) {
      case 'modal':
        typeConfig = Map<String, dynamic>.from(interfaceData['modalConfig'] ?? {});
        break;
      case 'bottomsheet':
        typeConfig = Map<String, dynamic>.from(interfaceData['bottomSheetConfig'] ?? {});
        break;
      case 'banner':
        typeConfig = Map<String, dynamic>.from(interfaceData['bannerConfig'] ?? {});
        break;
      case 'scratchcard':  // Dashboard uses 'scratchcard' without underscore
      case 'scratch_card':  // SDK uses 'scratch_card' with underscore - support both
        typeConfig = Map<String, dynamic>.from(interfaceData['scratchCardConfig'] ?? {});
        break;
      case 'tooltip':
        typeConfig = Map<String, dynamic>.from(interfaceData['tooltipConfig'] ?? {});
        break;
      case 'pip':
        typeConfig = Map<String, dynamic>.from(interfaceData['pipConfig'] ?? {});
        break;
      case 'floater':
        typeConfig = Map<String, dynamic>.from(interfaceData['floaterConfig'] ?? {});
        break;
      case 'story':
        typeConfig = Map<String, dynamic>.from(interfaceData['storyConfig'] ?? {});
        break;
      case 'inline':
        typeConfig = Map<String, dynamic>.from(interfaceData['inlineConfig'] ?? {});
        break;
      default:
        NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ Unknown interface type: $type, using empty config');
    }
    
    // Create a mini-campaign from interface data
    final interfaceCampaign = Campaign(
      id: interfaceId,
      title: interfaceData['name']?.toString() ?? 'Interface',
      type: type,
      config: {
        'type': type,
        'components': interfaceData['layers'],
        ...typeConfig,
      },
      layers: interfaceData['layers'] is List 
          ? List<dynamic>.from(interfaceData['layers']) 
          : null,
      // CRITICAL FIX: Pass parent interfaces to allow interface chaining (1→2→3→4)
      // Previously this was null which broke chaining - Interface 1 couldn't open Interface 2
      interfaces: parentCampaign.interfaces,
    );

    NinjaLog.d('AppNinja', 'InAppNinja: 🎯 Opening interface: $interfaceId (type: $type)');
    
    NinjaCampaignRenderer.show(
      campaign: interfaceCampaign,
      context: context,
      onDismiss: () {
        NinjaLog.d('AppNinja', 'InAppNinja: Interface $interfaceId dismissed');
        onDismiss?.call();
      },
      onCTAClick: onCTAClick,
    );
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'InterfaceHandler.show');
    }
  }

  /// Show interface with parent dismiss handling
  /// 
  /// PARITY FIX: In Dashboard, when interface opens, main campaign is hidden (not permanently closed).
  /// In SDK, we need to:
  /// 1. Dismiss parent overlay (remove from view)
  /// 2. Show interface
  /// 3. When interface closes, call the final onDismiss
  static void showWithParentDismiss({
    required String interfaceId,
    required Campaign parentCampaign,
    required BuildContext context,
    VoidCallback? parentDismiss, // Called immediately to clean up parent
    VoidCallback? onInterfaceDismiss, // Called when interface finally closes
    Function(String action, Map<String, dynamic>? data)? onCTAClick,
  }) {
    try {
    NinjaLog.d('AppNinja', 'InAppNinja: 🎭 InterfaceHandler.showWithParentDismiss called');
    
    // First, dismiss the parent campaign overlay (removes it from view)
    parentDismiss?.call();
    
    // Then show the interface with the final dismiss callback
    show(
      interfaceId: interfaceId,
      parentCampaign: parentCampaign,
      context: context,
      onDismiss: onInterfaceDismiss,
      onCTAClick: onCTAClick,
    );
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'InterfaceHandler.showWithParentDismiss');
    }
  }
}

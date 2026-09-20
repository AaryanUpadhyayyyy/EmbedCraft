import 'package:flutter/material.dart';
import '../../models/campaign.dart';
import '../../utilities/sharedHelper/campaign_layers.dart';
import '../../utilities/sharedHelper/design_scale.dart';
import 'Floater_render_v2.dart';
import '../../models/nudge_model.dart';

/// Inline/Widget Nudge Renderer
///
/// Renders a campaign as an inline (embedded) widget rather than an overlay.
/// Designed for campaigns with type 'inline' or 'widget'.
class InlineNudgeRenderer extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onDismiss;
  final Function(String action, Map<String, dynamic>? data)? onCTAClick;
  final VoidCallback? onImpression; // FIX: Added onImpression

  const InlineNudgeRenderer({
    Key? key,
    required this.campaign,
    this.onDismiss,
    this.onCTAClick,
    this.onImpression,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = NudgeConfig.fromJson(campaign.config);
    final layers = parseCampaignLayers(campaign);
    final scale = DesignScale.fromContext(context);

    return FloaterRenderV2(
      key: ValueKey('inline_${campaign.id}'),
      layers: layers,
      config: config,
      scale: scale.scaleX,
      scaleY: scale.scaleY,
      onDismiss: onDismiss,
      onNavigate: (screen) => onCTAClick?.call('navigate', {'screen': screen}),
      onInterfaceAction: (id) => onCTAClick?.call('interface', {'interfaceId': id}),
      onAction: onCTAClick,
      onImpression: onImpression, // FIX: Pass down impression tracking
    );
  }
}

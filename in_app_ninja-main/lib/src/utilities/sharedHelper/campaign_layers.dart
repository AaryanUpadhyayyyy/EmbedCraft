import '../../models/campaign.dart';
import '../../models/nudge_model.dart';

/// Maps [Campaign.layers] JSON to typed [Layer] list (shared by renderers).
List<Layer> parseCampaignLayers(Campaign campaign) {
  final raw = campaign.layers;
  if (raw == null || raw.isEmpty) return [];
  return raw.map((l) {
    final map = l is Map<String, dynamic>
        ? l
        : Map<String, dynamic>.from(l as Map);
    return Layer.fromJson(map);
  }).toList();
}

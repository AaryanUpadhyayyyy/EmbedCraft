import 'challenge_model.dart';

/// Campaign model representing a nudge/campaign fetched from the server
class Campaign {
  final String id;
  final String title;
  final String? description;
  final String type; // 'bottom_sheet', 'modal', 'pip', 'scratch_card', 'banner', 'tooltip', 'story', 'inline'
  final Map<String, dynamic> config;
  final List<dynamic>? targeting; // Changed from Map to List
  final List<dynamic>? triggers; // Added
  final String? trigger; // ✅ FIX: Single trigger string from backend
  final List<dynamic>? layers;
  final List<dynamic>? stories; // NEW: Story Array from Dashboard
  final List<Map<String, dynamic>>? interfaces; // NEW: Sub-interfaces for linked UI flows
  final ChallengeConfig? challengeDetails; // NEW: Phase 2 Gamification engine config
  final String? variant;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final int? priority;
  final bool overrideGlobal;

  Campaign({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.config,
    this.targeting,
    this.triggers,
    this.trigger,
    this.layers,
    this.stories,
    this.interfaces,
    this.challengeDetails,
    this.variant,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.priority,
    this.overrideGlobal = false,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['campaign_name']?.toString() ?? json['title']?.toString() ?? json['name']?.toString() ?? 'Campaign',
      description: json['description']?.toString(),
      type: json['config']?['type']?.toString() ?? json['type']?.toString() ?? 'modal',
      config: Map<String, dynamic>.from(json['config'] ?? json['content'] ?? {})..addAll({
        if (json['display_rules'] != null) 'display_rules': json['display_rules'],
        if (json['displayRules'] != null) 'displayRules': json['displayRules'],
      }),
      targeting: json['targeting'] != null && json['targeting'] is List
          ? List<dynamic>.from(json['targeting'])
          : null,
      triggers: json['triggers'] != null && json['triggers'] is List
          ? List<dynamic>.from(json['triggers'])
          : null,
      // ✅ FIX: Backend uses 'trigger_event', Dashboard uses 'trigger'
      trigger: json['trigger']?.toString() ?? json['trigger_event']?.toString(),
      layers: json['layers'] != null && json['layers'] is List
          ? List<dynamic>.from(json['layers'])
          : null,
      stories: json['stories'] != null && json['stories'] is List
          ? List<dynamic>.from(json['stories'])
          : null,
      interfaces: json['interfaces'] != null && json['interfaces'] is List
          ? List<Map<String, dynamic>>.from(
              (json['interfaces'] as List).map((e) => Map<String, dynamic>.from(e))
            )
          : null,
      challengeDetails: json['challengeDetails'] != null && json['challengeDetails'] is Map
          ? ChallengeConfig.fromJson(Map<String, dynamic>.from(json['challengeDetails']))
          : null,
      variant: json['variant']?.toString(),
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      status: json['status']?.toString(),
      priority: () {
        final r = json['priority'] ??
                  json['displayRules']?['priority'] ??
                  json['display_rules']?['priority'];
        if (r != null) return int.tryParse(r.toString()) ?? 0;
        
        final config = json['config'];
        if (config is Map) {
          final priorityVal = config['displayRules']?['priority'] ?? config['display_rules']?['priority'];
          if (priorityVal != null) {
            return int.tryParse(priorityVal.toString()) ?? 0;
          }
        }
        return 0;
      }(),
      overrideGlobal: () {
        final og = json['displayRules']?['overrideGlobal'] ?? json['display_rules']?['overrideGlobal'];
        if (og != null) return og == true || og == 'true';
        final config = json['config'];
        if (config is Map) {
          final ogVal = config['displayRules']?['overrideGlobal'] ?? config['display_rules']?['overrideGlobal'];
          return ogVal == true || ogVal == 'true';
        }
        return false;
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'config': config,
      'targeting': targeting,
      'triggers': triggers,
      'trigger': trigger,
      'layers': layers,
      'stories': stories,
      'interfaces': interfaces,
      'challengeDetails': challengeDetails?.toJson(),
      'variant': variant,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
      'priority': priority,
    };
  }
}

/// Represents a Gamified Challenge's reward payload
class ChallengeTaskReward {
  final List<dynamic> rewardGroups;

  ChallengeTaskReward({required this.rewardGroups});

  factory ChallengeTaskReward.fromJson(Map<String, dynamic> json) {
    return ChallengeTaskReward(
      rewardGroups: json['rewardGroups'] != null && json['rewardGroups'] is List
          ? List<dynamic>.from(json['rewardGroups'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardGroups': rewardGroups,
    };
  }
}

/// Represents an individual event requirement within a task
class ChallengeEventCondition {
  final String eventId;
  final String operator;
  final int count;
  final List<dynamic>? filters;

  ChallengeEventCondition({
    required this.eventId,
    required this.operator,
    required this.count,
    this.filters,
  });

  factory ChallengeEventCondition.fromJson(Map<String, dynamic> json) {
    return ChallengeEventCondition(
      eventId: json['eventId']?.toString() ?? '',
      operator: json['operator']?.toString() ?? 'equals',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '1') ?? 1,
      filters: json['filters'] != null && json['filters'] is List ? List<dynamic>.from(json['filters']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'operator': operator,
      'count': count,
      'filters': filters,
    };
  }
}

/// Represents an event group with a boolean operator (AND/OR)
class ChallengeEventGroup {
  final String operator;
  final List<ChallengeEventCondition> events;

  ChallengeEventGroup({
    required this.operator,
    required this.events,
  });

  factory ChallengeEventGroup.fromJson(Map<String, dynamic> json) {
    return ChallengeEventGroup(
      operator: json['operator']?.toString() ?? 'AND',
      events: json['events'] != null && json['events'] is List
          ? (json['events'] as List).map((e) => ChallengeEventCondition.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operator': operator,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents the logic constraints for a challenge task
class ChallengeTaskLogic {
  final List<ChallengeEventGroup> eventGroups;
  final String userTrigger;
  final List<dynamic>? userFilters;
  final Map<String, dynamic> limits;

  ChallengeTaskLogic({
    required this.eventGroups,
    required this.userTrigger,
    this.userFilters,
    required this.limits,
  });

  factory ChallengeTaskLogic.fromJson(Map<String, dynamic> json) {
    return ChallengeTaskLogic(
      eventGroups: json['eventGroups'] != null && json['eventGroups'] is List
          ? (json['eventGroups'] as List).map((e) => ChallengeEventGroup.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      userTrigger: json['userTrigger']?.toString() ?? 'all_users',
      userFilters: json['userFilters'] != null && json['userFilters'] is List ? List<dynamic>.from(json['userFilters']) : null,
      limits: json['limits'] != null && json['limits'] is Map
          ? Map<String, dynamic>.from(json['limits'])
          : {'attemptFrequency': 'always'},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventGroups': eventGroups.map((e) => e.toJson()).toList(),
      'userTrigger': userTrigger,
      'userFilters': userFilters,
      'limits': limits,
    };
  }
}

/// Represents an individual task in a Gamified Challenge
class ChallengeTask {
  final String id;
  final String title;
  final ChallengeTaskLogic logic;
  final ChallengeTaskReward reward;
  final String? completionNudgeId; // References a CampaignInterface.id for task completion notification

  ChallengeTask({
    required this.id,
    required this.title,
    required this.logic,
    required this.reward,
    this.completionNudgeId,
  });

  factory ChallengeTask.fromJson(Map<String, dynamic> json) {
    return ChallengeTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      logic: ChallengeTaskLogic.fromJson(Map<String, dynamic>.from(json['logic'] ?? {})),
      reward: ChallengeTaskReward.fromJson(Map<String, dynamic>.from(json['reward'] ?? {})),
      completionNudgeId: json['completionNudgeId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'logic': logic.toJson(),
      'reward': reward.toJson(),
      if (completionNudgeId != null) 'completionNudgeId': completionNudgeId,
    };
  }
}

/// Represents the overarching gamification configuration for a challenge campaign
class ChallengeConfig {
  final String executionOrder; // 'sequential' | 'any_order'
  final bool allowMultipleSimultaneousTasks;
  final bool hideOnCompletion;
  final List<ChallengeTask> tasks;

  ChallengeConfig({
    required this.executionOrder,
    required this.allowMultipleSimultaneousTasks,
    required this.hideOnCompletion,
    required this.tasks,
  });

  factory ChallengeConfig.fromJson(Map<String, dynamic> json) {
    return ChallengeConfig(
      executionOrder: json['executionOrder']?.toString() ?? 'sequential',
      allowMultipleSimultaneousTasks: json['allowMultipleSimultaneousTasks'] == true,
      hideOnCompletion: json['hideOnCompletion'] == true,
      tasks: json['tasks'] != null && json['tasks'] is List
          ? (json['tasks'] as List).map((e) => ChallengeTask.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executionOrder': executionOrder,
      'allowMultipleSimultaneousTasks': allowMultipleSimultaneousTasks,
      'hideOnCompletion': hideOnCompletion,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }
}

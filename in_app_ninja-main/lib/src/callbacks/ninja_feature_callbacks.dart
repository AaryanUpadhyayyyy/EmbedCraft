/// Strongly typed feature callbacks for AppNinja SDK.
/// Matches the architecture of nudgecore_v2.

abstract class NinjaBaseCallback {
  String get action;
  Map<String, dynamic>? get data;
}

class NinjaCoreCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaCoreCallback(this.action, [this.data]);
}

class NinjaNudgesCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaNudgesCallback(this.action, [this.data]);
}

class NinjaGamificationCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaGamificationCallback(this.action, [this.data]);
}

class NinjaSpinTheWheelCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaSpinTheWheelCallback(this.action, [this.data]);
}

class NinjaStoriesCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaStoriesCallback(this.action, [this.data]);
}

class NinjaQuizCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaQuizCallback(this.action, [this.data]);
}

class NinjaSurveyCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaSurveyCallback(this.action, [this.data]);
}

class NinjaLeaderboardCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaLeaderboardCallback(this.action, [this.data]);
}

class NinjaGlobalExperienceCallback implements NinjaBaseCallback {
  @override
  final String action;
  @override
  final Map<String, dynamic>? data;

  NinjaGlobalExperienceCallback(this.action, [this.data]);
}

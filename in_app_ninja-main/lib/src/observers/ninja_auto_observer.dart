import 'package:flutter/material.dart';
import '../app_ninja.dart';
import '../utils/ninja_sdk_safe.dart';
import '../utils/ninja_logger.dart';

/// Auto NavigatorObserver for InAppNinja SDK
///
/// Automatically tracks screen views when routes change
/// Add to MaterialApp.navigatorObservers for auto-tracking
///
/// Example:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [NinjaAutoObserver()],
/// )
/// ```
class NinjaAutoObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreenView(newRoute);
    }
  }

  void _trackScreenView(Route route) {
    try {
      final screenName = route.settings.name ??
          route.runtimeType.toString().replaceAll('MaterialPageRoute', '');

      if (screenName.isEmpty || screenName == 'null') return;

      AppNinja.track(
        '${screenName}_Viewed',
        properties: {
          'screen_name': screenName,
          'timestamp': DateTime.now().toIso8601String(),
          'auto_tracked': true,
        },
      );

      NinjaLog.v('NinjaAutoObserver', '📱 Auto-tracked: ${screenName}_Viewed');

      ninjaSdkSafeUnawaited(
        AppNinja.autoFetchCampaigns(),
        context: 'NinjaAutoObserver.autoFetchCampaigns',
      );
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'NinjaAutoObserver._trackScreenView');
    }
  }
}

import 'package:flutter/foundation.dart';

// ignore: avoid_classes_with_only_static_members
/// Centralized logger for the InAppNinja SDK.
///
/// All SDK log output is routed through this class.
/// Logs are only emitted when [AppNinja.debugMode] is `true`,
/// making them invisible in production and easily searchable in debug.
///
/// Format: `AppNinja: [<tag>] <message>`
///
/// Usage:
/// ```dart
/// NinjaLog.d('CampaignRepo', 'Fetching campaigns from server...');
/// // => AppNinja: [CampaignRepo] Fetching campaigns from server...
///
/// NinjaLog.w('AppNinja', 'Session limit reached');
/// // => AppNinja: ⚠️ [AppNinja] Session limit reached
///
/// NinjaLog.e('FloaterV2', 'Render failed', error: e, stack: st);
/// // => AppNinja: ❌ [FloaterV2] Render failed
/// //    <stack trace>
/// ```
class NinjaLog {
  /// Callback that returns whether debug logging is currently enabled.
  /// Wired up to [AppNinja.debugMode] during SDK init.
  static bool Function() _isDebugEnabled = () => kDebugMode;

  /// Called once during [AppNinja.init] to wire the debug-mode gate.
  static void configure(bool Function() isDebugEnabled) {
    _isDebugEnabled = isDebugEnabled;
  }

  // ── Core ────────────────────────────────────────────────────────────────

  /// Debug log — general informational messages.
  static void d(String tag, String message) {
    if (!_isDebugEnabled()) return;
    debugPrint('AppNinja: [$tag] $message');
  }

  /// Warning log — unexpected but non-fatal conditions.
  static void w(String tag, String message) {
    if (!_isDebugEnabled()) return;
    debugPrint('AppNinja: ⚠️ [$tag] $message');
  }

  /// Error log — failures that may affect SDK behaviour.
  /// Always prints even without debug mode (errors are never silenced).
  static void e(String tag, String message, {Object? error, StackTrace? stack}) {
    debugPrint('AppNinja: ❌ [$tag] $message${error != null ? ' — $error' : ''}');
    if (stack != null && kDebugMode) {
      debugPrint('$stack');
    }
  }

  /// Verbose log — high-frequency diagnostic messages (e.g. drag events).
  /// Only emits in debug mode AND when kDebugMode is true.
  static void v(String tag, String message) {
    if (!_isDebugEnabled() || !kDebugMode) return;
    debugPrint('AppNinja: 🔍 [$tag] $message');
  }
}

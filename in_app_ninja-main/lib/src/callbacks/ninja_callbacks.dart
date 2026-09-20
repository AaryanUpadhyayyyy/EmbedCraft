import '../models/ninja_callback_data.dart';
import '../utils/ninja_logger.dart';

/// NinjaCallbackListener - Interface for listening to SDK events
///
/// Implement this interface in your widget state to receive callbacks
/// from the Ninja SDK for both CORE (lifecycle) and UI (interaction) events.
///
/// Example:
/// ```dart
/// class _HomePageState extends State<HomePage>
///     with SingleTickerProviderStateMixin implements NinjaCallbackListener {
///
///   @override
///   void initState() {
///     super.initState();
///     NinjaCallbackManager.registerListener(this);
///   }
///
///   @override
///   void dispose() {
///     NinjaCallbackManager.unregisterListener(this);
///     super.dispose();
///   }
///
///   @override
///   void onEvent(NinjaCallbackData event) {
///     NinjaLog.d('AppNinja', "callback event: ${event.type} - ${event.action}");
///     switch (event.type) {
///       case "CORE":
///         // Handle core events (init, identify, rewards)
///         break;
///       case "UI":
///         // Handle UI events (open, dismiss, cta click)
///         break;
///     }
///   }
/// }
/// ```
abstract class NinjaCallbackListener {
  /// Called when an SDK event occurs
  ///
  /// [event] - The callback data containing type, action, method, and data
  void onEvent(NinjaCallbackData event);
}

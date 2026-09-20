import 'package:flutter/foundation.dart';

/// Registry to manage input values collected from NinjaInputLayer widgets.
/// 
/// This allows other components (like Button actions) to retrieve values 
/// using the `variableName` defined in the Input Layer.
class NinjaInputRegistry {
  // Map of variableName -> currentValue
  static final Map<String, dynamic> _values = {};
  
  // Notifier for clear events (Generic integer increment serves as signal)
  static final ValueNotifier<int> clearNotifier = ValueNotifier(0);

  /// Register or update a value for a specific variable
  static void register(String variableName, dynamic value) {
    if (variableName.isEmpty) return;
    _values[variableName] = value;
  }

  /// Retrieve a value for a specific variable
  static dynamic getValue(String variableName) {
    return _values[variableName];
  }

  /// Retrieve all registered values
  static Map<String, dynamic> getAllValues() {
    return Map.unmodifiable(_values);
  }

  /// Clear all values (e.g., when closing a campaign)
  static void clear() {
    _values.clear();
    clearNotifier.value++; // Signal listeners to clear
  }
}

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/ninja_logger.dart';

/// Centralized, safe external URL / deeplink launching for CTAs.
class NinjaUrlLauncher {
  NinjaUrlLauncher._();

  /// Opens [rawUrl] in an external application (browser or registered handler).
  /// Returns whether [launchUrl] reported success.
  static Future<bool> launchExternal(String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) return false;
    
    String finalUrl = rawUrl.trim();
    
    // Auto-prepend https if it lacks a scheme and looks like a web URL
    if (!finalUrl.contains('://')) {
        // If it starts with a common domain pattern or www
        if (RegExp(r'^(www\.|[a-zA-Z0-9-]+\.[a-zA-Z]{2,})').hasMatch(finalUrl)) {
            finalUrl = 'https://$finalUrl';
        }
    }

    try {
      final uri = Uri.parse(finalUrl);
      if (!uri.hasScheme) return false;

      // Skip canLaunchUrl check because it reliably fails on Android 11+ 
      // without explicit <queries> in AndroidManifest.xml.
      // Directly attempt launchUrl and catch the exception if it fails.
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) {
        NinjaLog.d('UrlLauncher', 'NinjaUrlLauncher: parse/launch error: $e');
      }
      return false;
    }
  }
}

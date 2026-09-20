import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../utils/ninja_log.dart';

class EnterpriseFontManager {
  static final Map<String, bool> _loadedFonts = {};

  /// Downloads (if necessary) and registers a custom font with the Flutter Engine.
  static Future<void> loadFont(String fontFamily, String fontUrl) async {
    if (_loadedFonts[fontFamily] == true) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${dir.path}/ninja_fonts');
      if (!await fontDir.exists()) {
        await fontDir.create(recursive: true);
      }

      // We use a safe filename based on the family
      final safeName = fontFamily.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${fontDir.path}/$safeName.ttf');

      if (!await file.exists()) {
        NinjaLog.d('EnterpriseFontManager', 'Downloading custom font: $fontFamily from $fontUrl');
        final response = await http.get(Uri.parse(fontUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download font: ${response.statusCode}');
        }
      }

      // Load font bytes into the engine
      final fontBytes = await file.readAsBytes();
      final loader = FontLoader(fontFamily);
      loader.addFont(Future.value(ByteData.view(fontBytes.buffer)));
      await loader.load();
      
      _loadedFonts[fontFamily] = true;
      NinjaLog.d('EnterpriseFontManager', 'Successfully loaded custom font into engine: $fontFamily');
    } catch (e) {
      NinjaLog.d('EnterpriseFontManager', 'Error loading custom font $fontFamily: $e');
    }
  }
}

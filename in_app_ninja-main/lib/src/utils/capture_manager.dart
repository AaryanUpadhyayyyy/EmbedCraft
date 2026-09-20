import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../app_ninja.dart';
import 'ninja_sdk_safe.dart';
import 'ninja_logger.dart';

class CaptureManager {
  static StreamSubscription? _sub;
  // Remove static controller. user registerScreenshotCallback instead.
  // static ScreenshotController screenshotController = ScreenshotController();
  
  static Future<Uint8List?> Function(Duration delay, double pixelRatio)? _captureCallback;

  static void registerScreenshotCallback(Future<Uint8List?> Function(Duration, double) callback) {
    _captureCallback = callback;
  }

  static final _appLinks = AppLinks();
  // static OverlayEntry? _overlayEntry; // REMOVED: Using Stack/Notifier instead
  static String? _sessionToken;
  
  // Controls visibility of the Capture Button in NinjaApp
  // Controls visibility of the Capture Button in NinjaApp
  static final ValueNotifier<bool> showCaptureUi = ValueNotifier(false);

  // Initialize Deep Link Listener
  static void init([BuildContext? context]) {
    NinjaLog.d('CaptureManager', '🚀 EmbedCraft SDK: CaptureManager.init() called. Listening for deep links...');
    
    ninjaSdkSafeUnawaited(
      _appLinks.getInitialLink().then((uri) {
        if (uri != null) {
          NinjaLog.d('CaptureManager', '🚀 EmbedCraft SDK: Initial Deep Link found on startup!');
          _handleLink(uri, context);
        }
      }),
      context: 'CaptureManager getInitialLink',
    );

    // 2. Listen for incoming links
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      NinjaLog.d('CaptureManager', '🚀 EmbedCraft SDK: Incoming Deep Link stream fired!');
      _handleLink(uri, context);
    }, onError: (err) {
      NinjaLog.d('CaptureManager', '❌ EmbedCraft SDK: Deep Link Error: $err');
    });
  }

  static void dispose() {
    _sub?.cancel();
    showCaptureUi.value = false;
  }

  static void _handleLink(Uri uri, [BuildContext? context]) {
    NinjaLog.d('CaptureManager', '🔗 EmbedCraft SDK: Deep Link received -> $uri');
    
    // Accept any scheme (embedfin://, bigbasket://, embeddedcraft://, etc.)
    // Check if host or path contains 'capture'
    if (uri.host == 'capture' || uri.path.contains('capture') || uri.toString().contains('capture')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        NinjaLog.d('CaptureManager', '✅ EmbedCraft SDK: Valid Capture Token found -> $token');
        _sessionToken = token;
        
        // Enable Capture UI
        showCaptureUi.value = true;
        _showOverlayFallback(context);
      } else {
        NinjaLog.d('CaptureManager', '⚠️ EmbedCraft SDK: Deep link contains capture but missing token!');
      }
    } else {
      NinjaLog.d('CaptureManager', 'ℹ️ EmbedCraft SDK: Deep link ignored (not a capture link).');
    }
  }

  static OverlayEntry? _overlayEntry;

  static void _showOverlayFallback([BuildContext? context]) async {
    if (_overlayEntry != null) {
      NinjaLog.d('CaptureManager', 'ℹ️ EmbedCraft SDK: Capture Button is already rendered.');
      return;
    }
    
    NinjaLog.d('CaptureManager', '⏳ EmbedCraft SDK: Polling for Navigator Overlay...');
    OverlayState? overlayState;
    int attempts = 0;
    
    // Poll for the navigator to mount (deep links can fire before UI is ready)
    while (overlayState == null && attempts < 10) {
      overlayState = AppNinja.navigatorKey.currentState?.overlay;
      if (overlayState != null) {
        NinjaLog.d('CaptureManager', '✅ EmbedCraft SDK: Navigator Overlay found on attempt ${attempts + 1}!');
        break;
      }
      attempts++;
      NinjaLog.d('CaptureManager', '⏳ EmbedCraft SDK: Waiting for Navigator Overlay... (Attempt $attempts)');
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (overlayState == null) {
      NinjaLog.d('CaptureManager', '❌ EmbedCraft SDK: Could not find navigatorKey overlay to show button after 3 seconds.');
      return;
    }

    NinjaLog.d('CaptureManager', '🎨 EmbedCraft SDK: Injecting Capture Button into UI...');
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        bottom: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: FloatingActionButton.extended(
            onPressed: () {
              NinjaLog.d('CaptureManager', '👆 EmbedCraft SDK: Capture Button Tapped!');
              startCaptureFlow(AppNinja.navigatorKey.currentContext ?? ctx);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Screen'),
            backgroundColor: Colors.purple,
          ),
        ),
      ),
    );
    overlayState.insert(_overlayEntry!);
    NinjaLog.d('CaptureManager', '✅ EmbedCraft SDK: Capture Button successfully rendered!');
    
    try {
      final activeContext = AppNinja.navigatorKey.currentContext ?? context;
      if (activeContext != null) {
        ScaffoldMessenger.of(activeContext).showSnackBar(
          const SnackBar(content: Text('📸 Capture Mode Enabled'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {}
  }

  static void closeCaptureMode() {
    showCaptureUi.value = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Called by the Button in NinjaApp or Fallback Overlay
  static Future<void> startCaptureFlow(BuildContext context) async {
    NinjaLog.d('CaptureManager', '📸 Capture Flow Started');
    
    // 1. Hide Button
    showCaptureUi.value = false; 
    _overlayEntry?.remove();
    _overlayEntry = null;

    // 2. Wait for UI to settle
    NinjaLog.d('CaptureManager', '⏳ UI Settling (500ms)...');
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      NinjaLog.d('CaptureManager', '📸 Requesting Capture (via callback)...');
      
      Uint8List? imageBytes;
      int attempts = 0;

      // Try user-registered callback first (Screenshot package wrapper)
      if (_captureCallback != null) {
        while (attempts < 3) {
          try {
            attempts++;
            imageBytes = await _captureCallback!(
              const Duration(milliseconds: 100), 
              MediaQuery.of(context).devicePixelRatio
            );
            if (imageBytes != null) break; 
          } catch (e) {
            NinjaLog.d('CaptureManager', '⚠️ Capture Attempt #$attempts failed: $e');
            if (attempts >= 3) rethrow;
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      } else {
        // FALLBACK: Capture without any wrapper using native Flutter RenderRepaintBoundary
        NinjaLog.d('CaptureManager', '⚠️ No Capture Callback registered! Attempting native wrapper-less capture...');
        imageBytes = await _captureNativeScreen(AppNinja.navigatorKey.currentContext ?? context);
        if (imageBytes == null) {
           throw Exception('Native capture failed. You may need to wrap your app in NinjaApp or a RepaintBoundary.');
        }
      }
      
      if (imageBytes == null) throw Exception('Screenshot returned null bytes');
      NinjaLog.d('CaptureManager', '✅ Screenshot captured (${imageBytes.length} bytes)');

      // 3. Data Mining
      NinjaLog.d('CaptureManager', '⛏️ Starting Data Mining...');
      final size = MediaQuery.of(context).size;
      final elements = AppNinja.getAllElements(
        'capture_${DateTime.now().millisecondsSinceEpoch}',
        MediaQuery.of(context).devicePixelRatio,
        size.width,
        size.height,
      );

      // 3.5. Capture Scroll Data (for tooltip scroll replay)
      final scrollData = AppNinja.getActiveScrollData();
      NinjaLog.d('CaptureManager', '📜 Scroll Data: $scrollData');

      // 4. Show Name Dialog
      // Use Global Navigator Key for context if available, else fall back
      final navContext = AppNinja.navigatorKey.currentContext ?? context;

      if (navContext.mounted) {
         // Check if Navigator calls are safe
         if (Navigator.maybeOf(navContext) != null) {
            _showNameDialog(navContext, imageBytes, elements, scrollData);
         } else {
            NinjaLog.d('CaptureManager', '❌ Capture Error: Context found, but NO Navigator available.');
            // Try to warn using ScaffoldMessenger if possible
            try {
              ScaffoldMessenger.of(navContext).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Config Error: No Navigator found! Set AppNinja.navigatorKey in MaterialApp.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );
            } catch (_) {}
            showCaptureUi.value = true;
         }
      } else {
         NinjaLog.d('CaptureManager', '❌ No valid context found for Dialog');
         showCaptureUi.value = true;
      }

    } catch (e) {
      NinjaLog.d('CaptureManager', '❌ Capture Error: $e');
      final navContext = AppNinja.navigatorKey.currentContext ?? context;
      if (navContext.mounted) {
        try {
          ScaffoldMessenger.of(navContext).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        } catch (_) {}
      }
      showCaptureUi.value = true;
    }
  }

  static Future<Uint8List?> _captureNativeScreen(BuildContext context) async {
    try {
      RenderObject? renderObject = context.findRenderObject();
      while (renderObject != null && renderObject is! RenderRepaintBoundary) {
        renderObject = renderObject.parent as RenderObject?;
      }
      
      if (renderObject == null) {
        RenderRepaintBoundary? boundary;
        context.visitAncestorElements((element) {
          if (element.renderObject is RenderRepaintBoundary) {
            boundary = element.renderObject as RenderRepaintBoundary;
          }
          return true;
        });
        renderObject = boundary;
      }

      if (renderObject is RenderRepaintBoundary) {
        final ui.Image image = await renderObject.toImage(pixelRatio: ui.window.devicePixelRatio);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      NinjaLog.d('CaptureManager', 'Native capture error: $e');
    }
    return null;
  }



  static void _showNameDialog(BuildContext context, dynamic imageBytes, List<Map<String, dynamic>> elements, [Map<String, dynamic>? scrollData]) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Page Name',
                hintText: 'e.g. Checkout Screen',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            Text('${elements.length} interactable elements found.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              showCaptureUi.value = true; // Restore button
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              Navigator.pop(ctx);
              _uploadCapture(context, imageBytes, elements, nameController.text, scrollData);
            },
            child: const Text('Save & Upload'),
          ),
        ],
      ),
    );
  }

  static Future<void> _uploadCapture(
    BuildContext context, 
    dynamic imageBytes, 
    List<Map<String, dynamic>> elements,
    String pageName,
    [Map<String, dynamic>? scrollData]
  ) async {
    // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/screenshot.png').create();
      await file.writeAsBytes(imageBytes);

      final metadata = {
        'deviceType': Platform.isAndroid ? 'Android' : 'iOS',
        'width': MediaQuery.of(context).size.width,
        'height': MediaQuery.of(context).size.height,
        'density': MediaQuery.of(context).devicePixelRatio,
        'orientation': MediaQuery.of(context).orientation.name,
      };

      await _upload(file, _sessionToken!, metadata, elements, pageName, scrollData);

      Navigator.pop(context); // Remove Loading
      showCaptureUi.value = false; // Disable mode after success
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Page Uploaded Successfully! Check Dashboard.'), backgroundColor: Colors.green),
      );

    } catch (e) {
      Navigator.pop(context); // Remove Loading
      NinjaLog.d('CaptureManager', 'Upload Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed: $e'), backgroundColor: Colors.red),
      );
      showCaptureUi.value = true; // Restore UI to try again
    }
  }

  static Future<http.StreamedResponse> _sendMultipartRequest(
      String url, 
      File imageFile, 
      String token, 
      Map metadata, 
      List<Map<String, dynamic>> elements,
      String pageName,
      [Map<String, dynamic>? scrollData]) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('screenshot', imageFile.path));
    
    request.fields['name'] = pageName;
    request.fields['pageTag'] = pageName.toLowerCase().replaceAll(' ', '_');
    request.fields['deviceMetadata'] = jsonEncode(metadata);
    request.fields['elements'] = jsonEncode(elements);
    if (scrollData != null && scrollData.isNotEmpty) {
      request.fields['scrollData'] = jsonEncode(scrollData);
    }

    return await request.send();
  }

  static Future<void> _upload(
    File imageFile, 
    String token, 
    Map metadata, 
    List<Map<String, dynamic>> elements,
    String pageName,
    [Map<String, dynamic>? scrollData]
  ) async {
    String uploadUrl = '${AppNinja.baseUrl}/api/pages/upload'; 

    var response = await _sendMultipartRequest(uploadUrl, imageFile, token, metadata, elements, pageName, scrollData);
    
    int redirectCount = 0;
    while ((response.statusCode == 307 || response.statusCode == 308) && redirectCount < 3) {
      final location = response.headers['location'];
      if (location == null) break;
      NinjaLog.d('CaptureManager', '↪️ Following ${response.statusCode} redirect to: $location');
      final redirectUrl = Uri.parse(uploadUrl).resolve(location).toString();
      // Re-create request because streams in MultipartRequest cannot be reused natively
      response = await _sendMultipartRequest(redirectUrl, imageFile, token, metadata, elements, pageName, scrollData);
      redirectCount++;
    }
    
    if (response.statusCode == 401) {
      throw Exception('Session Expired ⏳. Please refresh Dashboard & Scan New QR.');
    }
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}

import 'package:flutter/material.dart';
import '../app_ninja.dart';
import '../utils/ninja_sdk_safe.dart';
import 'package:screenshot/screenshot.dart';
import '../utils/capture_manager.dart';
import '../utils/ninja_logger.dart';

/// NinjaApp Wrapper Widget
///
/// Wrap your app's home widget with this to enable auto-rendering
/// This widget automatically provides context to the SDK for showing campaigns
///
/// Example:
/// ```dart
/// MaterialApp(
///   home: NinjaApp(
///     child: MyHomePage(),
///   ),
/// )
/// ```
class NinjaApp extends StatefulWidget {
  final Widget child;

  const NinjaApp({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NinjaApp> createState() => _NinjaAppState();
}

class _NinjaAppState extends State<NinjaApp> with WidgetsBindingObserver {
  // Local Controller (Alive with this State)
  final ScreenshotController _localController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Register this controller with CaptureManager
    CaptureManager.registerScreenshotCallback((delay, pixelRatio) {
      return _localController.capture(delay: delay, pixelRatio: pixelRatio);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ninjaSdkSafeSync(
        () {
          AppNinja.setGlobalContext(context);
          AppNinja.setContext(context);
          CaptureManager.init(context);
          NinjaLog.d('NinjaApp', '✅ NinjaApp: Key Registered for Capture');
        },
        context: 'NinjaApp postFrameCallback',
      );
    });
  }

// ... existing lifecycle methods ...

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return Directionality(
      textDirection: textDirection,
      child: Stack(
        children: [
          Screenshot(
            controller: _localController, 
            child: widget.child,
          ),
          
          // Capture Buttons Layer (Controlled by CaptureManager)
          ValueListenableBuilder<bool>(
            valueListenable: CaptureManager.showCaptureUi,
            builder: (ctx, isVisible, _) {
              if (!isVisible) return const SizedBox.shrink();

              return Positioned(
                bottom: 50,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () => CaptureManager.startCaptureFlow(context),
                        label: const Text('Capture Page'),
                        icon: const Icon(Icons.camera_alt),
                        backgroundColor: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(
                        onPressed: CaptureManager.closeCaptureMode,
                        child: const Icon(Icons.close),
                        backgroundColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

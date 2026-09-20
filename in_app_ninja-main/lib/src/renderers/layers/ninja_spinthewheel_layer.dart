import 'dart:math' as math;
import 'dart:ui'; // For ImageFilter & MaskFilter
import 'package:flutter/material.dart';
import '../../app_ninja.dart';
import 'ninja_layer_utils.dart';
import '../../models/nudge_model.dart';
import '../../callbacks/ninja_callback_manager.dart';
import '../../utils/ninja_logger.dart';

class NinjaSpinTheWheelLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final double scale;
  final Size? parentSize;
  final Function(String, Map<String, dynamic>?)? onAction;
  final NudgeConfig? config;
  final String? campaignId;
  final List<dynamic>? allLayers;
  final Widget? Function(dynamic childLayer,
      {double? parentWidth, double? parentHeight})? renderChild;

  const NinjaSpinTheWheelLayer({
    Key? key,
    required this.layer,
    this.scale = 1.0,
    this.parentSize,
    this.onAction,
    this.config,
    this.campaignId,
    this.allLayers,
    this.renderChild,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NinjaSpinTheWheelLayerState createState() => _NinjaSpinTheWheelLayerState();
}

class _NinjaSpinTheWheelLayerState extends State<NinjaSpinTheWheelLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  bool _isSpinning = false;
  double _currentAngleOffset = 0.0;

  // Game State
  int _spinsLeft = -1;
  int _maxSpins = -1;
  int? _winningIndex;
  bool _isWinResult = false; // Server-authoritative win determination
  String? _showResult; // 'congrats' or 'betterLuck'
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    final layerContent = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final int spinDuration =
        (layerContent['spinDuration'] as num?)?.toInt() ?? 3000;

    _spinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: spinDuration),
    );

    _spinAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCirc),
    )..addListener(() {
        setState(() {});
      });

    _initLocalState();

    // Parity: React window.addEventListener('spinTheWheel', ...) — register global spin trigger
    // so buttons with action.type='spin_wheel' can call _startSpin() via AppNinja.triggerSpin()
    AppNinja.stwSpinTrigger = _startSpin;
    AppNinja.stwCloseOverlay = _onCloseOverlay;
  }

  void _initLocalState() {
    final layerContent = widget.layer['content'] as Map<String, dynamic>? ?? {};

    // Setup SDK global state sync if not already set by another component
    int parsedMax =
        NinjaLayerUtils.parseDouble(layerContent['maxAttempts'])?.toInt() ?? 50;
    if (_spinsLeft == -1) {
      _maxSpins = parsedMax;
      AppNinja.stwMaxSpins = _maxSpins;

      // FIX: Use server-persisted value if available from a previous session,
      // otherwise use maxAttempts as the default. Do NOT broadcast default
      // to AppNinja.stwSpinsLeft until server confirms — this prevents the
      // counter flashing "50" briefly on every new session before the API responds.
      if (AppNinja.stwSpinsLeft >= 0 && AppNinja.stwSpinsLeft <= parsedMax) {
        _spinsLeft = AppNinja.stwSpinsLeft;
      } else {
        _spinsLeft = parsedMax;
        AppNinja.stwSpinsLeft = _spinsLeft;
      }

      // Fetch actual remaining spins from server (authoritative source)
      _fetchRemainingSpins();
    }
  }

  Future<void> _fetchRemainingSpins() async {
    final String cmpId = widget.campaignId ??
        widget.config?.raw['_id']?.toString() ??
        widget.config?.raw['id']?.toString() ??
        widget.layer['campaignId']?.toString() ??
        '';

    if (cmpId.isNotEmpty) {
      final res = await AppNinja.getSpinsRemaining(cmpId);
      if (mounted && res['success'] == true) {
        final remaining = (res['remainingSpins'] as num?)?.toInt();
        final maxAtt = (res['maxAttempts'] as num?)?.toInt();
        if (remaining != null) {
          setState(() {
            _spinsLeft = remaining;
            _maxSpins = maxAtt ?? _maxSpins;
            AppNinja.stwSpinsLeft = _spinsLeft;
            AppNinja.stwMaxSpins = _maxSpins;
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(NinjaSpinTheWheelLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parity: React useEffect([content.maxAttempts]) — re-sync spinsLeft when config changes
    final oldContent =
        oldWidget.layer['content'] as Map<String, dynamic>? ?? {};
    final newContent = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final oldMax =
        NinjaLayerUtils.parseDouble(oldContent['maxAttempts'])?.toInt() ?? 50;
    final newMax =
        NinjaLayerUtils.parseDouble(newContent['maxAttempts'])?.toInt() ?? 50;
    if (oldMax != newMax) {
      setState(() {
        _spinsLeft = newMax;
        _maxSpins = newMax;
        AppNinja.stwSpinsLeft = _spinsLeft;
        AppNinja.stwMaxSpins = _maxSpins;
      });
    }
    // BUG 10 FIX: Sync spinDuration on config change (dashboard re-reads it every render)
    final oldDuration = (oldContent['spinDuration'] as num?)?.toInt() ?? 3000;
    final newDuration = (newContent['spinDuration'] as num?)?.toInt() ?? 3000;
    if (oldDuration != newDuration) {
      _spinController.duration = Duration(milliseconds: newDuration);
    }
  }

  bool _onCloseOverlay() {
    if (_showResult != null) {
      setState(() {
        _showResult = null;
      });
      return true; // Intercepted
    }
    return false; // Not intercepted
  }

  @override
  void dispose() {
    // Parity: React window.removeEventListener('spinTheWheel', ...) — clear global spin trigger
    if (AppNinja.stwSpinTrigger == _startSpin) AppNinja.stwSpinTrigger = null;
    if (AppNinja.stwCloseOverlay == _onCloseOverlay) AppNinja.stwCloseOverlay = null;
    _spinController.dispose();
    super.dispose();
  }

  void _startSpin() async {
    if (_isSpinning || _spinsLeft <= 0) return;

    // Parity: Dashboard decrements AFTER animation completes (inside setTimeout)
    // SDK must NOT decrement here — only set spinning state
    setState(() {
      _isSpinning = true;
    });

    // Let global SDK know
    if (widget.onAction != null) {
      widget.onAction!('spin_started', {'spinsLeft': _spinsLeft});
    }

    // Dispatch the advanced interaction callback
    NinjaCallbackManager.dispatchSpinWheelSpun(
      campaignId: widget.campaignId ?? 'unknown',
      additionalData: {'spinsLeft': _spinsLeft},
    );

    // Resolve campaignId from widget prop (primary), then config/layer fallbacks
    final String cmpId = widget.campaignId ??
        widget.config?.raw['_id']?.toString() ??
        widget.config?.raw['id']?.toString() ??
        widget.layer['campaignId']?.toString() ??
        '';
    NinjaLog.d('AppNinja', 
        'NinjaSTW: campaignId resolved to "$cmpId" (from widget=${widget.campaignId != null})');
    final spinConfig =
        widget.config?.raw['spinTheWheelConfig'] as Map<String, dynamic>? ?? {};
    final sections = (widget.config?.raw['sections'] as List<dynamic>?) ??
        (spinConfig['sections'] as List<dynamic>?) ??
        [];
    int numSections = sections.isNotEmpty ? sections.length : 6;

    // Local-spin fallback: used when cmpId is missing or server is unreachable.
    // The wheel still animates to a random section (no-win) so UX is not broken.
    void localFallbackSpin({int? nextSpins}) {
      _winningIndex = math.Random().nextInt(numSections);
      _isWinResult = false;
      _doWheelAnimation(numSections, nextSpinsLeft: nextSpins);
    }

    if (cmpId.isEmpty) {
      NinjaLog.d('AppNinja', "NinjaSTW: No campaign ID — local fallback spin");
      localFallbackSpin();
      return;
    }
    NinjaLog.d('AppNinja', 
        'NinjaSTW: Calling initiateGame with cmpId=$cmpId numSections=$numSections');

    Map<String, dynamic> gameResult = {};
    int? serverSpinsLeft;

    try {
      gameResult = await AppNinja.initiateGame(cmpId);

      // CRITICAL: Check mounted after async gap — user may have dismissed the modal
      if (!mounted) return;

      if (gameResult['success'] == true) {
        _winningIndex = gameResult['winningIndex'] as int;

        // BUG 2 FIX: Use server-authoritative isWin field.
        // The SDK's sections come from sanitized campaign config where rewardId
        // is stripped for security — re-deriving isWin locally always yields false.
        _isWinResult = gameResult['isWin'] == true;

        if (gameResult.containsKey('remainingSpins')) {
          serverSpinsLeft = (gameResult['remainingSpins'] as num?)?.toInt();
          _maxSpins = (gameResult['maxAttempts'] as num?)?.toInt() ?? _maxSpins;
        }

        NinjaLog.d('AppNinja', 
            'NinjaSTW: API result — winningIndex=$_winningIndex isWin=$_isWinResult rewardName=${gameResult["rewardName"]}');
      } else {
        if (gameResult.containsKey('remainingSpins')) {
          serverSpinsLeft = (gameResult['remainingSpins'] as num?)?.toInt();
          _maxSpins = (gameResult['maxAttempts'] as num?)?.toInt() ?? _maxSpins;
        }
        NinjaLog.d('AppNinja', 
            "NinjaSTW: Server rejected spin: ${gameResult['error']} — local fallback spin");
        localFallbackSpin(nextSpins: serverSpinsLeft);
        return;
      }
    } catch (e) {
      NinjaLog.d('AppNinja', "NinjaSTW: Network error: $e — local fallback spin");
      localFallbackSpin();
      return;
    }

    // BUG FIX: Save rewardDetails so {{coupon_code}} interpolation works for bulk codes
    if (gameResult.containsKey('rewardDetails') && gameResult['rewardDetails'] != null) {
      AppNinja.stwRewardDetails = Map<String, dynamic>.from(gameResult['rewardDetails'] as Map);
    } else {
      AppNinja.stwRewardDetails = {};
    }

    // Use actual reward name from rewardDetails if available, otherwise fall back to serverRewardName or mapReward name
    final detailsRewardName = AppNinja.stwRewardDetails['name']?.toString();
    final serverRewardName = gameResult['rewardName']?.toString();
    final mapReward = (sections.isNotEmpty &&
            _winningIndex != null &&
            _winningIndex! < sections.length)
        ? sections[_winningIndex!]
        : {};

    String rawName = (detailsRewardName != null && detailsRewardName.isNotEmpty)
        ? detailsRewardName
        : (serverRewardName ?? mapReward['name']?.toString() ?? 'Prize');
    if (rawName.contains('{{')) {
      final RegExp exp = RegExp(r'\{\{([^}]+)\}\}');
      rawName = rawName.replaceAllMapped(exp, (match) {
        final prop = match.group(1)?.trim();
        if (prop != null && AppNinja.stwRewardDetails.containsKey(prop)) {
          return AppNinja.stwRewardDetails[prop]?.toString() ?? match.group(0)!;
        }
        if (prop != null && mapReward.containsKey(prop)) {
          return mapReward[prop]?.toString() ?? match.group(0)!;
        }
        if (prop != null && mapReward['reward'] is Map && (mapReward['reward'] as Map).containsKey(prop)) {
          return (mapReward['reward'] as Map)[prop]?.toString() ?? match.group(0)!;
        }
        return 'No Reward';
      });
    }
    AppNinja.stwRewardName = rawName;

    _doWheelAnimation(numSections, nextSpinsLeft: serverSpinsLeft);
  }

  /// Runs the physical wheel spin animation and then shows the result overlay.
  /// Called by both the normal (API-backed) path and the local fallback path.
  void _doWheelAnimation(int numSections, {int? nextSpinsLeft}) {
    // Math for stopping point
    final sliceAngle = (360 / numSections);

    final layerContent = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final double offset = NinjaLayerUtils.parseDouble(layerContent['wheelRotationOffset']) ?? 0.0;

    // We want the WINNING SLICE to end up directly at the POINTER (Top, 0°).
    // The slice's center angle at index i is: i * sliceAngle + (sliceAngle / 2) + offset
    final targetSliceCenterAngle =
        (_winningIndex! * sliceAngle) + (sliceAngle / 2) + offset;

    // Base extra rotations (5–7 full spins for drama)
    final extraSpinsCount = 5 + math.Random().nextInt(3);
    final extraRotations = 360.0 * extraSpinsCount;

    final requiredAbsoluteRotation = 360.0 - targetSliceCenterAngle;
    var delta = requiredAbsoluteRotation - (_currentAngleOffset % 360.0);
    if (delta < 0.0) delta += 360.0;

    // Add subtle randomness inside the slice so it doesn't always land dead-center
    final randomOffset =
        (math.Random().nextDouble() * (sliceAngle * 0.8)) - (sliceAngle * 0.4);
    final targetAngle =
        _currentAngleOffset + delta + extraRotations + randomOffset;

    // Parity: Dashboard uses cubic-bezier(0.17, 0.67, 0.12, 0.99)
    // BUG 1 FIX: Re-attach the setState listener to the NEW animation object.
    // Previously, the listener was only on the initial dummy animation from initState().
    // Reassigning _spinAnimation without re-attaching the listener meant setState()
    // was never called during subsequent spins → wheel appeared frozen.
    _spinAnimation = Tween<double>(begin: _currentAngleOffset, end: targetAngle)
        .animate(CurvedAnimation(
            parent: _spinController,
            curve: const Cubic(0.17, 0.67, 0.12, 0.99)))
      ..addListener(() {
        setState(() {});
      });

    _spinController.forward(from: 0).whenComplete(() async {
      // Parity: React fires result callback at spinDuration + 200ms
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      // Use server provided spins if available, otherwise just decrement
      final newSpinsLeft = nextSpinsLeft ?? math.max(0, _spinsLeft - 1);

      setState(() {
        _isSpinning = false;
        _currentAngleOffset = targetAngle % 360;
        _spinsLeft = newSpinsLeft;
        AppNinja.stwSpinsLeft = newSpinsLeft;
        AppNinja.stwMaxSpins = _maxSpins;
      });

      if (widget.onAction != null) {
        widget.onAction!('spin_completed', {
          'index': _winningIndex,
          'reward': AppNinja.stwRewardName,
          'spinsLeft': _spinsLeft
        });
      }

      final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
      final bool isWin = _isWinResult;

      if (isWin) {
        AppNinja.stwSectionIndex = _winningIndex ?? 0;

        NinjaCallbackManager.dispatchRewardReceived([
          {
            'rewardName': AppNinja.stwRewardName,
            'winningIndex': _winningIndex,
            'sectionIndex': _winningIndex,
            'campaignId': widget.layer['campaignId']?.toString() ?? '',
            'source': 'spin_the_wheel',
          }
        ]);

        if (content['showCongratsScreen'] == true) {
          setState(() {
            _showResult = 'congrats';
          });
        }
        if (content['addConfetti'] != false) {
          setState(() {
            _showConfetti = true;
          });
          Future.delayed(const Duration(milliseconds: 3500), () {
            if (mounted)
              setState(() {
                _showConfetti = false;
              });
          });
        }
      } else {
        if (content['showBetterLuckScreen'] == true) {
          setState(() {
            _showResult = 'betterLuck';
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showResult = null;
              });
            }
          });
        }
      }
    });
  }

  Widget _buildWheelPainter(
      List<dynamic> sections,
      Color strokeColor,
      double scale,
      Map<String, dynamic> layerContent,
      List<String> defaultColors,
      Size containerSize) {
    bool hasSectionImages = sections
        .any((s) => s['image'] != null && s['image'].toString().isNotEmpty);

    final Color textColor =
        NinjaLayerUtils.parseColor(layerContent['textColor']) ?? Colors.white;
    final Color accentColor =
        NinjaLayerUtils.parseColor(layerContent['accentColor']) ??
            const Color(0xFF1F2937);

    // If no images, just use a single painter for performance
    if (!hasSectionImages) {
      return CustomPaint(
        painter: _WheelPainter(
          sections: sections,
          strokeColor: strokeColor,
          scale: scale,
          defaultColors: defaultColors,
          textColor: textColor,
          accentColor: accentColor,
        ),
      );
    }

    final double paddingRatio = 10.0 / 320.0;
    final double padding = containerSize.width * paddingRatio;
    final double radius = (containerSize.width / 2) - padding;
    final double sweepAngle = (2 * math.pi) / sections.length;

    List<Widget> stackChildren = [];

    // 1. Backgrounds
    stackChildren.add(CustomPaint(
        size: containerSize,
        painter: _WheelBackgroundPainter(
            sections: sections, defaultColors: defaultColors)));

    // 2. Section Images
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i] as Map<String, dynamic>;
      final String? imgUrl = section['image']?.toString();
      if (imgUrl == null || imgUrl.isEmpty) continue;

      final double startAngle = i * sweepAngle - (math.pi / 2);

      stackChildren.add(Positioned.fill(
        child: ClipPath(
            clipper: _SectionClipper(
                startAngle: startAngle, sweepAngle: sweepAngle, radius: radius),
            // Dashboard uses xMidYMid slice (BoxFit.cover) over the svgRadius box.
            // We'll wrap the image in a positioned box matching the bounding box of the circle to mimic SVG <image> logic exactly.
            child: Stack(children: [
              Positioned(
                left: padding,
                top: padding,
                width: radius * 2,
                height: radius * 2,
                child: Image.network(imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const SizedBox()),
              )
            ])),
      ));
    }

    // 3. Foreground (Text, Borders, Dots)
    stackChildren.add(CustomPaint(
        size: containerSize,
        painter: _WheelForegroundPainter(
            sections: sections,
            scale: scale,
            textColor: textColor,
            accentColor: accentColor,
            strokeColor: strokeColor)));

    return Stack(children: stackChildren);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};
    final layerContent = widget.layer['content'] as Map<String, dynamic>? ?? {};

    // SECTIONS: The API places sections at config.raw['sections'] (top-level in the campaign config),
    // NOT inside spinTheWheelConfig. Fall back to spinTheWheelConfig.sections if absent.
    final spinConfig =
        widget.config?.raw['spinTheWheelConfig'] as Map<String, dynamic>? ?? {};
    final sections = (widget.config?.raw['sections'] as List<dynamic>?) ??
        (spinConfig['sections'] as List<dynamic>?) ??
        [];

    if (sections.isEmpty) {
      return const SizedBox(); // Nothing to draw
    }

    final double scale = widget.scale;

    // Wrap in LayoutBuilder to get actual rendered STW dimensions from Flutter's layout engine.
    // This is critical for two reasons:
    //   1) style['width']='100%' and style['height']='71%' can't be parsed as doubles, so
    //      NinjaLayerUtils.parseDouble falls back to 320 — using constraints gives the true size.
    //   2) _resolveChildPositioned needs the STW's OWN size (e.g. 360×510), NOT widget.parentSize
    //      which is the PARENT container's size (360×719). Using the wrong value puts the
    //      spins counter at 81% × 719 = 585px, way below the visible area.
    return LayoutBuilder(builder: (context, constraints) {
      // Actual rendered dimensions of this STW widget
      final double stwW = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : (widget.parentSize?.width ?? 360.0);
      final double stwH = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : (widget.parentSize?.height ?? 510.0);

      // Dashboard Parity Sizes — use actual rendered width as diameter basis
      final double rawDiameter = stwW > 0
          ? stwW
          : (NinjaLayerUtils.parseDouble(style['width'], context) ?? 320.0);

      // Parse Wheel Properties
      final double rawWheelScale =
          NinjaLayerUtils.parseDouble(layerContent['wheelScale']) ?? 1.0;
      final double wheelScale = rawWheelScale.clamp(0.3, 3.0);

      // Dashboard parity: We removed the height fallback in the Dashboard to prevent the shrink loop.
      // We do the same here to ensure it scales purely off the container width.
      // Calculate theoretical diameter based on wheelScale
      final double calculatedDiameter = rawDiameter * 0.70 * wheelScale;
      // Cap it so the wheel physically cannot overflow the screen width, ensuring perfect 1:1 circular rendering without squashing
      final double standardDiameter = calculatedDiameter > rawDiameter ? rawDiameter : calculatedDiameter;
      
      final Size containerSize = Size(standardDiameter, standardDiameter);

      // Aesthetics
      final strokeColor =
          NinjaLayerUtils.parseColor(style['borderColor']) ?? Colors.black;

      // Scale offsets by scale to maintain layout parity across different device densities
      final double pointerOffsetX =
          (NinjaLayerUtils.parseDouble(layerContent['pointerOffsetX']) ?? 0) * scale;
      final double pointerOffsetY =
          (NinjaLayerUtils.parseDouble(layerContent['pointerOffsetY']) ?? 0) * scale;
      final double spinButtonOffsetX =
          (NinjaLayerUtils.parseDouble(layerContent['spinButtonOffsetX']) ?? 0) * scale;
      final double spinButtonOffsetY =
          (NinjaLayerUtils.parseDouble(layerContent['spinButtonOffsetY']) ?? 0) * scale;

      // Assets exactly mapped as React Layer Content
      final String pointerUrl = layerContent['pointerImage']?.toString() ?? '';
      final String spinButtonUrl =
          layerContent['spinButtonImage']?.toString() ?? '';
      final String wheelImage = layerContent['wheelImage']?.toString() ?? '';

      // Fallback default colors from React dashboard
      final List<String> defaultColors = [
        '#FF6B6B',
        '#4ECDC4',
        '#45B7D1',
        '#96CEB4',
        '#FFEAA7',
        '#DDA0DD',
        '#98D8C8',
        '#F7DC6F',
        '#BB8FCE',
        '#85C1E9',
        '#F0B27A',
        '#82E0AA',
      ];

      // Parity: Pointer and spin button sizes relative to diameter (matching Dashboard)
      final double pointerSize = standardDiameter / 2 * 0.18;
      final double innerRadius = standardDiameter / 2 * 0.15;

      // Transform logic from Dashboard
      final alignments = _getAlignments(style);

      Widget wheelCore = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. The Spinning Wheel — Parity: drop-shadow(0 4px 12px rgba(0,0,0,0.15))
          Transform.rotate(
            angle: _spinAnimation.value * (math.pi / 180),
            child: Container(
              width: containerSize.width,
              height: containerSize.height,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: wheelImage.isNotEmpty
                  // Mode 1: Custom Wheel Image OVERRIDES canvas sections (Like React)
                  ? ClipOval(
                      child: Image.network(wheelImage,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => _buildWheelPainter(
                              sections,
                              strokeColor,
                              scale,
                              layerContent,
                              defaultColors,
                              containerSize)))
                  // Mode 2: Standard SVG-style Painter
                  : _buildWheelPainter(sections, strokeColor, scale,
                      layerContent, defaultColors, containerSize),
            ),
          ),

          // 2. Spin Button — Parity: positioned at center using translate(-50%, -50%) equivalent
          Positioned(
              top: (containerSize.height / 2) + spinButtonOffsetY,
              left: (containerSize.width / 2) + spinButtonOffsetX,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: GestureDetector(
                  onTap: _startSpin,
                  behavior: HitTestBehavior.opaque,
                child: spinButtonUrl.isNotEmpty
                    // Parity: drop-shadow(0 2px 6px rgba(0,0,0,0.2)) on spin button image
                    ? Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 6,
                                offset: Offset(0, 2))
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          spinButtonUrl,
                          width: pointerSize * 1.5,
                          height: pointerSize * 1.5,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      )
                    : Container(
                        // Parity: Dashboard uses innerRadius * 2.5 for fallback button
                        width: innerRadius * 2.5,
                        height: innerRadius * 2.5,
                        decoration: BoxDecoration(
                          color: NinjaLayerUtils.parseColor(
                                  layerContent['accentColor']) ??
                              const Color(0xFF1F2937),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "SPIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            fontSize: innerRadius * 0.5,
                            letterSpacing: 1,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                ),
              )),

          // 3. Pointer — Parity: top = -pointerSize * 0.3 + offsetY, drop-shadow(0 2px 4px rgba(0,0,0,0.3))
          // FIX: Dashboard uses CSS `filter: drop-shadow()` which follows the image's alpha channel.
          // Flutter's BoxShadow always creates a RECTANGULAR shadow regardless of image shape.
          // Solution: No BoxShadow on the Container. Instead, wrap in a filter widget that
          // applies a shadow respecting the child's actual shape (ImageFiltered or no shadow).
          Positioned(
            top: -pointerSize * 0.3 + pointerOffsetY,
            left: (containerSize.width / 2) + pointerOffsetX,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: pointerUrl.isNotEmpty
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Shadow Layer using ImageFiltered & ColorFiltered to follow transparent shape
                        Transform.translate(
                          offset: const Offset(0, 2),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color.fromRGBO(0, 0, 0, 0.3),
                                BlendMode.srcIn,
                              ),
                              child: Image.network(
                                pointerUrl,
                                width: pointerSize * 1.5,
                                height: pointerSize * 1.5,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                        // Foreground Image
                        Image.network(
                          pointerUrl,
                          width: pointerSize * 1.5,
                          height: pointerSize * 1.5,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ],
                    )
                  // Parity: Dashboard renders SVG triangle fallback when no pointer image
                  : CustomPaint(
                      size: Size(pointerSize * 1.5, pointerSize * 1.5),
                      painter: _PointerTrianglePainter(
                        color: NinjaLayerUtils.parseColor(
                                layerContent['accentColor']) ??
                            const Color(0xFF1F2937),
                      ),
                    ),
            ),
          )
        ],
      );

      // Apply Opacity/Backdrop
      final isAbsolute = style['position'] == 'absolute';
      EdgeInsets margin =
          isAbsolute ? EdgeInsets.zero : const EdgeInsets.only(bottom: 20);

      // Only overlay children (Congrats/BetterLuck) are rendered inside the STW Stack.
      // Regular children (Spins Counter, etc.) are rendered by FloaterV2 in the root Stack
      // at the correct absolute positions — DO NOT re-render them here, as renderChild!
      // already returns a Positioned widget and wrapping it again causes a competing
      // ParentDataWidget crash.
      List<Widget> overlayChildren = [];
      List<Widget> regularChildren = [];

      if (widget.renderChild != null && widget.allLayers != null) {
        final childLayers = widget.allLayers!
            .where((l) => l['parent'] == widget.layer['id'])
            .toList();

        for (var child in childLayers) {
          final childName = (child['name']?.toString() ?? '').toLowerCase();
          final isCongrats = childName.contains('congrats');
          final isBetterLuck = childName.contains('better luck') ||
              childName.contains('betterluck');

          final builtChild =
              widget.renderChild!(child, parentWidth: stwW, parentHeight: stwH);
          if (builtChild == null) continue;

          if (!isCongrats && !isBetterLuck) {
            regularChildren.add(builtChild);
          } else {
            bool showOverlay = false;
            if (isCongrats && _showResult == 'congrats') showOverlay = true;
            if (isBetterLuck && _showResult == 'betterLuck') showOverlay = true;
            if (showOverlay) {
              if (overlayChildren.isEmpty) {
                // Add an invisible backdrop that dismisses the overlay when tapping outside
                overlayChildren.add(Positioned.fill(
                  key: const ValueKey('congrats_backdrop'),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showResult = null;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ));
              }

              // FIX: Place a Positioned.fill GestureDetector at the bottom of a Stack
              // sibling hierarchy. If an interactive child (e.g. copy or close button)
              // is tapped, it returns true and intercepts the tap directly, avoiding
              // gesture arena competition with this parent's onTap. If a non-interactive
              // area is tapped, the children return false, and this bottom sibling GestureDetector
              // absorbs the tap, preventing it from dismissing the overlay (backdrop).
              Widget tapAbsorber = Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {}, // Absorb taps on non-interactive card areas
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  builtChild is Positioned ? builtChild.child : builtChild,
                ],
              );

              if (builtChild is Positioned) {
                overlayChildren.add(Positioned(
                    key: ValueKey('congrats_pos_${child['id'] ?? child.hashCode}'),
                    left: builtChild.left,
                    top: builtChild.top,
                    right: builtChild.right,
                    bottom: builtChild.bottom,
                    width: builtChild.width,
                    height: builtChild.height,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('anim_${child['id'] ?? child.hashCode}'),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, opacity, innerChild) =>
                          Opacity(opacity: opacity, child: innerChild),
                      child: tapAbsorber,
                    )));
              } else {
                overlayChildren.add(TweenAnimationBuilder<double>(
                  key: ValueKey('anim_${child['id'] ?? child.hashCode}'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, opacity, innerChild) =>
                      Opacity(opacity: opacity, child: innerChild),
                  child: tapAbsorber,
                ));
              }
            }
          }
        }
      }

      // Parity: Pass through layer background styles (backgroundColor, backgroundImage, backgroundSize, backgroundPosition)
      final bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']);
      final bgImage = style['backgroundImage']?.toString();
      // Parity: React defaults backgroundSize to 'cover', backgroundPosition to 'center'
      final String bgSize = style['backgroundSize']?.toString() ?? 'cover';
      final String bgPosition =
          style['backgroundPosition']?.toString() ?? 'center';
      BoxFit bgFit = BoxFit.cover;
      if (bgSize == 'contain')
        bgFit = BoxFit.contain;
      else if (bgSize == 'fill') bgFit = BoxFit.fill;
      Alignment bgAlignment = Alignment.center;
      if (bgPosition == 'top' || bgPosition == 'top center')
        bgAlignment = Alignment.topCenter;
      else if (bgPosition == 'bottom' || bgPosition == 'bottom center')
        bgAlignment = Alignment.bottomCenter;
      else if (bgPosition == 'left' || bgPosition == 'center left')
        bgAlignment = Alignment.centerLeft;
      else if (bgPosition == 'right' || bgPosition == 'center right')
        bgAlignment = Alignment.centerRight;
      else if (bgPosition == 'top left')
        bgAlignment = Alignment.topLeft;
      else if (bgPosition == 'top right')
        bgAlignment = Alignment.topRight;
      else if (bgPosition == 'bottom left')
        bgAlignment = Alignment.bottomLeft;
      else if (bgPosition == 'bottom right')
        bgAlignment = Alignment.bottomRight;

      return Container(
          // Use double.infinity so the Container fills the full Positioned allocation from FloaterV2
          width: double.infinity,
          height: double.infinity,
          alignment: alignments,
          margin: margin,
          decoration: BoxDecoration(
            color: bgColor,
            image: (bgImage != null && bgImage.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(bgImage),
                    fit: bgFit,
                    alignment: bgAlignment)
                : null,
          ),
          padding: NinjaLayerUtils.parsePadding(style['padding'], context),
          // FIX: Use SizedBox.expand so the Stack fills the full STW allocation
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // The wheel sits centered in the full-size Stack and is allowed to overflow parent constraints
                OverflowBox(
                  minWidth: 0.0,
                  maxWidth: double.infinity,
                  minHeight: 0.0,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: containerSize.width,
                    height: containerSize.height,
                    child: wheelCore,
                  ),
                ),
                // Regular layout children (Spins Left Counter, etc.) are NOT injected here, 
                // they are injected at the ROOT level by FloaterV2 to maintain absolute positioning relative to the screen.
                ...regularChildren,
                if (_showConfetti)
                  Positioned.fill(
                    key: const ValueKey('stw_confetti_overlay'),
                    child: ClipRect(
                      child: _ConfettiOverlay(
                          confettiImage:
                              layerContent['confettiImage']?.toString()),
                    ),
                  ),
                // Gamification overlays (Congrats/BetterLuck) — zIndex:30, full coverage
                ...overlayChildren,
              ],
            ),
          ),
      ); // end Container
    }); // end LayoutBuilder
  }

  Alignment _getAlignments(Map<String, dynamic> style) {
    final align = style['alignSelf']?.toString() ?? 'center';
    if (align == 'flex-start' || align == 'left') return Alignment.centerLeft;
    if (align == 'flex-end' || align == 'right') return Alignment.centerRight;
    return Alignment.center;
  }
}

class _WheelPainter extends CustomPainter {
  final List<dynamic> sections;
  final Color strokeColor;
  final double scale;
  final List<String> defaultColors;
  final Color textColor;
  final Color accentColor;

  _WheelPainter({
    required this.sections,
    required this.strokeColor,
    required this.scale,
    required this.defaultColors,
    required this.textColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sections.isEmpty) return;

    // Emulate React's SVG viewBox: -10 -10 320 320 (Padding = 10 units per side on a 320 scale)
    final double paddingRatio = 10.0 / 320.0;
    final double padding = size.width * paddingRatio;

    final double radius = (size.width / 2) - padding;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweepAngle = (2 * math.pi) / sections.length;

    // Parity: Outer ring radius offset is 4 units in SVG space
    final double outerRadiusOffset = size.width * (4.0 / 320.0);
    final double outerRingRadius = radius + outerRadiusOffset;

    // Start pointing TOP (-90 degrees) to match standard SVG viewBox setup
    double currentAngle = -math.pi / 2;

    // Parity: Internal borders are 1.5 SVG units
    final double scaledBorderWidth = size.width * (1.5 / 320.0);
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledBorderWidth;

    // Parity: Outer ring stroke is 8 SVG units
    final double scaledOuterRingWidth = size.width * (8.0 / 320.0);
    final Paint outerRingPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledOuterRingWidth;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i] as Map<String, dynamic>;

      // Match React color resolution
      final String rawColor = section['color']?.toString() ??
          defaultColors[i % defaultColors.length];
      final Color fillColor =
          NinjaLayerUtils.parseColor(rawColor) ?? Colors.white;

      // Draw Wedge
      final Paint fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        fillPaint,
      );

      // Draw Sector Border (internal lines)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Text Drawing Parity
      // Support dynamic placeholders like {{name}}, {{value}} using the section map
      String textStr = section['name']?.toString() ?? 'Section ${i + 1}';
      if (textStr.contains('{{')) {
        final RegExp exp = RegExp(r'\{\{([^}]+)\}\}');
        textStr = textStr.replaceAllMapped(exp, (match) {
          final prop = match.group(1)?.trim();
          if (prop != null && section.containsKey(prop)) {
            return section[prop]?.toString() ?? match.group(0)!;
          }
          // If the backend nested the reward object inside the section
          if (prop != null && section['reward'] is Map && (section['reward'] as Map).containsKey(prop)) {
             return (section['reward'] as Map)[prop]?.toString() ?? match.group(0)!;
          }
          return 'No Reward';
        });
      }

      if (textStr.isNotEmpty) {
        canvas.save();

        // FIX: Translate to the text anchor point first (radially outward from center),
        // then rotate for tangential text orientation.
        // Previous approach (translate-to-center then draw at offset) placed text
        // at the wrong position for top-half sections.
        final double mid = currentAngle + (sweepAngle / 2);
        final double textR = radius * 0.62;
        final double anchorX = center.dx + textR * math.cos(mid);
        final double anchorY = center.dy + textR * math.sin(mid);
        canvas.translate(anchorX, anchorY);

        // BUG 3 FIX: Dashboard uses unconditional rotation: (midAngle * 180/PI) + 90
        // The previous conditional flip (isBottom check) produced different text
        // orientation than the dashboard for bottom-half sections.
        canvas.rotate(mid + math.pi / 2);

        final baseFontSize =
            math.max(8.0, math.min(14.0, (150.0 / sections.length) * 1.2));
        final double layoutScaleRatio = size.width / 300.0;
        // BUG 5 FIX: containerSize already includes scale (baseDim * 0.70 * scale * wheelScale)
        // so size.width already has scale baked in. Multiplying by scale again = double-scaling.
        final finalFontSize = baseFontSize * layoutScaleRatio;

        String displayText = textStr;
        if (displayText.length > 12)
          displayText = '${displayText.substring(0, 11)}…';

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: displayText,
            style: TextStyle(
                color: textColor,
                fontSize: finalFontSize,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                // BUG 14 FIX: Dashboard uses fixed CSS values: textShadow: '0 1px 3px rgba(0,0,0,0.5)'
                shadows: const [
                  Shadow(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  )
                ]),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(maxWidth: radius * 0.7);
        // Center text at the anchor point
        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }

      currentAngle += sweepAngle;
    }

    // Draw outer boundary ring
    canvas.drawCircle(center, outerRingRadius, outerRingPaint);

    // Decorative dots
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final double scaledDotRadius = size.width * (3.0 / 320.0);
    for (int i = 0; i < sections.length; i++) {
      final double angle = i * sweepAngle - (math.pi / 2);
      final double dotX = center.dx + outerRingRadius * math.cos(angle);
      final double dotY = center.dy + outerRingRadius * math.sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), scaledDotRadius, dotPaint);
    }

    // Draw Center Circle
    // Parity: React strokeWidth={3} in SVG units → scale proportionally
    final double scaledCenterStroke = size.width * (3.0 / 320.0);
    final innerRadius = radius * 0.15;
    final Paint centerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final Paint centerStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = scaledCenterStroke
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, innerRadius, centerPaint);
    canvas.drawCircle(center, innerRadius, centerStroke);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return true;
  }
}

/// Parity: Dashboard renders an SVG triangle pointer when no pointer image is set
/// SVG: <polygon points="20,38 6,6 34,6" fill={accentColor} stroke="white" strokeWidth={2} />
class _PointerTrianglePainter extends CustomPainter {
  final Color color;
  _PointerTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Map SVG viewBox 0 0 40 40 coords to actual size
    final sx = size.width / 40;
    final sy = size.height / 40;

    final path = Path()
      ..moveTo(20 * sx, 38 * sy) // bottom center
      ..lineTo(6 * sx, 6 * sy) // top left
      ..lineTo(34 * sx, 6 * sy) // top right
      ..close();

    // Draw Drop Shadow (to match dashboard filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3)))
    final shadowPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Fill
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
    // Stroke
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * sx);
  }

  @override
  bool shouldRepaint(covariant _PointerTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WheelBackgroundPainter extends CustomPainter {
  final List<dynamic> sections;
  final List<String> defaultColors;

  _WheelBackgroundPainter(
      {required this.sections, required this.defaultColors});

  @override
  void paint(Canvas canvas, Size size) {
    if (sections.isEmpty) return;

    final double paddingRatio = 10.0 / 320.0;
    final double padding = size.width * paddingRatio;
    final double radius = (size.width / 2) - padding;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweepAngle = (2 * math.pi) / sections.length;
    double currentAngle = -math.pi / 2;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i] as Map<String, dynamic>;
      final String rawColor = section['color']?.toString() ??
          defaultColors[i % defaultColors.length];
      final Color fillColor =
          NinjaLayerUtils.parseColor(rawColor) ?? Colors.white;

      final Paint fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        fillPaint,
      );
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _WheelBackgroundPainter oldDelegate) => true;
}

class _WheelForegroundPainter extends CustomPainter {
  final List<dynamic> sections;
  final double scale;
  final Color textColor;
  final Color accentColor;
  final Color strokeColor;

  _WheelForegroundPainter({
    required this.sections,
    required this.scale,
    required this.textColor,
    required this.accentColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sections.isEmpty) return;

    final double paddingRatio = 10.0 / 320.0;
    final double padding = size.width * paddingRatio;
    final double radius = (size.width / 2) - padding;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweepAngle = (2 * math.pi) / sections.length;
    final double outerRadiusOffset = size.width * (4.0 / 320.0);
    final double outerRingRadius = radius + outerRadiusOffset;

    double currentAngle = -math.pi / 2;

    final double scaledBorderWidth = size.width * (1.5 / 320.0);
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledBorderWidth;

    final double scaledOuterRingWidth = size.width * (8.0 / 320.0);
    final Paint outerRingPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledOuterRingWidth;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i] as Map<String, dynamic>;

      // Draw Sector Border (internal lines)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Text Drawing Parity
      // React: name = sec?.name || `Section ${i + 1}`;
      String textStr = section['name']?.toString() ?? 'Section ${i + 1}';
      if (textStr.contains('{{')) {
        final RegExp exp = RegExp(r'\{\{([^}]+)\}\}');
        textStr = textStr.replaceAllMapped(exp, (match) {
          final prop = match.group(1)?.trim();
          if (prop != null && section.containsKey(prop)) {
            return section[prop]?.toString() ?? match.group(0)!;
          }
          if (prop != null && section['reward'] is Map && (section['reward'] as Map).containsKey(prop)) {
             return (section['reward'] as Map)[prop]?.toString() ?? match.group(0)!;
          }
          return 'No Reward';
        });
      }

      if (textStr.isNotEmpty) {
        canvas.save();
        // FIX: Translate-first approach — same as _WheelPainter
        final double mid = currentAngle + (sweepAngle / 2);
        final double textRadius = radius * 0.62;
        final double anchorX = center.dx + textRadius * math.cos(mid);
        final double anchorY = center.dy + textRadius * math.sin(mid);
        canvas.translate(anchorX, anchorY);

        // BUG 3 FIX: Match dashboard's unconditional rotation for 1:1 parity.
        canvas.rotate(mid + math.pi / 2);

        final baseFontSize =
            math.max(8.0, math.min(14.0, (150.0 / sections.length) * 1.2));
        final double layoutScaleRatio = size.width / 300.0;
        // BUG 5 FIX: Remove double-scaling (same fix as _WheelPainter).
        final finalFontSize = baseFontSize * layoutScaleRatio;

        String displayText = textStr;
        if (displayText.length > 12)
          displayText = '${displayText.substring(0, 11)}…';

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: displayText,
            style: TextStyle(
                color: textColor,
                fontSize: finalFontSize,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                shadows: const [
                  Shadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      offset: Offset(0, 1),
                      blurRadius: 3)
                ]),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(maxWidth: radius * 0.7);
        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }

      currentAngle += sweepAngle;
    }

    // Draw outer boundary ring
    canvas.drawCircle(center, outerRingRadius, outerRingPaint);

    // Decorative dots
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final double scaledDotRadius = size.width * (3.0 / 320.0);
    for (int i = 0; i < sections.length; i++) {
      final double angle = i * sweepAngle - (math.pi / 2);
      final double dotX = center.dx + outerRingRadius * math.cos(angle);
      final double dotY = center.dy + outerRingRadius * math.sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), scaledDotRadius, dotPaint);
    }

    // Draw Center Circle
    // Parity: React strokeWidth={3} in SVG units → scale proportionally
    final double scaledCenterStroke = size.width * (3.0 / 320.0);
    final innerRadius = radius * 0.15;
    final Paint centerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final Paint centerStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = scaledCenterStroke
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, innerRadius, centerPaint);
    canvas.drawCircle(center, innerRadius, centerStroke);
  }

  @override
  bool shouldRepaint(covariant _WheelForegroundPainter oldDelegate) => true;
}

class _SectionClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;
  final double radius;

  _SectionClipper(
      {required this.startAngle,
      required this.sweepAngle,
      required this.radius});

  @override
  Path getClip(Size size) {
    // FIX: Center must be the actual center of the container (size.width/2, size.height/2)
    // Previous bug used (radius, radius) which offset by `padding` pixels from true center,
    // causing section images to be misaligned from their wheel slices.
    final center = Offset(size.width / 2, size.height / 2);
    final Path path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _SectionClipper oldClipper) => true;
}

// --------------------------------------------------------
// Confetti Gamification Engine (Dashboard Parity)
// --------------------------------------------------------

class _ConfettiOverlay extends StatefulWidget {
  final String? confettiImage;
  const _ConfettiOverlay({this.confettiImage});

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final List<Color> _colors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF45B7D1),
    const Color(0xFFFFEAA7),
    const Color(0xFFDDA0DD),
    const Color(0xFFFFD700),
    const Color(0xFFFF69B4),
    const Color(0xFF00CED1)
  ];

  @override
  void initState() {
    super.initState();
    // Parity: React uses fixed 3500ms for the confetti container
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500));
    _generateParticles();
    _controller.forward();
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: math.Random().nextDouble(),
        yOffset: -0.1 -
            (math.Random().nextDouble() * 0.2), // Start slightly above screen
        color: _colors[math.Random().nextInt(_colors.length)],
        delay: math.Random().nextDouble() * 0.8,
        size: 6.0 + (math.Random().nextDouble() * 10.0),
        rotationOffset: math.Random().nextDouble() * 360.0,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
              confettiImage: widget.confettiImage,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double yOffset;
  final Color color;
  final double delay;
  final double size;
  final double rotationOffset;

  _ConfettiParticle(
      {required this.x,
      required this.yOffset,
      required this.color,
      required this.delay,
      required this.size,
      required this.rotationOffset});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final String?
      confettiImage; // Note: For exact parity we would load UI Image, but using solid rects for now

  // Note: confettiImage rendering via ui.Image would require async loading.
  // For now solid rects are used as fallback when no image.
  _ConfettiPainter(
      {required this.particles, required this.progress, this.confettiImage});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Delay phase
      double pProgress = (progress - (p.delay * 0.3)).clamp(0.0, 1.0);
      if (pProgress <= 0) continue;

      // Parity: Fall animation (stw-confetti-fall)
      // 0% -> opacity 1, y = 0
      // 25% -> opacity 1
      // 100% -> opacity 0, y = height + 50

      // BUG 15 FIX: Dashboard CSS starts fade at 25% (not 70%)
      // @keyframes stw-confetti-fall { 0% { opacity: 1 } 25% { opacity: 1 } 100% { opacity: 0 } }
      double opacity =
          pProgress > 0.25 ? 1.0 - ((pProgress - 0.25) / 0.75) : 1.0;
      double currentY =
          size.height * p.yOffset + (size.height + 50) * pProgress;
      double currentX = size.width * p.x;

      final Paint paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(currentX, currentY);
      // Spin while falling
      canvas.rotate(p.rotationOffset + (pProgress * math.pi * 4));

      // Draw standard rect confetti
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

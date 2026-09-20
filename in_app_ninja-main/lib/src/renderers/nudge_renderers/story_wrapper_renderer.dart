import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/campaign.dart';
import '../../callbacks/ninja_callback_manager.dart';
import 'slide_container_renderer.dart';

class NinjaStoryWrapperRenderer extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback? onDismiss;
  final Function(String action, Map<String, dynamic>? data)? onCTAClick;
  final VoidCallback? onImpression; // FIX: Added onImpression

  const NinjaStoryWrapperRenderer({
    Key? key,
    required this.campaign,
    this.onDismiss,
    this.onCTAClick,
    this.onImpression,
  }) : super(key: key);

  @override
  State<NinjaStoryWrapperRenderer> createState() =>
      _NinjaStoryWrapperRendererState();
}

class _NinjaStoryWrapperRendererState extends State<NinjaStoryWrapperRenderer>
    with SingleTickerProviderStateMixin {
  int _currentStoryIndex = 0;
  int _previousStoryIndex = 0;
  List<dynamic> _stories = [];

  bool _isTransitioning = false;
  String _direction = 'forward'; // 'forward' | 'backward'
  late AnimationController _transitionController;

  bool get _shouldLoop {
    final fullscreenConfig = widget.campaign.config['fullscreenConfig'];
    if (fullscreenConfig is Map) {
      final val = fullscreenConfig['loopStories'];
      if (val is bool) return val;
    }
    // Fallback: check top-level config
    final topLevel = widget.campaign.config['loopStories'];
    if (topLevel is bool) return topLevel;
    return true; // Dashboard default is TRUE
  }

  @override
  void initState() {
    super.initState();
    
    // Track impression
    if (widget.onImpression != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onImpression!();
      });
    }

    _buildStories();
    
    // Dispatch initial slide open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NinjaCallbackManager.dispatchSlideOpen(
        campaignId: widget.campaign.id,
        slideIndex: 0,
      );
    });
    
    // Dashboard parity: 350ms duration matching CSS `0.35s`
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
            _previousStoryIndex = _currentStoryIndex;
          });
        }
      }
    });
  }

  void _buildStories() {
    if (widget.campaign.stories != null &&
        widget.campaign.stories!.isNotEmpty) {
      _stories = widget.campaign.stories!;
    } else if (widget.campaign.layers != null &&
        widget.campaign.layers!.isNotEmpty) {
      // Legacy: wrap single layers array as one story
      _stories = [
        {
          'id': 'legacy_story',
          'title': widget.campaign.title,
          'layers': widget.campaign.layers,
        }
      ];
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _goToNextStory() {
    if (_stories.isEmpty || _isTransitioning) return;

    final isLastStory = _currentStoryIndex == _stories.length - 1;
    if (isLastStory && !_shouldLoop) {
      widget.onDismiss?.call();
      return;
    }

    final nextIndex = (_currentStoryIndex + 1) % _stories.length;
    _navigateTo(nextIndex, 'forward');
  }

  void _goToPrevStory() {
    if (_stories.isEmpty || _isTransitioning) return;

    final isFirstStory = _currentStoryIndex == 0;
    if (isFirstStory && !_shouldLoop) {
      return; // Dashboard: if no loop, ignore going back past first story
    }

    final prevIndex = (_currentStoryIndex - 1 + _stories.length) % _stories.length;
    _navigateTo(prevIndex, 'backward');
  }

  void _navigateTo(int index, String direction) {
    if (!mounted) return;
    if (index == _currentStoryIndex) return;

    setState(() {
      _previousStoryIndex = _currentStoryIndex;
      _currentStoryIndex = index;
      _direction = direction;
      _isTransitioning = true;
    });

    _transitionController.forward(from: 0.0);
  }

  Widget _buildStoryRenderer(int index) {
    final story = _stories[index];
    return SlideContainerRenderer(
      // Important to use a stable key related to the story so state doesn't wipe randomly
      key: ValueKey('story_${story['id'] ?? index}'),
      story: story is Map<String, dynamic>
          ? story
          : Map<String, dynamic>.from(story),
      onNextStory: _goToNextStory,
      onPrevStory: _goToPrevStory,
      onDismiss: widget.onDismiss,
      onCTAClick: widget.onCTAClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return Container(color: Colors.black);
    }

    return Material(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Normal Non-Transitioning Render
          if (!_isTransitioning) {
            return _buildStoryRenderer(_currentStoryIndex);
          }

          // HIGH-FIDELITY 3D CUBE RENDERER (Parity with StoryCubeTransition.tsx)
          final double w = constraints.maxWidth;
          final double halfWidth = w / 2.0;

          return AnimatedBuilder(
            animation: _transitionController,
            builder: (context, _) {
              // Custom cubic easing imitating CSS `cubic-bezier(0.1, 0, 0, 1)` (outQuad/outCubic approximate)
              // Curves.easeOutCubic closely mirrors 0.1, 0, 0, 1 mapping.
              final double t = Curves.easeOutCubic.transform(_transitionController.value);

              // --- Matrix Formulas ---
              final double rotationTarget = _direction == 'forward' ? -90.0 : 90.0;
              final double incomingStartDeg = _direction == 'forward' ? 90.0 : -90.0;
              
              // Base parent wrapper applying perspective and primary global frame spin
              final double parentRotY = (rotationTarget * t) * (math.pi / 180.0);
              final Matrix4 parentTransform = Matrix4.identity()
                ..setEntry(3, 2, 1.0 / 1800.0)       // CSS: perspective: 1800px
                ..translate(0.0, 0.0, -halfWidth)     // CSS: translateZ(-halfWidth)
                ..rotateY(parentRotY);                // CSS: rotateY(...)

               // Outgoing Element transforms (Front face of the spinning cube)
              final Matrix4 outgoingTransform = Matrix4.identity()
                ..rotateY(0.0)
                ..translate(0.0, 0.0, halfWidth);
                
              final double shadowOutOpacity = (t * 0.6).clamp(0.0, 0.6); // Animation: shadowOut 0->0.6

              // Incoming Element transforms (Side face waiting to become front face)
              final double incomingRotY = incomingStartDeg * (math.pi / 180.0);
              final Matrix4 incomingTransform = Matrix4.identity()
                ..rotateY(incomingRotY)
                ..translate(0.0, 0.0, halfWidth);
                
              final double shadowInOpacity = (0.6 - (t * 0.6)).clamp(0.0, 0.6); // Animation: shadowIn 0.6->0

              return Container(
                color: Colors.black, // Dark void backdrop logic
                width: w,
                clipBehavior: Clip.hardEdge,
                child: Transform(
                  transform: parentTransform,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Outgoing Plane
                      Transform(
                        transform: outgoingTransform,
                        alignment: Alignment.center,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            IgnorePointer(child: _buildStoryRenderer(_previousStoryIndex)),
                            Container(color: Colors.black.withOpacity(shadowOutOpacity)),
                          ],
                        ),
                      ),
                      
                      // Incoming Plane
                      Transform(
                        transform: incomingTransform,
                        alignment: Alignment.center,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            IgnorePointer(child: _buildStoryRenderer(_currentStoryIndex)),
                            Container(color: Colors.black.withOpacity(shadowInOpacity)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

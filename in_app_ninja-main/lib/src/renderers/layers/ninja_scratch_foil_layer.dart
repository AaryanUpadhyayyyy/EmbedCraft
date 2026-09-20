import 'package:flutter/material.dart';

import 'ninja_scratcher.dart';
import 'dart:convert'; // For base64Decode
import 'ninja_layer_utils.dart';
import '../../app_ninja.dart';
import '../../callbacks/ninja_callback_manager.dart';
import '../../models/ninja_callback_data.dart';
import '../../utils/ninja_logger.dart';

class NinjaScratchFoilLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final List<dynamic>? allLayers;
  final double scale;
  final Function(String action, Map<String, dynamic> data)? onAction;

  const NinjaScratchFoilLayer({
    Key? key,
    required this.layer,
    this.allLayers,
    this.scale = 1.0,
    this.onAction,
  }) : super(key: key);

  @override
  State<NinjaScratchFoilLayer> createState() => _NinjaScratchFoilLayerState();
}

class _NinjaScratchFoilLayerState extends State<NinjaScratchFoilLayer> {
  // Fix: Use GlobalObjectKey to preserve Scratcher state even if this parent state is recreated
  late final GlobalKey<NinjaScratcherState> _scratcherKey;

  // Custom cursor state — tracks pointer position for the cursor overlay image.
  // The scratcher package has no built-in cursor support, so we render the
  // cursor image as an absolutely-positioned widget in a Stack and hide
  // the system cursor via MouseRegion.
  final ValueNotifier<Offset?> _cursorPositionNotifier = ValueNotifier(null);
  
  bool _isFullyScratched = false;
  double _lastDispatchedProgress = 0.0;

  bool _isClaimed = false;
  String? _resolvedLedgerId;
  String? _resolvedRewardId;

  @override
  void initState() {
    super.initState();
    _scratcherKey = GlobalObjectKey<NinjaScratcherState>('scratcher_${widget.layer['id'] ?? hashCode}');
    _initializeState();
  }

  @override
  void didUpdateWidget(NinjaScratchFoilLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data updates dynamically, re-evaluate state
    if (widget.layer['mappedState']?.toString() != oldWidget.layer['mappedState']?.toString()) {
      _initializeState();
    }
  }

  void _initializeState() {
    final mappedState = widget.layer['mappedState'];
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    
    // Fallbacks to determine if the scratch has already occurred for this item
    if (mappedState != null) {
        // 1. Direct status from UserLedger schema
        final status = mappedState['status']?.toString().toLowerCase();
        if (status == 'unlocked' || status == 'claimed' || status == 'redeemed') {
            _isClaimed = true;
        } 
        // 2. Boolean explicit checks if provided
        else if (mappedState['isScratched'] == true) {
            _isClaimed = true;
        }
        // 3. Optional binding key from Dashboard editor
        else if (content['statusBindingKey'] != null) {
            final keyStr = content['statusBindingKey'].toString();
            if (keyStr.isNotEmpty) {
               final val = mappedState[keyStr];
               if (val == true || val == 'unlocked' || val == 'claimed') {
                   _isClaimed = true;
               }
            }
        }
        
        _resolvedLedgerId = mappedState['_id']?.toString() ?? mappedState['id']?.toString();
        
        // Fallback to custom binding key
        if (content['rewardIdBindingKey'] != null && content['rewardIdBindingKey'].toString().isNotEmpty) {
            _resolvedRewardId = mappedState[content['rewardIdBindingKey'].toString()]?.toString();
        } else {
            _resolvedRewardId = mappedState['reward_id']?.toString() ?? mappedState['rewardId']?.toString();
        }
    }
    
    // GENUINE FIX: Standalone floater campaigns only pass the raw Reward document (status: 'active'),
    // OR they might not pass mappedState to the foil layer at all.
    // To respect backend deduplication rules and auto-allocate tickets, we MUST fetch the true User Ledger state asynchronously
    // to discover if the backend refused to allocate a ticket (or if they previously unlocked it), OR if we need to call initiateGame.
    if (!_isClaimed) {
        _syncLedgerState();
    }
  }

  Future<void> _syncLedgerState() async {
      try {
          final campaignId = widget.layer['campaignId']?.toString();
          final rawMappedId = widget.layer['mappedState']?['_id']?.toString();
          
          final wallet = await AppNinja.fetchDataSource('/api/v1/game/wallet');
          NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: _syncLedgerState fetched wallet. campaignId=$campaignId, rawMappedId=$rawMappedId, walletSize=${wallet.length}");
          
          // 1. Prioritize finding a 'pending' (unscratched) ticket for this campaign
          var ticket = wallet.firstWhere((t) {
              final tCampId = t['campaignId']?.toString() ?? t['campaignIdRef']?.toString();
              final tRewardId = t['rewardIdRef']?.toString();
              final tStatus = t['status']?.toString().toLowerCase();
              
              bool matchesId = false;
              if (campaignId != null && campaignId.isNotEmpty && tCampId == campaignId) {
                  if (rawMappedId != null && rawMappedId.isNotEmpty) {
                      matchesId = (tRewardId == rawMappedId);
                  } else {
                      matchesId = true;
                  }
              } else if (rawMappedId != null && rawMappedId.isNotEmpty && tRewardId == rawMappedId) {
                  matchesId = true;
              }
              
              NinjaLog.d('AppNinja', "NinjaScratchFoilLayer Match Check: tCampId=$tCampId, tRewardId=$tRewardId, tStatus=$tStatus, matchesId=$matchesId");
                                
              return matchesId && tStatus == 'pending';
          }, orElse: () => null);
          
          // 2. If NO pending ticket is found, the backend deduplicated or hasn't allocated one yet.
          // Attempt to explicitly generate a new ticket via the gamification engine (if limits allow).
          if (ticket == null && campaignId != null && campaignId.isNotEmpty) {
              NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: No pending ticket found, requesting backend allocation...");
              final initRes = await AppNinja.initiateGame(campaignId);
              
              if (initRes['success'] == true) {
                  NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Backend allocated a new ticket!");
                  // Fetch the updated wallet to retrieve the exact Ledger ID of the newly generated ticket
                  final updatedWallet = await AppNinja.fetchDataSource('/api/v1/game/wallet');
                  ticket = updatedWallet.firstWhere((t) {
                      final tCampId = t['campaignId']?.toString() ?? t['campaignIdRef']?.toString();
                      final tStatus = t['status']?.toString().toLowerCase();
                      return tCampId == campaignId && tStatus == 'pending';
                  }, orElse: () => null);
              } else {
                  NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Backend refused allocation (Limits reached or deduplicated).");
              }
          }

          // 3. If STILL no pending ticket (backend blocked it), fallback to the OLD ticket so we can correctly mark it as claimed.
          ticket ??= wallet.firstWhere((t) {
              final tCampId = t['campaignId']?.toString() ?? t['campaignIdRef']?.toString();
              final tRewardId = t['rewardIdRef']?.toString();
              
              bool matchesId = false;
              if (campaignId != null && campaignId.isNotEmpty && tCampId == campaignId) {
                  if (rawMappedId != null && rawMappedId.isNotEmpty) {
                      matchesId = (tRewardId == rawMappedId);
                  } else {
                      matchesId = true;
                  }
              } else if (rawMappedId != null && rawMappedId.isNotEmpty && tRewardId == rawMappedId) {
                  matchesId = true;
              }
              
              return matchesId;
          }, orElse: () => null);
          
          if (ticket != null && mounted) {
              setState(() {
                  _resolvedLedgerId = ticket['_id']?.toString() ?? ticket['id']?.toString();
                  final ticketStatus = ticket['status']?.toString().toLowerCase();
                  if (ticketStatus == 'unlocked' || ticketStatus == 'claimed' || ticketStatus == 'redeemed') {
                      _isClaimed = true;
                  } else if (_resolvedLedgerId != null && AppNinja.isTicketLocallyUnlocked(_resolvedLedgerId!)) {
                      _isClaimed = true;
                  }
              });
          }
      } catch (e) {
          NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Error syncing ledger state: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Building scratch layer ${widget.layer['id']}");

    // Content Parsing
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};
    
    NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: cursorImage in content: ${content['cursorImage']}");

    // Properties
    // Default to gray for foil if not specified
    final coverColor = NinjaLayerUtils.parseColor(content['coverColor']) ?? const Color(0xFFCCCCCC);
    
    // Size is responsive to container
    final scratchSize = (NinjaLayerUtils.parseDouble(content['scratchSize']) ?? 40.0) * widget.scale;
    
    // Threshold Parsing (Robust to %)
    double threshold = 50.0;
    if (content['revealThreshold'] != null) {
       String tStr = content['revealThreshold'].toString().replaceAll('%', '').trim();
       threshold = double.tryParse(tStr) ?? 50.0;
    }

    // Border Radius Logic
    dynamic radiusRaw = content['borderRadius'] ?? style['borderRadius'];
    BorderRadius borderRadiusVal = BorderRadius.zero;

    if (radiusRaw is Map) {
      borderRadiusVal = BorderRadius.only(
        topLeft: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['topLeft']) ?? 0) * widget.scale),
        topRight: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['topRight']) ?? 0) * widget.scale),
        bottomLeft: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['bottomLeft']) ?? 0) * widget.scale),
        bottomRight: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['bottomRight']) ?? 0) * widget.scale),
      );
    } else {
       // Single value (Dashboard Slider)
       final r = (NinjaLayerUtils.parseDouble(radiusRaw) ?? 0) * widget.scale;
       borderRadiusVal = BorderRadius.circular(r);
    }

    // Image Resolution Logic (Http & Data URI)
    Image? scratchImage;
    if (content['coverImage'] != null) {
      String url = content['coverImage'].toString().trim();
      if (url.isNotEmpty) {
        if (url.startsWith('http')) {
          final uri = Uri.tryParse(url);
          if (uri != null && uri.host.isNotEmpty) {
            scratchImage = Image.network(
               url, 
               fit: BoxFit.fill, // Dashboard parity: defaults to stretch
               errorBuilder: (c, e, s) {
                  NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Network Image Error: $e");
                  return Container(color: coverColor); 
               }
            );
          } else {
             NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Invalid URL ignored: $url");
          }
        } else if (url.startsWith('data:')) {
           try {
              final base64String = url.split(',').last.replaceAll(RegExp(r'\s+'), '');
              scratchImage = Image.memory(
                  base64Decode(base64String), 
                  fit: BoxFit.fill, // Dashboard parity: defaults to stretch
                  errorBuilder: (c, e, s) {
                     NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Data URI Decode Error: $e");
                     return Container(color: coverColor);
                  }
              );
           } catch (e) {
              NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Base64 Parse Error: $e");
           }
        }
      }
    }
    
    // Custom Cursor — Dashboard parity: content.cursorImage
    final String cursorImageUrl = content['cursorImage']?.toString() ?? '';
    final bool hasCursorImage = cursorImageUrl.isNotEmpty && cursorImageUrl.startsWith('http');
    final double cursorSize = 80.0 * widget.scale; // Independent, big custom cursor

    // Skip scratcher if already claimed
    if (_isClaimed) {
        return const SizedBox.shrink(); // Show what's behind
    }

    // Build the core scratcher widget
    Widget scratcherWidget = NinjaScratcher(
      key: _scratcherKey, // Correct Key Usage
      rebuildOnResize: false, // Prevent jittery layout resizes from resetting the scratcher visually
      brushSize: scratchSize * widget.scale, // FIX: properly scale brush size for device density
      threshold: threshold,
      color: coverColor,
      image: scratchImage,
      onChange: (value) {
          // Dispatch progress at 10% intervals to prevent spamming
          if (value - _lastDispatchedProgress >= 10.0) {
              _lastDispatchedProgress = value;
              NinjaCallbackManager.dispatchScratchCardScratched(
                  campaignId: widget.layer['campaignId']?.toString() ?? '',
                  percentScratched: value,
                  additionalData: {'layerId': widget.layer['id']},
              );
          }
      },
      onThreshold: () {
         NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Threshold reached ($threshold%)! revealing...");
         
         if (mounted) {
             setState(() {
                 _isFullyScratched = true;
             });
         }
         
         // AUTO-REVEAL VISUAL (Using State Key)
         _scratcherKey.currentState?.reveal(duration: const Duration(milliseconds: 600));

         String campaignId = widget.layer['campaignId']?.toString() ?? '';
         
         // AUTO-RESOLVE: Transition ledger entry from 'pending' → 'unlocked'
         if (_resolvedLedgerId != null && _resolvedLedgerId!.isNotEmpty) {
             NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Auto-resolving ledger ticket $_resolvedLedgerId");
              AppNinja.completeScratchWalletTicket(_resolvedLedgerId!).then((res) {
                  NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Wallet ticket resolved → ${res['success']}");
              });
         }

         // DISPATCH: Standardized callback through NinjaCallbackManager
         NinjaCallbackManager.dispatchScratchCardRevealed(
             campaignId: campaignId,
             additionalData: {
                 'layerId': widget.layer['id'],
                 'ledgerId': _resolvedLedgerId,
                 'rewardId': _resolvedRewardId,
             },
         );

         // FORWARD: Notify parent renderer via onAction (uses standardized constant)
         if (widget.onAction != null) {
            widget.onAction!(NINJA_SCRATCH_CARD_REVEALED, {
                'layerId': widget.layer['id'],
                'ledgerId': _resolvedLedgerId,   // Specific transaction
                'rewardId': _resolvedRewardId    // Underlying prize
            });
         }
      },
      // Transparent child allows seeing layers BEHIND the scratcher widget when scratched
      child: const SizedBox.expand(),
    );

    // Wrap in ClipRRect for border radius
    Widget result = ClipRRect(
      borderRadius: borderRadiusVal,
      // FIX: Disable pointer events once scratched so buttons underneath can be clicked
      child: IgnorePointer(
        ignoring: _isFullyScratched,
        child: scratcherWidget,
      ),
    );

    // Custom cursor overlay — wraps in Listener (for touch) + MouseRegion (to hide system cursor)
    // The scratcher package has no cursor property, so this overlay approach provides
    // parity with the dashboard's JS cursor.
    if (hasCursorImage) {
      result = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: onPointerDown at ${event.localPosition}");
          if (!_isFullyScratched) {
            _cursorPositionNotifier.value = event.localPosition;
          }
        },
        onPointerHover: (event) {
          if (!_isFullyScratched) {
            _cursorPositionNotifier.value = event.localPosition;
          }
        },
        onPointerMove: (event) {
          NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: onPointerMove at ${event.localPosition}");
          if (!_isFullyScratched) {
            _cursorPositionNotifier.value = event.localPosition;
          }
        },
        onPointerUp: (_) {
          _cursorPositionNotifier.value = null;
        },
        onPointerCancel: (_) {
          _cursorPositionNotifier.value = null;
        },
        child: MouseRegion(
          opaque: false,
          cursor: SystemMouseCursors.none,
          onExit: (_) {
            _cursorPositionNotifier.value = null;
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              result,
              // Custom cursor image overlay — pointer-events pass through
              ValueListenableBuilder<Offset?>(
                valueListenable: _cursorPositionNotifier,
                builder: (context, cursorPosition, child) {
                  NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: ValueListenableBuilder rebuilding with cursorPosition: $cursorPosition");
                  if (cursorPosition == null) return const SizedBox.shrink();
                  return Positioned(
                    left: cursorPosition.dx - cursorSize / 2,
                    top: cursorPosition.dy - cursorSize / 2, // Centered exactly on the touch point
                    child: IgnorePointer(
                      child: Image.network(
                        cursorImageUrl,
                        width: cursorSize,
                        height: cursorSize,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) {
                          NinjaLog.d('AppNinja', "NinjaScratchFoilLayer: Cursor image failed to load - $e");
                          return Container(width: cursorSize, height: cursorSize, color: Colors.red);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return result;
  }
}

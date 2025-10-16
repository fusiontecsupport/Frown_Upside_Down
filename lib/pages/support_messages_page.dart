import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportMessagesPage extends StatefulWidget {
  final String title;
  final List<String> messages;

  const SupportMessagesPage({
    super.key,
    required this.title,
    required this.messages,
  });

  @override
  State<SupportMessagesPage> createState() => _SupportMessagesPageState();
}

class _SupportMessagesPageState extends State<SupportMessagesPage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnim;
  int _index = 0;
  bool _showExplore = false;
  bool _showIntro = true;
  late AnimationController _loaderController;
  bool _showInterstitial = false;
  final bool _onlyLoading = false; // show messages with interstitial loader

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() {
        _showIntro = false;
      });
      _loaderController.stop();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  void _onAdvance() {
    HapticFeedback.lightImpact();
    // Intro: skip to messages
    if (_showIntro) {
      setState(() => _showIntro = false);
      _loaderController.stop();
      return;
    }
    // If interstitial is showing, skip and go to next immediately
    if (_showInterstitial) {
      if (_index < widget.messages.length - 1) {
        setState(() {
          _showInterstitial = false;
          _index++;
        });
      }
      return;
    }
    // Otherwise show interstitial then advance
    if (_index < widget.messages.length - 1) {
      setState(() => _showInterstitial = true);
      _loaderController.repeat();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_showInterstitial) {
          setState(() {
            _showInterstitial = false;
            _index++;
          });
        }
      });
    } else {
      setState(() => _showExplore = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF4A6FA5);
    final themeBlue2 = const Color(0xFF5B7DB1);

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFE8F1FF), const Color(0xFFF0F6FF), _bgAnim.value)!,
                      Color.lerp(const Color(0xFFE0EBFF), const Color(0xFFEDF4FF), _bgAnim.value)!,
                      Color.lerp(const Color(0xFFD6E4FF), const Color(0xFFE8F0FF), _bgAnim.value)!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Subtle floating circles
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) {
              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      top: 120 - (15 * _bgAnim.value),
                      left: 24,
                      child: _circle(100, themeBlue.withOpacity(0.10)),
                    ),
                    Positioned(
                      bottom: 160 + (20 * _bgAnim.value),
                      right: 24,
                      child: _circle(120, themeBlue2.withOpacity(0.10)),
                    ),
                    Positioned(
                      top: 300 + (10 * _bgAnim.value),
                      right: 60,
                      child: _circle(70, themeBlue.withOpacity(0.08)),
                    ),
                  ],
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: GestureDetector(
              onTap: _showExplore ? null : _onAdvance,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeBlue.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Text('😢', style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C4A7C),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Text(
                          '${_index + 1}/${widget.messages.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C4A7C).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Message card with glass effect (hidden while loading)
                    Expanded(
                      child: Center(
                        child: (_showIntro || _showInterstitial)
                            ? _buildStandaloneLoader(themeBlue)
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: 700,
                              constraints: const BoxConstraints(maxWidth: 600),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.85),
                                    Colors.white.withOpacity(0.72),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeBlue.withOpacity(0.18),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Messages view
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) {
                                      final offset = Tween<Offset>(
                                        begin: const Offset(0.0, 0.08),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
                                      return FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(position: offset, child: child),
                                      );
                                    },
                                    child: _showIntro
                                        ? const SizedBox.shrink()
                                        : _MessageView(
                                            key: ValueKey(_index),
                                            text: widget.messages[_index],
                                          ),
                                  ),

                                  // Funny loader overlay
                                  if (_showIntro)
                                    Positioned.fill(
                                      child: Center(child: _buildStandaloneLoader(themeBlue)),
                                    ),

                                  // Interstitial loader overlay between messages
                                  if (_showInterstitial)
                                    Positioned.fill(
                                      child: Center(child: _buildStandaloneLoader(themeBlue)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.messages.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: active ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? themeBlue : themeBlue.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Explore button at the end
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _showExplore
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: themeBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildStandaloneLoader(Color themeBlue) {
    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, cons) {
            final maxW = cons.maxWidth;
            final maxH = cons.maxHeight;
            final gifSize = (maxH.isFinite)
                ? math.max(64.0, math.min(maxH * 0.45, 200.0))
                : 160.0;
            final ringSize = gifSize * 1.35;
            final showLabels = maxH >= 120.0;

            final t = _loaderController.value; // 0..1
            final bob = math.sin(t * 2 * math.pi) * 6; // -6..+6
            final scale = 1.0 + math.sin(t * 2 * math.pi) * 0.02; // subtle 2%
            final rotation = t * 2 * math.pi; // rotating ring

            Widget dots() {
              double dotOffset(int i) => math.max(0, math.sin((t + i * 0.15) * 2 * math.pi)) * 6;
              final baseColor = themeBlue;
              return SizedBox(
                width: gifSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final alpha = 0.4 + 0.6 * math.max(0.0, math.sin((t + i * 0.15) * 2 * math.pi));
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Transform.translate(
                        offset: Offset(0, -dotOffset(i)),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(alpha.clamp(0.2, 1.0)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withOpacity(0.35),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rotating ring + pulsing glow + GIF
                Transform.translate(
                  offset: Offset(0, bob),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow
                      Container(
                        width: ringSize,
                        height: ringSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: themeBlue.withOpacity(0.20 + 0.10 * math.sin(t * 2 * math.pi).abs()),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      // Rotating ring
                      Transform.rotate(
                        angle: rotation,
                        child: Container(
                          width: ringSize,
                          height: ringSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                themeBlue.withOpacity(0.0),
                                themeBlue.withOpacity(0.25),
                                themeBlue.withOpacity(0.0),
                              ],
                            ),
                            border: Border.all(color: themeBlue.withOpacity(0.25), width: 1),
                          ),
                        ),
                      ),
                      // GIF with subtle scale
                      Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: gifSize,
                          height: gifSize,
                          child: Image.asset(
                            'assets/walk.gif',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              return const Center(
                                child: Text('🙂', style: TextStyle(fontSize: 48)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Bouncing dots
                dots(),
                if (showLabels) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Warming up the smiles...',
                    style: TextStyle(
                      color: const Color(0xFF2C4A7C).withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to skip',
                    style: TextStyle(
                      color: const Color(0xFF2C4A7C).withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  final String text;
  const _MessageView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    String formatText(String input) {
      final parts = input.split(RegExp(r'(?<=[.!?])\s+'));
      if (parts.length > 1) {
        final first = parts.first.trimRight();
        final rest = parts.sublist(1).join(' ').trimLeft();
        return '$first\n$rest';
      }
      return input;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.self_improvement, color: Color(0xFF4A6FA5), size: 28),
        const SizedBox(height: 10),
        Text(
          formatText(text),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class SupportMessagesPage extends StatefulWidget {
  final String title;
  final int subEmotionId;

  const SupportMessagesPage({
    super.key,
    required this.title,
    required this.subEmotionId,
  });

  @override
  State<SupportMessagesPage> createState() => _SupportMessagesPageState();
}

class _SupportMessagesPageState extends State<SupportMessagesPage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnim;
  int _index = 0;
  bool _loading = true;
  late AnimationController _loaderController;
  List<String> _contents = const [];

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

    _fetchContents();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  Future<void> _fetchContents() async {
    try {
      final items = await ApiService.fetchSubEmotionContents(
        email: 'logesh2528@gmail.com',
        password: '12345678',
        subEmotionId: widget.subEmotionId,
      );
      if (!mounted) return;
      setState(() {
        _contents = items;
        _loading = false;
      });
      _loaderController.stop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _contents = const [];
        _loading = false;
      });
      _loaderController.stop();
    }
  }

  void _onAdvance() {
    HapticFeedback.lightImpact();
    if (_loading || _contents.isEmpty) return;
    if (_index < _contents.length - 1) {
      setState(() => _index++);
    }
  }

  Future<String?> _showFollowUpDialog() async {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Follow Up Emotion',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        String selected = '';
        final followUpOptions = [
          {'label': 'Still feeling sad', 'emoji': '😢', 'description': 'My sadness hasn\'t changed'},
          {'label': 'Slightly better', 'emoji': '🔄', 'description': 'I\'m feeling a bit improved'},
          {'label': 'Much better now', 'emoji': '😊', 'description': 'I\'m feeling more positive'},
          {'label': 'Motivated to change', 'emoji': '💪', 'description': 'Ready to take action'},
          {'label': 'Hopeful', 'emoji': '🌟', 'description': 'I see light ahead'},
          {'label': 'Grateful for support', 'emoji': '🙏', 'description': 'Thankful for the help'},
        ];
        
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        final themeBlue = const Color(0xFF4A6FA5);
        final themeBlue2 = const Color(0xFF5B7DB1);
        
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Opacity(
            opacity: curved.value,
            child: Transform.scale(
              scale: 0.94 + 0.06 * curved.value,
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Material(
                      color: Colors.transparent,
                      child: Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.10),
                                      ],
                                    ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeBlue.withOpacity(0.1),
                                    blurRadius: 60,
                                    offset: const Offset(0, 30),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: themeBlue.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Emotion icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [themeBlue2, themeBlue],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeBlue.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '😢',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Text(
                                    'How are you feeling now?',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'After reading all the messages, how has your mood changed?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF8E8E93),
                                      letterSpacing: -0.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Follow-up options
                                  Column(
                                    children: followUpOptions.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final option = entry.value;
                                      final isSelected = selected == option['label'];
                                      
                                      // Staggered entrance animation
                                      final base = (curved.value - index * 0.05).clamp(0.0, 1.0);
                                      final dy = (1.0 - base) * 8.0;
                                      
                                      return Opacity(
                                        opacity: base,
                                        child: Transform.translate(
                                          offset: Offset(0, dy),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setState(() => selected = option['label'] as String);
                                                Future.delayed(const Duration(milliseconds: 150), () {
                                                  Navigator.of(context).pop(option['label']);
                                                });
                                              },
                                              child: AnimatedScale(
                                                duration: const Duration(milliseconds: 140),
                                                scale: isSelected ? 1.02 : 1.0,
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient: isSelected
                                                        ? LinearGradient(
                                                            colors: [themeBlue2, themeBlue],
                                                          )
                                                        : LinearGradient(
                                                            colors: [
                                                              Colors.white.withOpacity(0.3),
                                                              Colors.white.withOpacity(0.2),
                                                            ],
                                                          ),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: isSelected 
                                                          ? Colors.transparent 
                                                          : Colors.white.withOpacity(0.4),
                                                      width: 1,
                                                    ),
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color: themeBlue2.withOpacity(0.3),
                                                              blurRadius: 12,
                                                              offset: const Offset(0, 6),
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? Colors.white.withOpacity(0.2)
                                                              : themeBlue.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            option['emoji'] as String,
                                                            style: const TextStyle(fontSize: 20),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              option['label'] as String,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: isSelected 
                                                                    ? Colors.white 
                                                                    : const Color(0xFF1C1C1E),
                                                                letterSpacing: -0.1,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              option['description'] as String,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w400,
                                                                color: isSelected 
                                                                    ? Colors.white.withOpacity(0.8)
                                                                    : const Color(0xFF8E8E93),
                                                                letterSpacing: -0.1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Skip button
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).pop('skip');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Skip for now',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: themeBlue,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
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
              onTap: _onAdvance,
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
                        const SizedBox.shrink(),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Glass card shell with content
                    Expanded(
                      child: Center(
                        child: ClipRRect(
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
                              child: SizedBox(
                                height: 220,
                                child: Center(
                                  child: _loading
                                      ? _buildStandaloneLoader(themeBlue)
                                      : (_contents.isEmpty
                                          ? Text(
                                              'No content available',
                                              style: TextStyle(
                                                color: const Color(0xFF2C4A7C).withOpacity(0.7),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          : _MessageView(
                                              key: ValueKey(_index),
                                              text: _contents[_index],
                                            )),
                                ),
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
                      children: List.generate(_contents.isEmpty ? 1 : _contents.length, (i) {
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

                    const SizedBox.shrink(),
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

class _SkipAndFeelButton extends StatelessWidget {
  const _SkipAndFeelButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF4A6FA5);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 4,
          ),
          onPressed: () async {
            final result = await _showFeelingsDialog(context);
            // Optionally handle the result here
          },
          child: const Text(
            'Feel Better',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> _showFeelingsDialog(BuildContext context) async {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'How are you feeling?',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      String selected = '';
      final followUpOptions = [
        {'label': 'Still feeling bad', 'emoji': '😢', 'description': 'My mood hasn\'t improved'},
        {'label': 'Slightly better', 'emoji': '🔄', 'description': 'I\'m feeling a bit improved'},
        {'label': 'Much better now', 'emoji': '😊', 'description': 'I\'m feeling more positive'},
        {'label': 'Motivated to change', 'emoji': '💪', 'description': 'Ready to take action'},
        {'label': 'Hopeful', 'emoji': '🌟', 'description': 'I see light ahead'},
        {'label': 'Grateful for support', 'emoji': '🙏', 'description': 'Thankful for the help'},
      ];
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      final themeBlue = const Color(0xFF4A6FA5);
      final themeBlue2 = const Color(0xFF5B7DB1);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
        child: Opacity(
          opacity: curved.value,
          child: Transform.scale(
            scale: 0.94 + 0.06 * curved.value,
            child: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Material(
                    color: Colors.transparent,
                    child: Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeBlue.withOpacity(0.1),
                                      blurRadius: 60,
                                      offset: const Offset(0, 30),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: themeBlue.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [themeBlue2, themeBlue],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeBlue.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '😢',
                                          style: TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'How are you feeling now?',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'After reading this message, how has your mood changed?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF8E8E93),
                                        letterSpacing: -0.1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      children: followUpOptions.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final option = entry.value;
                                        final isSelected = selected == option['label'];
                                        final base = (curved.value - index * 0.05).clamp(0.0, 1.0);
                                        final dy = (1.0 - base) * 8.0;
                                        return Opacity(
                                          opacity: base,
                                          child: Transform.translate(
                                            offset: Offset(0, dy),
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  setState(() => selected = option['label'] as String);
                                                  Future.delayed(const Duration(milliseconds: 150), () {
                                                    Navigator.of(context).pop(option['label']);
                                                    Navigator.of(context).pop(); // Go back to previous page
                                                  });
                                                },
                                                child: AnimatedScale(
                                                  duration: const Duration(milliseconds: 140),
                                                  scale: isSelected ? 1.02 : 1.0,
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      gradient: isSelected
                                                          ? LinearGradient(
                                                              colors: [themeBlue2, themeBlue],
                                                            )
                                                          : LinearGradient(
                                                              colors: [
                                                                Colors.white.withOpacity(0.3),
                                                                Colors.white.withOpacity(0.2),
                                                              ],
                                                            ),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(
                                                        color: isSelected 
                                                            ? Colors.transparent 
                                                            : Colors.white.withOpacity(0.4),
                                                        width: 1,
                                                      ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                color: themeBlue2.withOpacity(0.3),
                                                                blurRadius: 12,
                                                                offset: const Offset(0, 6),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? Colors.white.withOpacity(0.2)
                                                                : themeBlue.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              option['emoji'] as String,
                                                              style: const TextStyle(fontSize: 20),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                option['label'] as String,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: isSelected 
                                                                      ? Colors.white 
                                                                      : const Color(0xFF1C1C1E),
                                                                  letterSpacing: -0.1,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 2),
                                                              Text(
                                                                option['description'] as String,
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.w400,
                                                                  color: isSelected 
                                                                      ? Colors.white.withOpacity(0.8)
                                                                      : const Color(0xFF8E8E93),
                                                                  letterSpacing: -0.1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(context).pop('skip');
                                        Navigator.of(context).pop(); // Go back to previous page
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Skip for now',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: themeBlue,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
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
        const SizedBox(height: 24),
        _SkipAndFeelButton(),
      ],
    );
  }
}

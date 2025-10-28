import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmileAnimationPage extends StatefulWidget {
  const SmileAnimationPage({super.key});

  @override
  State<SmileAnimationPage> createState() => _SmileAnimationPageState();
}

class _SmileAnimationPageState extends State<SmileAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _confettiController;
  late Animation<double> _breath;
  late Animation<double> _confetti;
  late AnimationController _timerController;

  // Shorter, clearer session
  static const int _durationSeconds = 30;
  bool _chimeOn = false;
  int _lastPromptIndex = -1;
  bool _isHolding = false;
  late final AnimationController _glowController;
  late final Animation<double> _glow;
  int _lastHapticQuarter = -1; // for quarter progress haptics

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(seconds: _durationSeconds),
      vsync: this,
    )
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          _confettiController.forward(from: 0);
          final messages = [
            'Every small smile builds a brighter day. Keep going!',
            'You showed up for yourself. That matters.',
            'A gentle smile can shift your whole mood—nice work!',
          ];
          final msg = messages[DateTime.now().millisecondsSinceEpoch % messages.length];
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Congrats!'),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // back to Home
                  },
                  child: const Text('Go Home'),
                ),
              ],
            ),
          );
        }
      });

    _breath = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _confetti = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _confettiController.dispose();
    _timerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTick() {
    // Trigger micro-prompts and optional chime every 10 seconds
    final elapsed = (_durationSeconds * _timerController.value).floor();
    final promptIndex = (elapsed / 10).floor();
    if (promptIndex != _lastPromptIndex && elapsed % 10 == 0 && elapsed < _durationSeconds) {
      _lastPromptIndex = promptIndex;
      if (_chimeOn) {
        SystemSound.play(SystemSoundType.click);
      }
      if (mounted) {
        final prompts = <String>[
          'Soften your eyes and cheeks',
          'Lift the corners gently',
          'Breathe and hold the smile',
        ];
        final text = prompts[promptIndex.clamp(0, prompts.length - 1)];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    // Additional crisp haptics on 25%, 50%, 75% milestones
    final quarters = ( _timerController.value * 4 ).floor();
    if (quarters != _lastHapticQuarter && quarters > 0 && quarters < 4 && _isHolding) {
      _lastHapticQuarter = quarters;
      HapticFeedback.lightImpact();
    }

    // Rebuild UI so elapsed seconds/percentage update while holding
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minSide = size.shortestSide;
    final circleSize = (minSide * 0.48).clamp(160.0, 220.0);
    final remaining = (_durationSeconds * (1 - _timerController.value)).ceil();
    final progress = _timerController.value;
    final elapsed = (_durationSeconds * progress).floor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smile'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
      body: Stack(
        children: [
          // Subtle animated background orbs for premium feel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F1FF), Color(0xFFD6E4FF)],
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (context, _) {
                return CustomPaint(
                  painter: _OrbsPainter(animationValue: _glow.value),
                  size: Size(size.width, size.height),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress ring + vector smile inside
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) {
                    HapticFeedback.lightImpact();
                    setState(() => _isHolding = true);
                    _timerController.forward();
                  },
                  onTapUp: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _isHolding = false);
                    _timerController.stop(canceled: false);
                  },
                  onTapCancel: () {
                    setState(() => _isHolding = false);
                    _timerController.stop(canceled: false);
                  },
                  child: Semantics(
                    label: 'Smile timer',
                    readOnly: false,
                    value: 'Progress ${(progress * 100).toStringAsFixed(0)} percent',
                    onTapHint: 'Press and hold to start the smile timer',
                    child: ScaleTransition(
                    scale: _breath,
                    child: CustomPaint(
                      painter: _SmileRingPainter(progress: progress, isHolding: _isHolding),
                      child: SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              painter: _SmileFacePainter(smileProgress: progress),
                              size: const Size(double.infinity, double.infinity),
                            ),
                            // Elapsed seconds and percent when holding
                            if (_isHolding)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${elapsed}s',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: const Color(0xFF1C1C1E).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isHolding ? 'Hold to keep smiling' : 'Press and hold to smile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Completes in $remaining s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1C1C1E).withOpacity(0.7),
                          ),
                    ),
                    if (_isHolding) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Elapsed ${elapsed}s / ${_durationSeconds}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF1C1C1E).withOpacity(0.7),
                            ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Linear progress for clarity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF4A6FA5).withOpacity(0.15),
                      color: const Color(0xFF4A6FA5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Chime toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: _chimeOn,
                      onChanged: (v) => setState(() => _chimeOn = v),
                      activeColor: const Color(0xFF4A6FA5),
                    ),
                    const SizedBox(width: 8),
                    const Text('Chime every 10s'),
                  ],
                ),
                const SizedBox(height: 12),
                // Clear, meaningful guidance
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SmileInstructionsCard(),
                ),
              ],
            ),
          ),
          // Full-screen loading overlay while holding
          AnimatedOpacity(
            opacity: _isHolding ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_isHolding,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white.withOpacity(0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated smile emoji (pulsing + gentle tilt)
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (context, _) {
                          final scale = 1.0 + 0.05 * _glow.value;
                          final tilt = 0.06 * (2 * math.pi * _glow.value - math.pi);
                          return Transform.rotate(
                            angle: tilt,
                            child: Transform.scale(
                              scale: scale,
                              child: const Text(
                                '🙂',
                                style: TextStyle(fontSize: 56),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Large percentage
                      Text(
                        '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                        ,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Elapsed seconds out of total
                      Text(
                        'Elapsed ${(_durationSeconds * progress).floor()}s / ${_durationSeconds}s',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1E).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Circular indicator mirroring the ring
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFF4A6FA5).withOpacity(0.15),
                          color: const Color(0xFF4A6FA5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Keep holding…'),
                      const SizedBox(height: 12),
                      // Subtle animated dots for feedback
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (context, _) {
                          final a = _glow.value;
                          double dotOpacity(int i) {
                            // Staggered pulse per dot
                            final phase = (a + i * 0.2) % 1.0;
                            return 0.35 + 0.65 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A6FA5).withOpacity(dotOpacity(i)),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _confetti,
            builder: (context, child) {
              return IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(progress: _confetti.value),
                  size: MediaQuery.of(context).size,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  final List<Color> colors = const [
    Color(0xFF4A6FA5),
    Color(0xFF5B7DB1),
    Color(0xFF6B8FC3),
    Color(0xFFEFCA08),
    Color(0xFF06D6A0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rand = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    final count = 120;
    for (int i = 0; i < count; i++) {
      final angle = 2 * math.pi * (i / count);
      final radius = progress * (size.shortestSide * 0.6) * (0.6 + 0.4 * rand.nextDouble());
      final dx = center.dx + radius * math.cos(angle + progress * 6.0);
      final dy = center.dy + radius * math.sin(angle + progress * 6.0);
      paint.color = colors[i % colors.length].withOpacity(1 - progress);
      canvas.drawCircle(Offset(dx, dy), 2 + 2 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

class _SmileRingPainter extends CustomPainter {
  _SmileRingPainter({required this.progress, required this.isHolding});
  final double progress;
  final bool isHolding;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.5 - 6;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF4A6FA5).withOpacity(0.15)
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = const LinearGradient(colors: [Color(0xFF5B7DB1), Color(0xFF4A6FA5)])
          .createShader(Rect.fromCircle(center: center, radius: radius));

    // Glow ring when holding
    if (isHolding) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..color = const Color(0xFF4A6FA5).withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glow);
    }

    // Background ring
    canvas.drawCircle(center, radius, bg);
    // Foreground progress arc
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _SmileRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isHolding != isHolding;
}

class _SmileFacePainter extends CustomPainter {
  _SmileFacePainter({required this.smileProgress});
  final double smileProgress; // 0..1 widens the arc

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final faceRadius = size.shortestSide * 0.28;
    final eyeOffsetX = faceRadius * 0.6;
    final eyeOffsetY = -faceRadius * 0.4;

    final eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1C1C1E).withOpacity(0.9);

    // Eyes
    canvas.drawCircle(center + Offset(-eyeOffsetX, eyeOffsetY), 6, eyePaint);
    canvas.drawCircle(center + Offset(eyeOffsetX, eyeOffsetY), 6, eyePaint);

    // Smile mouth that widens over time
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1C1C1E).withOpacity(0.9);

    final mouthRadius = faceRadius * 0.9;
    // Start narrower and widen to a broad arc
    final startAngle = math.pi + (math.pi * 0.25 * (1 - smileProgress));
    final endAngle = 2 * math.pi - (math.pi * 0.25 * (1 - smileProgress));
    final rect = Rect.fromCircle(center: center + Offset(0, faceRadius * 0.25), radius: mouthRadius);
    canvas.drawArc(rect, startAngle, endAngle - startAngle, false, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant _SmileFacePainter oldDelegate) => oldDelegate.smileProgress != smileProgress;
}

class _SmileInstructionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A6FA5).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How to do the Smile Exercise (30s)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                fontSize: 14,
                color: Color(0xFF1C1C1E),
              ),
            ),
            SizedBox(height: 8),
            Text('1) Soften your eyes and cheeks.'),
            SizedBox(height: 4),
            Text('2) Gently lift the corners of your mouth.'),
            SizedBox(height: 4),
            Text('3) Breathe naturally and keep the smile relaxed.'),
            SizedBox(height: 4),
            Text('4) If thoughts wander, return to the gentle smile.'),
          ],
        ),
      ),
    );
  }
}

class _OrbsPainter extends CustomPainter {
  _OrbsPainter({required this.animationValue});
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centers = [
      Offset(size.width * 0.2, size.height * (0.3 + 0.02 * math.sin(animationValue * 2 * math.pi))),
      Offset(size.width * 0.8, size.height * (0.25 + 0.02 * math.cos(animationValue * 2 * math.pi))),
      Offset(size.width * 0.5, size.height * (0.8 + 0.02 * math.sin(animationValue * 2 * math.pi))),
    ];
    final radii = [60.0, 46.0, 54.0];
    final colors = [
      const Color(0xFF4A6FA5).withOpacity(0.08),
      const Color(0xFF5B7DB1).withOpacity(0.08),
      const Color(0xFF6B8FC3).withOpacity(0.08),
    ];
    for (int i = 0; i < centers.length; i++) {
      paint.color = colors[i];
      canvas.drawCircle(centers[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}



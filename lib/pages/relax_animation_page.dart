import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RelaxAnimationPage extends StatefulWidget {
  const RelaxAnimationPage({super.key});

  @override
  State<RelaxAnimationPage> createState() => _RelaxAnimationPageState();
}

class _RelaxAnimationPageState extends State<RelaxAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late Animation<double> _progress;
  bool _started = false;
  bool _paused = false;

  static const int inhale = 4;
  static const int hold = 7;
  static const int exhale = 8;
  static const int cycle = inhale + hold + exhale; // 19s

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(
      duration: const Duration(seconds: cycle),
      vsync: this,
    );
    _progress = CurvedAnimation(parent: _phaseController, curve: Curves.linear);

    _phaseController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _started) {
        // Show congrats after one full cycle; ask to go Home
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congrats!'),
            content: const Text('Nice breathing session. Continue or head back home?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _phaseController.forward(from: 0); // continue looping
                },
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
  }

  String _phaseText(double t) {
    final sec = (t * cycle).floor();
    if (sec < inhale) return 'Inhale';
    if (sec < inhale + hold) return 'Hold';
    return 'Exhale';
  }

  int _phaseRemaining(double t) {
    final sec = (t * cycle).floor();
    if (sec < inhale) return inhale - sec;
    if (sec < inhale + hold) return inhale + hold - sec;
    return cycle - sec;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relax (4‑7‑8)'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
      body: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          final t = _started ? _progress.value : 0.0;
          final phase = _started ? _phaseText(t) : 'Ready';
          final remaining = _started ? _phaseRemaining(t) : inhale;
          final scale = !_started
              ? 0.96
              : phase == 'Inhale'
                  ? 0.9 + 0.1 * (t * cycle / inhale).clamp(0.0, 1.0)
                  : phase == 'Hold'
                      ? 1.0
                      : 1.0 - 0.1 * ((t * cycle - inhale - hold) / exhale).clamp(0.0, 1.0);

          final progress = _started ? (t) : 0.0;

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8F1FF), Color(0xFFD6E4FF)],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress ring with animated circle and label
                    CustomPaint(
                      painter: _RelaxRingPainter(progress: progress),
                      child: AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B8FC3), Color(0xFF4A6FA5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A6FA5).withOpacity(0.22),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  phase,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _started ? 'Next in $remaining s' : '4‑7‑8 breathing',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            if (!_started) {
                              setState(() {
                                _started = true;
                                _paused = false;
                              });
                              _phaseController.forward(from: 0);
                            } else if (_paused) {
                              setState(() => _paused = false);
                              _phaseController.forward();
                            } else {
                              setState(() => _paused = true);
                              _phaseController.stop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6FA5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          icon: Icon(!_started || _paused ? Icons.play_arrow : Icons.pause),
                          label: Text(!_started ? 'Start' : (_paused ? 'Resume' : 'Pause')),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _started = false;
                              _paused = false;
                            });
                            _phaseController.reset();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4A6FA5),
                            side: const BorderSide(color: Color(0xFF4A6FA5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Inhale 4  •  Hold 7  •  Exhale 8',
                      style: TextStyle(color: const Color(0xFF1C1C1E).withOpacity(0.6)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF4A6FA5).withOpacity(0.12),
                          color: const Color(0xFF4A6FA5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RelaxRingPainter extends CustomPainter {
  _RelaxRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide * 0.5) - 8;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF4A6FA5).withOpacity(0.15)
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = const LinearGradient(colors: [Color(0xFF6B8FC3), Color(0xFF4A6FA5)])
          .createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159 / 2, 2 * 3.14159 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RelaxRingPainter oldDelegate) => oldDelegate.progress != progress;
}



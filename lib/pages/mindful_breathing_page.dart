import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class MindfulBreathingPage extends StatefulWidget {
  const MindfulBreathingPage({super.key});

  @override
  State<MindfulBreathingPage> createState() => _MindfulBreathingPageState();
}

class _MindfulBreathingPageState extends State<MindfulBreathingPage>
    with TickerProviderStateMixin {
  late final AnimationController _cycleController;
  late final Animation<double> _t;
  bool _holding = false;
  int _breathsCompleted = 0;
  static const int _targetBreaths = 5;

  // Deep breath phases: Inhale 5s → Exhale 3s
  static const int inhaleSeconds = 5;
  static const int exhaleSeconds = 3;
  static const int cycleSeconds = inhaleSeconds + exhaleSeconds; // 8 seconds per breath

  @override
  void initState() {
    super.initState();
    _cycleController = AnimationController(
      duration: const Duration(seconds: cycleSeconds),
      vsync: this,
    );
    _t = CurvedAnimation(parent: _cycleController, curve: Curves.linear)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _breathsCompleted += 1;
          HapticFeedback.mediumImpact();
          if (_breathsCompleted < _targetBreaths && _holding) {
            _cycleController.forward(from: 0); // start next breath automatically while holding
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Great work'),
                content: const Text('You completed 5 deep breaths. Notice how you feel now.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Stay'),
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
        }
      });
  }

  @override
  void dispose() {
    _cycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circle = (size.shortestSide * 0.5).clamp(180.0, 240.0);
    final progress = _t.value; // current breath progress 0..1
    final elapsed = (cycleSeconds * progress).floor();
    final remaining = (cycleSeconds * (1 - progress)).ceil();
    final overallProgress = ((_breathsCompleted + progress) / _targetBreaths).clamp(0.0, 1.0);
    final phase = elapsed < inhaleSeconds ? 'Inhale' : 'Exhale';
    final phaseRemaining = elapsed < inhaleSeconds
        ? inhaleSeconds - elapsed
        : cycleSeconds - elapsed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Breathing'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
      body: Stack(
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
                GestureDetector(
                  onTapDown: (_) {
                    HapticFeedback.lightImpact();
                    setState(() => _holding = true);
                    if (_cycleController.isDismissed) {
                      _cycleController.forward(from: 0);
                    } else {
                      _cycleController.forward();
                    }
                  },
                  onTapUp: (_) {
                    setState(() => _holding = false);
                    _cycleController.stop();
                  },
                  onTapCancel: () {
                    setState(() => _holding = false);
                    _cycleController.stop();
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 260),
                    scale: _holding ? 1.04 : 1.0,
                    curve: Curves.easeInOut,
                    child: Container(
                      width: circle,
                      height: circle,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B8FC3), Color(0xFF4A6FA5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A6FA5).withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _holding ? phase : 'Press and hold',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _holding
                                  ? 'Breath ${_breathsCompleted + 1} of 5 • ${elapsed}s • ${(progress * 100).toStringAsFixed(0)}%'
                                  : '5 deep breaths',
                              style: const TextStyle(color: Colors.white70),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      // overall progress across 5 breaths
                      value: overallProgress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF4A6FA5).withOpacity(0.12),
                      color: const Color(0xFF4A6FA5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('This breath: ${phase} • ${phaseRemaining}s left', style: TextStyle(color: const Color(0xFF1C1C1E).withOpacity(0.7))),
                    if (_holding) ...[
                      const SizedBox(width: 12),
                      Text('Breaths ${_breathsCompleted} / 5', style: TextStyle(color: const Color(0xFF1C1C1E).withOpacity(0.7))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Full-screen loading overlay with yoga emoji while holding
          AnimatedOpacity(
            opacity: _holding ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_holding,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (context, _) {
                      final a = _t.value;
                      final p = a; // live progress (0..1 within 8s cycle)
                      final e = (cycleSeconds * p).floor();
                      final ph = e < inhaleSeconds ? 'Inhale' : 'Exhale';
                      final scale = 1.0 + 0.06 * math.sin(2 * math.pi * a);
                      final tilt = 0.04 * math.sin(2 * math.pi * a);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: tilt,
                            child: Transform.scale(
                              scale: scale,
                              child: const Text('🧘', style: TextStyle(fontSize: 56)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ph,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(p * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Elapsed ${e}s / ${cycleSeconds}s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: p,
                              strokeWidth: 6,
                              backgroundColor: const Color(0xFF4A6FA5).withOpacity(0.15),
                              color: const Color(0xFF4A6FA5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Keep holding…'),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



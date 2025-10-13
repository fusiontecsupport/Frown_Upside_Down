import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_page.dart';

enum SplashStyle { aurora, liquid, orbs }

class _AnimatedProgressBar extends StatelessWidget {
  final AnimationController controller;
  final _Palette pal;
  const _AnimatedProgressBar({required this.controller, required this.pal});

  @override
  Widget build(BuildContext context) {
    final width = 180.0;
    final height = 6.0;
    final capsule = 56.0; // moving highlight width

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value; // 0..1
        // Move highlight back and forth smoothly
        final pos = (t < 0.5) ? (t * 2) : (1 - (t - 0.5) * 2); // ping-pong 0..1..0
        final left = (width - capsule) * pos;

        return Container(
          width: width,
          height: height + 6,
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              // Track
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
              // Moving gradient highlight
              Positioned(
                left: left,
                top: 0,
                child: Container(
                  width: capsule,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [pal.base1, pal.base2],
                    ),
                    borderRadius: BorderRadius.circular(height),
                    boxShadow: [
                      BoxShadow(
                        color: pal.glow.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
enum SplashPalette { ocean, sunset, mint, lavender, graphite, cobalt, coral, emerald, berry, night, colorhunt }

class SplashPage extends StatefulWidget {
  final SplashStyle style;
  final SplashPalette palette;
  const SplashPage({Key? key, this.style = SplashStyle.orbs, this.palette = SplashPalette.ocean}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Entrance animations
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _glow;
  late final Animation<Offset> _logoOffset;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _taglineOpacity;

  // Background looping animation
  late final AnimationController _bgController;
  late final Animation<Alignment> _gradBegin;
  late final Animation<Alignment> _gradEnd;

  // Palette helper
  _Palette get _pal => _palettes[widget.palette]!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    // Logo entrance
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _rotation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glow = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1.0, curve: Curves.easeIn)),
    );

    // Logo slide-in
    _logoOffset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    // Title and tagline entrance
    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.20, 0.60, curve: Curves.easeOut)),
    );
    _titleOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.20, 0.60, curve: Curves.easeOut));
    _taglineOffset = Tween<Offset>(begin: const Offset(0, 0.44), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.95, curve: Curves.easeOut)),
    );
    _taglineOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.95, curve: Curves.easeOut));

    // Background slow motion
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _gradBegin = AlignmentTween(begin: Alignment.topLeft, end: Alignment.centerRight).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
    _gradEnd = AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionDuration: const Duration(milliseconds: 700),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved), child: child),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _bgController]),
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final minSide = math.min(size.width, size.height);
        final double logoSize = ((minSide * 0.34).clamp(160.0, 260.0)) as double;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background: pale white
            Container(color: const Color(0xFFFAFAFA)),

            // Foreground content with responsive alignment
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo block
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft glow halo behind the logo (subtle on light background)
                        Container(
                          width: logoSize + 100,
                          height: logoSize + 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _pal.glow.withOpacity(0.18 * _glow.value),
                                blurRadius: 0.35 * (logoSize + 100) * _glow.value,
                                spreadRadius: 0.15 * _glow.value * 20,
                              ),
                            ],
                          ),
                        ),
                        // Removed frosted glass card for a cleaner look
                        // Logo with subtle bounce and settle rotation
                        SlideTransition(
                          position: _logoOffset,
                          child: Hero(
                            tag: 'app-logo',
                            child: Transform.rotate(
                              angle: _rotation.value,
                              child: Transform.scale(
                                scale: _scale.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/splash/logo.png',
                                    width: logoSize,
                                    height: logoSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title & Tagline under logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _titleOffset,
                          child: FadeTransition(
                            opacity: _titleOpacity,
                            child: Text(
                              'Frown Upside Down',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.black.withOpacity(0.82),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SlideTransition(
                          position: _taglineOffset,
                          child: FadeTransition(
                            opacity: _taglineOpacity,
                            child: Text(
                              'Turn moments into smiles',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black.withOpacity(0.60),
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Subtle loading indicator (three bouncing dots)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8 + MediaQuery.of(context).padding.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedProgressBar(controller: _bgController, pal: _pal),
                        const SizedBox(height: 10),
                        Text(
                          '© 2025 Frown Upside Down',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Template A: Aurora gradient (original, slightly dynamic)
  Widget _buildBackgroundAurora() {
    final t = _bgController.value;
    // Slightly oscillate hues around palette bases for movement
    final b1 = HSVColor.fromColor(_pal.base1);
    final b2 = HSVColor.fromColor(_pal.base2);
    final c1 = b1.withHue((b1.hue + 12 * t) % 360).withSaturation((b1.saturation * (0.95 + 0.05 * t))).toColor();
    final c2 = b2.withHue((b2.hue - 18 * t) % 360).withSaturation((b2.saturation * (0.95 + 0.05 * (1 - t)))).toColor();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: _gradBegin.value,
          end: _gradEnd.value,
          colors: [c1, c2],
        ),
      ),
    );
  }

  // Template B: Liquid blobs (animated radial gradients)
  Widget _buildBackgroundLiquid() {
    final size = MediaQuery.of(context).size;
    final v = _bgController.value;

    Widget blob({required double dx, required double dy, required double r, required List<Color> colors, double opacity = 0.6}) {
      return Positioned(
        left: dx * size.width - r,
        top: dy * size.height - r,
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: colors.map((c) => c.withOpacity(opacity)).toList(),
              stops: const [0.0, 1.0],
            ),
            boxShadow: [
              BoxShadow(color: colors.first.withOpacity(0.25), blurRadius: 60, spreadRadius: 10),
            ],
          ),
        ),
      );
    }

    // Animate positions with different phases
    final x1 = 0.3 + 0.05 * math.sin((v) * math.pi * 2);
    final y1 = 0.35 + 0.06 * math.cos((v) * math.pi * 2);
    final x2 = 0.75 + 0.06 * math.cos((v + 0.33) * math.pi * 2);
    final y2 = 0.30 + 0.05 * math.sin((v + 0.33) * math.pi * 2);
    final x3 = 0.55 + 0.07 * math.sin((v + 0.66) * math.pi * 2);
    final y3 = 0.75 + 0.06 * math.cos((v + 0.66) * math.pi * 2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_pal.base1.withOpacity(0.12), _pal.base2.withOpacity(0.12)],
        ),
      ),
      child: Stack(
        children: [
          blob(
            dx: x1,
            dy: y1,
            r: 180,
            colors: _pal.blobs[0],
            opacity: 0.55,
          ),
          blob(
            dx: x2,
            dy: y2,
            r: 220,
            colors: _pal.blobs[1],
            opacity: 0.45,
          ),
          blob(
            dx: x3,
            dy: y3,
            r: 200,
            colors: _pal.blobs[2],
            opacity: 0.40,
          ),
        ],
      ),
    );
  }

  // Template C: Orbiting orbs around center
  Widget _buildBackgroundOrbs() {
    final base = _buildBackgroundAurora();
    final t = _bgController.value * 2 * math.pi;

    Widget orb(double radius, double angle, Color color, {double size = 10}) {
      return Transform.rotate(
        angle: angle + t,
        child: Transform.translate(
          offset: Offset(radius, 0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, spreadRadius: 2),
            ]),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        Center(
          child: SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < _pal.orbs.length; i++)
                  orb(i < 3 ? 110 : 160, [0.0, 2.3, 4.6, 1.2, 3.7, 5.5][i], _pal.orbs[i], size: [10.0, 8.0, 9.0, 7.0, 7.0, 6.0][i]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Palette model and definitions
class _Palette {
  final Color base1;
  final Color base2;
  final Color glow;
  final List<List<Color>> blobs; // three pairs
  final List<Color> orbs; // six colors
  const _Palette({
    required this.base1,
    required this.base2,
    required this.glow,
    required this.blobs,
    required this.orbs,
  });
}

final Map<SplashPalette, _Palette> _palettes = {
  SplashPalette.ocean: _Palette(
    base1: const Color(0xFF5B8DEF),
    base2: const Color(0xFF78E3D0),
    glow: const Color(0xFF5B8DEF),
    blobs: const [
      [Color(0xFF6FA8FF), Color(0xFFBBD3FF)],
      [Color(0xFF67E8F9), Color(0xFFBAF2F6)],
      [Color(0xFF34D399), Color(0xFF9FF3D2)],
    ],
    orbs: const [
      Color(0xFF5B8DEF), Color(0xFF78E3D0), Color(0xFF34D399),
      Color(0xFF7AA7FF), Color(0xFF22D3EE), Color(0xFFA7F3D0),
    ],
  ),
  SplashPalette.sunset: _Palette(
    base1: const Color(0xFFFF9BC2),
    base2: const Color(0xFFFFC3A0),
    glow: const Color(0xFFFF8FB1),
    blobs: const [
      [Color(0xFFFF8FB1), Color(0xFFFFC8DC)],
      [Color(0xFFFFB380), Color(0xFFFFDDC8)],
      [Color(0xFFF6A7FF), Color(0xFFF4D9FF)],
    ],
    orbs: const [
      Color(0xFFFF8FB1), Color(0xFFFFB380), Color(0xFFF6A7FF),
      Color(0xFFFFC3A0), Color(0xFFFF9BC2), Color(0xFFFDD6E0),
    ],
  ),
  SplashPalette.mint: _Palette(
    base1: const Color(0xFF78E3D0),
    base2: const Color(0xFFB9F6CA),
    glow: const Color(0xFF34D399),
    blobs: const [
      [Color(0xFF34D399), Color(0xFF9FF3D2)],
      [Color(0xFF67E8F9), Color(0xFFBAF2F6)],
      [Color(0xFFB9F6CA), Color(0xFFDBFFE6)],
    ],
    orbs: const [
      Color(0xFF34D399), Color(0xFF78E3D0), Color(0xFF67E8F9),
      Color(0xFFB9F6CA), Color(0xFFA7F3D0), Color(0xFFBAF2F6),
    ],
  ),
  SplashPalette.lavender: _Palette(
    base1: const Color(0xFFB39DDB),
    base2: const Color(0xFF90CAF9),
    glow: const Color(0xFF9575CD),
    blobs: const [
      [Color(0xFF9575CD), Color(0xFFD1C4E9)],
      [Color(0xFF7E57C2), Color(0xFFB39DDB)],
      [Color(0xFF64B5F6), Color(0xFFBBDEFB)],
    ],
    orbs: const [
      Color(0xFF9575CD), Color(0xFF7E57C2), Color(0xFFB39DDB),
      Color(0xFF64B5F6), Color(0xFF90CAF9), Color(0xFFB3E5FC),
    ],
  ),
  SplashPalette.graphite: _Palette(
    base1: const Color(0xFFB0BEC5),
    base2: const Color(0xFFECEFF1),
    glow: const Color(0xFF90A4AE),
    blobs: const [
      [Color(0xFF90A4AE), Color(0xFFCFD8DC)],
      [Color(0xFFB0BEC5), Color(0xFFE0E6EA)],
      [Color(0xFF78909C), Color(0xFFCFD8DC)],
    ],
    orbs: const [
      Color(0xFF90A4AE), Color(0xFF78909C), Color(0xFFB0BEC5),
      Color(0xFFCFD8DC), Color(0xFFECEFF1), Color(0xFF607D8B),
    ],
  ),
  SplashPalette.cobalt: _Palette(
    base1: const Color(0xFF3B82F6),
    base2: const Color(0xFF60A5FA),
    glow: const Color(0xFF2563EB),
    blobs: const [
      [Color(0xFF2563EB), Color(0xFF93C5FD)],
      [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      [Color(0xFFA78BFA), Color(0xFFE9D5FF)],
    ],
    orbs: const [
      Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF38BDF8),
      Color(0xFF60A5FA), Color(0xFF93C5FD), Color(0xFFA78BFA),
    ],
  ),
  SplashPalette.coral: _Palette(
    base1: const Color(0xFFFF7A59),
    base2: const Color(0xFFFFB199),
    glow: const Color(0xFFFF5A3C),
    blobs: const [
      [Color(0xFFFF5A3C), Color(0xFFFFC1AE)],
      [Color(0xFFFFA24C), Color(0xFFFFD9BF)],
      [Color(0xFFFF9BC2), Color(0xFFFFD4E4)],
    ],
    orbs: const [
      Color(0xFFFF5A3C), Color(0xFFFF7A59), Color(0xFFFFA24C),
      Color(0xFFFFB199), Color(0xFFFFC1AE), Color(0xFFFF9BC2),
    ],
  ),
  SplashPalette.emerald: _Palette(
    base1: const Color(0xFF10B981),
    base2: const Color(0xFF6EE7B7),
    glow: const Color(0xFF059669),
    blobs: const [
      [Color(0xFF059669), Color(0xFFA7F3D0)],
      [Color(0xFF10B981), Color(0xFF6EE7B7)],
      [Color(0xFF67E8F9), Color(0xFFBAF2F6)],
    ],
    orbs: const [
      Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399),
      Color(0xFF6EE7B7), Color(0xFFA7F3D0), Color(0xFF67E8F9),
    ],
  ),
  SplashPalette.berry: _Palette(
    base1: const Color(0xFFE879F9),
    base2: const Color(0xFFFB7185),
    glow: const Color(0xFFD946EF),
    blobs: const [
      [Color(0xFFD946EF), Color(0xFFF5D0FE)],
      [Color(0xFFFB7185), Color(0xFFFBCFE8)],
      [Color(0xFFA78BFA), Color(0xFFE9D5FF)],
    ],
    orbs: const [
      Color(0xFFD946EF), Color(0xFFE879F9), Color(0xFFA78BFA),
      Color(0xFFFB7185), Color(0xFFF472B6), Color(0xFFF5D0FE),
    ],
  ),
  SplashPalette.night: _Palette(
    base1: const Color(0xFF1F2937),
    base2: const Color(0xFF111827),
    glow: const Color(0xFF374151),
    blobs: const [
      [Color(0xFF374151), Color(0xFF4B5563)],
      [Color(0xFF1F2937), Color(0xFF111827)],
      [Color(0xFF6B7280), Color(0xFF9CA3AF)],
    ],
    orbs: const [
      Color(0xFF6B7280), Color(0xFF4B5563), Color(0xFF9CA3AF),
      Color(0xFF374151), Color(0xFF1F2937), Color(0xFF111827),
    ],
  ),
  SplashPalette.colorhunt: _Palette(
    // Color Hunt palette: 1B3C53, 234C6A, 456882, D2C1B6
    base1: const Color(0xFF234C6A),
    base2: const Color(0xFF456882),
    glow: const Color(0xFF234C6A),
    blobs: const [
      [Color(0xFF234C6A), Color(0xFF456882)],
      [Color(0xFF1B3C53), Color(0xFF234C6A)],
      [Color(0xFFD2C1B6), Color(0xFF456882)],
    ],
    orbs: const [
      Color(0xFF234C6A), Color(0xFF456882), Color(0xFF1B3C53),
      Color(0xFFD2C1B6), Color(0xFF456882), Color(0xFF234C6A),
    ],
  ),
};

class _BouncingDots extends StatelessWidget {
  final AnimationController controller;
  const _BouncingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    double dot(double phase) {
      final v = (controller.value + phase) % 1.0;
      // Map to y using a sine ease
      return 1 - (0.5 + 0.5 * (math.sin(v * 3.14159 * 2)));
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final y = dot(i * 0.15);
            final scale = 0.9 + 0.1 * (1 - y);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, y * 8),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}


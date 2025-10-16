import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'support_messages_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String planType;
  
  const HomePage({Key? key, required this.planType}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;

  // Local Calm-inspired palette
  final Color kPrimary = const Color(0xFF00A8CC); // ocean
  final Color kSecondary = const Color(0xFF6C63FF); // cool lavender/cobalt
  final Color kAccent = const Color(0xFF7BCFE9); // light aqua
  final List<Color> kBg = const [
    Color(0xFFE9F5FF),
    Color(0xFFEAF0FF),
    Color(0xFFEEF3FF),
  ];

  int _selectedIndex = 0;
  bool _emotionComplete = false;
  bool _emotionDialogShown = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _breathingController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_emotionDialogShown) {
        _emotionDialogShown = true;
        final mood = await _openEmotionDialog();
        if (mounted) {
          setState(() {
            _emotionComplete = true;
          });
        }
        if (!mounted) return;
        if (mood == 'Sad') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SupportMessagesPage(
                title: 'Feeling Sad',
                messages: [
                  "Why? It's not worth it! Write down your feelings in order to make a solution.",
                  'Laughter is the best medicines. Watch something funny!',
                  'Most Importantly, SMILE! Smiling can become contagious. If you feel depressed, smiling can help elevate your mood.',
                  "If you need to crying definitely helps. Don't hold it back because you will feel a lot better.",
                  'Never Give Up on yourself!',
                  'Distract your mind from bad thoughts!',
                  'Exercise to divert your mind and to feel better. Exercising helps you get better mentally. It helps with frustations and getting things off your mind while building muscle.',
                  'Do not blame yourself. YOU ARE WORTH IT!',
                  'Listen to some of you favorite songs and dance it off.',
                  'If you know a place, you should go jump on a trampoline. It is a lot of fun and also incorporates cardio for exercising.',
                  'Have A Great Day & Keep Smiling!',
                ],
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Floating shapes
          _buildFloatingShapes(),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _emotionComplete ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9F5FF),
            Color(0xFFEAF0FF),
            Color(0xFFEEF3FF),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        ...List.generate(6, (index) {
          return AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              final offset = (index * 0.4) + (_breathingController.value * 0.3);
              return Positioned(
                left: 40 + (index * 80.0) + (offset * 25),
                top: 80 + (index * 100.0) + (offset * 20),
                child: Transform.scale(
                  scale: 0.7 + (offset * 0.3),
                  child: Container(
                    width: 15 + (index * 8.0),
                    height: 15 + (index * 8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: [
                        kPrimary.withOpacity(0.12),
                        kSecondary.withOpacity(0.10),
                        kAccent.withOpacity(0.08),
                      ][index % 3],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildContent() {
    if (!_emotionComplete) {
      return const SizedBox();
    }
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMeditationContent();
      case 2:
        return _buildProgressContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Future<String?> _openEmotionDialog() async {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Emotion',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        String selected = '';
        final options = [
          {'label': 'Happy', 'emoji': '😀'},
          {'label': 'Sad', 'emoji': '😢'},
          {'label': 'Disappointed', 'emoji': '😞'},
          {'label': 'Stressed', 'emoji': '😣'},
          {'label': 'Nervous', 'emoji': '😬'},
          {'label': 'Calm', 'emoji': '😌'},
        ];
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Opacity(
            opacity: curved.value,
            child: Transform.scale(
              scale: 0.96 + 0.04 * curved.value,
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final maxH = MediaQuery.of(context).size.height * 0.6;
                    return Material(
                      color: Colors.transparent,
                      child: Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxH),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.96),
                                    Colors.white.withOpacity(0.88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8E8E93).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Back button row
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF4A6FA5)),
                                          onPressed: () {
                                            Navigator.of(context).pop(null);
                                          },
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    AnimatedBuilder(
                                      animation: _breathingController,
                                      builder: (context, _) {
                                        final v = _breathingController.value; // 0..1
                                        final scale = 0.98 + (v * 0.04);      // 0.98..1.02
                                        final dy = (v - 0.5) * 8;              // -4..+4 px
                                        final glow = 0.15 + (v * 0.25);        // 0.15..0.40
                                        return Transform.translate(
                                          offset: Offset(0, dy),
                                          child: Transform.scale(
                                            scale: scale,
                                            child: Container(
                                              width: 88,
                                              height: 88,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF4A6FA5).withOpacity(glow),
                                                    blurRadius: 24,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 200),
                                                  transitionBuilder: (child, anim) =>
                                                      ScaleTransition(scale: anim, child: child),
                                                  child: Text(
                                                    selected.isEmpty
                                                        ? '🙂'
                                                        : options.firstWhere((e) => e['label'] == selected)['emoji'] as String,
                                                    key: ValueKey<String>(selected.isEmpty ? 'neutral' : selected),
                                                    style: const TextStyle(fontSize: 40, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'How are you feeling today?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Select one to continue',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF8E8E93),
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Builder(
                                      builder: (context) {
                                        final size = MediaQuery.of(context).size;
                                        final useAltDesign = size.width < 360; // circular chips on very narrow screens
                                        return Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: options.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final opt = entry.value;
                                            final isSelected = selected == opt['label'];
                                            // Staggered entrance based on dialog animation progress
                                            final base = (curved.value - index * 0.08).clamp(0.0, 1.0);
                                            final dy = (1.0 - base) * 12.0;
                                            return Opacity(
                                              opacity: base,
                                              child: Transform.translate(
                                                offset: Offset(0, dy),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() => selected = opt['label'] as String);
                                                    Future.delayed(const Duration(milliseconds: 150), () {
                                                      Navigator.of(context).pop(opt['label']);
                                                    });
                                                  },
                                                  child: AnimatedScale(
                                                    duration: const Duration(milliseconds: 140),
                                                    scale: isSelected ? 1.06 : 1.0,
                                                    child: useAltDesign
                                                        ? Container(
                                                            width: 92,
                                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                            decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? const Color(0xFF4A6FA5)
                                                                  : const Color(0xFF4A6FA5).withOpacity(0.06),
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(
                                                                color: const Color(0xFF4A6FA5).withOpacity(isSelected ? 0.0 : 0.15),
                                                              ),
                                                              boxShadow: isSelected
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: const Color(0xFF4A6FA5).withOpacity(0.25),
                                                                        blurRadius: 12,
                                                                        offset: const Offset(0, 6),
                                                                      ),
                                                                    ]
                                                                  : null,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(
                                                                  width: 44,
                                                                  height: 44,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: isSelected
                                                                        ? Colors.white.withOpacity(0.15)
                                                                        : const Color(0xFF4A6FA5).withOpacity(0.08),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      opt['emoji'] as String,
                                                                      style: TextStyle(fontSize: isSelected ? 22 : 20, color: isSelected ? Colors.white : const Color(0xFF1C1C1E)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 6),
                                                                Text(
                                                                  opt['label'] as String,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                                                                    letterSpacing: -0.1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                            decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? const Color(0xFF4A6FA5)
                                                                  : const Color(0xFF4A6FA5).withOpacity(0.06),
                                                              borderRadius: BorderRadius.circular(22),
                                                              border: Border.all(
                                                                color: const Color(0xFF4A6FA5).withOpacity(isSelected ? 0.0 : 0.15),
                                                                width: 1,
                                                              ),
                                                              boxShadow: isSelected
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: const Color(0xFF4A6FA5).withOpacity(0.25),
                                                                        blurRadius: 12,
                                                                        offset: const Offset(0, 6),
                                                                      ),
                                                                    ]
                                                                  : null,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  opt['emoji'] as String,
                                                                  style: const TextStyle(fontSize: 18),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  opt['label'] as String,
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                                                                    letterSpacing: -0.1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
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

  Widget _buildHomeContent() {
    return const SizedBox.shrink();
  }

  Widget _buildWelcomeHeader() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.92),
                Colors.white.withOpacity(0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kSecondary, kPrimary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/splash/logo.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.self_improvement,
                          size: 22,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ready for mindfulness?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A6FA5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF4A6FA5),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final mood = await _openEmotionDialog();
                      if (!mounted) return;
                      if (mood == 'Sad') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SupportMessagesPage(
                              title: 'Feeling Sad',
                              messages: [
                                "Why? It's not worth it! Write down your feelings in order to make a solution.",
                                'Laughter is the best medicines. Watch something funny!',
                                'Most Importantly, SMILE! Smiling can become contagious. If you feel depressed, smiling can help elevate your mood.',
                                "If you need to crying definitely helps. Don't hold it back because you will feel a lot better.",
                                'Never Give Up on yourself!',
                                'Distract your mind from bad thoughts!',
                                'Exercise to divert your mind and to feel better. Exercising helps you get better mentally. It helps with frustations and getting things off your mind while building muscle.',
                                'Do not blame yourself. YOU ARE WORTH IT!',
                                'Listen to some of you favorite songs and dance it off.',
                                'If you know a place, you should go jump on a trampoline. It is a lot of fun and also incorporates cardio for exercising.',
                                'Have A Great Day & Keep Smiling!',
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6FA5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mood,
                        color: Color(0xFF4A6FA5),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanStatusCard() {
    final isLifetime = widget.planType == 'lifetime';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLifetime 
              ? [
                  kSecondary,
                  kPrimary,
                ]
              : [
                  kPrimary,
                  kAccent,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLifetime ? 'LIFETIME' : 'FREE TRIAL',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLifetime 
                      ? 'Unlimited Access'
                      : '7 Days Left',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLifetime
                      ? 'All premium features'
                      : 'Upgrade anytime',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLifetime ? Icons.star : Icons.schedule,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Breathe',
            '5 min session',
            Icons.air,
            LinearGradient(colors: [kPrimary, kAccent]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Meditate',
            '10 min focus',
            Icons.self_improvement,
            LinearGradient(colors: [kSecondary, kPrimary]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Sleep',
            'Relax & rest',
            Icons.bedtime,
            LinearGradient(colors: [kAccent, kPrimary.withOpacity(0.9)]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, LinearGradient gradient) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.28),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle action
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedMeditations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.86),
            Colors.white.withOpacity(0.66),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Today\'s Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3 new',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00A8CC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMeditationItem('Morning Peace', '10 min', Icons.wb_sunny_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeditationItem('Focus Deep', '15 min', Icons.center_focus_strong),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeditationItem('Sleep Well', '20 min', Icons.bedtime_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationItem(String title, String duration, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          // Play meditation
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kPrimary.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSecondary, kPrimary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationContent() {
    return const Center(
      child: Text(
        'Meditation Library',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),
    );
  }

  Widget _buildProgressContent() {
    return const Center(
      child: Text(
        'Your Progress',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),
    );
  }

  Widget _profileCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return ProfilePage(planType: widget.planType);
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: kPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.self_improvement_outlined, Icons.self_improvement, 'Meditate'),
              _buildNavItem(2, Icons.trending_up_outlined, Icons.trending_up, 'Progress'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected 
                ? kPrimary
                : const Color(0xFF8E8E93),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected 
                  ? kPrimary
                  : const Color(0xFF8E8E93),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  // --- Sleep visuals ---
}

class _WeeklySleepBarChart extends StatelessWidget {
  final List<double> values; // hours slept per day (Mon..Sun)
  final double goal;

  const _WeeklySleepBarChart({Key? key, required this.values, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = (values.fold<double>(0, (p, c) => c > p ? c : p)).clamp(0, 12);
    final days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserve vertical space for label+spacing under each bar to avoid overflow
        const double labelSpace = 18.0; // approx label + bottom spacing
        const double betweenBarSpacing = 10.0;
        final double availableHeight = (constraints.maxHeight - labelSpace).clamp(0.0, constraints.maxHeight);
        // Make sure total width accounts for spacing only between bars, not after the last one
        final barWidth = (constraints.maxWidth - 6 * betweenBarSpacing) / 7;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final v = values[i];
            final denom = (maxValue == 0 ? 1 : maxValue);
            final h = availableHeight * (v / denom);
            final meetsGoal = v >= goal;
            return Padding(
              padding: EdgeInsets.only(right: i == 6 ? 0 : betweenBarSpacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: h < 4 ? 4 : h, // ensure a visible minimum height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: meetsGoal
                            ? const [Color(0xFF6C63FF), Color(0xFF00A8CC)]
                            : const [Color(0xFFB0CFE0), Color(0xFFD9ECF7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (meetsGoal ? const Color(0xFF00A8CC) : const Color(0xFF7BCFE9)).withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 12,
                    child: Text(
                      days[i],
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _SleepDonut extends StatelessWidget {
  final double sleptHours;
  final double goalHours;

  const _SleepDonut({Key? key, required this.sleptHours, required this.goalHours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (sleptHours / goalHours).clamp(0.0, 1.0);
    return CustomPaint(
      painter: _DonutPainter(progress: progress),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.2),
            ),
            const SizedBox(height: 2),
            Text(
              '${sleptHours.toStringAsFixed(1)} / ${goalHours.toStringAsFixed(0)}h',
              style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress; // 0..1

  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFE6EEF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 / 2, 3.14 * 2, false, backgroundPaint);
    // Foreground arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 / 2, (3.14 * 2) * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'emotion_content_page.dart';
import 'support_messages_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'wellness_components.dart';

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

  // Login/Profile page color palette
  final Color kPrimary = const Color(0xFF4A6FA5); // Deep blue
  final Color kSecondary = const Color(0xFF5B7DB1); // Medium blue
  final Color kAccent = const Color(0xFF6B8FC3); // Light blue
  final List<Color> kBg = const [
    Color(0xFFE8F1FF), // Soft sky blue
    Color(0xFFE0EBFF), // Light periwinkle
    Color(0xFFD6E4FF), // Pale blue
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
            Color(0xFFE8F1FF), // Soft sky blue
            Color(0xFFE0EBFF), // Light periwinkle
            Color(0xFFD6E4FF), // Pale blue
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        // Floating peaceful circles matching login page
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4A6FA5).withOpacity(0.12),
                  const Color(0xFF4A6FA5).withOpacity(0.04),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: 80,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5B7DB1).withOpacity(0.12),
                  const Color(0xFF5B7DB1).withOpacity(0.04),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 400,
          left: 30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B8FC3).withOpacity(0.1),
                  const Color(0xFF6B8FC3).withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 40,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4A6FA5).withOpacity(0.08),
                  const Color(0xFF4A6FA5).withOpacity(0.02),
                ],
              ),
            ),
          ),
        ),
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
          {'label': 'Magic', 'emoji': '✨'},
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
                                                  onTap: () async {
                                                    setState(() => selected = opt['label'] as String);
                                                    if (opt['label'] == 'Magic') {
                                                      // Open nested emotion dialog for Magic
                                                      Future.delayed(const Duration(milliseconds: 150), () async {
                                                        Navigator.of(context).pop();
                                                        await _openNestedEmotionDialog();
                                                      });
                                                    } else {
                                                      Future.delayed(const Duration(milliseconds: 150), () {
                                                        Navigator.of(context).pop(opt['label']);
                                                      });
                                                    }
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

  Future<String?> _openNestedEmotionDialog() async {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Nested Emotion',
      barrierColor: Colors.black.withOpacity(0.3),
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
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Opacity(
            opacity: curved.value,
            child: Transform.scale(
              scale: 0.94 + 0.06 * curved.value,
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
                                    Colors.purple.shade50.withOpacity(0.98),
                                    Colors.purple.shade100.withOpacity(0.92),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.2),
                                  width: 1.5,
                                ),
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
                                        color: Colors.purple.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Back button row
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.purple),
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
                                        final v = _breathingController.value;
                                        final scale = 0.98 + (v * 0.04);
                                        final dy = (v - 0.5) * 8;
                                        final glow = 0.15 + (v * 0.25);
                                        return Transform.translate(
                                          offset: Offset(0, dy),
                                          child: Transform.scale(
                                            scale: scale,
                                            child: Container(
                                              width: 88,
                                              height: 88,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple.withOpacity(glow),
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
                                                        ? '✨'
                                                        : options.firstWhere((e) => e['label'] == selected)['emoji'] as String,
                                                    key: ValueKey<String>(selected.isEmpty ? 'magic' : selected),
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
                                      'Magic Mood Selection',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Choose your magical feeling',
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
                                        final useAltDesign = size.width < 360;
                                        return Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: options.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final opt = entry.value;
                                            final isSelected = selected == opt['label'];
                                            final base = (curved.value - index * 0.08).clamp(0.0, 1.0);
                                            final dy = (1.0 - base) * 12.0;
                                            return Opacity(
                                              opacity: base,
                                              child: Transform.translate(
                                                offset: Offset(0, dy),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() => selected = opt['label'] as String);
                                                    Future.delayed(const Duration(milliseconds: 150), () async {
                                                      Navigator.of(context).pop();
                                                      // Navigate to emotion content page
                                                      await Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => EmotionContentPage(
                                                            emotion: opt['label'] as String,
                                                          ),
                                                        ),
                                                      );
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
                                                                  ? Colors.purple.shade400
                                                                  : Colors.purple.shade50,
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(
                                                                color: Colors.purple.withOpacity(isSelected ? 0.0 : 0.15),
                                                              ),
                                                              boxShadow: isSelected
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: Colors.purple.withOpacity(0.25),
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
                                                                        : Colors.purple.withOpacity(0.08),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      opt['emoji'] as String,
                                                                      style: TextStyle(fontSize: isSelected ? 22 : 20),
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
                                                                  ? Colors.purple.shade400
                                                                  : Colors.purple.shade50,
                                                              borderRadius: BorderRadius.circular(22),
                                                              border: Border.all(
                                                                color: Colors.purple.withOpacity(isSelected ? 0.0 : 0.15),
                                                                width: 1,
                                                              ),
                                                              boxShadow: isSelected
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: Colors.purple.withOpacity(0.25),
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Inspiration
                _buildWelcomeHeader(),
                const SizedBox(height: 20),
                
                // Daily Emotion Status
                _buildDailyEmotionStatus(),
                const SizedBox(height: 20),
                
                // Mood Improvement Streak
                _buildStreakCard(),
                const SizedBox(height: 20),
                
                // Quick Actions for Mood Improvement
                _buildQuickActions(),
                const SizedBox(height: 24),
                
                // Emotional Wellness Tips
                _buildWellnessTips(),
                const SizedBox(height: 20),
                
                // Content Categories
                _buildContentCategories(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        
        // Content Feed
        _buildContentFeed(),
        
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // State variables for content
  String _selectedEmotion = 'Happy';
  String _selectedEmoji = '😀';
  String _selectedCategory = 'All';
  
  Widget _buildDailyEmotionStatus() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Today\'s Mood',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final mood = await _openEmotionDialog();
                  if (mood != null && mounted) {
                    setState(() {
                      _selectedEmotion = mood;
                      _selectedEmoji = {
                        'Happy': '😀',
                        'Sad': '😢',
                        'Disappointed': '😞',
                        'Stressed': '😣',
                        'Nervous': '😬',
                        'Calm': '😌',
                      }[mood] ?? '😀';
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kSecondary, kPrimary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kSecondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.98 + (_breathingController.value * 0.04),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kSecondary, kPrimary],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feeling $_selectedEmotion',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s find content to match your mood',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8E93),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Row(
            children: [
              // Streak icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSecondary, kPrimary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kSecondary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Happiness Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep turning frowns upside down!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSecondary.withOpacity(0.2), kPrimary.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '7 Days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A6FA5),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessTips() {
    final tips = [
      {
        'title': 'Practice Gratitude',
        'description': 'Write 3 things you\'re grateful for',
        'icon': Icons.favorite_border,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'title': 'Deep Breathing',
        'description': 'Take 5 deep breaths to calm down',
        'icon': Icons.air,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'title': 'Connect & Smile',
        'description': 'Reach out to someone special',
        'icon': Icons.people_outline,
        'color': const Color(0xFFFFE66D),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wellness Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Padding(
                padding: EdgeInsets.only(right: index == tips.length - 1 ? 0 : 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: (tip['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              tip['icon'] as IconData,
                              color: tip['color'] as Color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Flexible(
                            child: Text(
                              tip['title'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              tip['description'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8E8E93),
                                letterSpacing: -0.1,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCategories() {
    final categories = [
      {'name': 'All', 'icon': Icons.apps, 'count': '12'},
      {'name': 'Happiness', 'icon': Icons.sentiment_very_satisfied, 'count': '4'},
      {'name': 'Motivation', 'icon': Icons.emoji_events, 'count': '3'},
      {'name': 'Relaxation', 'icon': Icons.spa, 'count': '2'},
      {'name': 'Positivity', 'icon': Icons.wb_sunny, 'count': '3'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse Content',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['name'];
              
              return Padding(
                padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedCategory = category['name'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kSecondary, kPrimary],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.2),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? kSecondary.withOpacity(0.4)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: isSelected ? 15 : 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: isSelected ? Colors.white : kPrimary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : kPrimary,
                            letterSpacing: -0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          category['count'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentFeed() {
    final contentItems = [
      {
        'type': 'video',
        'title': 'Morning Happiness Routine',
        'subtitle': 'Start your day with a smile - 5 simple steps',
        'duration': '8 min',
        'author': 'Emma Wilson',
        'likes': '3.2k',
        'category': 'Happiness',
      },
      {
        'type': 'audio',
        'title': 'Uplifting Music Mix',
        'subtitle': 'Feel-good tunes to brighten your spirit',
        'duration': '30 min',
        'author': 'Joy Sounds',
        'likes': '6.8k',
        'category': 'Happiness',
      },
      {
        'type': 'image',
        'title': 'Gratitude Journal Guide',
        'subtitle': 'Transform negative thoughts into positive ones',
        'duration': '5 min read',
        'author': 'Dr. Lisa Park',
        'likes': '2.1k',
        'category': 'Positivity',
      },
      {
        'type': 'video',
        'title': 'Laughter Yoga Session',
        'subtitle': 'Fun activities to make you laugh and smile',
        'duration': '12 min',
        'author': 'Happy Hearts',
        'likes': '4.5k',
        'category': 'Happiness',
      },
      {
        'type': 'audio',
        'title': 'Overcoming Sadness',
        'subtitle': 'Inspiring stories of resilience and hope',
        'duration': '20 min',
        'author': 'Hope Talks',
        'likes': '5.3k',
        'category': 'Motivation',
      },
      {
        'type': 'image',
        'title': 'Daily Affirmations',
        'subtitle': 'Powerful mantras to boost your confidence',
        'duration': '3 min read',
        'author': 'Mindful Joy',
        'likes': '3.9k',
        'category': 'Positivity',
      },
      {
        'type': 'video',
        'title': 'Nature Sounds Therapy',
        'subtitle': 'Peaceful outdoor scenes for instant calm',
        'duration': '15 min',
        'author': 'Nature Heals',
        'likes': '4.1k',
        'category': 'Relaxation',
      },
      {
        'type': 'audio',
        'title': 'Comedy Hour',
        'subtitle': 'Hilarious clips to turn frowns upside down',
        'duration': '25 min',
        'author': 'Laugh More',
        'likes': '7.2k',
        'category': 'Happiness',
      },
      {
        'type': 'video',
        'title': 'Self-Love Practice',
        'subtitle': 'Learn to appreciate yourself more each day',
        'duration': '10 min',
        'author': 'Love Yourself',
        'likes': '5.7k',
        'category': 'Positivity',
      },
      {
        'type': 'image',
        'title': 'Mood Tracking Tips',
        'subtitle': 'Understand your emotions better',
        'duration': '4 min read',
        'author': 'Wellness Guide',
        'likes': '2.8k',
        'category': 'Motivation',
      },
      {
        'type': 'audio',
        'title': 'Calming Rain Sounds',
        'subtitle': 'Soothing sounds for stress relief',
        'duration': '45 min',
        'author': 'Peace Sounds',
        'likes': '8.1k',
        'category': 'Relaxation',
      },
      {
        'type': 'video',
        'title': 'Building Resilience',
        'subtitle': 'Bounce back stronger from challenges',
        'duration': '18 min',
        'author': 'Strong Mind',
        'likes': '4.9k',
        'category': 'Motivation',
      },
    ];

    // Filter content based on selected category
    final filteredContent = _selectedCategory == 'All' 
        ? contentItems 
        : contentItems.where((item) => item['category'] == _selectedCategory).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredContent[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildContentCard(item),
            );
          },
          childCount: filteredContent.length,
        ),
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                HapticFeedback.lightImpact();
                // Handle content tap
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content Header
                Row(
                  children: [
                    _buildContentTypeIcon(item['type'] as String),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8E8E93),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildContentActions(),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Content Preview/Thumbnail
                _buildContentPreview(item),
                
                const SizedBox(height: 16),
                
                // Content Footer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: kPrimary.withOpacity(0.1),
                      child: Text(
                        (item['author'] as String)[0],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['author'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: const Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['duration'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.favorite_outline,
                      size: 14,
                      color: const Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['likes'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
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
    );
  }

  Widget _buildContentTypeIcon(String type) {
    IconData icon;
    List<Color> gradientColors;
    
    switch (type) {
      case 'video':
        icon = Icons.play_circle_filled;
        gradientColors = [kSecondary, kPrimary];
        break;
      case 'audio':
        icon = Icons.headphones;
        gradientColors = [kPrimary, kAccent];
        break;
      case 'image':
        icon = Icons.article;
        gradientColors = [kAccent, kPrimary];
        break;
      default:
        icon = Icons.circle;
        gradientColors = [kPrimary, kSecondary];
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildContentActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle bookmark
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.bookmark_outline,
              size: 16,
              color: kPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle share
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.share_outlined,
              size: 16,
              color: kPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentPreview(Map<String, dynamic> item) {
    final type = item['type'] as String;
    
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: type == 'video'
                          ? [kSecondary, kPrimary]
                          : type == 'audio'
                              ? [kPrimary, kAccent]
                              : [kAccent, kPrimary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    type == 'video' 
                        ? Icons.play_arrow
                        : type == 'audio'
                            ? Icons.volume_up
                            : Icons.image,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  type == 'video' 
                      ? 'Video Content'
                      : type == 'audio'
                          ? 'Audio Content'
                          : 'Visual Guide',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          
          // Play button overlay for video/audio
          if (type == 'video' || type == 'audio')
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSecondary, kPrimary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kSecondary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  type == 'video' ? Icons.play_arrow : Icons.headphones,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    // Daily inspirational quotes
    final quotes = [
      {'text': 'Every day is a fresh start. Choose happiness!', 'icon': Icons.wb_sunny},
      {'text': 'Your smile can change someone\'s day, including yours.', 'icon': Icons.sentiment_very_satisfied},
      {'text': 'Small steps forward are still progress.', 'icon': Icons.trending_up},
      {'text': 'You are stronger than you think.', 'icon': Icons.favorite},
      {'text': 'Turn your frown upside down - you\'ve got this!', 'icon': Icons.emoji_emotions},
      {'text': 'Believe in yourself and magic will happen.', 'icon': Icons.auto_awesome},
      {'text': 'Today is full of possibilities.', 'icon': Icons.star},
    ];
    
    // Select quote based on day of week
    final dayIndex = DateTime.now().weekday % quotes.length;
    final todayQuote = quotes[dayIndex];
    
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
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
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated icon
                  Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kSecondary, kPrimary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        todayQuote['icon'] as IconData,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Daily inspiration text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Inspiration',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayQuote['text'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Mood Boosters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Smile',
                'Turn it around',
                Icons.sentiment_very_satisfied,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kSecondary, kPrimary],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Laugh',
                'Feel better',
                Icons.emoji_emotions,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimary, kAccent],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Relax',
                'Find peace',
                Icons.spa,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kAccent, kPrimary],
                ),
              ),
            ),
          ],
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWellnessHeader(),
                const SizedBox(height: 24),
                _buildDailyWellnessQuote(),
                const SizedBox(height: 24),
                _buildMoodCheckIn(),
                const SizedBox(height: 24),
                _buildWellnessPrograms(),
                const SizedBox(height: 24),
                _buildQuickMeditations(),
                const SizedBox(height: 24),
                _buildSleepSection(),
                const SizedBox(height: 24),
                _buildBreathingExercises(),
                const SizedBox(height: 24),
                _buildWellnessChallenges(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Wellness Page Components
  Widget _buildWellnessHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimary, kSecondary, kAccent],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kSecondary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wellness Hub',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your daily dose of mindfulness',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccent.withOpacity(0.2), kSecondary.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '7 Day Streak 🔥',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyWellnessQuote() {
    final quotes = [
      "Peace comes from within. Do not seek it without. 🧘‍♀️",
      "Breathe in peace, breathe out stress. 🌸",
      "Your mind is a garden, your thoughts are the seeds. 🌱",
      "In stillness, find your strength. 💪",
      "Every breath is a new beginning. 🌅",
      "Mindfulness is about being fully awake in our lives. ✨",
      "The present moment is the only time over which we have dominion. 🕊️",
    ];
    
    final today = DateTime.now().weekday - 1;
    final quote = quotes[today % quotes.length];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathingAnimation.value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kAccent, kSecondary],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.format_quote,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Daily Wisdom',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                quote,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1E),
                  height: 1.4,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCheckIn() {
    return WellnessComponents.buildMoodCheckIn(_breathingAnimation);
  }

  Widget _buildWellnessPrograms() {
    return WellnessComponents.buildWellnessPrograms();
  }

  Widget _buildQuickMeditations() {
    return WellnessComponents.buildQuickMeditations();
  }

  Widget _buildSleepSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep & Relaxation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.bedtime,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sleep Stories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Peaceful stories to help you drift off',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '25 stories',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kSecondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Nature sounds',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: kPrimary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Breathing Exercises',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBreathingCard(
                '4-7-8 Technique',
                'Calm anxiety',
                Icons.air,
                const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBreathingCard(
                'Box Breathing',
                'Focus mind',
                Icons.crop_square,
                const Color(0xFF45B7D1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreathingCard(String title, String subtitle, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wellness Challenges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '30-Day Happiness Challenge',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Build positive habits daily',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Day 7/30',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.23, // 7/30 progress
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kPrimary, kSecondary],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 24),
                _buildMonthlySummary(),
                const SizedBox(height: 24),
                _buildHappinessStreak(),
                const SizedBox(height: 24),
                _buildWeeklyOverview(),
                const SizedBox(height: 24),
                _buildEmotionDistribution(),
                const SizedBox(height: 24),
                _buildStatisticsGrid(),
                const SizedBox(height: 24),
                _buildAchievements(),
                const SizedBox(height: 24),
                _buildWellnessInsight(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Progress Page Components
  Widget _buildProgressHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimary, kSecondary, kAccent],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kSecondary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Every smile counts! 😊',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'October 2025',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Happy Days', '26', Icons.sentiment_very_satisfied, kAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Improvement', '+15%', Icons.trending_up, kSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Goals Met', '8/10', Icons.emoji_events, kPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHappinessStreak() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🔥',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Happiness Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '7 Days Strong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep turning frowns upside down!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mood Levels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '5/7 days',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildWeekBar('M', 0.8),
                        _buildWeekBar('T', 0.6),
                        _buildWeekBar('W', 0.9),
                        _buildWeekBar('T', 0.7),
                        _buildWeekBar('F', 0.85),
                        _buildWeekBar('S', 0.4),
                        _buildWeekBar('S', 0.75),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekBar(String day, double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 60 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: value > 0.6 
                ? [kPrimary, kSecondary]
                : [const Color(0xFFB0CFE0), const Color(0xFFD9ECF7)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionDistribution() {
    final emotions = [
      {'name': 'Happy', 'count': 15, 'color': const Color(0xFFFFE66D)},
      {'name': 'Calm', 'count': 12, 'color': const Color(0xFF4ECDC4)},
      {'name': 'Stressed', 'count': 8, 'color': const Color(0xFFFF6B6B)},
      {'name': 'Sad', 'count': 5, 'color': const Color(0xFF95A5A6)},
      {'name': 'Disappointed', 'count': 3, 'color': const Color(0xFFE74C3C)},
      {'name': 'Nervous', 'count': 2, 'color': const Color(0xFF9B59B6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emotion Distribution',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: emotions.map((emotion) {
                  final percentage = ((emotion['count'] as int) / 45 * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: emotion['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Text(
                            emotion['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: (emotion['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: (emotion['count'] as int) / 15,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: emotion['color'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${emotion['count']} ($percentage%)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatisticCard('Mood Check-ins', '100', Icons.mood, kPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatisticCard('Happy Days', '85%', Icons.sentiment_very_satisfied, kAccent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatisticCard('Wellness Goals', '12', Icons.flag, kSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatisticCard('Day Streak', '7', Icons.local_fire_department, const Color(0xFFFF6B6B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'title': 'Smile Starter', 'description': 'First 7 happy days', 'unlocked': true, 'icon': Icons.sentiment_very_satisfied},
      {'title': 'Happiness Hero', 'description': '30 mood check-ins', 'unlocked': true, 'icon': Icons.favorite},
      {'title': 'Streak Master', 'description': '14 day happiness streak', 'unlocked': false, 'icon': Icons.local_fire_department},
      {'title': 'Positivity Pro', 'description': '100 uplifting moments', 'unlocked': true, 'icon': Icons.star},
      {'title': 'Joy Spreader', 'description': 'Share 10 positive vibes', 'unlocked': false, 'icon': Icons.share},
      {'title': 'Wellness Champion', 'description': 'Complete all wellness tips', 'unlocked': true, 'icon': Icons.emoji_events},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '4/6 unlocked',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final isUnlocked = achievement['unlocked'] as bool;
            
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isUnlocked
                        ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]
                        : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isUnlocked 
                                ? kAccent.withOpacity(0.2)
                                : const Color(0xFF8E8E93).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              achievement['icon'] as IconData,
                              color: isUnlocked ? kAccent : const Color(0xFF8E8E93),
                              size: 16,
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                              size: 16,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        achievement['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? const Color(0xFF1C1C1E) : const Color(0xFF8E8E93),
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: isUnlocked ? const Color(0xFF8E8E93) : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWellnessInsight() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Wellness Insight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Amazing Progress! 🌟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You've turned frowns upside down 85% of the time this week! Keep focusing on gratitude and mindful breathing to maintain this positive momentum.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1E),
                  height: 1.4,
                ),
              ),
            ],
          ),
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
              _buildNavItem(1, Icons.favorite_outline, Icons.favorite, 'Wellness'),
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

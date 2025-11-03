import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' show cos, sin, Random;
import 'dart:async';
import 'package:flutter/services.dart';
import 'emotion_content_page.dart';
import 'support_messages_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'wellness_components.dart';
import 'wellness_page.dart';
import 'smile_animation_page.dart';
import 'relax_animation_page.dart';
import 'mindful_breathing_page.dart';
import 'candy_crush_game.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final String planType;
  final String? userName;
  final String? email;
  final String? createdAt;
  
  const HomePage({
    Key? key, 
    required this.planType, 
    this.userName,
    this.email,
    this.createdAt,
  }) : super(key: key);

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
  
  // Turn Frown Around card state
  int _frownTurnedCount = 0;
  String _currentChallenge = '';
  bool _challengeCompleted = false;
  
  // New animation states
  bool _isFlipping = false;
  bool _isShaking = false;
  bool _showParticles = false;
  int _currentActivityIndex = 0;
  late AnimationController _flipController;
  late AnimationController _shakeController;
  late AnimationController _particleController;
  
  
  // Emotion state
  String _selectedEmotion = '';
  String _selectedEmoji = '';

  String _fallbackEmojiFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('happy') || l.contains('joy') || l.contains('glad')) return '😀';
    if (l.contains('sad') || l.contains('down')) return '😢';
    if (l.contains('angry') || l.contains('mad') || l.contains('rage')) return '😡';
    if (l.contains('stress') || l.contains('tense')) return '😣';
    if (l.contains('nerv') || l.contains('anx')) return '😬';
    if (l.contains('calm') || l.contains('peace')) return '😌';
    return '😀';
  }

  List<String> _buildSupportMessagesFor(String label) {
    final key = label.toLowerCase();
    if (key.contains('sad') || key.contains('down')) {
      return [
        'It\'s okay to feel sad. You\'re not alone in this.',
        'Take a deep breath. Small steps count today.',
        'Reach out to someone you trust, even with a short message.',
        'Be kind to yourself. Rest is productive too.',
        'This feeling will pass. You\'ve made it through before.'
      ];
    }
    if (key.contains('stress') || key.contains('overwhelm')) {
      return [
        'Pause and breathe in 4-4-6 rhythm for a minute.',
        'List just the next tiny step, not the whole mountain.',
        'Release what\'s outside your control right now.',
        'Progress over perfection. Done is better than perfect.',
        'You\'re stronger than this moment feels.'
      ];
    }
    if (key.contains('nerv') || key.contains('anx')) {
      return [
        'Notice 5 things you can see, 4 you can touch, 3 you can hear.',
        'Your body is safe right now. Let your shoulders drop.',
        'Prepare what you can, then let the rest unfold.',
        'Speak to yourself like you would to a close friend.',
        'You don\'t need to have it all figured out today.'
      ];
    }
    if (key.contains('disappoint') || key.contains('frustrat')) {
      return [
        'It\'s okay to feel let down. Your feelings make sense.',
        'What\'s one lesson you can carry forward?',
        'Set a tiny, kind next step for yourself.',
        'Your worth isn\'t defined by outcomes.',
        'Tomorrow offers a fresh attempt.'
      ];
    }
    if (key.contains('calm') || key.contains('peace')) {
      return [
        'Protect this calm—breathe and linger here a little longer.',
        'Savor a small joy: a sip, a sound, a view.',
        'Lightness spreads when shared—consider a gentle check-in with someone.',
        'Anchor this feeling with a short note in your journal.',
        'You\'re doing well. Keep it softly steady.'
      ];
    }
    // Default fallback
    return [
      'Thanks for sharing how you feel.',
      'Let\'s take one gentle step at a time.',
      'A short walk or a glass of water can help reset.',
      'You\'re allowed to take up space with your feelings.',
      'We\'re rooting for you. Keep going.'
    ];
  }

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
    
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    
    // Initialize daily challenge
    _initializeDailyChallenge();
    
    // Initialize emotion state
    _selectedEmotion = '';
    _selectedEmoji = '';

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
      }
    });
  }

  Future<void> _openSubEmotionDialog(int emotionId) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sub Emotions',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Opacity(
            opacity: curved.value,
            child: Transform.scale(
              scale: 0.94 + 0.06 * curved.value,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Select a sub emotion',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: ApiService.fetchSubEmotions(
                                email: 'logesh2528@gmail.com',
                                password: '12345678',
                                emotionId: emotionId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Failed to load sub emotions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF8E8E93),
                                      ),
                                    ),
                                  );
                                }
                                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                                if (items.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'No sub emotions found',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF8E8E93),
                                      ),
                                    ),
                                  );
                                }
                                return SingleChildScrollView(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: items.map((map) {
                                      final String label = (map['name'] ?? '').toString();
                                      final int subEmotionId = (map['id'] ?? -1) as int;
                                      return GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          final title = label;
                                          final parentContext = this.context; // use page context, not dialog context
                                          Navigator.of(context).pop(); // close sub-emotion dialog
                                          // Push after the dialog closes using the parent page context
                                          await Future.microtask(() async {
                                            if (!mounted) return;
                                            await Navigator.of(parentContext).push(
                                              MaterialPageRoute(
                                                builder: (context) => SupportMessagesPage(
                                                  title: title,
                                                  subEmotionId: subEmotionId,
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(22),
                                            border: Border.all(
                                              color: kPrimary.withOpacity(0.15),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1C1C1E),
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    _flipController.dispose();
    _shakeController.dispose();
    _particleController.dispose();
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
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const WellnessPage();
      case 2:
        return _buildProgressContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Future<String?> _openEmotionDialog() async {
    final options = [];

    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Emotion Selection',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        String selected = '';
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.85,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
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
                                      color: kPrimary.withOpacity(0.1),
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
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: kPrimary.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      const Text(
                                        'How are you feeling today?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C1C1E),
                                          letterSpacing: -0.2,
                                        ),
                                        textAlign: TextAlign.center,
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
                                      const SizedBox(height: 20),
                                      // Regular emotion options from API (with IDs)
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future: ApiService.fetchEmotionItems(
                                          email: 'logesh2528@gmail.com',
                                          password: '12345678',
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              child: Center(child: CircularProgressIndicator()),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Text(
                                                'Failed to load emotions',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF8E8E93),
                                                ),
                                              ),
                                            );
                                          }
                                          final items = snapshot.data ?? const <Map<String, dynamic>>[];
                                          if (items.isEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Text(
                                                'No emotions found',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF8E8E93),
                                                ),
                                              ),
                                            );
                                          }
                                          return Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: items.asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final map = entry.value;
                                              final String label = (map['name'] ?? '').toString();
                                              final int emotionId = (map['id'] ?? -1) as int;
                                              final String emoji = (map['emoji'] ?? '').toString();
                                              final isSelected = selected == label;
                                              final base = (curved.value - index * 0.05).clamp(0.0, 1.0);
                                              final dy = (1.0 - base) * 8.0;
                                              return Opacity(
                                                opacity: base,
                                                child: Transform.translate(
                                                  offset: Offset(0, dy),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      HapticFeedback.lightImpact();
                                                      setState(() => selected = label);
                                                      await Future.delayed(const Duration(milliseconds: 150));
                                                      if (mounted) {
                                                        // Persist the chosen emoji in parent state so the header can use it
                                                        this.setState(() {
                                                          _selectedEmoji = emoji.isNotEmpty ? emoji : _fallbackEmojiFor(label);
                                                        });
                                                      }
                                                      await _openSubEmotionDialog(emotionId);
                                                      if (mounted) {
                                                        Navigator.of(context).pop(label);
                                                      }
                                                    },
                                                    child: AnimatedScale(
                                                      duration: const Duration(milliseconds: 140),
                                                      scale: isSelected ? 1.02 : 1.0,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          gradient: isSelected
                                                              ? LinearGradient(
                                                                  colors: [kSecondary, kPrimary],
                                                                )
                                                              : LinearGradient(
                                                                  colors: [
                                                                    Colors.white.withOpacity(0.3),
                                                                    Colors.white.withOpacity(0.2),
                                                                  ],
                                                                ),
                                                          borderRadius: BorderRadius.circular(22),
                                                          border: Border.all(
                                                            color: isSelected 
                                                                ? Colors.transparent 
                                                                : kPrimary.withOpacity(0.15),
                                                            width: 1,
                                                          ),
                                                          boxShadow: isSelected
                                                              ? [
                                                                  BoxShadow(
                                                                    color: kSecondary.withOpacity(0.3),
                                                                    blurRadius: 12,
                                                                    offset: const Offset(0, 6),
                                                                  ),
                                                                ]
                                                              : null,
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            if (emoji.isNotEmpty) ...[
                                                              Text(
                                                                emoji,
                                                                style: const TextStyle(fontSize: 18),
                                                              ),
                                                              const SizedBox(width: 8),
                                                            ],
                                                            Text(
                                                              label,
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
                                      
                                      // Magic Button
                                      GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.mediumImpact();
                                          Navigator.of(context).pop();
                                          final magicEmotion = await _openNestedEmotionDialog();
                                          if (magicEmotion != null && mounted) {
                                            // Handle magic emotion selection
                                            setState(() {
                                              _selectedEmotion = 'Magic: $magicEmotion';
                                              _selectedEmoji = '✨';
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF9C27B0), // Purple
                                                Color(0xFFE91E63), // Pink
                                                Color(0xFFFF9800), // Orange
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF9C27B0).withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: const Color(0xFFE91E63).withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '✨',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Magic',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Skip button
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.of(context).pop(null);
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
                                              color: kPrimary,
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

  Future<String?> _openNestedEmotionDialog() async {
    // Retained legacy nested dialog (not used for API-driven sub-emotions)
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
        final options = [];
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

  // Initialize daily challenge based on current day
  void _initializeDailyChallenge() {
    final challenges = [
      'Send a compliment to someone today',
      'Write down 3 things you\'re grateful for',
      'Smile at 5 strangers you meet',
      'Do a random act of kindness',
      'Share a positive memory with a friend',
      'Take 10 deep breaths and appreciate the moment',
      'Listen to your favorite uplifting song',
    ];
    
    final dayIndex = DateTime.now().weekday - 1;
    _currentChallenge = challenges[dayIndex % challenges.length];
  }

  // Handle Turn Frown Around action - Navigate to shooting game
  void _handleTurnFrownAround() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _frownTurnedCount++;
      _challengeCompleted = true;
    });

    // Navigate to shooting game
    _navigateToShootingGame();
  }

  // Navigate to the shooting game
  void _navigateToShootingGame() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CandyCrushGame(),
      ),
    );
  }


  // Activity 1: Flip Animation
  void _performFlipAnimation() {
    setState(() => _isFlipping = true);
    _flipController.forward().then((_) {
      _flipController.reverse().then((_) {
        if (mounted) setState(() => _isFlipping = false);
      });
    });
  }

  // Activity 2: Shake Animation
  void _performShakeAnimation() {
    setState(() => _isShaking = true);
    _shakeController.repeat(count: 3).then((_) {
      _shakeController.reset();
      if (mounted) setState(() => _isShaking = false);
    });
  }

  // Activity 3: Particle Explosion
  void _performParticleExplosion() {
    setState(() => _showParticles = true);
    _particleController.forward().then((_) {
      _particleController.reset();
      if (mounted) setState(() => _showParticles = false);
    });
  }

  // Activity 4: Color Wave
  void _performColorWave() {
    // This will be handled in the UI with color transitions
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.selectionClick();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }

  // Activity 5: Bounce Animation
  void _performBounceAnimation() {
    _breathingController.stop();
    _breathingController.repeat(count: 3).then((_) {
      _breathingController.repeat(reverse: true);
    });
  }

  // Show Turn Frown Around success dialog
  void _showTurnFrownAroundDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Turn Frown Around',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Transform.scale(
              scale: curved.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success animation
                      AnimatedBuilder(
                        animation: _breathingController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: 1.0 + (_breathingController.value * 0.1),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [kPrimary, kSecondary],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '🎉 Frown Turned Around!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ve turned $_frownTurnedCount frowns around today!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                          letterSpacing: -0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Today\'s Challenge: $_currentChallenge',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                          letterSpacing: -0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPrimary, kSecondary],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Keep Going! 💪',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build enhanced Turn Frown Around card content - Always shows Smile Catcher Game
  Widget _buildTurnFrownAroundContent(Map<String, dynamic> tip, double iconSize, double iconInnerSize, double titleFontSize, double descriptionFontSize, double spacingBetween) {
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game icon with progress counter
          Row(
            children: [
              AnimatedBuilder(
                animation: _breathingController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1.0 + (_breathingController.value * 0.08),
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (tip['color'] as Color).withOpacity(0.4),
                            (tip['color'] as Color).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (tip['color'] as Color).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.videogame_asset,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Progress counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (tip['color'] as Color).withOpacity(0.2),
                      (tip['color'] as Color).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_frownTurnedCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tip['color'] as Color,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacingBetween.clamp(4.0, 8.0)),
          
          // Title with completion indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  tip['title'] as String,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_challengeCompleted) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade600,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          
          // Game description
          Expanded(
            child: Text(
              'Play Smile Catcher Game! 🎮',
              style: TextStyle(
                fontSize: (descriptionFontSize - 1).clamp(10.0, 14.0),
                fontWeight: FontWeight.w500,
                color: (tip['color'] as Color),
                letterSpacing: -0.1,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Action button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (tip['color'] as Color).withOpacity(0.15),
                  (tip['color'] as Color).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (tip['color'] as Color).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Tap to Play! 🎮',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A6FA5),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions for responsive design
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenHeight < 700 || screenWidth < 360;
        
        // Adjust spacing based on screen size
        final cardSpacing = isSmallScreen ? 8.0 : 12.0;
        final sectionSpacing = isSmallScreen ? 12.0 : 16.0;
        final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                isSmallScreen ? 80 : 100, // Responsive bottom padding for navigation bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Welcome Back Section
                _buildWelcomeBackSection(),
                SizedBox(height: sectionSpacing),
                
                // Daily Inspiration
                _buildWelcomeHeader(),
                SizedBox(height: sectionSpacing),
                
                // Daily Emotion Status
                _buildDailyEmotionStatus(),
                SizedBox(height: sectionSpacing),
                
                
                // Quick Actions for Mood Improvement
                _buildQuickActions(),
                SizedBox(height: cardSpacing + 8),
                
                // Emotional Wellness Tips
                _buildWellnessTips(),
                SizedBox(height: sectionSpacing),
                
                // Wellness Content Button
                _buildWellnessContentButton(),
                
                // Extra bottom spacing for safe area
                SizedBox(height: isSmallScreen ? 20 : 40),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

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
                      // Keep emoji set by the dialog; if none was set, fall back
                      if (_selectedEmoji.isEmpty) {
                        _selectedEmoji = _fallbackEmojiFor(mood);
                      }
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

  Widget _buildWelcomeBackSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Welcome icon
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
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
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
                      'Welcome back, ${widget.userName ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to turn your frown upside down?',
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
        ),
      ),
    );
  }

  Widget _buildWellnessTips() {
    final tips = [
      {
        'emoji': '🎮',
        'title': 'Smile Catcher',
        'desc': 'Play & boost mood',
        'action': 'game',
      },
      {
        'emoji': '🧘',
        'title': 'Breathe Deeply',
        'desc': '5 slow breaths',
        'action': 'breathing',
      },
      {
        'emoji': '😊',
        'title': 'Share a Smile',
        'desc': 'Brighten someone\'s day',
        'action': 'smile',
      },
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final cardW = isSmall ? 136.0 : 148.0;
    final cardH = isSmall ? 76.0 : 84.0;
    final emojiSize = isSmall ? 28.0 : 32.0;
    final titleSize = isSmall ? 13.0 : 14.0;
    final descSize = isSmall ? 11.0 : 12.0;
    final spacing = isSmall ? 8.0 : 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kSecondary],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Emotional Wellness Tips',
              style: TextStyle(
                fontSize: isSmall ? 15 : 16,
                fontWeight: FontWeight.w600,
                color: kPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        SizedBox(
          height: cardH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, i) {
              final tip = tips[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final action = tip['action'] as String?;
                    
                    if (action == 'game') {
                      // Navigate to Smile Catcher game
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CandyCrushGame()),
                      );
                    } else if (action == 'breathing') {
                      // Navigate to breathing exercise
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MindfulBreathingPage()),
                      );
                    } else {
                      // Show encouraging message for other tips
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Great choice! ${tip['desc']}'),
                          backgroundColor: kPrimary,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: cardW,
                    height: cardH,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          kAccent.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kPrimary.withOpacity(0.15), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          tip['emoji']!,
                          style: TextStyle(fontSize: emojiSize),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: titleSize,
                                  color: kPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                tip['desc']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: descSize,
                                  color: kSecondary,
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
          ),
        ),
      ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        // Responsive dimensions
        final headerFontSize = isSmallScreen ? 16.0 : 18.0;
        final spacingBetween = isSmallScreen ? 8.0 : 12.0;
        final spacingVertical = isSmallScreen ? 10.0 : 12.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Mood Boosters',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: spacingVertical),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Smile',
                    'Hold to smile',
                    Icons.sentiment_very_satisfied,
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kSecondary, kPrimary],
                    ),
                  ),
                ),
                SizedBox(width: spacingBetween),
                Expanded(
                  child: _buildActionCard(
                    'Relax',
                    '4‑7‑8 Breathing',
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
      },
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, LinearGradient gradient) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        // Responsive dimensions
        final cardHeight = isSmallScreen ? 100.0 : 120.0;
        final iconSize = isSmallScreen ? 28.0 : 32.0;
        final iconInnerSize = isSmallScreen ? 16.0 : 18.0;
        final titleFontSize = isSmallScreen ? 12.0 : 14.0;
        final subtitleFontSize = isSmallScreen ? 10.0 : 11.0;
        final padding = isSmallScreen ? 12.0 : 16.0;
        
        return Container(
          height: cardHeight,
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
                if (title.toLowerCase() == 'smile') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SmileAnimationPage()),
                  );
                } else if (title.toLowerCase() == 'relax') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RelaxAnimationPage()),
                  );
                }
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                if (title.toLowerCase() == 'smile') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SmileAnimationPage()),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: title == 'Smile' ? 'smileHero' : 'quickIcon_$title',
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: iconInnerSize),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
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
      },
    );
  }

  Widget _buildWellnessContentButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        // Responsive dimensions
        final padding = isSmallScreen ? 16.0 : 20.0;
        final iconSize = isSmallScreen ? 40.0 : 50.0;
        final iconInnerSize = isSmallScreen ? 22.0 : 26.0;
        final titleFontSize = isSmallScreen ? 14.0 : 16.0;
        final subtitleFontSize = isSmallScreen ? 11.0 : 13.0;
        final spacingWidth = isSmallScreen ? 12.0 : 16.0;
        final arrowSize = isSmallScreen ? 16.0 : 18.0;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedIndex = 1; // Navigate to wellness page
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
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
                            Icons.spa,
                            color: Colors.white,
                            size: iconInnerSize,
                          ),
                        ),
                        SizedBox(width: spacingWidth),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wellness Content',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1C1E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Videos, Audio & Guides for Your Journey',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8E8E93),
                                  letterSpacing: -0.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimary,
                          size: arrowSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
    return ProfilePage(
      planType: widget.planType,
      userName: widget.userName,
      email: widget.email,
      createdAt: widget.createdAt,
    );
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

// Particle Painter for sparkle burst effect
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final particleCount = 12;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * 3.14159;
      final distance = animationValue * 60; // Max distance
      final opacity = (1 - animationValue).clamp(0.0, 1.0);
      
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      
      // Different colors for particles
      final colors = [
        const Color(0xFF4A6FA5),
        const Color(0xFF5B7DB1),
        const Color(0xFF6B8FC3),
        const Color(0xFFFFD700), // Gold
        const Color(0xFFFF69B4), // Pink
      ];
      
      paint.color = colors[i % colors.length].withOpacity(opacity);
      
      // Draw particle as small circle
      canvas.drawCircle(
        Offset(x, y),
        4 * (1 - animationValue * 0.5), // Shrinking size
        paint,
      );
      
      // Draw sparkle effect
      if (animationValue < 0.7) {
        final sparkleSize = 8 * (1 - animationValue);
        paint.color = Colors.white.withOpacity(opacity * 0.8);
        
        // Draw cross sparkle
        canvas.drawLine(
          Offset(x - sparkleSize / 2, y),
          Offset(x + sparkleSize / 2, y),
          paint..strokeWidth = 2,
        );
        canvas.drawLine(
          Offset(x, y - sparkleSize / 2),
          Offset(x, y + sparkleSize / 2),
          paint..strokeWidth = 2,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}


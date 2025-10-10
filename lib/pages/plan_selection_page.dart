import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'home_page.dart';

class PlanSelectionPage extends StatefulWidget {
  const PlanSelectionPage({Key? key}) : super(key: key);

  @override
  State<PlanSelectionPage> createState() => _PlanSelectionPageState();
}

class _PlanSelectionPageState extends State<PlanSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _rippleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _rippleAnimation;

  int _selectedPlan = 0; // 0 for free trial, 1 for lifetime
  bool _isLoading = false;
  
  final List<Offset> _particlePositions = [];
  final List<double> _particleOpacities = [];
  final List<Color> _particleColors = [];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _initializeParticles();
    _fadeController.forward();
    _slideController.forward();
    _breathingController.repeat(reverse: true);
    _particleController.repeat();
    _rippleController.repeat();
  }
  
  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particlePositions.add(Offset(
        random.nextDouble(),
        random.nextDouble(),
      ));
      _particleOpacities.add(0.3 + random.nextDouble() * 0.4);
      _particleColors.add([
        const Color(0xFF6B73FF),
        const Color(0xFF9C88FF),
        const Color(0xFF7C3AED),
        const Color(0xFF4F46E5),
        const Color(0xFF8B5CF6),
      ][random.nextInt(5)]);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _breathingController.dispose();
    _particleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      // Navigate to home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            planType: _selectedPlan == 0 ? 'trial' : 'lifetime',
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Same animated background
          _buildAnimatedBackground(),
          
          // Same floating shapes
          _buildFloatingShapes(),
          
          // Plan selection content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Header
                          _buildHeader(),
                          
                          const SizedBox(height: 40),
                          
                          // Plan cards
                          _buildPlanCards(),
                          
                          const SizedBox(height: 40),
                          
                          // Continue button
                          _buildContinueButton(),
                          
                          const SizedBox(height: 20),
                          
                          // Terms text
                          _buildTermsText(),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFF0F4F8), const Color(0xFFE8F2F7), _breathingAnimation.value * 0.3)!,
                Color.lerp(const Color(0xFFE8F2F7), const Color(0xFFDCE9F1), _breathingAnimation.value * 0.2)!,
                Color.lerp(const Color(0xFFDCE9F1), const Color(0xFFD1E0EB), _breathingAnimation.value * 0.1)!,
                const Color(0xFFD1E0EB),
              ],
            ),
          ),
          child: _buildParticleSystem(),
        );
      },
    );
  }
  
  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particlePositions,
            opacities: _particleOpacities,
            colors: _particleColors,
            animationValue: _particleAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        // Ripple effects from center
        AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 150,
              top: 200,
              child: Stack(
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final rippleValue = (_rippleAnimation.value - delay).clamp(0.0, 1.0);
                  return Container(
                    width: 300 * rippleValue,
                    height: 300 * rippleValue,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6B73FF).withOpacity((1 - rippleValue) * 0.3),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        
        // Enhanced floating orbs
        ...List.generate(6, (index) {
          return AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              final offset = (index * 0.4) + (_breathingController.value * 0.6);
              final size = 25.0 + (index * 8.0) + (offset * 10);
              return Positioned(
                left: 40 + (index * 70.0) + (math.sin(offset * math.pi) * 30),
                top: 120 + (index * 90.0) + (math.cos(offset * math.pi) * 25),
                child: Transform.scale(
                  scale: 0.7 + (offset * 0.3),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          [
                            const Color(0xFF6B73FF).withOpacity(0.15),
                            const Color(0xFF9C88FF).withOpacity(0.12),
                            const Color(0xFF7C3AED).withOpacity(0.10),
                          ][index % 3],
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: [
                            const Color(0xFF6B73FF),
                            const Color(0xFF9C88FF),
                            const Color(0xFF7C3AED),
                          ][index % 3].withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
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

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(32),
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
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B73FF).withOpacity(0.1),
                      blurRadius: 60,
                      offset: const Offset(0, 20),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Logo with glow effect
                    Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6B73FF),
                              Color(0xFF9C88FF),
                              Color(0xFF7C3AED),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B73FF).withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: const Color(0xFF9C88FF).withOpacity(0.3),
                              blurRadius: 60,
                              offset: const Offset(0, 25),
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/splash/logo.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.self_improvement,
                                  size: 45,
                                  color: Color(0xFF6B73FF),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Enhanced Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF1C1C1E),
                          Color(0xFF4A5568),
                          Color(0xFF6B73FF),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Choose Your Plan',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Enhanced Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6B73FF).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '✨ Start your mindfulness journey today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Free Trial Card
          _buildPlanCard(
            index: 0,
            title: 'Free Trial',
            subtitle: '7 days free',
            price: 'Free',
            features: [
              'Access to basic meditations',
              'Daily mindfulness reminders',
              'Progress tracking',
              'Community support',
            ],
            isPopular: false,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6B8FC3),
                Color(0xFF5B7DB1),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lifetime Plan Card
          _buildPlanCard(
            index: 1,
            title: 'Lifetime Access',
            subtitle: 'One-time payment',
            price: '\$99',
            features: [
              'Unlimited premium meditations',
              'Advanced mindfulness programs',
              'Personalized recommendations',
              'Offline downloads',
              'Priority support',
              'Exclusive content',
            ],
            isPopular: true,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A6FA5),
                Color(0xFF5B7DB1),
                Color(0xFF6B8FC3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool isPopular,
    required LinearGradient gradient,
  }) {
    final isSelected = _selectedPlan == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.02 : 1.0)
          ..translate(0.0, isSelected ? -8.0 : 0.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? gradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.10),
                        ],
                      ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0xFF6B73FF).withOpacity(0.3)
                        : const Color(0xFF6B73FF).withOpacity(0.08),
                    blurRadius: isSelected ? 40 : 20,
                    offset: Offset(0, isSelected ? 20 : 10),
                    spreadRadius: isSelected ? -5 : -2,
                  ),
                  if (isSelected) ...[
                    BoxShadow(
                      color: const Color(0xFF9C88FF).withOpacity(0.2),
                      blurRadius: 60,
                      offset: const Offset(0, 30),
                      spreadRadius: -10,
                    ),
                  ],
                ],
              ),
              child: Stack(
                children: [
                  // Animated background glow for selected card
                  if (isSelected)
                    AnimatedBuilder(
                      animation: _breathingController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.0 + (_breathingAnimation.value - 1.0) * 0.2,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Popular badge with enhanced design
                  if (isPopular)
                    Positioned(
                      top: -2,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B6B),
                              Color(0xFFFF8E53),
                              Color(0xFFFFB347),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'POPULAR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with enhanced styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Plan icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            )
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFF6B73FF),
                                                Color(0xFF9C88FF),
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isSelected 
                                              ? Colors.white 
                                              : const Color(0xFF6B73FF)).withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      index == 0 ? Icons.explore : Icons.diamond,
                                      size: 24,
                                      color: isSelected 
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                  
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.8)
                                          : const Color(0xFF6B7280),
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Price with enhanced styling
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  price,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? Colors.white : const Color(0xFF6B73FF),
                                    letterSpacing: -1.0,
                                    height: 1.0,
                                  ),
                                ),
                                if (index == 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: (isSelected ? Colors.white : const Color(0xFF6B73FF)).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'forever',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                            ? Colors.white.withOpacity(0.9)
                                            : const Color(0xFF6B73FF),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Features with enhanced design
                        ...features.asMap().entries.map((entry) {
                          final featureIndex = entry.key;
                          final feature = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    gradient: isSelected 
                                        ? LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF6B73FF),
                                              Color(0xFF9C88FF),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isSelected 
                                            ? Colors.white 
                                            : const Color(0xFF6B73FF)).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: isSelected 
                                        ? Colors.white
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.95)
                                          : const Color(0xFF374151),
                                      letterSpacing: -0.1,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  // Enhanced selection indicator
                  Positioned(
                    top: 20,
                    right: 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: isSelected 
                            ? const LinearGradient(
                                colors: [Colors.white, Colors.white],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                        border: Border.all(
                          color: isSelected 
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Color(0xFF6B73FF),
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              size: 20,
                              color: Colors.white.withOpacity(0.6),
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
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(_isLoading ? 0.95 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6B73FF),
                    Color(0xFF9C88FF),
                    Color(0xFF7C3AED),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B73FF).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF9C88FF).withOpacity(0.3),
                    blurRadius: 60,
                    offset: const Offset(0, 25),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isLoading ? null : _handleContinue,
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Processing...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _selectedPlan == 0 ? Icons.play_arrow_rounded : Icons.diamond,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedPlan == 0 ? 'Start Free Trial' : 'Get Lifetime Access',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
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
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedPlan == 0 ? Icons.info_outline : Icons.security,
              color: const Color(0xFF6B73FF),
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedPlan == 0
                  ? 'Free trial for 7 days. Cancel anytime during trial period. No credit card required.'
                  : 'One-time payment. No recurring charges. 30-day money-back guarantee. Secure payment.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                letterSpacing: -0.1,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedPlan == 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Best Value',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom particle painter for enhanced background effects
class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final List<double> opacities;
  final List<Color> colors;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.opacities,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(
          opacities[i] * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + i)),
        )
        ..style = PaintingStyle.fill;

      // Calculate animated position
      final baseX = particles[i].dx * size.width;
      final baseY = particles[i].dy * size.height;
      
      // Add floating movement
      final offsetX = math.sin(animationValue * 2 * math.pi + i * 0.5) * 30;
      final offsetY = math.cos(animationValue * 1.5 * math.pi + i * 0.3) * 20;
      
      final x = baseX + offsetX;
      final y = baseY + offsetY;
      
      // Wrap around screen edges
      final wrappedX = x % size.width;
      final wrappedY = y % size.height;
      
      // Draw particle with size variation
      final radius = 3.0 + 2.0 * math.sin(animationValue * 3 * math.pi + i * 0.7);
      
      // Draw main particle
      canvas.drawCircle(
        Offset(wrappedX, wrappedY),
        radius,
        paint,
      );
      
      // Draw subtle glow effect
      final glowPaint = Paint()
        ..color = colors[i].withOpacity(opacities[i] * 0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(wrappedX, wrappedY),
        radius * 2.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'register_page.dart';
import 'home_page.dart';

/// Clean, basic login page with iOS-style social buttons
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _socialController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _socialAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
    
    _socialAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _socialController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations with staggered timing
    _fadeController.forward();
    _slideController.forward();
    
    // Delayed card and social animations
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _socialController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _cardController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  // Authentication handlers
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });
    HapticFeedback.lightImpact();
      
      await Future.delayed(const Duration(seconds: 2));
      
      final usernameOrEmail = _emailController.text.trim();
      final password = _passwordController.text;

      if (usernameOrEmail == 'admin' && password == '123456') {
        setState(() => _isLoading = false);
        // Navigate to HomePage with a default plan type
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(planType: 'lifetime'),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid credentials';
        });
      }
  }

  void _handleSocialLogin(String provider) {
    HapticFeedback.mediumImpact();
    _showMessage('Continue with $provider');
  }

  void _navigateToRegister() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4A6FA5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isSmallHeight = size.height < 700;
    final isNarrow = size.width < 360;
    final hUnit = size.height / 812.0;
    final wUnit = size.width / 375.0;
    final topSpace = isSmallHeight ? 40.0 * hUnit : 80.0 * hUnit;
    final sectionSpaceLarge = isSmallHeight ? 20.0 * hUnit : 32.0 * hUnit;
    final sectionSpaceMedium = isSmallHeight ? 14.0 * hUnit : 20.0 * hUnit;
    final horizontalPad = isNarrow ? 16.0 : 24.0;
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
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: topSpace),
                  
                      // Animated logo with app name (horizontal)
                      _buildAnimatedLogo(),
                      
                      SizedBox(height: sectionSpaceLarge),
                      
                      // Login/Sign up form with glassmorphism
                      ScaleTransition(
                        scale: _cardAnimation,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildGlassCard(),
                        ),
                      ),
                      
                      SizedBox(height: sectionSpaceLarge),
                      
                      // Social buttons after sign in
                      FadeTransition(
                        opacity: _socialAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_socialAnimation),
                          child: _buildSocialSection(),
                        ),
                      ),
                      
                      SizedBox(height: sectionSpaceMedium),
                      
                      // Toggle sign up/login
                      _buildTogglePrompt(),
                      const SizedBox(height: 12),
                      // Footer
                      _buildFooterCopyright(),
                      
                      SizedBox(height: sectionSpaceLarge),
                    ],
                  ),
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
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFE8F1FF), // Soft sky blue
                  const Color(0xFFF0F6FF),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFFE0EBFF), // Light periwinkle
                  const Color(0xFFEDF4FF),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFFD6E4FF), // Pale blue
                  const Color(0xFFE8F0FF),
                  _backgroundAnimation.value,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Decorative squares only - removed circles
            // Floating peaceful circles
            Positioned(
              top: 100 - (20 * _backgroundAnimation.value),
              left: 30,
              child: Transform.rotate(
                angle: _backgroundAnimation.value * math.pi / 6,
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
            ),
            
            Positioned(
              top: 250 + (30 * _backgroundAnimation.value),
              right: 20,
              child: Transform.rotate(
                angle: -_backgroundAnimation.value * math.pi / 4,
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
            ),
            
            Positioned(
              bottom: 150 + (25 * _backgroundAnimation.value),
              left: 50,
              child: Transform.rotate(
                angle: _backgroundAnimation.value * math.pi / 3,
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
            ),
            
            Positioned(
              bottom: 300 - (15 * _backgroundAnimation.value),
              right: 60,
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
      },
    );
  }

  Widget _buildGlassCard() {
    final size = MediaQuery.of(context).size;
    final isSmallHeight = size.height < 700;
    final cardPad = isSmallHeight ? 20.0 : 32.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.all(cardPad),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.65),
                Colors.white.withOpacity(0.70),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A6FA5).withOpacity(0.25),
                blurRadius: 50,
                offset: const Offset(0, 25),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: const Color(0xFF5B7DB1).withOpacity(0.2),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 360;
    final logoSize = isNarrow ? 56.0 : 72.0;
    final titleSize = isNarrow ? 20.0 : 24.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with static shadow
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A6FA5).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              'assets/splash/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A6FA5),
                        Color(0xFF5B7DB1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 32,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: isNarrow ? 8 : 16),
          // App name with better styling, scaled to fit
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Frown Upside Down',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF2C4A7C),
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Form fields
        _buildForm(),
        
        // Error message display
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        // Divider
        _buildDivider(),
        
        const SizedBox(height: 20),
        
        // Social buttons
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 12,
      children: [
        // Apple icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.apple,
          onPressed: () => _handleSocialLogin('Apple'),
          delay: 0,
        ),
        
        // Google icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.google,
          onPressed: () => _handleSocialLogin('Google'),
          delay: 100,
        ),
        
        // Facebook icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.facebook,
          onPressed: () => _handleSocialLogin('Facebook'),
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildAnimatedSocialIcon({
    required SocialButtonType type,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTapDown: (_) => setState(() {}),
              onTapUp: (_) => setState(() {}),
              onTapCancel: () => setState(() {}),
              onTap: () {
                HapticFeedback.lightImpact();
                onPressed();
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _getSocialBackgroundColor(type),
                  shape: BoxShape.circle,
                  border: type == SocialButtonType.google 
                      ? Border.all(color: Colors.grey[300]!, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _getSocialBackgroundColor(type).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildBrandIcon(type),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandIcon(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.apple:
        return const Icon(
          Icons.apple,
          color: Colors.white,
          size: 36,
        );
      case SocialButtonType.google:
        return CustomPaint(
          size: const Size(32, 32),
          painter: GoogleGPainter(),
        );
      case SocialButtonType.facebook:
        return const Icon(
          Icons.facebook,
          color: Colors.white,
          size: 36,
        );
    }
  }

  Color _getSocialBackgroundColor(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.apple:
        return Colors.black;
      case SocialButtonType.google:
        return Colors.white;
      case SocialButtonType.facebook:
        return const Color(0xFF1877F2);
    }
  }

  Color _getSocialTextColor(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.apple:
        return Colors.white;
      case SocialButtonType.google:
        return Colors.black87;
      case SocialButtonType.facebook:
        return Colors.white;
    }
  }

  String _getSocialLabel(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.apple:
        return 'Apple';
      case SocialButtonType.google:
        return 'Google';
      case SocialButtonType.facebook:
        return 'Facebook';
    }
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email or Username',
            hint: 'Enter email or "admin"',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              // Allow special username 'admin' or enforce valid email
              if (value.trim() != 'admin' &&
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email or "admin"';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          
          const SizedBox(height: 16),
          
          // Login button
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 360;
    final fieldVPad = isNarrow ? 12.0 : 14.0;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 30),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: fieldVPad),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: const Color(0xFF4A6FA5).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: const Color(0xFF4A6FA5).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF4A6FA5), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A6FA5),
            Color(0xFF5B7DB1),
            Color(0xFF4A6FA5),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.6),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: const Color(0xFF5B7DB1).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _isLoading ? null : () {
            HapticFeedback.mediumImpact();
            _handleEmailLogin();
          },
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTogglePrompt() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _navigateToRegister,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'New to Frown? Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A6FA5),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterCopyright() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          ' 2025 Frown Upside Down',
          style: TextStyle(
            color: Colors.black.withOpacity(0.45),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// Social button types
enum SocialButtonType { apple, google, facebook }

// Precise Google "G" painter using stroke-based segmented arcs
class GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Thinner stroke and inset rect to avoid clipping with round caps
    final stroke = size.width * 0.16;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2 - 0.5; // small inset for safety
    final rect = Rect.fromCircle(center: center, radius: radius).deflate(0.5);

    void seg(Color color, double start, double sweep) {
      final p = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, start, sweep, false, p);
    }

    // Angles chosen to visually match the Google "G"
    final startTop = -math.pi / 2; // 12 o'clock
    // Cover ~2π minus a small gap on right; distribute brand segments
    const redSweep = 0.9;    // ~52°
    const yellowSweep = 0.9; // ~52°
    const greenSweep = 0.9;  // ~52°
    const blueSweep = 2.98;  // ~171°

    // Red (top-left)
    seg(const Color(0xFFEA4335), startTop, redSweep);
    // Yellow (bottom-left)
    final yellowStart = startTop + redSweep;
    seg(const Color(0xFFFBBC05), yellowStart, yellowSweep);
    // Green (bottom-right)
    final greenStart = yellowStart + yellowSweep;
    seg(const Color(0xFF34A853), greenStart, greenSweep);
    // Blue (top-right and around)
    final blueStart = greenStart + greenSweep;
    seg(const Color(0xFF4285F4), blueStart, blueSweep);

    // Blue crossbar to complete the G (shorter to stay within bounds)
    final barPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.85
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4285F4);
    final y = center.dy;
    final x1 = center.dx + radius * 0.25;
    final x2 = center.dx + radius * 0.9;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), barPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plan_selection_page.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/user_model.dart';

/// Creative modern register page with innovative design
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  DateTime? _selectedDate;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late AnimationController _breathingController;
  late AnimationController _cardController;
  late AnimationController _socialController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _breathingAnimation;
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
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
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
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
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

  Widget _buildFooterCopyright() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          '© 2025 Frown Upside Down',
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _breathingController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  // Authentication handlers
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      return;
    }

    // Format DOB as YYYY-MM-DD for API
    final dobFormatted = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    
    // Create user model (without calling API yet)
    final user = UserModel(
      userName: _nameController.text.trim(),
      dob: dobFormatted,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Navigate to plan selection page with user data (API call will happen after plan selection)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanSelectionPage(userData: user),
        ),
      );
    }
  }

  void _handleSocialRegister(String provider) async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    // Note: Social registration would need additional OAuth implementation
    // For now, we'll show a message
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider registration is not yet implemented'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A6FA5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      HapticFeedback.selectionClick();
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
          
          // iOS-style main content
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
                          const SizedBox(height: 10),
                          
                          // iOS-style header
                          _buildIOSHeader(),
                          
                          const SizedBox(height: 20),
                          
                          // iOS-style form sections
                          _buildIOSFormSections(),
                          
                          const SizedBox(height: 20),
                          
                          // iOS-style continue button
                          _buildIOSContinueButton(),
                          
                          const SizedBox(height: 16),
                          
                          // iOS-style social section
                          _buildIOSSocialSection(),
                          
                          const SizedBox(height: 12),
                          
                          // Login prompt
                          _buildLoginPrompt(),
                          const SizedBox(height: 12),
                          _buildFooterCopyright(),
                          
                          const SizedBox(height: 20),
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

  Widget _buildIOSHeader() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Minimal iOS-style logo
              Transform.scale(
                scale: 0.95 + (_breathingAnimation.value - 1.0) * 0.1,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A6FA5).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/splash/logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.self_improvement,
                          size: 32,
                          color: Color(0xFF4A6FA5),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // iOS-style title
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join thousands finding their inner peace',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E93),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_breathingAnimation.value - 1.0) * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A6FA5).withOpacity(0.4 * _breathingAnimation.value),
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
                          size: 36,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  child: Text(
                    'Frown Upside Down',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF2C4A7C),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: (0.6 + (_breathingAnimation.value - 1.0) * 0.4).clamp(0.0, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF4A6FA5),
                        Color(0xFF5B7DB1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A6FA5).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Begin your mindful journey',
                style: TextStyle(
                  color: const Color(0xFF2C4A7C).withOpacity(0.75),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Date of Birth field
          _buildDateField(),
          
          const SizedBox(height: 16),
          
          // Password field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
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
                return 'Please create a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Confirm Password field
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Register button
          _buildRegisterButton(),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 26),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildRegisterButton() {
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
            _handleRegister();
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
                    'Create Account',
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dobController,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'Select your date of birth',
            prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 26),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 26),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your date of birth';
            }
            if (_selectedDate == null) {
              return 'Please select a valid date';
            }
            // Check if user is at least 13 years old
            final now = DateTime.now();
            final age = now.year - _selectedDate!.year;
            if (age < 13 || (age == 13 && now.isBefore(DateTime(_selectedDate!.year + 13, _selectedDate!.month, _selectedDate!.day)))) {
              return 'You must be at least 13 years old';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildIOSFormSections() {
    return Form(
      key: _formKey,
      child: ScaleTransition(
        scale: _cardAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // iOS-style grouped section
              _buildIOSSection([
                _buildIOSField(
                  controller: _nameController,
                  placeholder: 'Full Name',
                  keyboardType: TextInputType.name,
                  isFirst: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                _buildIOSDateField(),
                _buildIOSField(
                  controller: _emailController,
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  isLast: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ]),
              
              const SizedBox(height: 16),
              
              // Password section
              _buildIOSSection([
                _buildIOSField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: _obscurePassword,
                  isFirst: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 24,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                _buildIOSField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  isLast: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 24,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A6FA5).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C4A7C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C4A7C),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: const Color(0xFF4A6FA5).withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFF4A6FA5),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(
            color: const Color(0xFF4A6FA5).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A6FA5).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _dobController,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C4A7C),
            ),
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6FA5), Color(0xFF5B7DB1)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4A6FA5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: const Color(0xFF4A6FA5).withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF4A6FA5),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              labelStyle: TextStyle(
                color: const Color(0xFF4A6FA5).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your date of birth';
              }
              if (_selectedDate == null) {
                return 'Please select a valid date';
              }
              final now = DateTime.now();
              final age = now.year - _selectedDate!.year;
              if (age < 13 || (age == 13 && now.isBefore(DateTime(_selectedDate!.year + 13, _selectedDate!.month, _selectedDate!.day)))) {
                return 'You must be at least 13 years old';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIOSSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIOSField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(
            color: const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1C1C1E),
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E8E93),
            letterSpacing: -0.2,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildIOSDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E5EA),
                width: 0.5,
              ),
            ),
          ),
          child: TextFormField(
            controller: _dobController,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
            decoration: const InputDecoration(
              hintText: 'Date of Birth',
              hintStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8E8E93),
                letterSpacing: -0.2,
              ),
              suffixIcon: Icon(
                Icons.chevron_right,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your date of birth';
              }
              if (_selectedDate == null) {
                return 'Please select a valid date';
              }
              final now = DateTime.now();
              final age = now.year - _selectedDate!.year;
              if (age < 13 || (age == 13 && now.isBefore(DateTime(_selectedDate!.year + 13, _selectedDate!.month, _selectedDate!.day)))) {
                return 'You must be at least 13 years old';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIOSContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A6FA5),
              Color(0xFF5B7DB1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A6FA5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isLoading ? null : () {
              HapticFeedback.lightImpact();
              _handleRegister();
            },
            child: Container(
              alignment: Alignment.center,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSSocialSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'Or sign up with',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIOSSocialIconButton(
                SocialButtonType.apple,
                Colors.black,
                () => _handleSocialRegister('Apple'),
              ),
              _buildIOSSocialIconButton(
                SocialButtonType.google,
                Colors.white,
                () => _handleSocialRegister('Google'),
                hasGoogleBorder: true,
              ),
              _buildIOSSocialIconButton(
                SocialButtonType.facebook,
                const Color(0xFF1877F2),
                () => _handleSocialRegister('Facebook'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIOSSocialIconButton(
    SocialButtonType type,
    Color backgroundColor,
    VoidCallback onPressed,
    {bool hasGoogleBorder = false}
  ) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: hasGoogleBorder 
            ? Border.all(color: Colors.grey[300]!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              child: _buildBrandIcon(type),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSSocialButton(
    String text,
    SocialButtonType type,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
    {bool isFirst = false, bool isLast = false, bool hasGoogleBorder = false}
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        border: hasGoogleBorder 
            ? Border.all(color: Colors.grey[300]!, width: 1.5)
            : Border(
                bottom: isLast ? BorderSide.none : const BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 0.5,
                ),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  child: _buildBrandIcon(type),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSocialSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A6FA5).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Or continue with',
            style: TextStyle(
              color: const Color(0xFF2C4A7C).withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernSocialButton(SocialButtonType.apple, () => _handleSocialRegister('Apple')),
              _buildModernSocialButton(SocialButtonType.google, () => _handleSocialRegister('Google')),
              _buildModernSocialButton(SocialButtonType.facebook, () => _handleSocialRegister('Facebook')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSocialButton(SocialButtonType type, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getSocialBackgroundColor(type),
        borderRadius: BorderRadius.circular(15),
        border: type == SocialButtonType.google 
            ? Border.all(color: Colors.grey[300]!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: _getSocialBackgroundColor(type).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Center(
            child: _buildBrandIcon(type),
          ),
        ),
      ),
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

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or sign up with',
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

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Apple icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.apple,
          onPressed: () => _handleSocialRegister('Apple'),
          delay: 0,
        ),
        
        // Google icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.google,
          onPressed: () => _handleSocialRegister('Google'),
          delay: 100,
        ),
        
        // Facebook icon
        _buildAnimatedSocialIcon(
          type: SocialButtonType.facebook,
          onPressed: () => _handleSocialRegister('Facebook'),
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
                width: 56,
                height: 56,
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
          size: 28,
        );
      case SocialButtonType.google:
        return CustomPaint(
          size: const Size(26, 26),
          painter: GoogleGPainter(),
        );
      case SocialButtonType.facebook:
        return const Icon(
          Icons.facebook,
          color: Colors.white,
          size: 28,
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

  Widget _buildLoginPrompt() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Already have an account? Sign In',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4A6FA5),
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
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

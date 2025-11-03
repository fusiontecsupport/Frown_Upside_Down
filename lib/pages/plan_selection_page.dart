import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class PlanSelectionPage extends StatefulWidget {
  final UserModel? userData;
  
  const PlanSelectionPage({Key? key, this.userData}) : super(key: key);

  @override
  State<PlanSelectionPage> createState() => _PlanSelectionPageState();
}

class _PlanSelectionPageState extends State<PlanSelectionPage> {
  int _selectedPlan = 0; // 0 for free trial, 1 for premium
  bool _isLoading = false;

  void _handleContinue() async {
    if (_isLoading) return;
    
    if (widget.userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data is missing. Please register again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      Navigator.pop(context);
      return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    
    try {
      // Determine plan type: trial (0) or premium (1)
      final planType = _selectedPlan == 0 ? 'trial' : 'premium';
      
      // Create user with all data including Plan_Type and Updated_at
      final userWithPlan = widget.userData!.copyWith(
        planType: planType,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      // Send complete user data to API (including Plan_Type)
      final createdUser = await ApiService.createUser(userWithPlan);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Navigate to home page with user data
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              planType: planType,
              userName: createdUser.userName,
              email: createdUser.email,
              createdAt: createdUser.createdAt,
            ),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Extract error message
        String errorMessage = 'Failed to create account';
        if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        } else {
          errorMessage = e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF3FA),
              Color(0xFFE6EEF8),
              Color(0xFFDDE7F5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPlanCards(),
                const SizedBox(height: 24),
                _buildContinueButton(),
                const SizedBox(height: 16),
                _buildTermsText(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 8),
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.6,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'Start your mindfulness journey',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: [
        _buildPlanCard(
          index: 0,
          title: 'Free Trial',
          subtitle: '7 days free',
          price: 'Free',
          features: const [
            'Basic meditations',
            'Daily reminders',
            'Progress tracking',
          ],
          isPopular: false,
          accentColor: const Color(0xFF5B7DB1),
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          index: 1,
          title: 'Premium',
          subtitle: 'Full access',
          price: '\$99',
          features: const [
            'Unlimited meditations',
            'Advanced programs',
            'Offline downloads',
          ],
          isPopular: true,
          accentColor: const Color(0xFF4A6FA5),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool isPopular,
    required Color accentColor,
  }) {
    final isSelected = _selectedPlan == index;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedPlan = index);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(index == 0 ? Icons.explore : Icons.diamond, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (index == 1)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'forever',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: accentColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                        ),
                      ),
                    ],
                  ),
                )),
            if (isPopular)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E53).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF8E53), letterSpacing: 0.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleContinue,
        icon: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Icon(_selectedPlan == 0 ? Icons.play_arrow_rounded : Icons.diamond, size: 20),
        label: Text(_selectedPlan == 0 ? 'Start Free Trial' : 'Get Premium Access'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6FA5),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
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
                  : 'Full premium access. No recurring charges. 30-day money-back guarantee. Secure payment.',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String planType;
  final String? userName;
  final String? email;
  final String? createdAt;
  
  const ProfilePage({
    Key? key, 
    required this.planType,
    this.userName,
    this.email,
    this.createdAt,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _backgroundAnimation;

  File? _profileImage;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';

  // App colors matching the design
  final Color kPrimary = const Color(0xFF4A6FA5);
  final Color kSecondary = const Color(0xFF5B7DB1);
  final Color kAccent = const Color(0xFF6B8FC3);

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _breathingController.repeat(reverse: true);
    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingShapes(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildProfileContent(),
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
                  const Color(0xFFE8F1FF),
                  const Color(0xFFF0F6FF),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFFE0EBFF),
                  const Color(0xFFEDF4FF),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFFD6E4FF),
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
                        kPrimary.withOpacity(0.12),
                        kPrimary.withOpacity(0.04),
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
                        kSecondary.withOpacity(0.12),
                        kSecondary.withOpacity(0.04),
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
                        kAccent.withOpacity(0.1),
                        kAccent.withOpacity(0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildSettingsSection(),
          const SizedBox(height: 20),
          _buildSupportSection(),
          const SizedBox(height: 20),
          _buildAccountSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _formatMemberSince(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return 'Member';
    }
    
    try {
      // Parse ISO8601 date string (e.g., "2025-11-03T06:03:02+00:00")
      final dateTime = DateTime.parse(createdAt);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return 'Member since ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return 'Member';
    }
  }

  Widget _buildProfileHeader() {
    final isPremium = widget.planType == 'lifetime' || widget.planType == 'premium';
    
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kPrimary, kSecondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Image.asset(
                                'assets/splash/logo.png',
                                width: 35,
                                height: 35,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.userName ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremium 
                                ? [kSecondary, kPrimary]
                                : [kPrimary, kAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPremium ? Icons.diamond : Icons.schedule,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPremium ? 'PREMIUM' : 'TRIAL',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatMemberSince(widget.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    final isPremium = widget.planType == 'lifetime' || widget.planType == 'premium';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isPremium 
              ? [kSecondary, kPrimary]
              : [kPrimary, kAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPremium ? 'PREMIUM MEMBER' : 'TRIAL MEMBER',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isPremium ? 'Unlimited Access' : 'Trial Active',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium 
                      ? 'All premium features unlocked'
                      : 'Upgrade to unlock all features',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPremium ? Icons.diamond : Icons.schedule,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Your Mindfulness Journey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem('24', 'Sessions', Icons.self_improvement, kPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem('7', 'Day Streak', Icons.local_fire_department, const Color(0xFFFF6B35)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem('180', 'Minutes', Icons.timer, kSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          'Dark Mode',
          'Switch between light and dark themes',
          Icons.dark_mode_outlined,
          trailing: _buildCustomSwitch(
            _isDarkMode, 
            (value) {
              HapticFeedback.lightImpact();
              setState(() => _isDarkMode = value);
            },
            isDarkModeSwitch: true,
          ),
        ),
        _buildSettingsTile(
          'Notifications',
          'Mindfulness reminders and updates',
          Icons.notifications_outlined,
          trailing: _buildCustomSwitch(_notificationsEnabled, (value) {
            HapticFeedback.lightImpact();
            setState(() => _notificationsEnabled = value);
          }),
        ),
        _buildSettingsTile(
          'Sound Effects',
          'Meditation bells and ambient sounds',
          Icons.volume_up_outlined,
          trailing: _buildCustomSwitch(_soundEnabled, (value) {
            HapticFeedback.lightImpact();
            setState(() => _soundEnabled = value);
          }),
        ),
        _buildSettingsTile(
          'Language',
          _selectedLanguage,
          Icons.language_outlined,
          onTap: () => _showLanguageSelector(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Download Quality',
          'High quality for offline sessions',
          Icons.download_outlined,
          onTap: () => _showQualitySelector(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Support & Community',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          'FAQ\'s',
          'Get answers to common questions',
          Icons.help_outline,
          onTap: () => _showHelpCenter(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Contact Support',
          'Reach out to our mindfulness experts',
          Icons.support_agent_outlined,
          onTap: () => _showContactSupport(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'App Guidelines',
          'Creating a safe mindful space',
          Icons.people_outline,
          onTap: () => _showCommunityGuidelines(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Rate Our App',
          'Share your mindfulness journey',
          Icons.star_outline,
          onTap: () => _rateApp(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Account & Legal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          'Privacy Policy',
          'How we protect your data',
          Icons.privacy_tip_outlined,
          onTap: () => _showPrivacyPolicy(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Terms of Service',
          'Our terms and conditions',
          Icons.description_outlined,
          onTap: () => _showTermsOfService(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'User Agreement',
          'Community standards and guidelines',
          Icons.handshake_outlined,
          onTap: () => _showUserAgreement(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Manage Subscription',
          widget.planType == 'lifetime' ? 'Lifetime member' : 'Free trial active',
          Icons.card_membership_outlined,
          onTap: () => _manageSubscription(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF8E8E93),
          ),
        ),
        _buildSettingsTile(
          'Sign Out',
          'Take a break from your journey',
          Icons.logout_outlined,
          onTap: () => _showSignOutDialog(),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.red,
          ),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildCustomSwitch(bool value, Function(bool) onChanged, {bool isDarkModeSwitch = false}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          gradient: value
              ? LinearGradient(
                  colors: [kPrimary, kSecondary],
                )
              : null,
          color: value ? null : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: value ? kPrimary.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          curve: Curves.easeInOut,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isDarkModeSwitch
                ? Icon(
                    value ? Icons.nightlight_round : Icons.wb_sunny,
                    size: 14,
                    color: value ? const Color(0xFF4A5568) : const Color(0xFFFFA500),
                  )
                : (value
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: kPrimary,
                      )
                    : null),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive 
              ? Colors.red.withOpacity(0.2)
              : kPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : kPrimary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive 
                              ? Colors.red
                              : const Color(0xFF1C1C1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action Methods
  void _showLanguageSelector() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLanguageSelector(),
    );
  }

  void _showQualitySelector() {
    HapticFeedback.lightImpact();
    _showInfoDialog('Download Quality', 'Choose audio quality for offline sessions.', 'Got it');
  }

  void _showHelpCenter() {
    HapticFeedback.lightImpact();
    _showInfoDialog('FAQ\'s', 'Find answers to frequently asked questions about your mindfulness journey.', 'View FAQ\'s');
  }

  void _showContactSupport() {
    HapticFeedback.lightImpact();
    _showInfoDialog('Contact Support', 'Our mindfulness experts are here 24/7 to help.\n\nEmail: support@frownupsidedown.com', 'Contact Us');
  }

  void _showCommunityGuidelines() {
    HapticFeedback.lightImpact();
    _showInfoDialog('App Guidelines', 'Guidelines for using our app responsibly and creating a safe mindful space.', 'Understand');
  }

  void _rateApp() {
    HapticFeedback.lightImpact();
    _showInfoDialog('Rate Our App', 'Love your mindfulness journey? Share your experience!', 'Rate Now');
  }

  void _showPrivacyPolicy() {
    HapticFeedback.lightImpact();
    _showInfoDialog('Privacy Policy', 'Your privacy is sacred. We protect your data with care.', 'Read Policy');
  }

  void _showTermsOfService() {
    HapticFeedback.lightImpact();
    _showInfoDialog('Terms of Service', 'Our terms help maintain a peaceful environment for all.', 'Read Terms');
  }

  void _showUserAgreement() {
    HapticFeedback.lightImpact();
    _showInfoDialog('User Agreement', 'Guidelines for using Frown Upside Down responsibly.', 'View Agreement');
  }

  void _manageSubscription() {
    HapticFeedback.lightImpact();
    final isPremium = widget.planType == 'lifetime' || widget.planType == 'premium';
    _showInfoDialog('Manage Subscription', isPremium ? 'You have premium access to all features!' : 'Trial active. Upgrade anytime!', isPremium ? 'Manage' : 'Upgrade');
  }

  void _showSignOutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
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
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.logout_outlined,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you sure you want to sign out? Your mindfulness journey will be here when you return.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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

  void _signOut() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  void _showInfoDialog(String title, String content, String buttonText) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
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
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  Widget _buildLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Japanese', 'Korean', 'Chinese', 'Hindi'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.all(16),
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
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = language == _selectedLanguage;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedLanguage = language);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  language,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? kPrimary : const Color(0xFF1C1C1E),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: kPrimary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

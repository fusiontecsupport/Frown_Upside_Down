import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({Key? key}) : super(key: key);

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;

  // Login/Profile page color palette
  final Color kPrimary = const Color(0xFF4A6FA5); // Deep blue
  final Color kSecondary = const Color(0xFF5B7DB1); // Medium blue
  final Color kAccent = const Color(0xFF6B8FC3); // Light blue

  String _selectedCategory = 'All';

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
              child: _buildWellnessContent(),
            ),
          ),
        ],
      ),
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

  Widget _buildWellnessContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wellness Header
                _buildWellnessHeader(),
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

  Widget _buildWellnessHeader() {
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
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Wellness text
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness Content',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Videos, Audio & Guides for Your Journey',
                          style: TextStyle(
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
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF8E8E93),
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
                        const Icon(
                          Icons.favorite_outline,
                          size: 14,
                          color: Color(0xFF8E8E93),
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
}

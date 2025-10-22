import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class EmotionContentPage extends StatefulWidget {
  final String emotion;

  const EmotionContentPage({
    Key? key,
    required this.emotion,
  }) : super(key: key);

  @override
  State<EmotionContentPage> createState() => _EmotionContentPageState();
}

class _EmotionContentPageState extends State<EmotionContentPage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  
  bool _isAudioPlaying = false;
  bool _isVideoPlaying = false;
  double _audioProgress = 0.0;
  double _videoProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _breathingController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getEmotionData() {
    switch (widget.emotion.toLowerCase()) {
      case 'happy':
        return {
          'emoji': '😀',
          'color': Colors.yellow.shade400,
          'gradient': [Colors.yellow.shade300, Colors.orange.shade400],
          'title': 'Embrace Your Joy',
          'description': 'Happiness is a choice we make every day. Let these resources amplify your positive energy.',
          'audioTitle': 'Joyful Meditation',
          'audioDuration': '8:30',
          'videoTitle': 'Morning Happiness Routine',
          'videoDuration': '12:45',
          'textContent': [
            'Practice gratitude daily - write down 3 things you\'re thankful for',
            'Share your joy with others through acts of kindness',
            'Engage in activities that bring you genuine pleasure',
            'Celebrate small victories and achievements',
            'Surround yourself with positive, uplifting people'
          ]
        };
      case 'sad':
        return {
          'emoji': '😢',
          'color': Colors.blue.shade400,
          'gradient': [Colors.blue.shade300, Colors.indigo.shade400],
          'title': 'Healing Through Sadness',
          'description': 'It\'s okay to feel sad. These resources will help you process and heal through difficult emotions.',
          'audioTitle': 'Gentle Healing Sounds',
          'audioDuration': '15:20',
          'videoTitle': 'Emotional Release Meditation',
          'videoDuration': '18:30',
          'textContent': [
            'Allow yourself to feel without judgment',
            'Reach out to trusted friends or family for support',
            'Practice self-compassion and gentle self-care',
            'Journal your thoughts and feelings',
            'Remember that sadness is temporary and will pass'
          ]
        };
      case 'stressed':
        return {
          'emoji': '😣',
          'color': Colors.red.shade400,
          'gradient': [Colors.red.shade300, Colors.pink.shade400],
          'title': 'Stress Relief & Calm',
          'description': 'Transform stress into strength with these calming techniques and mindful practices.',
          'audioTitle': 'Deep Relaxation Audio',
          'audioDuration': '10:15',
          'videoTitle': 'Stress-Busting Breathing',
          'videoDuration': '7:45',
          'textContent': [
            'Practice deep breathing exercises regularly',
            'Break large tasks into smaller, manageable steps',
            'Take regular breaks and prioritize self-care',
            'Use progressive muscle relaxation techniques',
            'Focus on what you can control, let go of what you can\'t'
          ]
        };
      case 'nervous':
        return {
          'emoji': '😬',
          'color': Colors.purple.shade400,
          'gradient': [Colors.purple.shade300, Colors.deepPurple.shade400],
          'title': 'Calming Your Nerves',
          'description': 'Channel nervous energy into positive action with these grounding techniques.',
          'audioTitle': 'Anxiety Relief Meditation',
          'audioDuration': '12:00',
          'videoTitle': 'Grounding Techniques',
          'videoDuration': '9:20',
          'textContent': [
            'Use the 5-4-3-2-1 grounding technique',
            'Practice mindful breathing to center yourself',
            'Prepare thoroughly to build confidence',
            'Visualize successful outcomes',
            'Remember that nervousness shows you care'
          ]
        };
      case 'disappointed':
        return {
          'emoji': '😞',
          'color': Colors.grey.shade500,
          'gradient': [Colors.grey.shade400, Colors.blueGrey.shade500],
          'title': 'Rising from Disappointment',
          'description': 'Turn disappointment into opportunity for growth and new possibilities.',
          'audioTitle': 'Resilience Building Audio',
          'audioDuration': '11:40',
          'videoTitle': 'Overcoming Setbacks',
          'videoDuration': '14:15',
          'textContent': [
            'Acknowledge your feelings without dwelling on them',
            'Look for lessons and growth opportunities',
            'Adjust your expectations and try new approaches',
            'Focus on what you can learn from the experience',
            'Remember that setbacks often lead to comebacks'
          ]
        };
      case 'calm':
        return {
          'emoji': '😌',
          'color': Colors.green.shade400,
          'gradient': [Colors.green.shade300, Colors.teal.shade400],
          'title': 'Maintaining Inner Peace',
          'description': 'Nurture and expand your sense of calm with these peaceful practices.',
          'audioTitle': 'Peaceful Nature Sounds',
          'audioDuration': '20:00',
          'videoTitle': 'Mindful Meditation',
          'videoDuration': '16:30',
          'textContent': [
            'Practice regular meditation to maintain inner peace',
            'Spend time in nature to ground yourself',
            'Create peaceful spaces in your environment',
            'Use calming breathing techniques throughout the day',
            'Cultivate mindfulness in daily activities'
          ]
        };
      default:
        return {
          'emoji': '🙂',
          'color': Colors.blue.shade400,
          'gradient': [Colors.blue.shade300, Colors.indigo.shade400],
          'title': 'Emotional Wellness',
          'description': 'Explore resources to support your emotional well-being.',
          'audioTitle': 'General Wellness Audio',
          'audioDuration': '10:00',
          'videoTitle': 'Mindfulness Practice',
          'videoDuration': '12:00',
          'textContent': [
            'Practice self-awareness and emotional intelligence',
            'Develop healthy coping strategies',
            'Build strong, supportive relationships',
            'Maintain a balanced lifestyle',
            'Seek professional help when needed'
          ]
        };
    }
  }

  void _toggleAudio() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });
    
    // Simulate audio progress
    if (_isAudioPlaying) {
      _simulateProgress(true);
    }
  }

  void _toggleVideo() {
    HapticFeedback.lightImpact();
    setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
    
    // Simulate video progress
    if (_isVideoPlaying) {
      _simulateProgress(false);
    }
  }

  void _simulateProgress(bool isAudio) {
    if (isAudio && _isAudioPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isAudioPlaying) {
          setState(() {
            _audioProgress += 0.01;
            if (_audioProgress >= 1.0) {
              _audioProgress = 0.0;
              _isAudioPlaying = false;
            }
          });
          _simulateProgress(true);
        }
      });
    } else if (!isAudio && _isVideoPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isVideoPlaying) {
          setState(() {
            _videoProgress += 0.01;
            if (_videoProgress >= 1.0) {
              _videoProgress = 0.0;
              _isVideoPlaying = false;
            }
          });
          _simulateProgress(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionData = _getEmotionData();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (emotionData['gradient'] as List<Color>)[0].withOpacity(0.1),
              (emotionData['gradient'] as List<Color>)[1].withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C1C1E)),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(
                    'Magic ${widget.emotion}',
                    style: const TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  centerTitle: true,
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeader(emotionData),
                        const SizedBox(height: 30),
                        
                        // Audio Section
                        _buildAudioSection(emotionData),
                        const SizedBox(height: 20),
                        
                        // Video Section
                        _buildVideoSection(emotionData),
                        const SizedBox(height: 20),
                        
                        // Text Content Section
                        _buildTextSection(emotionData),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, _) {
        final v = _breathingController.value;
        final scale = 0.95 + (v * 0.1);
        final glow = 0.2 + (v * 0.3);
        
        return Column(
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: data['gradient'] as List<Color>,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (data['color'] as Color).withOpacity(glow),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    data['emoji'] as String,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['title'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              data['description'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8E8E93),
                letterSpacing: -0.1,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioSection(Map<String, dynamic> data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: data['gradient'] as List<Color>,
                      ),
                    ),
                    child: const Icon(
                      Icons.headphones,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['audioTitle'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['audioDuration'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleAudio,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (data['color'] as Color).withOpacity(0.2),
                      ),
                      child: Icon(
                        _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                        color: data['color'] as Color,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isAudioPlaying) ...[
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: _audioProgress,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(data['color'] as Color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection(Map<String, dynamic> data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: data['gradient'] as List<Color>,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['videoTitle'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['videoDuration'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleVideo,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (data['color'] as Color).withOpacity(0.2),
                      ),
                      child: Icon(
                        _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                        color: data['color'] as Color,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isVideoPlaying) ...[
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: _videoProgress,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(data['color'] as Color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(Map<String, dynamic> data) {
    final textContent = data['textContent'] as List<String>;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: data['gradient'] as List<Color>,
                      ),
                    ),
                    child: const Icon(
                      Icons.article,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Helpful Tips & Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...textContent.asMap().entries.map((entry) {
                final index = entry.key;
                final text = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < textContent.length - 1 ? 12 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: data['color'] as Color,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.1,
                            height: 1.4,
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
      ),
    );
  }
}

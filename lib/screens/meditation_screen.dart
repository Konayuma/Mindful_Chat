import 'package:flutter/material.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  final List<MeditationSession> _sessions = [
    MeditationSession(
      id: '1',
      title: 'Mindful Breathing',
      duration: '5 min',
      category: 'Beginner',
      description: 'Focus on your breath and find inner peace',
      color: const Color(0xFF64B5F6),
      icon: Icons.air,
    ),
    MeditationSession(
      id: '2',
      title: 'Body Scan',
      duration: '10 min',
      category: 'Relaxation',
      description: 'Release tension throughout your body',
      color: const Color(0xFF9C27B0),
      icon: Icons.accessibility_new,
    ),
    MeditationSession(
      id: '3',
      title: 'Loving Kindness',
      duration: '15 min',
      category: 'Compassion',
      description: 'Cultivate love and compassion for yourself and others',
      color: const Color(0xFFE91E63),
      icon: Icons.favorite,
    ),
    MeditationSession(
      id: '4',
      title: 'Sleep Meditation',
      duration: '20 min',
      category: 'Sleep',
      description: 'Drift into peaceful slumber',
      color: const Color(0xFF3F51B5),
      icon: Icons.bedtime,
    ),
    MeditationSession(
      id: '5',
      title: 'Stress Relief',
      duration: '8 min',
      category: 'Anxiety',
      description: 'Calm your mind and reduce stress',
      color: const Color(0xFFFF9800),
      icon: Icons.psychology,
    ),
    MeditationSession(
      id: '6',
      title: 'Focus Enhancement',
      duration: '12 min',
      category: 'Productivity',
      description: 'Improve concentration and mental clarity',
      color: const Color(0xFF4CAF50),
      icon: Icons.center_focus_strong,
    ),
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
    
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  List<MeditationSession> get _filteredSessions {
    if (_selectedCategory == 'All') return _sessions;
    return _sessions.where((session) => session.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meditation',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // TODO: Show meditation history
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
                  isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E8),
                ],
                stops: [
                  0.0,
                  _backgroundAnimation.value,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            // Category filter
            _buildCategoryFilter(isDark),
            const SizedBox(height: 20),
            
            // Sessions list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredSessions.length,
                itemBuilder: (context, index) {
                  final session = _filteredSessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSessionCard(isDark, session),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final categories = ['All', 'Beginner', 'Relaxation', 'Compassion', 'Sleep', 'Anxiety', 'Productivity'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              selectedColor: const Color(0xFF8FEC95).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF8FEC95) : (isDark ? Colors.white : Colors.black),
                fontFamily: 'Satoshi',
              ),
              checkmarkColor: const Color(0xFF8FEC95),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(bool isDark, MeditationSession session) {
    return GestureDetector(
      onTap: () {
        _showSessionDialog(session);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: session.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                session.icon,
                color: session.color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            
            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.black54,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: session.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: session.color,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Satoshi',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          fontFamily: 'Satoshi',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Play button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: session.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDialog(MeditationSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          session.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.description,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.black54,
                fontFamily: 'Satoshi',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: session.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  session.category,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Satoshi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: session.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  session.duration,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Satoshi',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.black54,
                fontFamily: 'Satoshi',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startMeditation(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: session.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start Session',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startMeditation(MeditationSession session) {
    // TODO: Navigate to meditation player screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${session.title}...'),
        backgroundColor: session.color,
      ),
    );
  }
}

class MeditationSession {
  final String id;
  final String title;
  final String duration;
  final String category;
  final String description;
  final Color color;
  final IconData icon;

  MeditationSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.category,
    required this.description,
    required this.color,
    required this.icon,
  });
}

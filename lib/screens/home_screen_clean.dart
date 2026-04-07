import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavBar(isDark),
            // Main Content
            Expanded(
              child: _buildCurrentContent(isDark),
            ),
            // Bottom Navigation
            _buildBottomNav(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentContent(bool isDark) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(isDark);
      case 1:
        return _buildSearchContent(isDark);
      case 2:
        return _buildAddContent(isDark);
      case 3:
        return _buildResourcesContent(isDark);
      case 4:
        return _buildProfileContent(isDark);
      default:
        return _buildHomeContent(isDark);
    }
  }

  Widget _buildAddContent(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an action from the home screen',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Resources',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildResourceCard(
                  isDark,
                  'Meditation Guides',
                  'Guided meditation sessions for all levels',
                  Icons.self_improvement,
                  const Color(0xFF9C27B0),
                  () {
                    Navigator.pushNamed(context, '/meditation');
                  },
                ),
                const SizedBox(height: 12),
                _buildResourceCard(
                  isDark,
                  'Breathing Exercises',
                  'Quick breathing techniques for stress relief',
                  Icons.air,
                  const Color(0xFF64B5F6),
                  () {
                    Navigator.pushNamed(context, '/breathing');
                  },
                ),
                const SizedBox(height: 12),
                _buildResourceCard(
                  isDark,
                  'Crisis Support',
                  '24/7 crisis helplines and resources',
                  Icons.phone,
                  const Color(0xFFE91E63),
                  () {
                    Navigator.pushNamed(context, '/crisis');
                  },
                ),
                const SizedBox(height: 12),
                _buildResourceCard(
                  isDark,
                  'Educational Articles',
                  'Learn about mental health and wellness',
                  Icons.article,
                  const Color(0xFFFF9800),
                  () {
                    Navigator.pushNamed(context, '/articles');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FEC95).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: const Color(0xFF8FEC95),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Satoshi',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontFamily: 'Satoshi',
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileOption(
                  isDark,
                  'Account Settings',
                  Icons.settings,
                  () {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }
                  },
                ),
                _buildProfileOption(
                  isDark,
                  'Privacy & Security',
                  Icons.lock,
                  () {
                    // TODO: Navigate to privacy settings
                  },
                ),
                _buildProfileOption(
                  isDark,
                  'Help & Support',
                  Icons.help_outline,
                  () {
                    // TODO: Navigate to help
                  },
                ),
                _buildProfileOption(
                  isDark,
                  'Sign Out',
                  Icons.logout,
                  () {
                    // TODO: Implement sign out
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(bool isDark, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
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
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.black54,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[600] : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(bool isDark, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? Colors.grey[400] : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Satoshi',
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[600] : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
              onPressed: () {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }
              },
            ),
          ),
          // Notification Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ),
          // User Profile Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Welcome Message
          Text(
            'Welcome back, User',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 30),
          // Mood Check-in Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8FEC95),
                  const Color(0xFF6BCF77),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8FEC95).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Check-in',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Satoshi',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Take a moment to reflect on your mental wellness',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontFamily: 'Satoshi',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/mood-checkin');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8FEC95),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Check-in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  isDark,
                  'Breathe',
                  Icons.air,
                  const Color(0xFF64B5F6),
                  () {
                    Navigator.pushNamed(context, '/breathing');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  isDark,
                  'Meditate',
                  Icons.self_improvement,
                  const Color(0xFF9C27B0),
                  () {
                    Navigator.pushNamed(context, '/meditation');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  isDark,
                  'Journal',
                  Icons.book,
                  const Color(0xFFFF9800),
                  () {
                    Navigator.pushNamed(context, '/journal');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  isDark,
                  'Chat',
                  Icons.chat,
                  const Color(0xFF8FEC95),
                  () {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: isDark ? Colors.grey[400] : Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontFamily: 'Satoshi',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionCard(bool isDark, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Satoshi',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Search',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for meditations, articles, etc...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey,
                  fontFamily: 'Satoshi',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[500] : Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontFamily: 'Satoshi',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Search functionality coming soon...',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontFamily: 'Satoshi',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                isDark,
                Icons.home,
                'Home',
                _currentIndex == 0,
                () => setState(() => _currentIndex = 0),
              ),
              _buildNavItem(
                isDark,
                Icons.search,
                'Search',
                _currentIndex == 1,
                () => setState(() => _currentIndex = 1),
              ),
              _buildAddButton(isDark),
              _buildNavItem(
                isDark,
                Icons.favorite_border,
                'Resources',
                _currentIndex == 3,
                () => setState(() => _currentIndex = 3),
              ),
              _buildNavItem(
                isDark,
                Icons.person_outline,
                'Profile',
                _currentIndex == 4,
                () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(bool isDark, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF8FEC95) : (isDark ? Colors.grey[600] : Colors.grey),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF8FEC95) : (isDark ? Colors.grey[600] : Colors.grey),
              fontFamily: 'Satoshi',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF8FEC95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8FEC95).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

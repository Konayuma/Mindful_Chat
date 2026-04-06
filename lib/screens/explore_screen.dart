import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'bookmarks_screen.dart';
import 'affirmation_screen.dart';
import 'settings_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        title: Text(
          'Explore Features',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover what Mindful Chat can do for you',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.chat,
                  iconColor: const Color(0xFF8FEC95),
                  title: 'AI Chat',
                  description: 'Have meaningful conversations with our supportive AI companion',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.auto_stories,
                  iconColor: const Color(0xFF9B7EBD),
                  title: 'Journal',
                  description: 'Reflect on your thoughts and track your emotional journey',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JournalScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.spa,
                  iconColor: const Color(0xFF4ECDC4),
                  title: 'Daily Affirmations',
                  description: 'Get inspired with personalized affirmations and quotes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AffirmationScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFFFB74D),
                  title: 'Favourites',
                  description: 'Save and revisit your favorite messages and affirmations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.settings,
                  iconColor: const Color(0xFF78909C),
                  title: 'Settings',
                  description: 'Customize your experience and manage your account',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title feature',
      hint: description,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFF8FEC95),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Getting Started',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mindful Chat is your personal mental wellness companion. Explore these features to support your emotional well-being:',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoPoint(isDark, 'Chat with AI for immediate support and guidance'),
          _buildInfoPoint(isDark, 'Journal to reflect and track your progress'),
          _buildInfoPoint(isDark, 'Read affirmations to start your day positively'),
          _buildInfoPoint(isDark, 'Save important moments in your favourites'),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8FEC95),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

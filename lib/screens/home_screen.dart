import 'package:flutter/material.dart';
import '../services/affirmation_service.dart';
import '../services/supabase_auth_service.dart';
import '../models/affirmation.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'bookmarks_screen.dart';
import 'affirmation_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AffirmationService _affirmationService = AffirmationService();
  Affirmation? _dailyQuote;
  bool _isLoadingQuote = true;
  String? _userName;
  int _selectedNavIndex = 0;
  int _selectedDayIndex = DateTime.now().weekday - 1; // Current day

  // Emotions tracking moved to journal screen for better context

  @override
  void initState() {
    super.initState();
    _loadDailyQuote();
    _loadUserName();
  }

  Future<void> _loadDailyQuote() async {
    try {
      final quote = await _affirmationService.getDailyAffirmation();
      if (mounted) {
        setState(() {
          _dailyQuote = quote;
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingQuote = false);
      }
    }
  }

  void _loadUserName() {
    final user = SupabaseAuthService.instance.currentUser;
    if (user != null) {
      final email = user.email ?? '';
      final name = email.split('@').first;
      setState(() {
        _userName = name.isNotEmpty 
            ? '${name[0].toUpperCase()}${name.substring(1)}' 
            : 'Friend';
      });
    }
  }

  List<_DayInfo> _getWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return _DayInfo(
        dayName: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
        date: day.day,
        isToday: day.day == now.day && day.month == now.month,
      );
    });
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekDays = _getWeekDays();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F0),
      body: SafeArea(
        child: _buildHomeContent(isDark, weekDays),
      ),
      floatingActionButton: Tooltip(
        message: 'Start a new chat conversation',
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          ),
          backgroundColor: const Color(0xFF8FEC95),
          elevation: 4,
          child: const Icon(Icons.chat, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildHomeContent(bool isDark, List<_DayInfo> weekDays) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(isDark),
            const SizedBox(height: 24),
            _buildWeekCalendar(isDark, weekDays),
            const SizedBox(height: 24),
            _buildSectionHeader('Daily Affirmation', isDark, onSeeAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AffirmationScreen()));
            }),
            const SizedBox(height: 12),
            _buildJournalCard(isDark),
            const SizedBox(height: 24),
            _buildSectionHeader('Reflection Prompts', isDark, onSeeAll: () {}),
            const SizedBox(height: 12),
            _buildQuickJournalPrompts(isDark),
            const SizedBox(height: 24),
            _buildSectionHeader('Chat with AI', isDark),
            const SizedBox(height: 12),
            _buildQuickChatWidget(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hi, ${_userName ?? 'Friend'}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Tooltip(
          message: 'View profile menu',
          child: GestureDetector(
            onTap: _showProfileMenu,
            child: Semantics(
              label: 'Profile menu button',
              hint: 'Double tap to open settings, bookmarks, and sign out options',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  border: Border.all(color: const Color(0xFF8FEC95), width: 2),
                ),
                child: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.grey[600], size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(bool isDark, List<_DayInfo> weekDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = index == _selectedDayIndex;
        
        return Semantics(
          label: '${day.dayName}, ${day.date}${day.isToday ? ", today" : ""}',
          hint: isSelected ? 'Selected' : 'Tap to select this day',
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Column(
              children: [
              Text(
                day.dayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    day.date.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),);
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        if (onSeeAll != null)
          Semantics(
            label: 'See all $title entries',
            hint: 'Tap to view all items',
            button: true,
            child: GestureDetector(
              onTap: onSeeAll,
              child: Text('See all', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ),
          ),
      ],
    );
  }

  Widget _buildJournalCard(bool isDark) {
    final timeOfDay = _getTimeOfDay();
    final quoteText = _isLoadingQuote 
        ? "Take a deep breath and reflect on your day" 
        : (_dailyQuote?.content ?? "Take a deep breath and reflect on your day");
    final quoteAuthor = _dailyQuote?.author;
    
    return Semantics(
      label: 'Daily affirmation with journal access',
      hint: 'Tap to open daily affirmations',
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AffirmationScreen())),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 13), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: timeOfDay == 'morning'
                      ? [const Color(0xFF87CEEB), const Color(0xFF98D8AA)]
                      : timeOfDay == 'afternoon'
                          ? [const Color(0xFFFFE4B5), const Color(0xFF90EE90)]
                          : [const Color(0xFF4A4A7A), const Color(0xFF2E4A5A)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: timeOfDay == 'evening' ? Colors.white70 : const Color(0xFF8FEC95),
                      ),
                      child: timeOfDay != 'evening' ? Icon(
                        Icons.sentiment_satisfied_alt,
                        size: 28,
                        color: timeOfDay == 'evening' ? Colors.white : Colors.black87,
                      ) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomPaint(size: const Size(double.infinity, 80), painter: _HillsPainter(timeOfDay: timeOfDay)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                quoteText,
                                style: TextStyle(
                                  fontSize: quoteText.length > 80 ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: timeOfDay == 'evening' ? Colors.white : Colors.black87,
                                  height: 1.4,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (quoteAuthor != null && quoteAuthor.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '— $quoteAuthor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: timeOfDay == 'evening' ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
              Container(
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E4DD),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      timeOfDay.substring(0, 1).toUpperCase() + timeOfDay.substring(1),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickJournalPrompts(bool isDark) {
    final prompts = [
      _JournalPrompt(icon: Icons.nature, title: 'Pause & reflect', question: 'What are you grateful for today?', tag: 'Personal', tagColor: const Color(0xFFFF6B6B)),
      _JournalPrompt(icon: Icons.sentiment_satisfied_alt, title: 'Set Intentions', question: 'How do you want to feel?', tag: 'Family', tagColor: const Color(0xFF8FEC95)),
      _JournalPrompt(icon: Icons.psychology, title: 'Emotional Check-in', question: 'How are you feeling right now?', tag: 'Wellness', tagColor: const Color(0xFF4ECDC4)),
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return Semantics(
            label: '${prompt.title}: ${prompt.question}',
            hint: 'Tap to start journaling about ${prompt.title.toLowerCase()}',
            button: true,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalScreen())),
              child: Container(
                width: 160,
                margin: EdgeInsets.only(right: index < prompts.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 13), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(prompt.icon, size: 16, color: prompt.tagColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(prompt.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: Text(prompt.question, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.3))),
                    Row(
                      children: [
                        Text('Today', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[500])),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: prompt.tagColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: prompt.tagColor, width: 1),
                          ),
                          child: Text(prompt.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: prompt.tagColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickChatWidget(bool isDark) {
    return Semantics(
      label: 'Quick chat suggestions',
      hint: 'Choose a topic to start chatting about',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 13), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FEC95).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8FEC95), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    Text('Start a conversation about...', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildChatSuggestion(isDark, Icons.psychology, 'How I\'m feeling today', 'Share your current emotions'),
            const SizedBox(height: 12),
            _buildChatSuggestion(isDark, Icons.track_changes, 'My goals and aspirations', 'Discuss your plans and dreams'),
            const SizedBox(height: 12),
            _buildChatSuggestion(isDark, Icons.sentiment_satisfied_alt, 'Something positive', 'Talk about what\'s going well'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                label: 'Start a new chat conversation',
                hint: 'Opens chat screen',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat, size: 20),
                  label: const Text('Start Chatting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSuggestion(bool isDark, IconData icon, String title, String subtitle) {
    return Semantics(
      label: '$title chat suggestion',
      hint: 'Tap to start chatting about $subtitle',
      button: true,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF8FEC95)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 13), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', isDark),
          _buildNavItem(1, Icons.explore_outlined, Icons.explore, 'Explore', isDark),
          const SizedBox(width: 56),
          _buildNavItem(2, Icons.favorite_outline, Icons.favorite, 'Favourites', isDark),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isSelected = _selectedNavIndex == index;
    String semanticLabel = label;
    String semanticHint = '';
    
    if (index == 1) {
      semanticLabel = 'Explore features';
      semanticHint = 'Tap to explore app features and resources';
    } else if (index == 2) {
      semanticLabel = 'Favourites';
      semanticHint = 'Tap to view your saved messages and affirmations';
    } else if (index == 3) {
      semanticLabel = 'Profile and settings';
      semanticHint = 'Tap to manage your account';
    } else {
      semanticLabel = 'Home dashboard';
      semanticHint = 'Tap to return to home';
    }
    
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[600] : Colors.grey[400]), size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[600] : Colors.grey[400]))),
        ],
      ),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.grey[600] : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Semantics(
                label: 'Settings',
                hint: 'Tap to open app settings and preferences',
                button: true,
                child: ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }),
              ),
              Semantics(
                label: 'Favourites',
                hint: 'Tap to view your saved messages and affirmations',
                button: true,
                child: ListTile(leading: const Icon(Icons.favorite_outline), title: const Text('Favourites'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksScreen())); }),
              ),
              Semantics(
                label: 'Sign out',
                hint: 'Tap to log out of your account',
                button: true,
                child: ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Sign Out', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); _handleSignOut(); }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Sign Out')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await SupabaseAuthService.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}

class _DayInfo {
  final String dayName;
  final int date;
  final bool isToday;
  _DayInfo({required this.dayName, required this.date, required this.isToday});
}

class _JournalPrompt {
  final IconData icon;
  final String title;
  final String question;
  final String tag;
  final Color tagColor;
  _JournalPrompt({required this.icon, required this.title, required this.question, required this.tag, required this.tagColor});
}

class _HillsPainter extends CustomPainter {
  final String timeOfDay;
  _HillsPainter({required this.timeOfDay});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = timeOfDay == 'evening' ? const Color(0xFF2E4A5A) : const Color(0xFF4A6741);
    final backHill = Path();
    backHill.moveTo(0, size.height);
    backHill.lineTo(0, size.height * 0.6);
    backHill.quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.6, size.height * 0.5);
    backHill.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.4);
    backHill.lineTo(size.width, size.height);
    backHill.close();
    canvas.drawPath(backHill, paint);

    paint.color = timeOfDay == 'evening' ? const Color(0xFF1A3A4A) : const Color(0xFF3A5A31);
    final frontHill = Path();
    frontHill.moveTo(0, size.height);
    frontHill.lineTo(0, size.height * 0.8);
    frontHill.quadraticBezierTo(size.width * 0.4, size.height * 0.3, size.width * 0.7, size.height * 0.7);
    frontHill.quadraticBezierTo(size.width * 0.85, size.height * 0.85, size.width, size.height * 0.6);
    frontHill.lineTo(size.width, size.height);
    frontHill.close();
    canvas.drawPath(frontHill, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

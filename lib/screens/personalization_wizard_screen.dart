import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../services/user_preferences_service.dart';
import 'home_screen.dart';

/// Personalization wizard for onboarding
class PersonalizationWizardScreen extends StatefulWidget {
  const PersonalizationWizardScreen({super.key});

  @override
  State<PersonalizationWizardScreen> createState() => _PersonalizationWizardScreenState();
}

class _PersonalizationWizardScreenState extends State<PersonalizationWizardScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final UserPreferencesService _prefsService = UserPreferencesService();
  
  int _currentPage = 0;
  final int _totalPages = 3;
  
  final List<String> _selectedGoals = [];
  String _selectedTime = '';
  String _selectedStyle = CommunicationStyles.supportive;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _fadeController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _fadeController.reset();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
    }
  }

  Future<void> _completeOnboarding() async {
    final preferences = UserPreferences(
      mentalHealthGoals: _selectedGoals,
      preferredReminderTime: _selectedTime,
      communicationStyle: _selectedStyle,
      onboardingCompleted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _prefsService.saveUserPreferences(preferences);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(isDark),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildGoalsPage(isDark),
                  _buildReminderPage(isDark),
                  _buildCommunicationStylePage(isDark),
                ],
              ),
            ),
            _buildNavigationButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_totalPages, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF8FEC95)
                    : (isDark ? Colors.grey[800] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoalsPage(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.track_changes,
              size: 64,
              color: const Color(0xFF8FEC95),
            ),
            const SizedBox(height: 24),
            Text(
              'What are your mental health goals?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select all that apply. We\'ll personalize your experience based on your goals.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...MentalHealthGoals.getAllGoals().map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGoalCard(goal, isSelected, isDark),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String goal, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedGoals.remove(goal);
              } else {
                _selectedGoals.add(goal);
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8FEC95).withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8FEC95)
                    : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FEC95).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    MentalHealthGoals.getIcon(goal),
                    size: 28,
                    color: const Color(0xFF8FEC95),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    MentalHealthGoals.getDisplayName(goal),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF8FEC95),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderPage(bool isDark) {
    final times = [
      {'value': '08:00', 'label': 'Morning', 'subtitle': '8:00 AM', 'icon': '🌅'},
      {'value': '12:00', 'label': 'Midday', 'subtitle': '12:00 PM', 'icon': '☀️'},
      {'value': '18:00', 'label': 'Evening', 'subtitle': '6:00 PM', 'icon': '🌆'},
      {'value': '21:00', 'label': 'Night', 'subtitle': '9:00 PM', 'icon': '🌙'},
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '⏰',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'When would you like daily reminders?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a time that works best for your daily check-in and affirmations.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...times.map((time) {
              final isSelected = _selectedTime == time['value'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTimeCard(time, isSelected, isDark),
              );
            }),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedTime = '');
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Skip reminders for now',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(Map<String, String> time, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedTime = time['value']!);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8FEC95).withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8FEC95)
                    : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(
                  time['icon']!,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time['label']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        time['subtitle']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF8FEC95),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunicationStylePage(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: const Color(0xFF8FEC95),
            ),
            const SizedBox(height: 24),
            Text(
              'How should I communicate with you?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a communication style that feels comfortable for you.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...CommunicationStyles.getAllStyles().map((style) {
              final isSelected = _selectedStyle == style;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildStyleCard(style, isSelected, isDark),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(String style, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedStyle = style);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8FEC95).withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8FEC95)
                    : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        CommunicationStyles.getDisplayName(style),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF8FEC95),
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CommunicationStyles.getDescription(style),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FEC95),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == _totalPages - 1 ? 'Get Started' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoals.isNotEmpty;
      case 1:
        return true; // Reminder is optional
      case 2:
        return _selectedStyle.isNotEmpty;
      default:
        return false;
    }
  }
}

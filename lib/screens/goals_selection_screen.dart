import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notification_preferences_screen.dart';

class GoalsSelectionScreen extends StatefulWidget {
  const GoalsSelectionScreen({super.key});

  @override
  State<GoalsSelectionScreen> createState() => _GoalsSelectionScreenState();
}

class _GoalsSelectionScreenState extends State<GoalsSelectionScreen> {
  // Track selected goals
  final Set<String> _selectedGoals = {};

  final List<Map<String, String>> _goals = [
    {
      'id': 'stress',
      'label': 'Manage Stress/Anxiety',
      'icon': 'assets/images/onboarding/fdc4471573f44b1cec3ae66cce16351cb10245a3.svg',
    },
    {
      'id': 'mood',
      'label': 'Boost Daily Mood',
      'icon': 'assets/images/onboarding/6bc4efa08d79e11cf58c21a816f8917e65e2edb6.svg',
    },
    {
      'id': 'resilience',
      'label': 'Build Resilience',
      'icon': 'assets/images/onboarding/1202588e2e2369af0dc32a8663a37652e7809680.svg',
    },
    {
      'id': 'mindfulness',
      'label': 'Learn Mindfulness',
      'icon': 'assets/images/onboarding/f6202f1fab7da27220c70292341b8dd0a9089232.svg',
    },
  ];

  void _toggleGoal(String goalId) {
    setState(() {
      if (_selectedGoals.contains(goalId)) {
        _selectedGoals.remove(goalId);
      } else {
        _selectedGoals.add(goalId);
      }
    });
  }

  void _continue() {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one goal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Save selected goals to user profile
    print('Selected goals: $_selectedGoals');

    // Navigate to notification preferences screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPreferencesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: Column(
                  children: [
                    const SizedBox(height: 64),
                    // Main content container
                    Container(
                      width: 336,
                      height: 634,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3FB),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
                      child: Column(
                        children: [
                          // Title
                          const SizedBox(
                            width: 266,
                            child: Text(
                              'What brings you here?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Subtitle
                          const SizedBox(
                            width: 255,
                            child: Text(
                              'Select all that apply',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Goals list
                          ..._goals.map((goal) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildGoalOption(
                                  id: goal['id']!,
                                  label: goal['label']!,
                                  icon: goal['icon']!,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 98),
                  ],
                ),
              ),
            ),
            // "Continue" button - positioned at bottom
            Positioned(
              left: 47,
              right: 47,
              bottom: 64,
              child: SizedBox(
                width: 304,
                height: 44,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 93, vertical: 14),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption({
    required String id,
    required String label,
    required String icon,
  }) {
    final isSelected = _selectedGoals.contains(id);

    return GestureDetector(
      onTap: () => _toggleGoal(id),
      child: Container(
        width: 253,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 14,
              height: 14,
              child: SvgPicture.asset(
                icon,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Satoshi',
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Checkbox circle
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2D9CDB) : const Color(0xFFD9D9D9),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2D9CDB) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

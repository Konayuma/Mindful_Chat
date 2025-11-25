import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _notificationsEnabled = false;

  void _goToChat() {
    // TODO: Save notification preference to user profile
    print('Notifications enabled: $_notificationsEnabled');

    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3FB),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Safety/notification icon (reusing from safety screen)
                          SizedBox(
                            width: 83,
                            height: 83,
                            child: SvgPicture.asset(
                              'assets/images/onboarding/3632acd00347e777593b61706d0a1b1d3e944db7.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Title
                          const SizedBox(
                            width: 266,
                            child: Text(
                              'Stay Consistent',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Description
                          const SizedBox(
                            width: 304,
                            child: Text(
                              'We\'ll send a gentle, personalized reminder for your daily check-in or a quick moment of calm when you need it. You can adjust the timing later in settings.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Enable notifications toggle
                          Container(
                            width: 304,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            child: Row(
                              children: [
                                // Bell icon
                                const Icon(
                                  Icons.notifications_outlined,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 12),
                                // Label
                                const Expanded(
                                  child: Text(
                                    'Enable Notifications',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Satoshi',
                                    ),
                                  ),
                                ),
                                // Toggle switch
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: _notificationsEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _notificationsEnabled = value;
                                      });
                                    },
                                    activeThumbColor: const Color(0xFF2D9CDB),
                                    activeTrackColor: const Color(0xFF2D9CDB).withOpacity(0.5),
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 98),
                  ],
                ),
              ),
            ),
            // "Go to chat" button - positioned at bottom
            Positioned(
              left: 47,
              right: 47,
              bottom: 64,
              child: SizedBox(
                width: 304,
                height: 44,
                child: ElevatedButton(
                  onPressed: _goToChat,
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
                    'Go to chat',
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
}

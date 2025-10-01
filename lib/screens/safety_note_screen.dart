import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'goals_selection_screen.dart';

class SafetyNoteScreen extends StatelessWidget {
  const SafetyNoteScreen({super.key});

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Safety icon
                          SizedBox(
                            width: 83,
                            height: 83,
                            child: SvgPicture.asset(
                              'assets/images/onboarding/3632acd00347e777593b61706d0a1b1d3e944db7.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const SizedBox(
                            width: 266,
                            child: Text(
                              'A Note on Safety',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          const SizedBox(
                            width: 255,
                            child: Text(
                              'I am an AI companion and cannot replace professional therapy or emergency services. If you are ever experiencing a crisis, please contact the resources below immediately.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Emergency contacts list
                          _buildEmergencyContact(
                            number: '933',
                            description: '(Lifeline Zambia – National Suicide Prevention Helpline)',
                          ),
                          const SizedBox(height: 8),
                          _buildEmergencyContact(
                            number: '116',
                            description: '(GBV and Child Protection Helpline)',
                          ),
                          const SizedBox(height: 8),
                          _buildEmergencyContact(
                            number: '991',
                            description: '(Medical Emergency)',
                          ),
                          const SizedBox(height: 8),
                          _buildEmergencyContact(
                            number: '999',
                            description: '(Police Emergency)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 68),
                  ],
                ),
              ),
            ),
            // "I understand" button - positioned at bottom
            Positioned(
              left: 47,
              right: 47,
              bottom: 64,
              child: SizedBox(
                width: 304,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to goals selection screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalsSelectionScreen(),
                      ),
                    );
                  },
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
                    'I understand',
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

  Widget _buildEmergencyContact({
    required String number,
    required String description,
  }) {
    return Container(
      width: 304,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: SvgPicture.asset(
              'assets/images/onboarding/ce76dc0e8419f24a09ed1566475551a80dacf3ba.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.black,
                  fontFamily: 'Satoshi',
                ),
                children: [
                  TextSpan(
                    text: number,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $description',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> with TickerProviderStateMixin {
  MoodType? _selectedMood;
  final List<String> _selectedFeelings = [];
  final TextEditingController _notesController = TextEditingController();
  int _currentStep = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _progressController.forward(from: 0.0);
    } else {
      _submitCheckin();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _progressController.forward(from: 0.0);
    }
  }

  void _submitCheckin() {
    // TODO: Save checkin to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in saved successfully!'),
        backgroundColor: Color(0xFF8FEC95),
      ),
    );
    
    Navigator.of(context).pop();
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
            Icons.close,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Daily Check-in',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.black54,
                fontFamily: 'Satoshi',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(isDark),
          const SizedBox(height: 30),
          
          // Content
          Expanded(
            child: _buildCurrentStep(isDark),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep 
                        ? const Color(0xFF8FEC95)
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of 3',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildMoodSelection(isDark);
      case 1:
        return _buildFeelingsSelection(isDark);
      case 2:
        return _buildNotesStep(isDark);
      default:
        return Container();
    }
  }

  Widget _buildMoodSelection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the mood that best represents how you feel right now',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: MoodType.values.length,
              itemBuilder: (context, index) {
                final mood = MoodType.values[index];
                final isSelected = _selectedMood == mood;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? mood.color.withValues(alpha: 0.2) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(color: mood.color, width: 2) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mood.icon,
                          size: 48,
                          color: mood.color,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? mood.color : (isDark ? Colors.white : Colors.black),
                            fontFamily: 'Satoshi',
                          ),
                        ),
                        Text(
                          mood.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.black54,
                            fontFamily: 'Satoshi',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingsSelection(bool isDark) {
    final feelings = [
      'Grateful', 'Anxious', 'Energetic', 'Tired', 'Focused', 'Distracted',
      'Calm', 'Stressed', 'Happy', 'Sad', 'Confident', 'Worried',
      'Peaceful', 'Frustrated', 'Excited', 'Bored', 'Motivated', 'Overwhelmed'
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What specific feelings are you experiencing?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply (you can choose multiple)',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: feelings.map((feeling) {
                final isSelected = _selectedFeelings.contains(feeling);
                return FilterChip(
                  label: Text(feeling),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFeelings.add(feeling);
                      } else {
                        _selectedFeelings.remove(feeling);
                      }
                    });
                  },
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  selectedColor: const Color(0xFF8FEC95).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF8FEC95) : (isDark ? Colors.white : Colors.black),
                    fontFamily: 'Satoshi',
                  ),
                  checkmarkColor: const Color(0xFF8FEC95),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any additional thoughts?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional: Add any notes about your day or what\'s on your mind',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Type your thoughts here...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey,
                    fontFamily: 'Satoshi',
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() ? const Color(0xFF8FEC95) : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep == 2 ? 'Complete' : 'Next',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
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
    switch (_currentStep) {
      case 0:
        return _selectedMood != null;
      case 1:
        return _selectedFeelings.isNotEmpty;
      case 2:
        return true; // Notes are optional
      default:
        return false;
    }
  }
}

enum MoodType {
  veryHappy('Very Happy', 'Feeling joyful and positive', Icons.sentiment_very_satisfied, Color(0xFFFFD54F)),
  happy('Happy', 'Feeling good and content', Icons.sentiment_satisfied, Color(0xFF4CAF50)),
  neutral('Neutral', 'Feeling balanced', Icons.sentiment_neutral, Color(0xFF9E9E9E)),
  sad('Sad', 'Feeling down', Icons.sentiment_dissatisfied, Color(0xFF64B5F6)),
  anxious('Anxious', 'Feeling worried', Icons.psychology, Color(0xFFFF9800)),
  angry('Angry', 'Feeling frustrated', Icons.mood_bad, Color(0xFFE91E63));

  const MoodType(this.label, this.description, this.icon, this.color);
  
  final String label;
  final String description;
  final IconData icon;
  final Color color;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;
  
  BreathingPhase _currentPhase = BreathingPhase.ready;
  int _cyclesCompleted = 0;
  int _targetCycles = 5;
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _currentPhase = BreathingPhase.inhale;
      _cyclesCompleted = 0;
    });
    
    _pulseController.repeat(reverse: true);
    _runBreathingCycle();
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _currentPhase = BreathingPhase.ready;
    });
    
    _breathingController.stop();
    _pulseController.stop();
    _breathingController.reset();
  }

  Future<void> _runBreathingCycle() async {
    if (!_isRunning || !mounted) return;
    
    // Inhale phase (4 seconds)
    setState(() => _currentPhase = BreathingPhase.inhale);
    await _breathingController.forward();
    
    if (!_isRunning || !mounted) return;
    
    // Hold phase (4 seconds)
    setState(() => _currentPhase = BreathingPhase.hold);
    await Future.delayed(const Duration(seconds: 4));
    
    if (!_isRunning || !mounted) return;
    
    // Exhale phase (4 seconds)
    setState(() => _currentPhase = BreathingPhase.exhale);
    await _breathingController.reverse();
    
    if (!_isRunning || !mounted) return;
    
    // Rest phase (2 seconds)
    setState(() => _currentPhase = BreathingPhase.rest);
    await Future.delayed(const Duration(seconds: 2));
    
    // Cycle completed
    setState(() => _cyclesCompleted++);
    
    // Check if target cycles reached
    if (_cyclesCompleted >= _targetCycles) {
      _stopBreathing();
      _showCompletionDialog();
    } else {
      _runBreathingCycle();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: Text('You\'ve completed $_targetCycles breathing cycles. Take a moment to notice how you feel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startBreathing();
            },
            child: const Text('Do More'),
          ),
        ],
      ),
    );
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
          'Breathing Exercise',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(isDark),
              const SizedBox(height: 40),
              
              // Breathing circle
              Expanded(
                child: Center(
                  child: _buildBreathingCircle(isDark),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Phase text
              _buildPhaseText(isDark),
              const SizedBox(height: 30),
              
              // Controls
              _buildControls(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Satoshi',
                ),
              ),
              Text(
                '$_cyclesCompleted / $_targetCycles cycles',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontFamily: 'Satoshi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _cyclesCompleted / _targetCycles,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF64B5F6)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _pulseAnimation]),
      builder: (context, child) {
        double scale = _isRunning ? _breathingAnimation.value : 1.0;
        double pulseScale = _currentPhase == BreathingPhase.hold ? _pulseAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale * pulseScale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF64B5F6).withValues(alpha: 0.8),
                  const Color(0xFF42A5F5).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64B5F6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getPhaseIcon(),
                        size: 40,
                        color: const Color(0xFF64B5F6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPhaseText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'Satoshi',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseText(bool isDark) {
    String instruction = '';
    String subtitle = '';
    
    switch (_currentPhase) {
      case BreathingPhase.ready:
        instruction = 'Ready to begin?';
        subtitle = 'Press start when you\'re ready to begin the breathing exercise';
        break;
      case BreathingPhase.inhale:
        instruction = 'Breathe In';
        subtitle = 'Slowly inhale through your nose';
        break;
      case BreathingPhase.hold:
        instruction = 'Hold';
        subtitle = 'Hold your breath gently';
        break;
      case BreathingPhase.exhale:
        instruction = 'Breathe Out';
        subtitle = 'Slowly exhale through your mouth';
        break;
      case BreathingPhase.rest:
        instruction = 'Rest';
        subtitle = 'Pause before the next breath';
        break;
    }
    
    return Column(
      children: [
        Text(
          instruction,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.black54,
            fontFamily: 'Satoshi',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControls(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: _targetCycles > 1 ? () {
                    setState(() => _targetCycles--);
                  } : null,
                ),
                Text(
                  '$_targetCycles cycles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Satoshi',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() => _targetCycles++);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isRunning ? _stopBreathing : _startBreathing,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64B5F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            children: [
              Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              const SizedBox(width: 8),
              Text(
                _isRunning ? 'Stop' : 'Start',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Satoshi',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getPhaseIcon() {
    switch (_currentPhase) {
      case BreathingPhase.ready:
        return Icons.air;
      case BreathingPhase.inhale:
        return Icons.arrow_downward;
      case BreathingPhase.hold:
        return Icons.pause;
      case BreathingPhase.exhale:
        return Icons.arrow_upward;
      case BreathingPhase.rest:
        return Icons.self_improvement;
    }
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case BreathingPhase.ready:
        return 'Ready';
      case BreathingPhase.inhale:
        return '4s';
      case BreathingPhase.hold:
        return '4s';
      case BreathingPhase.exhale:
        return '4s';
      case BreathingPhase.rest:
        return '2s';
    }
  }
}

enum BreathingPhase {
  ready,
  inhale,
  hold,
  exhale,
  rest,
}

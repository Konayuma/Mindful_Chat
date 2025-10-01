import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'create_password_screen.dart';
import '../services/email_verification_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isResendEnabled = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
    _startResendTimer();
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _sendVerificationCode() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    try {
      // Use the email verification service to generate and send code
      await EmailVerificationService.instance.sendVerificationCode(widget.email);
      
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        
        // Show success message after the frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Verification code sent to ${widget.email}',
                  // Note: In production, NEVER show the actual code
                  // For testing: '\nCode: $code (for testing only)'
                ),
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send verification code: $e'),
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }
  
  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }
  
  Future<void> _resendCode() async {
    if (_isResendEnabled && !_isSending) {
      // Clear all input fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      await _sendVerificationCode();
      _startResendTimer();
    }
  }
  
  Future<void> _verifyCode() async {
    final enteredCode = _controllers.map((c) => c.text).join();
    
    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Verify OTP code using Supabase Auth
      // This will automatically sign in the user if successful
      final isValid = await EmailVerificationService.instance.verifyCode(
        widget.email,
        enteredCode,
      );
      
      if (!mounted) return;
      
      // Dismiss loading indicator
      Navigator.of(context).pop();
      
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        
        // User is now signed in via Supabase OTP
        // Navigate to create password screen to set permanent password
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePasswordScreen(email: widget.email),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired verification code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Clear all fields and focus on first field
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      
      // Dismiss loading indicator
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    // Brain illustration (smaller version)
                    Container(
                      width: 127,
                      height: 191,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/16d9b135ef8cf0979211ae7db43c13eed5916059.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Check your email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Satoshi',
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Subtitle with email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontFamily: 'Satoshi',
                            height: 1.3,
                          ),
                          children: [
                            const TextSpan(
                              text: 'We\'ve sent a 6-digit confirmation code to ',
                            ),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '. Please enter the code below to complete your registration.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 6-Digit Code Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 44,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.2),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Satoshi',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Move to next field
                                  if (index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    // Last field, verify code
                                    _focusNodes[index].unfocus();
                                    _verifyCode();
                                  }
                                }
                              },
                              onTap: () {
                                // Select all text when tapping
                                _controllers[index].selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _controllers[index].text.length,
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 42),
                    // Resend code text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _resendCode,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Satoshi',
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Didn\'t receive code? ',
                              ),
                              TextSpan(
                                text: _isResendEnabled
                                    ? 'Resend code'
                                    : 'Resend code ($_resendCountdown s)',
                                style: TextStyle(
                                  color: _isResendEnabled
                                      ? const Color(0xFF00BCD4)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
            ),
        ),
        // Back button
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
        ),
      ),
    );
  }
}

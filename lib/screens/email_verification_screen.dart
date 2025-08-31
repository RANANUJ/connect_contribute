import 'package:flutter/material.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final Function(bool) onVerificationStatusChanged;
  final VoidCallback onResendEmail;
  final VoidCallback onContinue;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.onVerificationStatusChanged,
    required this.onResendEmail,
    required this.onContinue,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  bool _isVerified = false;
  bool _isChecking = true;
  
  // Timer for resend functionality
  Timer? _timer;
  int _resendCountdown = 30;
  bool _canResend = false;
  
  // Animation controller for success animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // Start checking verification status
    widget.onVerificationStatusChanged(_isVerified);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 30;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _resendEmail() {
    if (!_canResend) return;
    
    widget.onResendEmail();
    _startResendTimer();
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification email sent to ${widget.email}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _checkVerificationManually() {
    setState(() {
      _isChecking = true;
    });
    
    // Trigger verification check
    widget.onVerificationStatusChanged(_isVerified);
    
    // Stop checking after 3 seconds if still not verified
    Timer(const Duration(seconds: 3), () {
      if (mounted && !_isVerified) {
        setState(() {
          _isChecking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Icon with animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isVerified ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isVerified 
                          ? Colors.green.withOpacity(0.1)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      _isVerified ? Icons.check_circle : Icons.email,
                      size: 40,
                      color: _isVerified ? Colors.green : Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              _isVerified ? 'Email Verified!' : 'Check Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _isVerified ? Colors.green : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              _isVerified 
                  ? 'Your email has been successfully verified.'
                  : 'We sent a verification link to:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (!_isVerified) ...[
              const SizedBox(height: 8),
              
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Click the link in the email to verify your account.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 40),
            
            // Verification status indicator
            if (_isChecking && !_isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Checking verification status...',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Check verification button
            if (!_isVerified)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerificationManually,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Check Verification Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            
            // Continue button (when verified)
            if (_isVerified)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Resend email link
            if (!_isVerified)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the email? ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _resendEmail : null,
                    child: Text(
                      _canResend ? 'Resend' : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: _canResend ? Theme.of(context).primaryColor : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Instructions
            if (!_isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your inbox and spam folder\n'
                      '• Click the verification link in the email\n'
                      '• Return to this screen and tap "Check Verification Status"',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

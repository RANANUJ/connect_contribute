import 'package:flutter/material.dart';
import '../services/optimized_auth_service.dart';

class PhoneOTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final OptimizedAuthService authService;

  const PhoneOTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.authService,
  });

  @override
  State<PhoneOTPVerificationScreen> createState() => _PhoneOTPVerificationScreenState();
}

class _PhoneOTPVerificationScreenState extends State<PhoneOTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Phone Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Phone icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2CBF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: Color(0xFF7B2CBF),
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Verify Your Phone Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We have sent a 6-digit verification code to',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Phone number
              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B2CBF),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _otpControllers[index].text.isNotEmpty 
                            ? const Color(0xFF7B2CBF) 
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _otpControllers[index].text.isNotEmpty 
                          ? const Color(0xFF7B2CBF).withOpacity(0.05)
                          : Colors.white,
                    ),
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2CBF),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild for border color
                        
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto verify when all fields are filled
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Resend code section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isResending ? null : _resendOTP,
                    child: Text(
                      _isResending ? 'Sending...' : 'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isResending ? Colors.grey : const Color(0xFF7B2CBF),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify Phone Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Verifying OTP: $otp'); // Debug log
      bool isVerified = await widget.authService.verifyPhoneOTP(otp);
      
      if (isVerified) {
        if (mounted) {
          _showSuccessSnackBar('Phone number verified successfully!');
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Invalid verification code. Please try again.');
          _clearOTPFields();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Verification failed: ${e.toString()}');
        _clearOTPFields();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      await widget.authService.sendPhoneOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (message) {
          if (mounted) {
            _showSuccessSnackBar('Verification code sent successfully!');
            _clearOTPFields();
          }
        },
        onVerificationCompleted: (message) {
          if (mounted) {
            _showSuccessSnackBar('Phone number verified automatically!');
            Navigator.of(context).pop(true);
          }
        },
        onVerificationFailed: (error) {
          if (mounted) {
            _showErrorSnackBar('Failed to resend code: $error');
          }
        },
        onCodeAutoRetrievalTimeout: () {
          // Handle timeout if needed
          print('Auto-retrieval timeout');
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to resend code: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

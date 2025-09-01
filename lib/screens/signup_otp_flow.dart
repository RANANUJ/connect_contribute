import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/phone_otp_screen.dart';
import '../screens/email_verification_screen.dart';

class SignupOTPFlow extends StatefulWidget {
  const SignupOTPFlow({super.key});

  @override
  State<SignupOTPFlow> createState() => _SignupOTPFlowState();
}

class _SignupOTPFlowState extends State<SignupOTPFlow> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // State variables
  String _selectedUserType = 'individual';
  bool _isLoading = false;
  String _errorMessage = '';
  
  // OTP verification states
  bool _isEmailVerified = false;
  String _phoneOTP = '';
  
  // User credential for final registration
  UserCredential? _userCredential;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    _authService.dispose();
    super.dispose();
  }

  // Step 1: Basic Information Form
  Widget _buildBasicInfoForm() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              const Text(
                'Join Connect & Contribute',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Create your account to start making a difference',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // User Type Selection
              const Text(
                'I am a',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Individual'),
                      subtitle: const Text('Person looking to volunteer'),
                      value: 'individual',
                      groupValue: _selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('NGO'),
                      subtitle: const Text('Organization seeking help'),
                      value: 'ngo',
                      groupValue: _selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedUserType == 'ngo' ? 'Organization Name' : 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'We\'ll send an OTP to verify this number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendPhoneOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Phone OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms and Privacy
              Text(
                'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Send Phone OTP
  Future<void> _sendPhoneOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      await _authService.sendPhoneOTP(
        phoneNumber: _phoneController.text.trim(),
        onCodeSent: (message) {
          setState(() {
            _isLoading = false;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        onVerificationCompleted: (message) {
          setState(() {
            _isLoading = false;
          });
        },
        onVerificationFailed: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
        onCodeAutoRetrievalTimeout: () {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Verify Phone OTP and proceed to email verification
  Future<void> _verifyPhoneOTPAndProceed(String otp) async {
    try {
      _phoneOTP = otp;
      bool isVerified = await _authService.verifyPhoneOTP(otp);
      
      if (isVerified) {
        setState(() {
          _phoneOTP = otp;
        });
        
        // Proceed to create account and send email verification
        await _createAccountAndSendEmailVerification();
      }
    } catch (e) {
      // Show error on phone OTP screen
      if (_pageController.hasClients) {
        final phoneOTPScreen = (_pageController.page?.round() == 1);
        if (phoneOTPScreen) {
          // Access the phone OTP screen and show error
          setState(() {
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  // Create account and send email verification
  Future<void> _createAccountAndSendEmailVerification() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Create account with verified phone OTP
      _userCredential = await _authService.registerWithEmailPasswordOTP(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _selectedUserType,
        _phoneController.text.trim(),
        _phoneOTP,
      );
      
      if (_userCredential != null) {
        // Navigate to email verification screen
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        
        // Start email verification polling
        _authService.startEmailVerificationPolling(
          onVerificationStatusChanged: (isVerified) {
            if (isVerified && !_isEmailVerified) {
              setState(() {
                _isEmailVerified = true;
              });
            }
          },
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Complete registration and navigate to home
  void _completeRegistration() {
    _authService.stopEmailVerificationPolling();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Step 1: Basic Information Form
        _buildBasicInfoForm(),
        
        // Step 2: Phone OTP Verification
        PhoneOTPScreen(
          phoneNumber: _phoneController.text,
          onOTPVerified: _verifyPhoneOTPAndProceed,
          onResendOTP: () async {
            await _authService.resendPhoneOTP(
              phoneNumber: _phoneController.text.trim(),
              onCodeSent: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              onVerificationFailed: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: Colors.red),
                );
              },
            );
          },
        ),
        
        // Step 3: Email Verification
        EmailVerificationScreen(
          email: _emailController.text,
          onVerificationStatusChanged: (isVerified) async {
            bool actualStatus = await _authService.checkEmailVerification();
            if (actualStatus && !_isEmailVerified) {
              setState(() {
                _isEmailVerified = true;
              });
            }
          },
          onResendEmail: () async {
            try {
              await _authService.resendEmailVerification();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to resend email: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onContinue: _completeRegistration,
        ),
      ],
    );
  }
}

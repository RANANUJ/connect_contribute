import 'package:flutter/material.dart';
import '../utils/firebase_config_checker.dart';
import '../services/optimized_auth_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _configStatus;
  bool? _phoneAuthTestResult;
  String _testPhoneNumber = '+91';
  final TextEditingController _phoneController = TextEditingController();
  final OptimizedAuthService _authService = OptimizedAuthService();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _testPhoneNumber;
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    final status = await FirebaseConfigChecker.checkFirebaseConfiguration();
    final phoneTestResult = await FirebaseConfigChecker.testPhoneAuthConnection();

    setState(() {
      _configStatus = status;
      _phoneAuthTestResult = phoneTestResult;
      _isLoading = false;
    });
  }

  Future<void> _testRealPhoneOTP() async {
    final phone = _phoneController.text.trim();
    
    if (phone.length < 10) {
      _showSnackBar('Please enter a valid phone number', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPhoneOTP(
        phoneNumber: phone,
        onCodeSent: (message) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('✅ OTP sent successfully! Check console for verification ID', isError: false);
        },
        onVerificationCompleted: (message) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('✅ Auto verification completed!', isError: false);
        },
        onVerificationFailed: (error) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('❌ Verification failed: $error', isError: true);
        },
        onCodeAutoRetrievalTimeout: () {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('⏰ Auto retrieval timeout', isError: false);
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('❌ Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase OTP Test'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConfiguration,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Configuration Status
                  if (_configStatus != null) ...[
                    FirebaseConfigChecker.buildConfigurationReport(_configStatus!),
                    const SizedBox(height: 24),
                  ],

                  // Phone Auth Test Result
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _phoneAuthTestResult == true 
                          ? Colors.green[50] 
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _phoneAuthTestResult == true 
                            ? Colors.green[200]! 
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _phoneAuthTestResult == true 
                              ? Icons.check_circle 
                              : Icons.error,
                          color: _phoneAuthTestResult == true 
                              ? Colors.green[700] 
                              : Colors.red[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _phoneAuthTestResult == true
                                ? 'Phone Auth Service: Connected ✅'
                                : 'Phone Auth Service: Not Reachable ❌',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _phoneAuthTestResult == true 
                                  ? Colors.green[700] 
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Real Phone OTP Test
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Real Phone OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your phone number to test if OTP is actually sent:',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+91XXXXXXXXXX',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testRealPhoneOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Send Test OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Firebase Console Links
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase Console Checklist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildChecklistItem('Enable Phone Authentication in Firebase Console'),
                        _buildChecklistItem('Add SHA-1 fingerprint for Android app'),
                        _buildChecklistItem('Verify project is on Blaze plan (required for SMS)'),
                        _buildChecklistItem('Check SMS quota and usage'),
                        _buildChecklistItem('Add test phone numbers if needed'),
                        const SizedBox(height: 12),
                        Text(
                          'Your Project ID: ${_configStatus?['project_id'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Debug Console Output Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.terminal, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Debug Console Output',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Watch the VS Code Debug Console for detailed logs when testing OTP. Look for:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• "OptimizedAuthService: Starting phone OTP for: [number]"\n'
                          '• "OptimizedAuthService: Code sent, verification ID: [id]"\n'
                          '• Any error messages with specific Firebase error codes',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, 
               size: 16, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.orange[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

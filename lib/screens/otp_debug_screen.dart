import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_otp_debugger.dart';
import '../services/optimized_auth_service.dart';

class OTPDebugScreen extends StatefulWidget {
  const OTPDebugScreen({super.key});

  @override
  State<OTPDebugScreen> createState() => _OTPDebugScreenState();
}

class _OTPDebugScreenState extends State<OTPDebugScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+916230278253');
  final TextEditingController _otpController = TextEditingController();
  final OptimizedAuthService _authService = OptimizedAuthService();
  
  Map<String, dynamic>? _debugResults;
  bool _isDebugging = false;
  bool _isSendingOTP = false;
  bool _isVerifyingOTP = false;
  String? _verificationId;
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Debug Tool'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firebase Setup Check
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Firebase Setup Check',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isDebugging ? null : _runFirebaseDebug,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: _isDebugging
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Debugging...'),
                                ],
                              )
                            : const Text('Run Firebase Debug Check'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Debug Results
            if (_debugResults != null) ...[
              const SizedBox(height: 16),
              _buildDebugResults(),
            ],
            
            const SizedBox(height: 24),
            
            // Manual OTP Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Manual OTP Test',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Number Input
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+916230278253',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSendingOTP ? null : _sendTestOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSendingOTP
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Sending OTP...'),
                                ],
                              )
                            : const Text('Send Test OTP'),
                      ),
                    ),
                    
                    // OTP Input (shown after OTP is sent)
                    if (_verificationId != null) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'Enter OTP',
                          hintText: '123456',
                          prefixIcon: Icon(Icons.security),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Verify OTP Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isVerifyingOTP ? null : _verifyTestOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isVerifyingOTP
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Verifying...'),
                                  ],
                                )
                              : const Text('Verify OTP'),
                        ),
                      ),
                    ],
                    
                    // Error Display
                    if (_lastError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _lastError!,
                                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Fixes
            _buildQuickFixes(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugResults() {
    final results = _debugResults!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Status indicators
            _buildStatusRow('Firebase Connected', results['firebaseConnected']),
            _buildStatusRow('Phone Auth Enabled', results['phoneAuthEnabled']),
            _buildStatusRow('Test Number Working', results['testNumberWorking']),
            
            // Errors
            if (results['errors'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('❌ Errors:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ...results['errors'].map<Widget>((error) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $error', style: const TextStyle(color: Colors.red)),
              )),
            ],
            
            // Warnings
            if (results['warnings'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('⚠️ Warnings:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...results['warnings'].map<Widget>((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $warning', style: const TextStyle(color: Colors.orange)),
              )),
            ],
            
            // Suggestions
            if (results['suggestions'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('💡 Suggestions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ...results['suggestions'].map<Widget>((suggestion) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $suggestion', style: const TextStyle(color: Colors.blue)),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildQuickFixes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Quick Fixes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('1. Verify SHA-1 fingerprint in Firebase Console:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const SelectableText(
                'E1:C4:DC:6C:C3:D1:C9:16:42:D5:0C:65:C3:4A:52:F4:DF:9E:00:8E',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('2. Enable Phone Authentication in Firebase Console', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('• Go to Authentication → Sign-in method → Phone → Enable'),
            
            const SizedBox(height: 16),
            const Text('3. Check Firebase project settings:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('• Project ID: ngo-app-4e7a9\n• Package: com.example.connect_contribute'),
            
            const SizedBox(height: 16),
            const Text('4. If still not working:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('• Wait 1-2 hours for rate limit reset\n• Download fresh google-services.json\n• Run: flutter clean && flutter pub get'),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runFirebaseDebug() async {
    setState(() {
      _isDebugging = true;
      _debugResults = null;
    });
    
    try {
      final results = await FirebaseOTPDebugger.checkFirebaseOTPSetup();
      setState(() {
        _debugResults = results;
      });
    } catch (e) {
      setState(() {
        _debugResults = {
          'errors': ['Debug failed: $e'],
          'suggestions': ['Check internet connection and try again'],
        };
      });
    } finally {
      setState(() {
        _isDebugging = false;
      });
    }
  }
  
  Future<void> _sendTestOTP() async {
    setState(() {
      _isSendingOTP = true;
      _lastError = null;
      _verificationId = null;
    });
    
    try {
      print('🔍 Sending test OTP to: ${_phoneController.text}');
      
      // Use the debug method for better error information
      final result = await _authService.sendPhoneOTPForDebug(_phoneController.text);
      
      setState(() {
        _isSendingOTP = false;
      });
      
      if (result['success'] == true) {
        setState(() {
          _verificationId = result['verificationId'] ?? 'success';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']} SMS Count: ${result['smsCount']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _lastError = '${result['error']}: ${result['message']}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastError = 'Error: $e';
        _isSendingOTP = false;
      });
    }
  }
  
  Future<void> _verifyTestOTP() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _lastError = 'Please enter a 6-digit OTP';
      });
      return;
    }
    
    setState(() {
      _isVerifyingOTP = true;
      _lastError = null;
    });
    
    try {
      print('🔍 Verifying OTP: ${_otpController.text}');
      
      // Use the debug method for better error information
      final result = await _authService.verifyPhoneOTPForDebug(_otpController.text);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear the form
        setState(() {
          _verificationId = null;
          _otpController.clear();
        });
      } else {
        setState(() {
          _lastError = '${result['error']}: ${result['message']}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastError = 'Verification failed: $e';
      });
    } finally {
      setState(() {
        _isVerifyingOTP = false;
      });
    }
  }
}

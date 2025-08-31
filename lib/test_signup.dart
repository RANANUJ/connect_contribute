import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class TestSignupScreen extends StatefulWidget {
  const TestSignupScreen({super.key});

  @override
  State<TestSignupScreen> createState() => _TestSignupScreenState();
}

class _TestSignupScreenState extends State<TestSignupScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _result = '';

  Future<void> _testSignup() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing signup...';
    });

    try {
      final result = await _authService.registerWithEmailPasswordOTP(
        'test@example.com',
        'password123',
        'Test User',
        'individual',
        '+91123456789',
        '123456',
      );

      setState(() {
        _result = 'Success! User UID: ${result?.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testSignup,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test Signup'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}

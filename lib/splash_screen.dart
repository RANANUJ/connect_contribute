import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _debugTapCount = 0;
  
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (_debugTapCount < 5) { // Only navigate if debug mode not activated
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  void _handleDebugTap() {
    setState(() {
      _debugTapCount++;
    });
    
    if (_debugTapCount >= 5) {
      // Navigate to OTP debug screen after 5 taps
      Navigator.pushNamed(context, '/otp-debug');
      _debugTapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image (tap 5 times for debug mode)
            GestureDetector(
              onTap: _handleDebugTap,
              child: Image.asset(
                'assets/images/image.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            
            // NGO text
        
            const SizedBox(height: 40),
            
            // App title
            const Text(
              'Connect & Contribute',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 60),
            
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90A4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder home screen - replace this with your actual home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Contribute'),
        backgroundColor: const Color(0xFF4A90A4),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Welcome to Connect & Contribute!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

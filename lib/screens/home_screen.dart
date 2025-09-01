import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../splash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Contribute'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2CBF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Color(0xFF7B2CBF),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Welcome, ${user?.displayName ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              const Text(
                'You have successfully signed in to Connect & Contribute',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Email: ${user?.email ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Quick Actions
              const Text(
                'Coming Soon:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              const Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  Chip(
                    avatar: Icon(Icons.volunteer_activism, size: 18),
                    label: Text('Browse Donations'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  Chip(
                    avatar: Icon(Icons.people, size: 18),
                    label: Text('Find Volunteers'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  Chip(
                    avatar: Icon(Icons.business, size: 18),
                    label: Text('NGO Directory'),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  Chip(
                    avatar: Icon(Icons.track_changes, size: 18),
                    label: Text('Track Impact'),
                    backgroundColor: Colors.purple,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF7B2CBF),
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User ID: ${user?.uid.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account Created: ${user?.metadata.creationTime?.toString().split(' ')[0] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Quick test script to create admin account in Firebase Auth
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // You'll need to initialize Firebase here
  // await Firebase.initializeApp();
  
  print('🔧 Admin Account Creation Test');
  
  const adminEmail = 'rana1452005@gmail.com';
  const adminPassword = 'anuj#123';
  
  try {
    print('📝 Attempting to create admin account...');
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );
    
    if (userCredential.user != null) {
      print('✅ Admin account created successfully!');
      print('   UID: ${userCredential.user!.uid}');
      print('   Email: ${userCredential.user!.email}');
    }
  } catch (e) {
    if (e.toString().contains('email-already-in-use')) {
      print('ℹ️ Admin account already exists, trying to sign in...');
      try {
        final signInResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        print('✅ Admin sign-in successful!');
        print('   UID: ${signInResult.user!.uid}');
      } catch (signInError) {
        print('❌ Admin sign-in failed: $signInError');
      }
    } else {
      print('❌ Error creating admin account: $e');
    }
  }
}

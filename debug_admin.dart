import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';
import 'lib/services/admin_initialization_service.dart';
import 'lib/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔧 Admin Debug Script Started');
  
  // Test admin email
  const adminEmail = 'rana1452005@gmail.com';
  const adminPassword = 'anuj#123';
  
  try {
    print('📧 Checking admin email: $adminEmail');
    
    // Check if admin document exists
    final adminModel = await AdminInitializationService.checkAdminStatus(adminEmail);
    
    if (adminModel != null) {
      print('✅ Admin document found:');
      print('   UID: ${adminModel.uid}');
      print('   Name: ${adminModel.name}');
      print('   Email: ${adminModel.email}');
      print('   Role: ${adminModel.role}');
      print('   Permissions: ${adminModel.permissions}');
    } else {
      print('❌ No admin document found for $adminEmail');
      
      // Try to authenticate and create admin
      print('🔐 Attempting to authenticate with Firebase...');
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        if (userCredential.user != null) {
          print('✅ Firebase authentication successful');
          print('   UID: ${userCredential.user!.uid}');
          
          // Create admin document
          print('📝 Creating admin document...');
          await AdminInitializationService.createAdminAccount(
            uid: userCredential.user!.uid,
            name: 'System Administrator',
            email: adminEmail,
            phone: '+91-9999999999',
            role: 'super_admin',
            permissions: [
              'create_ngos',
              'delete_ngos',
              'verify_members',
              'manage_admins',
              'access_analytics',
              'system_settings',
              'user_management',
              'content_moderation'
            ],
            canCreateNGOs: true,
            canDeleteNGOs: true,
            canVerifyMembers: true,
            canAccessAnalytics: true,
          );
          
          print('✅ Admin document created successfully');
          
          // Verify creation
          final newAdminModel = await AdminInitializationService.checkAdminStatus(adminEmail);
          if (newAdminModel != null) {
            print('✅ Admin document verification successful');
          } else {
            print('❌ Admin document verification failed');
          }
        }
      } catch (authError) {
        print('❌ Firebase authentication failed: $authError');
      }
    }
    
    // Test Firestore permissions
    print('\n🔒 Testing Firestore permissions...');
    final firestoreService = FirestoreService();
    
    try {
      print('📋 Testing NGO collection access...');
      final ngosSnapshot = await FirebaseFirestore.instance
          .collection('ngos')
          .limit(1)
          .get();
      print('✅ NGO collection access successful (${ngosSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ NGO collection access failed: $e');
    }
    
    try {
      print('👥 Testing NGO members collection access...');
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('ngo_members')
          .limit(1)
          .get();
      print('✅ NGO members collection access successful (${membersSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ NGO members collection access failed: $e');
    }
    
    try {
      print('👨‍💼 Testing admins collection access...');
      final adminsSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .limit(1)
          .get();
      print('✅ Admins collection access successful (${adminsSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ Admins collection access failed: $e');
    }
    
  } catch (e) {
    print('❌ Debug script error: $e');
  }
  
  print('\n🔧 Admin Debug Script Completed');
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import 'firestore_service.dart';

class AdminInitializationService {
  static final FirestoreService _firestoreService = FirestoreService();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Initialize default admin account
  static Future<void> initializeDefaultAdmin() async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return;
      }

      print('🔍 Current user UID: ${currentUser.uid}');
      print('🔍 Current user email: ${currentUser.email}');

      // Check if admin already exists for current user
      final existingAdmin = await _firestoreService.getAdminById(currentUser.uid);
      
      if (existingAdmin == null) {
        print('🔄 Creating new admin document for UID: ${currentUser.uid}');
        // Create default admin account using current user's UID
        final defaultAdmin = AdminModel(
          uid: currentUser.uid, // Use current user's UID
          name: 'System Administrator',
          email: currentUser.email ?? 'rana1452005@gmail.com',
          phone: '+91-9999999999',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isActive: true,
          profileImageUrl: '',
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
          department: 'System Administration',
          adminSettings: {
            'theme': 'default',
            'language': 'en',
            'notifications': true,
            'dashboard_layout': 'default'
          },
          managedNGOs: [], // Super admin can manage all NGOs
          canCreateNGOs: true,
          canDeleteNGOs: true,
          canVerifyMembers: true,
          canAccessAnalytics: true,
          additionalPrivileges: {
            'can_create_admins': true,
            'can_modify_system_settings': true,
            'can_access_all_data': true,
            'can_export_data': true
          },
        );
        
        await _firestoreService.createAdmin(defaultAdmin);
        print('✅ Default admin account created successfully');
        print('🔍 Admin document path: admins/${currentUser.uid}');
        
        // Wait a moment and verify the admin document was created
        await Future.delayed(Duration(milliseconds: 500));
        final verifyAdmin = await _firestoreService.getAdminById(currentUser.uid);
        if (verifyAdmin != null) {
          print('✅ Admin document verified successfully');
        } else {
          print('❌ Admin document verification failed');
        }
      } else {
        print('ℹ️ Default admin account already exists');
      }
    } catch (e) {
      print('❌ Error initializing default admin: $e');
    }
  }
  
  // Create additional admin accounts
  static Future<void> createAdminAccount({
    required String uid,
    required String name,
    required String email,
    required String phone,
    String role = 'admin',
    List<String> permissions = const [],
    String department = 'General',
    List<String> managedNGOs = const [],
    bool canCreateNGOs = true,
    bool canDeleteNGOs = false,
    bool canVerifyMembers = true,
    bool canAccessAnalytics = true,
  }) async {
    try {
      final admin = AdminModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isActive: true,
        role: role,
        permissions: permissions.isEmpty ? _getDefaultPermissions(role) : permissions,
        department: department,
        managedNGOs: managedNGOs,
        canCreateNGOs: canCreateNGOs,
        canDeleteNGOs: canDeleteNGOs,
        canVerifyMembers: canVerifyMembers,
        canAccessAnalytics: canAccessAnalytics,
        adminSettings: {
          'theme': 'default',
          'language': 'en',
          'notifications': true,
        },
      );
      
      await _firestoreService.createAdmin(admin);
      print('✅ Admin account created for $email');
    } catch (e) {
      print('❌ Error creating admin account: $e');
      throw e;
    }
  }
  
  // Get default permissions based on role
  static List<String> _getDefaultPermissions(String role) {
    switch (role) {
      case 'super_admin':
        return [
          'create_ngos',
          'delete_ngos',
          'verify_members',
          'manage_admins',
          'access_analytics',
          'system_settings',
          'user_management',
          'content_moderation'
        ];
      case 'admin':
        return [
          'create_ngos',
          'verify_members',
          'access_analytics',
          'user_management'
        ];
      case 'moderator':
        return [
          'verify_members',
          'content_moderation'
        ];
      default:
        return ['verify_members'];
    }
  }
  
  // Check if user has admin privileges
  static Future<AdminModel?> checkAdminStatus(String email) async {
    try {
      return await _firestoreService.getAdminByEmail(email);
    } catch (e) {
      print('Error checking admin status: $e');
      return null;
    }
  }
  
  // Update admin last login
  static Future<void> updateAdminLogin(String adminId) async {
    try {
      await _firestoreService.updateAdmin(adminId, {
        'lastLogin': FieldValue.serverTimestamp(),
      });
      await _firestoreService.updateAdminLastAction(adminId);
    } catch (e) {
      print('Error updating admin login: $e');
    }
  }
}

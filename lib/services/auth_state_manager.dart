import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class AuthStateManager {
  static const String _lastUserTypeKey = 'last_user_type';
  static const String _autoLoginEnabledKey = 'auto_login_enabled';
  
  final FirestoreService _firestoreService = FirestoreService();

  /// Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginEnabledKey) ?? true; // Default enabled
  }

  /// Enable or disable auto-login
  Future<void> setAutoLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginEnabledKey, enabled);
  }

  /// Save user type for faster navigation
  Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserTypeKey, userType);
  }

  /// Get last saved user type
  Future<String?> getLastUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserTypeKey);
  }

  /// Clear saved user data (for logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUserTypeKey);
  }

  /// Determine user type from Firebase data
  Future<String> determineUserType(User user) async {
    try {
      print('🔍 AuthStateManager - Starting determineUserType for user: ${user.email}');
      
      // Check if admin user
      if (user.email == 'rana1452005@gmail.com') {
        print('✅ AuthStateManager - Admin user detected');
        await saveUserType('admin');
        return 'admin';
      }

      // Check regular users collection first
      print('🔍 AuthStateManager - Checking users collection...');
      final userModel = await _firestoreService.getUserById(user.uid);
      if (userModel != null) {
        print('✅ AuthStateManager - Found in users collection, type: ${userModel.userType}');
        await saveUserType(userModel.userType);
        return userModel.userType;
      }
      print('❌ AuthStateManager - Not found in users collection');

      // Check NGO members collection
      print('🔍 AuthStateManager - Checking ngo_members collection...');
      final ngoMemberModel = await _firestoreService.getNGOMemberById(user.uid);
      if (ngoMemberModel != null) {
        print('✅ AuthStateManager - NGO Member found');
        print('🔍 AuthStateManager - Approval Status: ${ngoMemberModel.approvalStatus}');
        print('🔍 AuthStateManager - Is Verified: ${ngoMemberModel.isVerified}');
        
        // Check approval status - only route to NGO dashboard if approved AND verified
        if (ngoMemberModel.approvalStatus == 'approved' && ngoMemberModel.isVerified == true) {
          print('✅ AuthStateManager - User approved AND verified, returning ngo type');
          await saveUserType('ngo');
          return 'ngo';
        } else {
          // If pending or rejected, treat as pending approval
          print('⏳ AuthStateManager - User pending/not verified (status: ${ngoMemberModel.approvalStatus}, verified: ${ngoMemberModel.isVerified}), returning ngo_pending type');
          await saveUserType('ngo_pending');
          return 'ngo_pending';
        }
      }
      print('❌ AuthStateManager - Not found in ngo_members collection');

      // Default to member if no data found
      print('⚠️ AuthStateManager - No user data found, defaulting to member type');
      await saveUserType('member');
      return 'member';
    } catch (e) {
      print('❌ AuthStateManager - Error determining user type: $e');
      // Return cached type if available, otherwise default
      final cachedType = await getLastUserType();
      print('🔄 AuthStateManager - Returning cached type: $cachedType');
      return cachedType ?? 'member';
    }
  }

  /// Get current authentication state
  Future<Map<String, dynamic>> getAuthState() async {
    print('🔐 AuthStateManager - Getting auth state');
    final user = FirebaseAuth.instance.currentUser;
    final autoLoginEnabled = await isAutoLoginEnabled();
    
    print('👤 AuthStateManager - User: ${user?.email}');
    print('🔓 AuthStateManager - Auto login enabled: $autoLoginEnabled');
    
    if (user == null || !autoLoginEnabled) {
      print('❌ AuthStateManager - Not authenticated (user null or auto-login disabled)');
      return {
        'isAuthenticated': false,
        'user': null,
        'userType': null,
      };
    }

    print('🎯 AuthStateManager - Determining user type...');
    final userType = await determineUserType(user);
    print('✨ AuthStateManager - User type determined: $userType');
    
    return {
      'isAuthenticated': true,
      'user': user,
      'userType': userType,
    };
  }
}

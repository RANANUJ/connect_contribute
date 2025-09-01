import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_service.dart';
import 'firestore_service.dart';
import '../models/app_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OTPService _otpService = OTPService();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password with OTP verification
  Future<UserCredential?> registerWithEmailPasswordOTP(
    String email, 
    String password, 
    String name,
    String userType, // 'individual', 'ngo'
    String phone,
    String phoneOTP,
    {String? ngoName, String? ngoCode}
  ) async {
    try {
      print('Auth Service: Starting registration with OTP verification for $email');
      
      // Verify NGO credentials if user type is NGO
      if (userType.toLowerCase() == 'ngo') {
        if (ngoName == null || ngoCode == null) {
          throw 'NGO name and code are required for NGO member registration';
        }
        
        final ngoVerification = await _firestoreService.verifyNGOCredentials(ngoName, ngoCode);
        if (ngoVerification == null) {
          throw 'Invalid NGO credentials. Please check NGO name and code.';
        }
        print('Auth Service: NGO credentials verified for ${ngoVerification.name}');
      }
      
      // First verify phone OTP
      bool isPhoneVerified = await _otpService.verifyPhoneOTP(phoneOTP);
      if (!isPhoneVerified) {
        throw 'Phone OTP verification failed';
      }
      
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Auth Service: User created with UID: ${result.user?.uid}');

      if (result.user != null) {
        // Send email verification
        await _otpService.sendEmailVerification(result.user!);
        print('Auth Service: Email verification sent');
        
        // Update display name
        await result.user!.updateDisplayName(name);
        print('Auth Service: Display name updated');
        
        // Link phone credential if available
        PhoneAuthCredential? phoneCredential = _otpService.getPhoneAuthCredential(phoneOTP);
        if (phoneCredential != null) {
          try {
            await result.user!.linkWithCredential(phoneCredential);
            print('Auth Service: Phone number linked to account');
          } catch (e) {
            print('Auth Service: Phone linking failed (non-critical): $e');
            // Continue even if phone linking fails
          }
        }
        
        // Create user document in Firestore
        await _createUserDocument(result.user!, name, userType, phone, ngoName: ngoName, ngoCode: ngoCode);
        print('Auth Service: User document created in Firestore');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Auth Service: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Auth Service: Unexpected error: $e');
      throw e.toString();
    }
  }

  // Send phone OTP
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
    required Function() onCodeAutoRetrievalTimeout,
  }) async {
    await _otpService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  // Verify phone OTP
  Future<bool> verifyPhoneOTP(String otp) async {
    return await _otpService.verifyPhoneOTP(otp);
  }

  // Resend phone OTP
  Future<void> resendPhoneOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    await _otpService.resendPhoneOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    return await _otpService.checkEmailVerification();
  }

  // Start email verification polling
  void startEmailVerificationPolling({
    required Function(bool) onVerificationStatusChanged,
  }) {
    _otpService.startEmailVerificationPolling(
      onVerificationStatusChanged: onVerificationStatusChanged,
    );
  }

  // Stop email verification polling
  void stopEmailVerificationPolling() {
    _otpService.stopEmailVerificationPolling();
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    User? user = currentUser;
    if (user != null) {
      await _otpService.sendEmailVerification(user);
    } else {
      throw 'No user logged in';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailPassword(
    String email, 
    String password, 
    String name,
    String userType, // 'individual', 'ngo'
    String phone,
  ) async {
    try {
      print('Auth Service: Starting registration for $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Auth Service: User created with UID: ${result.user?.uid}');

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);
        print('Auth Service: Display name updated');
        
        // Create user document in Firestore
        await _createUserDocument(result.user!, name, userType, phone);
        print('Auth Service: User document created in Firestore');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Auth Service: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Auth Service: Unexpected error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name, String userType, String phone, {String? ngoName, String? ngoCode}) async {
    try {
      print('Creating user document for UID: ${user.uid}');
      
      // Common user data
      final userData = {
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileImageUrl': '',
        'address': '',
      };

      // Create document in appropriate collection based on user type
      if (userType.toLowerCase() == 'ngo') {
        // Get the verified NGO information
        NGOModel? ngoInfo;
        if (ngoName != null && ngoCode != null) {
          ngoInfo = await _firestoreService.verifyNGOCredentials(ngoName, ngoCode);
        }
        
        if (ngoInfo == null) {
          throw 'Invalid NGO credentials';
        }
        
        // Create NGO member document
        final ngoMemberData = {
          ...userData,
          'ngoId': ngoInfo.id,
          'ngoName': ngoInfo.name,
          'ngoCode': ngoInfo.ngoCode,
          'position': 'Member', // Default position
          'permissions': ['read'],
          'department': '',
          'joinedAt': FieldValue.serverTimestamp(),
          'isAdmin': false,
          'salary': 0.0,
          'employeeId': '',
          'responsibilities': <String>[],
          'workSchedule': '',
          'emergencyContact': '',
          'additionalInfo': <String, dynamic>{},
          'lastLogin': null,
          'isVerified': false,
        };
        
        await _firestore.collection('ngo_members').doc(user.uid).set(ngoMemberData);
        print('NGO member document created successfully in ngo_members collection');
        
        // DO NOT increment member count during signup - only when admin approves
        // Member count is managed by admin approval/rejection in admin dashboard
        
      } else {
        // Store individual user data in 'users' collection
        await _firestore.collection('users').doc(user.uid).set({
          ...userData,
          'userType': 'individual',
          'dateOfBirth': null,
          'interests': <String>[],
          'volunteerHistory': <String>[],
        });
        print('User document created successfully in users collection');
      }
    } catch (e) {
      print('Error creating user document: $e');
      
      // Check if it's a Firestore database not found error
      if (e.toString().contains('database (default) does not exist')) {
        throw 'Account created successfully, but database setup is required. Please contact support or set up Firestore database.';
      }
      
      throw 'Failed to create user profile. Please try again.';
    }
  }

  // Get user document from Firestore (checks both collections)
  Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      // First check users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc;
      }
      
      // Then check ngos collection
      DocumentSnapshot ngoDoc = await _firestore.collection('ngos').doc(uid).get();
      if (ngoDoc.exists) {
        return ngoDoc;
      }
      
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Get user type (individual or ngo)
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot? doc = await getUserDocument(uid);
      if (doc?.exists == true) {
        Map<String, dynamic> data = doc!.data() as Map<String, dynamic>;
        // Check if it's from ngos collection or has organizationType field
        if (data.containsKey('organizationType')) {
          return 'ngo';
        } else {
          return 'individual';
        }
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Update user profile (routes to correct collection)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      String? userType = await getUserType(uid);
      if (userType == 'ngo') {
        await _firestore.collection('ngos').doc(uid).update(data);
      } else {
        await _firestore.collection('users').doc(uid).update(data);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Clean up OTP service resources
  void dispose() {
    _otpService.dispose();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

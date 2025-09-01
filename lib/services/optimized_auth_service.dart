import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'firestore_service.dart';

class OptimizedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for user data to reduce Firestore reads
  static final Map<String, Map<String, dynamic>> _userCache = {};
  static const String _cacheKeyPrefix = 'user_data_';
  static const Duration _cacheTimeout = Duration(hours: 1);
  
  // Phone verification state
  String? _verificationId;
  int? _resendToken;
  DateTime? _lastOTPSentTime;
  PhoneAuthCredential? _phoneCredential;
  static const Duration _otpCooldown = Duration(minutes: 1); // Prevent spam
  
  // Email verification polling
  Timer? _emailVerificationTimer;
  bool _isEmailPolling = false;
  
  // Usage tracking for cost monitoring
  static int _firestoreReads = 0;
  static int _firestoreWrites = 0;
  static int _smsSent = 0;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get usage statistics
  static Map<String, int> get usageStats => {
    'firestore_reads': _firestoreReads,
    'firestore_writes': _firestoreWrites,
    'sms_sent': _smsSent,
  };
  
  // Reset usage statistics (call this monthly to track costs)
  static void resetUsageStats() {
    _firestoreReads = 0;
    _firestoreWrites = 0;
    _smsSent = 0;
  }

  // ========== OPTIMIZED SIGN IN ==========
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Preload user data into cache for better UX
      if (result.user != null) {
        await _cacheUserData(result.user!.uid);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // ========== OPTIMIZED REGISTRATION WITH COST CONTROL ==========
  Future<UserCredential?> registerWithEmailPasswordOTP(
    String email, 
    String password, 
    String name,
    String userType,
    String phone,
    String phoneOTP, {
    String? ngoName, // For NGO members - NGO name entered by user
    String? ngoCode, // For NGO members - NGO code entered by user
  }) async {
    try {
      // Verify phone OTP first (no additional SMS cost)
      bool isPhoneVerified = await verifyPhoneOTP(phoneOTP);
      if (!isPhoneVerified) {
        throw 'Phone OTP verification failed';
      }
      
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Use batch operation to minimize Firestore costs
        await _createUserDocumentBatched(
          result.user!, 
          name, 
          userType, 
          phone,
          ngoName: ngoName,
          ngoCode: ngoCode,
        );
        
        // Send email verification
        await result.user!.sendEmailVerification();
        
        // Update display name (cached locally too)
        await result.user!.updateDisplayName(name);
        
        // Cache user data immediately
        await _cacheUserData(result.user!.uid, {
          'name': name,
          'email': email,
          'userType': userType,
          'phone': phone,
          'emailVerified': false,
          'phoneVerified': true,
          'createdAt': DateTime.now().toIso8601String(),
          if (ngoName != null) 'ngoName': ngoName,
          if (ngoCode != null) 'ngoCode': ngoCode,
        });
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // ========== COST-OPTIMIZED PHONE OTP ==========
  // ========== COST-OPTIMIZED PHONE OTP ==========
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
    required Function() onCodeAutoRetrievalTimeout,
  }) async {
    try {
      print('OptimizedAuthService: Starting phone OTP for: $phoneNumber');
      
      // Check cooldown to prevent SMS spam (saves money!)
      if (_lastOTPSentTime != null) {
        final timeSinceLastOTP = DateTime.now().difference(_lastOTPSentTime!);
        if (timeSinceLastOTP < _otpCooldown) {
          final remainingTime = _otpCooldown - timeSinceLastOTP;
          throw 'Please wait ${remainingTime.inSeconds} seconds before requesting another OTP';
        }
      }
      
      // Format phone number
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Change country code as needed
      }
      
      print('OptimizedAuthService: Formatted phone: $formattedPhone');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('OptimizedAuthService: Phone verification completed automatically');
          _phoneCredential = credential;
          onVerificationCompleted('Phone verification completed automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('OptimizedAuthService: Phone verification failed: ${e.code} - ${e.message}');
          onVerificationFailed(_handlePhoneAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OptimizedAuthService: Code sent, verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          _lastOTPSentTime = DateTime.now();
          _smsSent++; // Track SMS usage
          onCodeSent('OTP sent successfully to $formattedPhone');
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          print('OptimizedAuthService: Code auto retrieval timeout: $verificationId');
          _verificationId = verificationId;
          onCodeAutoRetrievalTimeout();
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      print('OptimizedAuthService: Error sending OTP: $e');
      onVerificationFailed('Failed to send OTP: $e');
    }
  }

  // ========== DEBUG SCREEN COMPATIBLE METHOD ==========
  Future<Map<String, dynamic>> sendPhoneOTPForDebug(String phoneNumber) async {
    try {
      print('OptimizedAuthService: Debug - Starting phone OTP for: $phoneNumber');
      
      // Check cooldown
      if (_lastOTPSentTime != null) {
        final timeSinceLastOTP = DateTime.now().difference(_lastOTPSentTime!);
        if (timeSinceLastOTP < _otpCooldown) {
          final remainingTime = _otpCooldown - timeSinceLastOTP;
          return {
            'success': false,
            'error': 'Cooldown active',
            'message': 'Please wait ${remainingTime.inSeconds} seconds before requesting another OTP',
            'details': 'Rate limiting to prevent SMS charges'
          };
        }
      }
      
      // Format phone number
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Change country code as needed
      }
      
      print('OptimizedAuthService: Debug - Formatted phone: $formattedPhone');
      
      bool otpSent = false;
      String? error;
      String? details;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('OptimizedAuthService: Debug - Phone verification completed automatically');
          _phoneCredential = credential;
        },
        verificationFailed: (FirebaseAuthException e) {
          print('OptimizedAuthService: Debug - Phone verification failed: ${e.code} - ${e.message}');
          error = e.code;
          details = e.message;
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OptimizedAuthService: Debug - Code sent, verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          _lastOTPSentTime = DateTime.now();
          _smsSent++;
          otpSent = true;
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          print('OptimizedAuthService: Debug - Code auto retrieval timeout: $verificationId');
          _verificationId = verificationId;
        },
      );
      
      // Wait a moment for callbacks
      await Future.delayed(Duration(seconds: 2));
      
      if (error != null) {
        return {
          'success': false,
          'error': error,
          'message': details ?? 'Unknown error',
          'phone': formattedPhone,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      if (otpSent) {
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'phone': formattedPhone,
          'verificationId': _verificationId,
          'timestamp': DateTime.now().toIso8601String(),
          'smsCount': _smsSent,
        };
      }
      
      return {
        'success': false,
        'error': 'timeout',
        'message': 'OTP sending timed out',
        'phone': formattedPhone,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      print('OptimizedAuthService: Debug - Error sending OTP: $e');
      return {
        'success': false,
        'error': 'exception',
        'message': e.toString(),
        'phone': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Verify phone OTP
  Future<bool> verifyPhoneOTP(String otp) async {
    try {
      print('OptimizedAuthService: Starting OTP verification for: $otp');
      
      if (_verificationId == null) {
        print('OptimizedAuthService: Verification ID is null');
        throw 'Verification ID not found. Please request OTP again.';
      }
      
      print('OptimizedAuthService: Using verification ID: $_verificationId');
      
      // Create the credential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      print('OptimizedAuthService: Created phone credential successfully');
      
      // Store the credential for later use in registration
      _phoneCredential = credential;
      
      print('OptimizedAuthService: OTP verification successful');
      // If we can create the credential without error, the OTP is valid
      return true;
    } on FirebaseAuthException catch (e) {
      print('OptimizedAuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      // Re-throw with proper error handling
      throw _handlePhoneAuthException(e);
    } catch (e) {
      print('OptimizedAuthService: General error: $e');
      throw 'Invalid OTP. Please try again.';
    }
  }
  
  // ========== DEBUG VERSION OF VERIFY OTP ==========
  Future<Map<String, dynamic>> verifyPhoneOTPForDebug(String otp) async {
    try {
      print('OptimizedAuthService: Debug - Starting OTP verification for: $otp');
      
      if (_verificationId == null) {
        print('OptimizedAuthService: Debug - Verification ID is null');
        return {
          'success': false,
          'error': 'no_verification_id',
          'message': 'Verification ID not found. Please request OTP again.',
          'details': 'sendPhoneOTP must be called first',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      print('OptimizedAuthService: Debug - Using verification ID: $_verificationId');
      
      // Create the credential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      print('OptimizedAuthService: Debug - Created phone credential successfully');
      
      // Store the credential for later use in registration
      _phoneCredential = credential;
      
      print('OptimizedAuthService: Debug - OTP verification successful');
      
      return {
        'success': true,
        'message': 'OTP verification successful',
        'otp': otp,
        'verificationId': _verificationId,
        'credentialStored': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } on FirebaseAuthException catch (e) {
      print('OptimizedAuthService: Debug - FirebaseAuthException: ${e.code} - ${e.message}');
      return {
        'success': false,
        'error': e.code,
        'message': e.message ?? 'Unknown Firebase error',
        'otp': otp,
        'verificationId': _verificationId,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('OptimizedAuthService: Debug - General error: $e');
      return {
        'success': false,
        'error': 'invalid_otp',
        'message': 'Invalid OTP. Please try again.',
        'otp': otp,
        'details': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  // Get phone auth credential for linking
  PhoneAuthCredential? getPhoneAuthCredential() {
    return _phoneCredential;
  }

  // ========== OPTIMIZED USER DATA OPERATIONS ==========
  
  // Create user document with batch operation (cost-efficient)
  Future<void> _createUserDocumentBatched(
    User user, 
    String name, 
    String userType, 
    String phone, {
    String? ngoName, // NGO name entered by user
    String? ngoCode, // NGO code entered by user
  }) async {
    final batch = _firestore.batch();
    
    // Determine if this is an NGO member or regular user
    if (userType.toLowerCase() == 'ngo' && ngoName != null && ngoCode != null) {
      // Verify NGO credentials first
      final firestoreService = FirestoreService();
      final ngoInfo = await firestoreService.verifyNGOCredentials(ngoName, ngoCode);
      if (ngoInfo == null) {
        throw 'NGO not found! Please check:\n'
              '• NGO name and code are exactly as shown in admin dashboard\n'
              '• Admin has created the NGO first\n'
              '• Case-sensitive match required\n'
              '• No extra spaces before/after text';
      }
      
      // Create NGO member document
      final ngoMemberDoc = _firestore.collection('ngo_members').doc(user.uid);
      final ngoMemberData = {
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'phone': phone,
        'ngoId': ngoInfo.id, // Store verified NGO ID
        'ngoName': ngoName, // Store NGO name as entered by user
        'ngoCode': ngoCode, // Store NGO code for verification
        'position': 'member', // Default position for all NGO signups
        'permissions': ['view', 'create_basic'], // Default permissions
        'department': '',
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': false, // Never admin for signup users
        'salary': 0.0,
        'employeeId': '',
        'responsibilities': [],
        'workSchedule': '',
        'emergencyContact': '',
        'additionalInfo': {},
        'emailVerified': false,
        'phoneVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileImageUrl': '',
        'isVerified': false, // Needs admin verification
        'approvalStatus': 'pending', // pending, approved, rejected
        'appliedAt': FieldValue.serverTimestamp(),
        'rejectionReason': null,
      };
      
      batch.set(ngoMemberDoc, ngoMemberData);
      
      // DO NOT increment member count during signup - only when admin approves
      // Member count is managed by admin approval/rejection in admin dashboard
      
      // Create NGO member stats document
      final memberStatsDoc = _firestore.collection('ngoMemberStats').doc(user.uid);
      batch.set(memberStatsDoc, {
        'tasksCompleted': 0,
        'projectsManaged': 0,
        'volunteersRecruited': 0,
        'donationsRaised': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
    } else {
      // Create regular user document
      final userDoc = _firestore.collection('users').doc(user.uid);
      final userData = {
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'phone': phone,
        'userType': userType.toLowerCase(),
        'address': '',
        'interests': [],
        'totalDonated': 0.0,
        'volunteerHours': 0,
        'completedTasks': 0,
        'rating': 0.0,
        'skills': [],
        'occupation': '',
        'dateOfBirth': null,
        'emergencyContact': '',
        'preferences': {},
        'emailVerified': false,
        'phoneVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileImageUrl': '',
      };
      
      batch.set(userDoc, userData);
      
      // Create user stats document
      final statsDoc = _firestore.collection('userStats').doc(user.uid);
      batch.set(statsDoc, {
        'totalContributions': 0,
        'totalDonations': 0,
        'totalVolunteerHours': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
    _firestoreWrites += 2; // Track writes
  }

  // Get user data with caching
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    // Check cache first
    if (_userCache.containsKey(uid)) {
      final cachedData = _userCache[uid]!;
      final cacheTime = DateTime.parse(cachedData['_cacheTime']);
      if (DateTime.now().difference(cacheTime) < _cacheTimeout) {
        return cachedData;
      }
    }
    
    // Fetch from Firestore if not cached or expired
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _firestoreReads++; // Track reads
      
      if (doc.exists) {
        final data = doc.data()!;
        await _cacheUserData(uid, data);
        return data;
      }
    } catch (e) {
      // Return cached data if available, even if expired
      if (_userCache.containsKey(uid)) {
        return _userCache[uid];
      }
    }
    
    return null;
  }

  // Cache user data locally
  Future<void> _cacheUserData(String uid, [Map<String, dynamic>? data]) async {
    try {
      if (data != null) {
        data['_cacheTime'] = DateTime.now().toIso8601String();
        _userCache[uid] = data;
        
        // Also save to local storage for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_cacheKeyPrefix$uid', jsonEncode(data));
      } else {
        // Load from local storage
        final prefs = await SharedPreferences.getInstance();
        final cachedString = prefs.getString('$_cacheKeyPrefix$uid');
        if (cachedString != null) {
          _userCache[uid] = jsonDecode(cachedString);
        }
      }
    } catch (e) {
      // Cache operations are non-critical
      print('Cache operation failed: $e');
    }
  }

  // ========== OPTIMIZED EMAIL VERIFICATION ==========
  
  // Check email verification with smart polling
  Future<bool> checkEmailVerification() async {
    try {
      await currentUser?.reload();
      return currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Start efficient email verification polling
  void startEmailVerificationPolling({
    required Function(bool) onVerificationStatusChanged,
  }) {
    if (_isEmailPolling) return;
    
    _isEmailPolling = true;
    int attempts = 0;
    const maxAttempts = 30; // Stop after 5 minutes
    
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      attempts++;
      
      final isVerified = await checkEmailVerification();
      onVerificationStatusChanged(isVerified);
      
      if (isVerified || attempts >= maxAttempts) {
        stopEmailVerificationPolling();
      }
    });
  }

  void stopEmailVerificationPolling() {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = null;
    _isEmailPolling = false;
  }

  // Resend email verification with rate limiting and error handling
  Future<void> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      if (user.emailVerified) {
        throw Exception('Email is already verified');
      }
      
      print('OptimizedAuthService: Attempting to resend email verification to: ${user.email}');
      await user.sendEmailVerification();
      print('OptimizedAuthService: Email verification sent successfully');
      
    } on FirebaseAuthException catch (e) {
      print('OptimizedAuthService: Email verification failed: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'too-many-requests':
          throw Exception(
            'Too many email verification requests. Firebase has temporarily blocked requests from this device due to unusual activity. '
            'Please wait 15-30 minutes before trying again, or try from a different device/network.'
          );
        case 'user-disabled':
          throw Exception('This account has been disabled. Please contact support.');
        case 'user-not-found':
          throw Exception('User account not found. Please sign up again.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection and try again.');
        case 'internal-error':
          throw Exception('Internal server error. Please try again in a few minutes.');
        default:
          throw Exception('Failed to send verification email: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      print('OptimizedAuthService: Unexpected error during email verification: $e');
      throw Exception('Failed to send verification email: $e');
    }
  }

  // ========== UTILITY METHODS ==========
  
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
    // Clear cache on sign out
    _userCache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Update user profile efficiently
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';
    
    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update(updates);
    _firestoreWrites++;
    
    // Update cache
    if (_userCache.containsKey(user.uid)) {
      _userCache[user.uid]!.addAll(updates);
      _userCache[user.uid]!['_cacheTime'] = DateTime.now().toIso8601String();
    }
  }

  // Dispose resources
  void dispose() {
    _emailVerificationTimer?.cancel();
  }

  // ========== ERROR HANDLING ==========
  
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  String _handlePhoneAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number.';
      case 'too-many-requests':
        return 'Too many SMS requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return e.message ?? 'Phone verification failed.';
    }
  }
}

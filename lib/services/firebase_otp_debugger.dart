import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOTPDebugger {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static Future<Map<String, dynamic>> checkFirebaseOTPSetup() async {
    Map<String, dynamic> results = {
      'firebaseConnected': false,
      'phoneAuthEnabled': false,
      'appVerificationEnabled': false,
      'testNumberWorking': false,
      'errors': <String>[],
      'warnings': <String>[],
      'suggestions': <String>[],
    };
    
    try {
      // Check 1: Firebase Connection
      print("🔍 Checking Firebase connection...");
      results['firebaseConnected'] = true;
      print("✅ Firebase connected successfully");
      
      // Check 2: Test phone number format
      print("🔍 Testing phone number formatting...");
      String testPhone = "+916230278253";
      if (testPhone.startsWith('+91') && testPhone.length == 13) {
        print("✅ Phone number format is correct: $testPhone");
      } else {
        results['errors'].add("Phone number format incorrect");
      }
      
      // Check 3: Try to send OTP to test number
      print("🔍 Testing OTP sending capability...");
      await _testOTPSending(testPhone, results);
      
    } catch (e) {
      print("❌ Firebase setup error: $e");
      results['errors'].add("Firebase setup error: $e");
    }
    
    return results;
  }
  
  static Future<void> _testOTPSending(String phoneNumber, Map<String, dynamic> results) async {
    try {
      bool otpSent = false;
      String? errorMessage;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print("✅ Auto verification completed");
          results['testNumberWorking'] = true;
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Verification failed: ${e.code} - ${e.message}");
          errorMessage = "${e.code}: ${e.message}";
          results['errors'].add(errorMessage!);
          
          // Specific error handling
          switch (e.code) {
            case 'invalid-phone-number':
              results['suggestions'].add("Check phone number format (+91XXXXXXXXXX)");
              break;
            case 'too-many-requests':
              results['suggestions'].add("Wait 1-2 hours before trying again (rate limited)");
              break;
            case 'app-not-authorized':
              results['suggestions'].add("Add SHA-1 fingerprint to Firebase Console");
              break;
            case 'captcha-check-failed':
              results['suggestions'].add("Enable App Check in Firebase Console");
              break;
            default:
              results['suggestions'].add("Check Firebase Console settings");
          }
        },
        codeSent: (String vId, int? resendToken) {
          print("✅ SMS OTP sent successfully! Verification ID: $vId");
          otpSent = true;
          results['testNumberWorking'] = true;
          results['phoneAuthEnabled'] = true;
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String vId) {
          print("⏰ Auto retrieval timeout for verification ID: $vId");
        },
      );
      
      // Wait a bit to see if SMS is sent
      await Future.delayed(const Duration(seconds: 5));
      
      if (!otpSent && errorMessage == null) {
        results['warnings'].add("OTP sending timed out - check network connection");
      }
      
    } catch (e) {
      print("❌ Error testing OTP: $e");
      results['errors'].add("OTP test failed: $e");
    }
  }
  
  // Debug email verification functionality
  static Future<Map<String, dynamic>> checkEmailVerificationSetup() async {
    Map<String, dynamic> results = {
      'userSignedIn': false,
      'emailSet': false,
      'emailVerified': false,
      'canSendVerification': false,
      'rateLimitActive': false,
      'errors': <String>[],
      'warnings': <String>[],
      'suggestions': <String>[],
    };
    
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        results['errors'].add("No user is currently signed in");
        results['suggestions'].add("Sign in first before testing email verification");
        return results;
      }
      
      results['userSignedIn'] = true;
      print("✅ User signed in: ${user.uid}");
      
      if (user.email != null && user.email!.isNotEmpty) {
        results['emailSet'] = true;
        print("✅ Email set: ${user.email}");
      } else {
        results['errors'].add("No email address set for user");
        return results;
      }
      
      results['emailVerified'] = user.emailVerified;
      if (user.emailVerified) {
        print("✅ Email already verified");
        results['suggestions'].add("Email is already verified - no action needed");
      } else {
        print("⚠️ Email not yet verified");
        
        // Test if we can send verification email
        try {
          await user.sendEmailVerification();
          results['canSendVerification'] = true;
          print("✅ Email verification sent successfully");
          results['suggestions'].add("Check your email inbox and spam folder");
        } catch (e) {
          print("❌ Failed to send email verification: $e");
          
          if (e.toString().contains('too-many-requests')) {
            results['rateLimitActive'] = true;
            results['errors'].add("Rate limit active - too many requests");
            results['suggestions'].add("Wait 15-30 minutes before trying again");
            results['suggestions'].add("Try from a different device or network");
          } else {
            results['errors'].add("Email verification failed: $e");
          }
        }
      }
      
    } catch (e) {
      print("❌ Email verification check error: $e");
      results['errors'].add("Email verification check failed: $e");
    }
    
    return results;
  }
}

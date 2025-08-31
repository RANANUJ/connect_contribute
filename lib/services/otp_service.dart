import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Phone verification
  String? _verificationId;
  int? _resendToken;
  Timer? _timer;
  
  // Email verification timer
  Timer? _emailVerificationTimer;
  
  // Phone OTP verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
    required Function() onCodeAutoRetrievalTimeout,
  }) async {
    try {
      // Ensure phone number has country code
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Default to India, you can change this
      }
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          onVerificationCompleted('Phone verification completed automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = _handlePhoneAuthException(e);
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent('OTP sent successfully to $formattedPhone');
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          onCodeAutoRetrievalTimeout();
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onVerificationFailed('Failed to send OTP: $e');
    }
  }
  
  // Verify phone OTP code
  Future<bool> verifyPhoneOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw 'Verification ID not found. Please request OTP again.';
      }
      
      // Create credential to verify OTP is valid
      PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      // If no exception is thrown, OTP is valid
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthException(e);
    } catch (e) {
      throw 'Invalid OTP. Please try again.';
    }
  }
  
  // Get phone auth credential for linking
  PhoneAuthCredential? getPhoneAuthCredential(String otp) {
    if (_verificationId == null) return null;
    
    return PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
  }
  
  // Send email verification
  Future<void> sendEmailVerification(User user) async {
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Failed to send email verification: $e';
    }
  }
  
  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Start email verification polling
  void startEmailVerificationPolling({
    required Function(bool) onVerificationStatusChanged,
    int intervalSeconds = 3,
  }) {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        bool isVerified = await checkEmailVerification();
        onVerificationStatusChanged(isVerified);
        if (isVerified) {
          timer.cancel();
        }
      },
    );
  }
  
  // Stop email verification polling
  void stopEmailVerificationPolling() {
    _emailVerificationTimer?.cancel();
  }
  
  // Resend phone OTP
  Future<void> resendPhoneOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: (msg) {},
      onVerificationFailed: onVerificationFailed,
      onCodeAutoRetrievalTimeout: () {},
    );
  }
  
  // Handle phone authentication exceptions
  String _handlePhoneAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled.';
      default:
        return 'Phone verification failed: ${e.message}';
    }
  }
  
  // Clean up resources
  void dispose() {
    _timer?.cancel();
    _emailVerificationTimer?.cancel();
  }
  
  // Clear verification data
  void clearVerificationData() {
    _verificationId = null;
    _resendToken = null;
    _timer?.cancel();
    _emailVerificationTimer?.cancel();
  }
}

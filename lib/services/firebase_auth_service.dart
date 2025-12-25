// lib/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Start the phone verification process.
  /// Returns verificationId on codeSent.
  Future<void> verifyPhone({
    required String phone,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
    required void Function(FirebaseAuthException e) verificationFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: timeout,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {
        // optional: handle auto retrieval timeout
      },
    );
  }

  /// Verify the SMS code and sign in.
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential;
  }

  /// Current logged in user (nullable)
  User? currentUser() => _auth.currentUser;

  /// Sign out
  Future<void> signOut() => _auth.signOut();
}

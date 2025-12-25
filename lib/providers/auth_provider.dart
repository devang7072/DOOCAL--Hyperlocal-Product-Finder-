// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/firebase_auth_service.dart';
import '../routes.dart';
import '../screens/auth/otp_screen.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User? get user => _authService.currentUser();

  Future<void> sendOtp({
    required BuildContext context,
    required String phoneNumberWithCountryCode, // e.g. +91xxxxxxxxxx
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyPhone(
        phone: phoneNumberWithCountryCode,
        verificationCompleted: (PhoneAuthCredential credential) {
          Fluttertoast.showToast(msg: "Auto-verification complete");
        },
        verificationFailed: (FirebaseAuthException e) {
          String msg = "Verification failed: ${e.message}";
          if (e.message != null && e.message!.contains("BILLING_NOT_ENABLED")) {
             msg = "Error: Project billing not enabled. Please use a Test Phone Number (e.g., +91 9999999999) configured in Firebase Console.";
          }
          Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
          debugPrint("Phone Auth Error: ${e.code} - ${e.message}");
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (verificationId, resendToken) {
          _isLoading = false;
          notifyListeners();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                verificationId: verificationId,
                phone: phoneNumberWithCountryCode,
              ),
            ),
          );
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: "OTP send error: $e");
    }
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _authService.signInWithSmsCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        await checkUserAndNavigate(context, userCredential.user!);
      } else {
        Fluttertoast.showToast(msg: "OTP verification failed");
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: "OTP error: ${e.message}");
    } catch (e) {
      Fluttertoast.showToast(msg: "OTP verification error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkUserAndNavigate(BuildContext context, User firebaseUser) async {
    final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (docSnapshot.exists) {
      // User exists, check role
      final userData = docSnapshot.data()!;
      final role = userData['role'];
      
      if (role == 'vendor') {
         // Check if setup is complete
         if (userData['isSetupComplete'] == true) {
            Navigator.pushNamedAndRemoveUntil(context, Routes.vendorHome, (route) => false);
         } else {
            Navigator.pushNamedAndRemoveUntil(context, Routes.vendorSetup, (route) => false);
         }
      } else {
         Navigator.pushNamedAndRemoveUntil(context, Routes.customerHome, (route) => false);
      }
    } else {
      // New User -> Role Selection
      Navigator.pushNamedAndRemoveUntil(context, Routes.roleSelection, (route) => false);
    }
  }

  Future<void> updateUserRole(BuildContext context, String role) async {
    final user = _authService.currentUser();
    if (user == null) return;

    try {
      // We use set with merge: true to avoid wiping existing data (like shopName)
      // while ensuring the document exists and has the role.
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (role == 'vendor') {
         Fluttertoast.showToast(msg: "Vendor profile initialized!");
      } else {
         Navigator.pushNamedAndRemoveUntil(context, Routes.customerHome, (route) => false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving profile: $e");
    }
  }
}

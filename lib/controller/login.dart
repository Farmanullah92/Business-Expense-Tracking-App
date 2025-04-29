import 'package:business_expense_tracking/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<UserCredential?> signUpWithEmail(
    String userName,
    String userEmail,
    String userPassword,
    String userDeviceToken,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      EasyLoading.show(status: "Please wait...");

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: userEmail,
            password: userPassword,
          );

      final userModel = UserModel(
        uId: userCredential.user!.uid,
        username: userName,
        email: userEmail,
        userDeviceToken: userDeviceToken,
        isAdmin: false,
        isActive: true,
        createdOn: DateTime.now(),
      );

      await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();

      String errorMessage = "An error occurred";
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "Email is already in use";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address";
          break;
        case 'weak-password':
          errorMessage = "Password is too weak";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled";
          break;
      }

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();
      debugPrint("Sign up error: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      EasyLoading.show(status: "Signing in...");

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();

      String errorMessage = "Sign in failed";
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
      }

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      _isLoading = false;
      notifyListeners();
      debugPrint("Sign in error: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}

import 'package:business_expense_tracking/models/user_model.dart';
import 'package:business_expense_tracking/views/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      EasyLoading.show(status: "Please Wait...");

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        _isLoading = false;
        notifyListeners();
        EasyLoading.dismiss();
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await _handleUserData(user);

        EasyLoading.dismiss();
        _isLoading = false;
        notifyListeners();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      EasyLoading.dismiss();
      // ignore: avoid_print
      print("Google Sign-In Error: $e");
      // You might want to show an error message to the user here
    }
  }

  Future<void> _handleUserData(User user) async {
    UserModel userModel = UserModel(
      uId: user.uid,
      username: user.displayName ?? 'No Name',
      email: user.email ?? 'No Email',
      userDeviceToken: '',
      isAdmin: false,
      isActive: true,
      createdOn: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}

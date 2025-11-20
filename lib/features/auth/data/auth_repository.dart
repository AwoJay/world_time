import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      final currentUser = userCredential.user;
      if (currentUser == null) return null;

      return UserModel(uid: currentUser.uid, name: name, email: email);
    } catch (e, st) {
      debugPrint('signUp error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final currentUser = userCredential.user;
      if (currentUser == null) return null;

      return UserModel(
        uid: currentUser.uid,
        name: currentUser.displayName ?? '',
        email: currentUser.email ?? '',
        emailVerified: currentUser.emailVerified,
      );
    } catch (e, st) {
      debugPrint('signIn error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final currentUser = userCredential.user;
      if (currentUser == null) return null;

      return UserModel(
        uid: currentUser.uid,
        name: currentUser.displayName ?? '',
        email: currentUser.email ?? '',
        emailVerified: currentUser.emailVerified,
      );
    } catch (e, st) {
      debugPrint('Google sign-in error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}

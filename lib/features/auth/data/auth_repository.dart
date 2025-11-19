import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Email/password signup
  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      final currentUser = userCredential.user;
      if (currentUser == null) return null;

      return UserModel(uid: currentUser.uid, name: name, email: email);
    } catch (e) {
      print('signUp error: $e');
      return null;
    }
  }

  // Email/password sign in
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
      );
    } catch (e) {
      print('signIn error: $e');
      return null;
    }
  }

  // Google Sign-In
  // Future<UserModel?> signInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // user canceled
  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       idToken: googleAuth.idToken,
  //       accessToken: googleAuth.accessToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final currentUser = userCredential.user;
  //     if (currentUser == null) return null;

  //     return UserModel(
  //       uid: currentUser.uid,
  //       name: currentUser.displayName ?? '',
  //       email: currentUser.email ?? '',
  //     );
  //   } catch (e) {
  //     print('Google sign-in error: $e');
  //     return null;
  //   }
  // }

  Future<void> signOut() async {
    await _auth.signOut();
    // await _googleSignIn.signOut();
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

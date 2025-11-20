import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

// NotifierProvider using the new Riverpod approach
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<UserModel?>>(
      () => AuthController(),
    );

class AuthController extends Notifier<AsyncValue<UserModel?>> {
  late final AuthRepository repo;

  @override
  AsyncValue<UserModel?> build() {
    repo = AuthRepository();
    // Initialize with current Firebase user if exists
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return AsyncValue.data(
        UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          emailVerified: currentUser.emailVerified,
        ),
      );
    }
    return const AsyncValue.data(null); // initial state
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signUp(name, email, password));
    // Reload Firebase user to ensure state is fresh
    await FirebaseAuth.instance.currentUser?.reload();
    // Update state with fresh user data
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      state = AsyncValue.data(
        UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? name,
          email: currentUser.email ?? email,
          emailVerified: currentUser.emailVerified,
        ),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signIn(email, password));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signInWithGoogle());
  }

  Future<void> signOut() async {
    await repo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    await repo.resetPassword(email);
  }

  Future<void> sendEmailVerification() async {
    await repo.sendEmailVerification();
  }
}

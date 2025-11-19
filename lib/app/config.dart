import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/password_reset_page.dart';
import '../features/auth/presentation/verify_email_page.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AuthGate()),
    GoRoute(path: '/signup', builder: (_, __) => SignupPage()),
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    GoRoute(path: '/reset', builder: (_, __) => PasswordResetPage()),
    GoRoute(path: '/verify', builder: (_, __) => VerifyEmailPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && state.uri.toString() != '/signup') {
      return '/signup'; // redirect to signup if not logged in
    }

    if (user != null &&
        !user.emailVerified &&
        state.uri.toString() != '/verify') {
      return '/verify';
    }

    if (user != null && user.emailVerified && state.uri.toString() != '/home') {
      return '/home';
    }

    return null; // no redirect
  },
);

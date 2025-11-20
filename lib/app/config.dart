import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/password_reset_page.dart';
import '../features/auth/presentation/verify_email_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, _) => const SplashPage()),
    GoRoute(path: '/signup', builder: (context, _) => const SignupPage()),
    GoRoute(path: '/login', builder: (context, _) => const LoginPage()),
    GoRoute(path: '/reset', builder: (context, _) => const PasswordResetPage()),
    GoRoute(path: '/verify', builder: (context, _) => const VerifyEmailPage()),
    GoRoute(path: '/home', builder: (context, _) => const HomePage()),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final path = state.uri.toString();
    const publicPaths = {'/', '/signup', '/login', '/reset', '/verify'};

    // Allow splash screen and public paths - no redirect
    if (publicPaths.contains(path)) {
      return null;
    }

    // Redirect unauthenticated users to signup
    if (user == null && path != '/signup') {
      return '/signup';
    }

    // For unverified users, allow access to verify and login pages
    if (user != null && !user.emailVerified) {
      if (path == '/verify' || path == '/login') {
        return null; // Allow these paths
      }
      // Redirect to verify page for any other path
      return '/verify';
    }

    // Redirect verified users to home
    if (user != null && user.emailVerified && path != '/home') {
      return '/home';
    }

    return null; // no redirect
  },
);

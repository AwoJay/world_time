import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth_controller.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Timer? timer;
  bool sendingEmail = false;

  @override
  void initState() {
    super.initState();
    // Periodically check if the email is verified
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final fbUser = FirebaseAuth.instance.currentUser;
      await fbUser?.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        timer?.cancel(); // stop timer
        if (mounted) {
          // After verification, go to login page
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> resendEmail() async {
    setState(() => sendingEmail = true);
    await ref.read(authControllerProvider.notifier).sendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verification email sent!")));
      setState(() => sendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A verification link has been sent to your email. Please verify to continue.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            sendingEmail
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resendEmail,
                    child: const Text("Resend Email"),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text("I've verified my email. Continue to Login"),
            ),
          ],
        ),
      ),
    );
  }
}

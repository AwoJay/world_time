import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth_controller.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signUp(
                            nameCtrl.text.trim(),
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );

                      final currentState = ref.read(authControllerProvider);
                      currentState.whenOrNull(
                        data: (user) async {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Signup failed. Try again."),
                              ),
                            );
                          } else {
                            await ref
                                .read(authControllerProvider.notifier)
                                .sendEmailVerification();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Signup successful! Check your email to verify.",
                                  ),
                                ),
                              );
                              context.go('/verify');
                            }
                          }
                        },
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}

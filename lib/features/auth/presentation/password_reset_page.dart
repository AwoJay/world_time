import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth_controller.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final emailCtrl = TextEditingController();
  bool _sendingLink = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the email tied to your account.")),
      );
      return;
    }

    setState(() => _sendingLink = true);
    await ref.read(authControllerProvider.notifier).resetPassword(email);
    if (!mounted) return;
    setState(() => _sendingLink = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password reset link sent to $email")),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We'll email you a secure link to choose a new password.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendingLink ? null : _requestReset,
                child: _sendingLink
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send reset link"),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text("Back to login"),
            ),
          ],
        ),
      ),
    );
  }
}

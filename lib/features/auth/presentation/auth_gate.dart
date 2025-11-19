import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/auth_controller.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);

    return userAsync.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user == null) {
            GoRouter.of(context).go('/login'); // redirect to login if no user
          } else if (!user.emailVerified) {
            GoRouter.of(
              context,
            ).go('/verify'); // redirect to verify if not verified
          } else {
            GoRouter.of(context).go('/home'); // redirect to home if verified
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}

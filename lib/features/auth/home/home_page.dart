import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _cities = [
    _WorldCity(name: 'UTC', offsetHours: 0, region: 'Coordinated Universal'),
    _WorldCity(name: 'New York', offsetHours: -5, region: 'Eastern Time'),
    _WorldCity(name: 'London', offsetHours: 0, region: 'Greenwich Mean'),
    _WorldCity(name: 'Berlin', offsetHours: 1, region: 'Central European'),
    _WorldCity(name: 'Dubai', offsetHours: 4, region: 'Gulf Standard'),
    _WorldCity(name: 'Singapore', offsetHours: 8, region: 'Singapore Standard'),
    _WorldCity(name: 'Sydney', offsetHours: 10, region: 'Australian Eastern'),
  ];

  Timer? _ticker;
  DateTime _utcNow = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _utcNow = DateTime.now().toUtc();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.displayName ?? user.email ?? 'Signed-in user'),
                  subtitle: Text(user.email ?? 'No email on record'),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Global times',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _cities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final time = _utcNow.add(Duration(hours: city.offsetHours));

                  return ListTile(
                    title: Text(city.name),
                    subtitle: Text(city.region),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(time),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_formatDate(time)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatDate(DateTime time) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[time.month - 1];
    final day = time.day.toString().padLeft(2, '0');
    return '$month $day';
  }
}

class _WorldCity {
  final String name;
  final int offsetHours;
  final String region;

  const _WorldCity({
    required this.name,
    required this.offsetHours,
    required this.region,
  });
}

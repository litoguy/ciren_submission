import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Home', style: TextStyle(color: Colors.white, fontSize: 24)),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => context.go('/chat'),
        child: const Text('Go to Chat'),
      ),
    ])),
  );
}

import 'package:flutter/material.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Topics', style: TextStyle(color: Colors.white))),
  );
}

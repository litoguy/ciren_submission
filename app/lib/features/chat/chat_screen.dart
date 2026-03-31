import 'package:flutter/material.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text(
      'Chat${initialMessage != null ? ": $initialMessage" : ""}',
      style: const TextStyle(color: Colors.white),
    )),
  );
}

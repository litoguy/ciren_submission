import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/features/splash/splash_screen.dart';
import 'package:campus_ai/features/chat/chat_screen.dart';
import 'package:campus_ai/features/topics/topics_screen.dart';
import 'package:campus_ai/features/home/home_screen.dart';
import 'package:campus_ai/features/shell/scaffold_with_nav.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (_, __, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/topics', builder: (_, __) => const TopicsScreen()),
        GoRoute(
          path: '/chat',
          builder: (_, state) => ChatScreen(
            initialMessage: state.uri.queryParameters['message'],
          ),
        ),
      ],
    ),
  ],
);

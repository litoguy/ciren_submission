import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.app;
    return Scaffold(
      backgroundColor: c.background,
      body: Stack(children: [
        // Layer 1: Primary maroon glow — soft mist
        Positioned.fill(child: Container(decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3), radius: 1.0,
            colors: [
              c.glowColor,
              c.glowColor.withValues(alpha: c.glowColor.a * 0.55),
              c.glowColor.withValues(alpha: c.glowColor.a * 0.15),
              c.glowColor.withValues(alpha: c.glowColor.a * 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
          ),
        ))),
        // Layer 2: Gold warmth bloom (light mode only)
        if (c.glowColorTwo != Colors.transparent)
          Positioned.fill(child: Container(decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.3, 0.0), radius: 1.1,
              colors: [
                c.glowColorTwo,
                c.glowColorTwo.withValues(alpha: c.glowColorTwo.a * 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ))),
        // Center content
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/icon.png',
            width: 110,
            height: 110,
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.7, 0.7)),
          const SizedBox(height: 28),
          Text('Campus Mind',
            style: GoogleFonts.playfairDisplay(
              fontSize: 40, fontWeight: FontWeight.w700, color: c.textPrimary),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3),
          const SizedBox(height: 8),
          Text('Central University Ghana',
            style: GoogleFonts.dmSans(fontSize: 14, color: c.textSecondary),
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          const SizedBox(height: 4),
          Text('Your AI campus guide',
            style: GoogleFonts.dmSans(
              fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
        ])),
        // Bottom label
        Positioned(bottom: 40, left: 0, right: 0,
          child: Text('Powered by Google Gemini',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 11, color: c.textMuted),
          ).animate().fadeIn(delay: 1000.ms),
        ),
      ]),
    );
  }
}

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(children: [
      // Ambient maroon glow
      Positioned.fill(child: Container(decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2), radius: 0.75,
          colors: [Color(0x668B1A2B), Color(0x228B1A2B), Color(0x000F0205)],
        ),
      ))),
      // Center content
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // CU logo placeholder
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
          ),
          child: const Icon(Icons.school_rounded, color: AppColors.gold, size: 44),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.7, 0.7)),
        const SizedBox(height: 28),
        Text('CampusAI',
          style: GoogleFonts.playfairDisplay(
            fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3),
        const SizedBox(height: 8),
        Text('Central University Ghana',
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 4),
        Text('Your AI campus guide',
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
        ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
      ])),
      // Bottom label
      Positioned(bottom: 40, left: 0, right: 0,
        child: Text('Powered by Google Gemini',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
        ).animate().fadeIn(delay: 1000.ms),
      ),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/providers/topics_provider.dart';
import 'package:campus_ai/services/storage_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final name = StorageService.userName ?? 'Student';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Ambient glow
        Positioned(
          top: 0, left: 0, right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Container(decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3), radius: 0.75,
              colors: [Color(0x558B1A2B), Color(0x1A8B1A2B), Color(0x000F0205)],
            ),
          )),
        ),
        SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_greeting(),
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.textSecondary, fontSize: 22)),
                Text(name, style: GoogleFonts.playfairDisplay(
                  color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Your AI campus guide',
                  style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 13,
                    fontWeight: FontWeight.w500)),
              ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
            ),
            const Spacer(),
            // Bottom sheet content
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('QUICK TOPICS',
                      style: GoogleFonts.dmSans(color: AppColors.textMuted,
                        fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 12),
                  // Topics horizontal scroll
                  SizedBox(height: 90, child: topicsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
                    error: (_, __) => Center(
                      child: TextButton.icon(
                        onPressed: () => ref.invalidate(topicsProvider),
                        icon: const Icon(Icons.refresh, color: AppColors.gold, size: 18),
                        label: Text('Retry', style: GoogleFonts.dmSans(color: AppColors.gold)),
                      ),
                    ),
                    data: (topics) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: topics.length,
                      itemBuilder: (_, i) {
                        final t = topics[i];
                        return GestureDetector(
                          onTap: () => context.go(
                            '/chat?message=${Uri.encodeComponent(t.prompt)}'),
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.cardIcon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(t.icon, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(t.label, textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textSecondary, fontSize: 10),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              ]),
                          ),
                        );
                      },
                    ),
                  )),
                  // Input bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: GestureDetector(
                      onTap: () => context.go('/chat'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardIcon,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(children: [
                          Expanded(child: Text('Ask CampusAI anything...',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textMuted, fontSize: 14))),
                          Container(width: 36, height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.gold, shape: BoxShape.circle),
                            child: const Icon(Icons.mic, color: Colors.white, size: 18)),
                        ]),
                      ),
                    ),
                  ),
                ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

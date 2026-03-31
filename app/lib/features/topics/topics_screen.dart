import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/providers/topics_provider.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final faqsAsync  = ref.watch(faqsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Topics & FAQ',
          style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Topic grid
          Text('Quick Topics',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          topicsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Could not load topics. $e',
              style: GoogleFonts.dmSans(color: AppColors.error)),
            data: (topics) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.5,
                crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: topics.length,
              itemBuilder: (_, i) {
                final t = topics[i];
                return GestureDetector(
                  onTap: () => context.go('/chat?message=${Uri.encodeComponent(t.prompt)}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardIcon),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(t.label,
                          style: GoogleFonts.dmSans(color: AppColors.textPrimary,
                            fontSize: 12, fontWeight: FontWeight.w500)),
                      ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // FAQ list
          Text('Frequently Asked Questions',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          faqsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Could not load FAQs. $e',
              style: GoogleFonts.dmSans(color: AppColors.error)),
            data: (faqs) => Column(
              children: faqs.map((f) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.question,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.gold, size: 14),
                onTap: () => context.go('/chat?message=${Uri.encodeComponent(f.question)}'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

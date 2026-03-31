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
        surfaceTintColor: Colors.transparent,
        title: Text('Topics & FAQ',
          style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Topic grid
          Text('QUICK TOPICS',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          topicsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
              ),
            ),
            error: (e, _) => _ErrorRetry(
              message: 'Could not load topics',
              onRetry: () => ref.invalidate(topicsProvider),
            ),
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
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: AppColors.primary.withOpacity(0.15),
                    onTap: () => context.go('/chat?message=${Uri.encodeComponent(t.prompt)}'),
                    child: Container(
                      decoration: BoxDecoration(
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
                              fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // FAQ list
          Text('FREQUENTLY ASKED',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          faqsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
              ),
            ),
            error: (e, _) => _ErrorRetry(
              message: 'Could not load FAQs',
              onRetry: () => ref.invalidate(faqsProvider),
            ),
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

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(children: [
      const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 32),
      const SizedBox(height: 8),
      Text(message, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, color: AppColors.gold, size: 18),
        label: Text('Retry', style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 13)),
      ),
    ]),
  );
}

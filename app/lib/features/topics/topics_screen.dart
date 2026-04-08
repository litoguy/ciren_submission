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
    final c = context.app;
    final topicsAsync = ref.watch(topicsProvider);
    final faqsAsync  = ref.watch(faqsProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('Topics & FAQ',
          style: GoogleFonts.playfairDisplay(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('QUICK TOPICS',
            style: GoogleFonts.dmSans(color: c.textMuted,
              fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          topicsAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            )),
            error: (_, __) => _ErrorRetry(
              message: 'Could not load topics',
              onRetry: () => ref.invalidate(topicsProvider),
              c: c,
            ),
            data: (topics) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.3,
                crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: topics.length,
              itemBuilder: (_, i) {
                final t = topics[i];
                return Material(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    splashColor: AppColors.primary.withValues(alpha: 0.12),
                    onTap: () => context.go(
                      '/chat?message=${Uri.encodeComponent(t.prompt)}'),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border, width: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: c.cardIcon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(t.icon,
                                style: const TextStyle(fontSize: 24),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(t.label,
                              style: GoogleFonts.dmSans(color: c.textPrimary,
                                fontSize: 12, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('FREQUENTLY ASKED',
            style: GoogleFonts.dmSans(color: c.textMuted,
              fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          faqsAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            )),
            error: (_, __) => _ErrorRetry(
              message: 'Could not load FAQs',
              onRetry: () => ref.invalidate(faqsProvider),
              c: c,
            ),
            data: (faqs) => Column(
              children: faqs.map((f) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.question,
                  style: GoogleFonts.dmSans(color: c.textPrimary, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.gold, size: 14),
                onTap: () => context.go(
                  '/chat?message=${Uri.encodeComponent(f.question)}'),
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
  final AppColorScheme c;
  const _ErrorRetry({required this.message, required this.onRetry, required this.c});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(children: [
      Icon(Icons.cloud_off_rounded, color: c.textMuted, size: 32),
      const SizedBox(height: 8),
      Text(message, style: GoogleFonts.dmSans(color: c.textSecondary, fontSize: 13)),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, color: AppColors.gold, size: 18),
        label: Text('Retry',
          style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 13)),
      ),
    ]),
  );
}

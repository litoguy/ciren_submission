import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/providers/topics_provider.dart';
import 'package:campus_ai/services/storage_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _liveText = '';

  // Pulse animation controller for the mic button while listening
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (_) => _stopListening(navigate: false),
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      // Speech not available — fall back to chat screen
      context.go('/chat');
      return;
    }

    if (_isListening) {
      await _stopListening(navigate: true);
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _liveText = '';
    });
    _pulseCtrl.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        setState(() => _liveText = result.recognizedWords);
        if (result.finalResult && _liveText.trim().isNotEmpty) {
          _stopListening(navigate: true);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(cancelOnError: true),
    );
  }

  Future<void> _stopListening({required bool navigate}) async {
    await _speech.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();

    final text = _liveText.trim();
    if (mounted) setState(() => _isListening = false);

    if (!mounted) return;
    if (navigate && text.isNotEmpty) {
      context.go('/chat?message=${Uri.encodeComponent(text)}');
    } else if (navigate) {
      context.go('/chat');
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.app;
    final topicsAsync = ref.watch(topicsProvider);
    final name = StorageService.userName ?? 'Student';

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(children: [
        // Layer 1: Primary glow
        Positioned(
          top: 0, left: 0, right: 0,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Container(decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.7),
              radius: 1.1,
              colors: [
                c.glowColor,
                c.glowColor.withValues(alpha: c.glowColor.a * 0.6),
                c.glowColor.withValues(alpha: c.glowColor.a * 0.2),
                c.glowColor.withValues(alpha: c.glowColor.a * 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
            ),
          )),
        ),
        // Layer 2: Gold warmth bloom (light mode only)
        if (c.glowColorTwo != Colors.transparent)
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.3, -0.4),
                radius: 1.2,
                colors: [
                  c.glowColorTwo,
                  c.glowColorTwo.withValues(alpha: c.glowColorTwo.a * 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
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
                    color: c.textSecondary, fontSize: 22)),
                Text(name, style: GoogleFonts.playfairDisplay(
                  color: c.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Your AI campus guide',
                  style: GoogleFonts.dmSans(color: AppColors.gold,
                    fontSize: 13, fontWeight: FontWeight.w500)),
              ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
            ),
            const Spacer(),

            // Bottom sheet
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: c.border, width: 0.5)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('QUICK TOPICS',
                    style: GoogleFonts.dmSans(color: c.textMuted,
                      fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500))),
                const SizedBox(height: 12),
                SizedBox(height: 90, child: topicsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
                  error: (_, __) => Center(
                    child: TextButton.icon(
                      onPressed: () => ref.invalidate(topicsProvider),
                      icon: const Icon(Icons.refresh, color: AppColors.gold, size: 18),
                      label: Text('Retry',
                        style: GoogleFonts.dmSans(color: AppColors.gold)),
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
                            color: c.cardIcon,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border, width: 0.5),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.icon, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(t.label, textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: c.textSecondary, fontSize: 10),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            ]),
                        ),
                      );
                    },
                  ),
                )),
                // Input bar + mic button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(children: [
                    // Tapping the text field goes to chat
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/chat'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: c.cardIcon,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: c.border, width: 0.5),
                          ),
                          child: Text(
                            _isListening
                              ? (_liveText.isEmpty
                                  ? 'Listening...'
                                  : _liveText)
                              : 'Ask Campus Mind anything...',
                            style: GoogleFonts.dmSans(
                              color: _isListening && _liveText.isNotEmpty
                                ? c.textPrimary
                                : c.textMuted,
                              fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Mic button — pulses while listening
                    GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, child) {
                          final scale = _isListening
                            ? 1.0 + _pulseCtrl.value * 0.18
                            : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _isListening
                              ? AppColors.primary
                              : AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

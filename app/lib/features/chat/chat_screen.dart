import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/models/chat_message.dart';
import 'package:campus_ai/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});
  @override ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).send(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.app;
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('Campus Mind',
          style: GoogleFonts.playfairDisplay(fontSize: 18)),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: c.textMuted),
              onPressed: () => ref.read(chatProvider.notifier).clear(),
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: SafeArea(child: Column(children: [
        Expanded(
          child: messages.isEmpty
            ? _EmptyState(c: c)
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == messages.length) return const _TypingIndicator();
                  return _MessageBubble(message: messages[i], isFirst: i == 1, c: c);
                },
              ),
        ),
        _InputRow(controller: _controller, onSend: _send, c: c),
      ])),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColorScheme c;
  const _EmptyState({required this.c});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/icon.png', width: 90, height: 90),
        const SizedBox(height: 20),
        Text('Ask Campus Mind',
          style: GoogleFonts.playfairDisplay(
            color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('I can help with fees, registration,\nexams, campus life, and more.',
          style: GoogleFonts.dmSans(color: c.textMuted, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFirst;
  final AppColorScheme c;
  const _MessageBubble({required this.message, required this.c, this.isFirst = false});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final bubbleColor = isUser ? AppColors.primary : c.surface;
    final textColor   = isUser ? Colors.white : c.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              border: isUser ? null : Border.all(color: c.border, width: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            // SelectionArea makes all text inside long-pressable / selectable
            child: SelectionArea(
              child: isUser
                // User messages: plain selectable text
                ? Text(message.text,
                    style: GoogleFonts.dmSans(
                      color: textColor, fontSize: 14, height: 1.5))
                // Bot messages: full markdown rendering with link support
                : MarkdownBody(
                    data: message.text,
                    selectable: false, // SelectionArea handles this
                    styleSheet: MarkdownStyleSheet(
                      p:          GoogleFonts.dmSans(color: textColor, fontSize: 14, height: 1.55),
                      strong:     GoogleFonts.dmSans(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                      em:         GoogleFonts.dmSans(color: textColor, fontSize: 14, fontStyle: FontStyle.italic),
                      code:       GoogleFonts.sourceCodePro(color: AppColors.gold, fontSize: 12,
                                    backgroundColor: c.cardIcon),
                      codeblockDecoration: BoxDecoration(
                        color: c.cardIcon,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      listBullet: GoogleFonts.dmSans(color: textColor, fontSize: 14),
                      blockquote: GoogleFonts.dmSans(color: c.textSecondary, fontSize: 14, fontStyle: FontStyle.italic),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
                      ),
                      a:          GoogleFonts.dmSans(
                                    color: AppColors.gold,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.gold),
                      h1:         GoogleFonts.playfairDisplay(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
                      h2:         GoogleFonts.playfairDisplay(color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
                      h3:         GoogleFonts.dmSans(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onTapLink: (text, url, title) {
                      if (url != null) _launchUrl(url);
                    },
                  ),
            ),
          ),
          if (!isUser && isFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text('Please verify important details with the relevant office.',
                style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: List.generate(3, (i) => AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = ((_ctrl.value + i * 0.33) % 1.0);
        final scale = 0.6 + 0.4 * (v < 0.5 ? v * 2 : (1 - v) * 2);
        return Container(
          width: 8, height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          transform: Matrix4.diagonal3Values(scale, scale, 1),
          decoration: const BoxDecoration(
            color: AppColors.gold, shape: BoxShape.circle),
        );
      },
    ))),
  );
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AppColorScheme c;
  const _InputRow({required this.controller, required this.onSend, required this.c});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(
      color: c.surface,
      border: Border(top: BorderSide(color: c.border, width: 0.5)),
    ),
    child: Row(children: [
      Expanded(child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(color: c.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ask about fees, exams, registration...',
          hintStyle: GoogleFonts.dmSans(color: c.textMuted, fontSize: 13),
          filled: true,
          fillColor: c.cardIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (_) => onSend(),
        textInputAction: TextInputAction.send,
      )),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: onSend,
        child: Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          child: const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    ]),
  );
}

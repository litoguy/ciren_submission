import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // If launched from a topic/FAQ, send the pre-filled message
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).send(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

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
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);

    // Auto-scroll when messages change
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('CampusAI',
          style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.read(chatProvider.notifier).clear(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(children: [
        // Messages list
        Expanded(
          child: messages.isEmpty
            ? Center(child: Text(
                'Ask me anything about Central University',
                style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ))
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == messages.length) return const _TypingIndicator();
                  return _MessageBubble(message: messages[i], isFirst: i == 1);
                },
              ),
        ),
        // Input row
        _InputRow(controller: _controller, onSend: _send),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFirst;
  const _MessageBubble({required this.message, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Text(message.text,
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
          ),
          // "Verify with office" disclaimer under first bot response only
          if (!isUser && isFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text('Please verify important details with the relevant office.',
                style: GoogleFonts.dmSans(
                  color: AppColors.gold, fontSize: 11)),
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
  Widget build(BuildContext context) {
    return Padding(
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
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputRow({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.cardIcon)),
    ),
    child: Row(children: [
      Expanded(child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Ask about fees, exams, registration...',
          hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cardIcon,
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

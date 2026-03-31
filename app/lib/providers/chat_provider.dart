import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/chat_message.dart';
import 'package:campus_ai/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final isLoadingProvider = StateProvider<bool>((ref) => false);

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read(apiServiceProvider), ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ApiService _api;
  final Ref _ref;

  ChatNotifier(this._api, this._ref) : super([]);

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    state = [
      ...state,
      ChatMessage(text: text.trim(), role: MessageRole.user, timestamp: DateTime.now()),
    ];

    _ref.read(isLoadingProvider.notifier).state = true;

    try {
      final response = await _api.chat(text.trim());
      state = [
        ...state,
        ChatMessage(
          text: response.reply,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ];
    } on ApiException catch (e) {
      state = [
        ...state,
        ChatMessage(
          text: 'Error: ${e.message}',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ];
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> clear() async {
    await _api.clearHistory();
    state = [];
  }
}

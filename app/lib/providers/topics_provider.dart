import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/topic.dart';
import 'package:campus_ai/providers/chat_provider.dart';

// FutureProvider automatically handles loading/error states
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return ref.read(apiServiceProvider).getTopics();
});

final faqsProvider = FutureProvider<List<Faq>>((ref) async {
  return ref.read(apiServiceProvider).getFaqs();
});

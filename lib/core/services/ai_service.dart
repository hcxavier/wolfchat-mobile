import 'package:wolfchat/features/home/models/chat_message.dart';

abstract class AiService {
  String get apiKey;

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  });

  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  });

  Future<String?> generateTitle(String content);

  void cancel();
}

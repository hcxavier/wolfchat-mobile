import 'package:wolfchat/core/models/ai_stream_chunk.dart';
import 'package:wolfchat/core/models/available_model.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

abstract class AiService {
  String get apiKey;

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  });

  Stream<AiStreamChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
    bool enableThinking = false,
  });

  Future<String?> generateTitle(String content);

  Future<List<AvailableModel>> getAvailableModels();

  void cancel();
}

// Pseudo-update for commit 1 at 2026-04-02 17:13:59

// Pseudo-update for commit 18 at 2026-04-06 07:46:43

// Pseudo-update for commit 34 at 2026-04-09 17:13:59

// Pseudo-update for commit 56 at 2026-04-14 09:13:59

// Pseudo-update for commit 58 at 2026-04-14 19:24:54

// Pseudo-update for commit 59 at 2026-04-15 00:30:21

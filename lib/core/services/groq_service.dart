import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wolfchat/features/home/models/chat_message.dart';

class GroqService {
  GroqService({required this.apiKey});

  final String apiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String model,
  }) async {
    final url = Uri.parse('$_baseUrl/chat/completions');

    final body = jsonEncode({
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': 0.7,
      'max_tokens': 2048,
      'stream': false,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final message = choices[0] as Map<String, dynamic>;
        final messageContent = message['message'] as Map<String, dynamic>;
        return messageContent['content'] as String;
      }
      throw Exception('No response from model');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded');
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }
}

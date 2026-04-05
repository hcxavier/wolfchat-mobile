import 'dart:async' as dart_async;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wolfchat/core/exceptions/app_exceptions.dart';
import 'package:wolfchat/core/models/available_model.dart';
import 'package:wolfchat/core/services/ai_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class GroqService implements AiService {
  GroqService({required this.apiKey});

  @override
  final String apiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  final _cancelCompleter = dart_async.Completer<void>();

  @override
  void cancel() {
    if (!_cancelCompleter.isCompleted) {
      _cancelCompleter.complete();
    }
  }

  @override
  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async {
    final url = Uri.parse('$_baseUrl/chat/completions');

    final allMessages = <Map<String, dynamic>>[];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      allMessages.add({'role': 'system', 'content': systemPrompt});
    }
    allMessages.addAll(messages.map((m) => m.toJson()).toList());

    final body = jsonEncode({
      'model': model,
      'messages': allMessages,
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
      throw const ModelException('A IA não retornou uma resposta.');
    } else if (response.statusCode == 401) {
      throw const AuthException(
        'Sua chave de API é inválida. Verifique-a nas configurações.',
      );
    } else if (response.statusCode == 429) {
      throw const RateLimitException(
        'Você excedeu o limite de requisições. '
        'Aguarde um momento e tente novamente.',
      );
    } else if (response.statusCode >= 500) {
      throw const ServerException(
        'O servidor está com problemas. Tente novamente em instantes.',
      );
    } else {
      throw ServerException(
        'Erro na comunicação com o servidor (${response.statusCode}).',
      );
    }
  }

  @override
  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async* {
    final url = Uri.parse('$_baseUrl/chat/completions');

    final allMessages = <Map<String, dynamic>>[];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      allMessages.add({'role': 'system', 'content': systemPrompt});
    }
    allMessages.addAll(messages.map((m) => m.toJson()).toList());

    final body = jsonEncode({
      'model': model,
      'messages': allMessages,
      'temperature': 0.7,
      'max_tokens': 2048,
      'stream': true,
    });

    final request = http.Request('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      })
      ..body = body;

    final client = http.Client();
    final response = await client.send(request);

    if (response.statusCode == 200) {
      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (_cancelCompleter.isCompleted) break;
        if (line.isEmpty) continue;
        if (line == 'data: [DONE]') break;

        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>;
          if (choices.isNotEmpty) {
            final choice = choices[0] as Map<String, dynamic>;
            final delta = choice['delta'] as Map<String, dynamic>;
            final content = delta['content'] as String?;
            if (content != null) {
              yield content;
            }
          }
        }
      }
    } else {
      await response.stream.bytesToString();
      if (response.statusCode == 401) {
        throw const AuthException(
          'Sua chave de API é inválida. '
          'Verifique-a nas configurações.',
        );
      } else if (response.statusCode == 429) {
        throw const RateLimitException(
          'Você excedeu o limite de requisições. '
          'Aguarde um momento e tente novamente.',
        );
      }
      throw ServerException(
        'Erro no streaming da resposta: '
        '${response.statusCode}.',
      );
    }
  }

  @override
  Future<List<AvailableModel>> getAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/models');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = data['data'] as List<dynamic>;
        return models
            .map(
              (model) => AvailableModel.fromJson(model as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        throw const AuthException(
          'Sua chave de API é inválida. Verifique-a nas configurações.',
        );
      } else if (response.statusCode == 429) {
        throw const RateLimitException(
          'Você excedeu o limite de requisições. '
          'Aguarde um momento e tente novamente.',
        );
      } else if (response.statusCode >= 500) {
        throw const ServerException(
          'O servidor está com problemas. Tente novamente em instantes.',
        );
      } else {
        throw ServerException(
          'Erro ao buscar modelos (${response.statusCode}).',
        );
      }
    } on dart_async.TimeoutException {
      throw const TimeoutException(
        'A conexão demorou muito. '
        'Verifique sua internet e tente novamente.',
      );
    } on AppException {
      rethrow;
    } on Exception catch (_) {
      throw const NetworkException(
        'Não foi possível conectar ao servidor. '
        'Verifique sua conexão com a internet.',
      );
    }
  }

  @override
  Future<String?> generateTitle(String content) async {
    final title = await _generateTitleWithModel(
      content,
      'llama-3.1-8b-instant',
    );

    if (title != null) return title;

    return content.length > 20 ? '${content.substring(0, 17)}...' : content;
  }

  Future<String?> _generateTitleWithModel(String content, String model) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/completions');

      final body = jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'Forneça um título curto (máximo 20 caracteres) para '
                'esta conversa com base na mensagem. Seja direto e '
                'não use aspas ou pontos finais.',
          },
          {'role': 'user', 'content': content},
        ],
        'temperature': 0.5,
        'max_tokens': 20,
      });

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices[0] as Map<String, dynamic>;
          final messageContent = message['message'] as Map<String, dynamic>;
          var title = messageContent['content'] as String;
          title = title.trim().replaceAll('"', '').replaceAll('.', '');
          if (title.length > 20) {
            title = '${title.substring(0, 17)}...';
          }
          return title;
        }
      }
    } on Exception catch (e) {
      debugPrint('Erro ao gerar título com modelo $model: $e');
    }
    return null;
  }
}

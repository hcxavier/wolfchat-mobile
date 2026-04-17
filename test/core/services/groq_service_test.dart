import 'package:flutter_test/flutter_test.dart';
import 'package:wolfchat/core/services/groq_service.dart';

void main() {
  group('GroqService - Filtro de modelos de chat', () {
    late GroqService service;
    setUp(() {
      service = GroqService(apiKey: 'test_api_key');
    });
    test('deve retornar true para modelos de chat válidos', () {
      expect(service.isLikelyChatModelId('llama-3.1-70b-instant'), isTrue);
      expect(service.isLikelyChatModelId('mixtral-8x7b-32768'), isTrue);
      expect(service.isLikelyChatModelId('gemma-7b-it'), isTrue);
      expect(service.isLikelyChatModelId('llama3-70b'), isTrue);
    });
    test('deve retornar false para modelos de áudio/transcrição', () {
      expect(service.isLikelyChatModelId('whisper-large-v3'), isFalse);
      expect(service.isLikelyChatModelId('whisper-1'), isFalse);
      expect(service.isLikelyChatModelId('distil-whisper'), isFalse);
    });
    test('deve retornar false para modelos de TTS/speech', () {
      expect(service.isLikelyChatModelId('play-tts'), isFalse);
      expect(service.isLikelyChatModelId('speech-1'), isFalse);
      expect(service.isLikelyChatModelId('tts-1-hd'), isFalse);
    });
    test('deve retornar false para modelos de embedding', () {
      expect(service.isLikelyChatModelId('embedding-english-v2'), isFalse);
      expect(service.isLikelyChatModelId('embed-multilingual'), isFalse);
    });
    test('deve retornar false para modelos de moderação/guard', () {
      expect(service.isLikelyChatModelId('guard-1'), isFalse);
      expect(service.isLikelyChatModelId('llama-guard'), isFalse);
    });
    test('deve ser case insensitive', () {
      expect(service.isLikelyChatModelId('WHISPER-LARGE-V3'), isFalse);
      expect(service.isLikelyChatModelId('Llama-3.1-70b-Instant'), isTrue);
    });
  });
}

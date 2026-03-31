import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ConversationViewModel extends ChangeNotifier {
  ConversationViewModel({
    required PersistenceService? persistence,
    required String groqKey,
    required String Function() getSelectedModelId,
  }) : _persistence = persistence,
       _groqKey = groqKey,
       _getSelectedModelId = getSelectedModelId;

  PersistenceService? _persistence;
  String _groqKey;
  final String Function() _getSelectedModelId;

  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
  String? _errorMessage;
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get currentConversation => _currentConversation;

  // ignore: use_setters_to_change_properties - method naming is clearer for this use case
  void updateGroqKey(String key) {
    _groqKey = key;
  }

  // ignore: use_setters_to_change_properties - method naming is clearer for this use case
  void setPersistence(PersistenceService? persistence) {
    _persistence = persistence;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  String _getLanguageCode(String language) {
    final languageMap = {
      'Português (Brasil)': 'PT-BR',
      'English': 'EN-US',
      'Español': 'ES-ES',
      'Français': 'FR-FR',
      'Deutsch': 'DE-DE',
      '日本語': 'JA-JP',
      '中文': 'ZH-CN',
    };
    return languageMap[language] ?? 'PT-BR';
  }

  Future<void> loadConversations() async {
    if (_persistence != null) {
      _conversations = await _persistence!.getAllConversations();
      notifyListeners();
    }
  }

  Future<void> createNewConversation() async {
    _currentConversation = null;
    _messages.clear();
    _errorMessage = null;

    if (_persistence != null) {
      _currentConversation = await _persistence!.createConversation(
        'Nova conversa',
        modelId: _getSelectedModelId(),
      );
      _conversations = await _persistence!.getAllConversations();
    }

    notifyListeners();
  }

  Future<void> loadConversation(int conversationId) async {
    if (_persistence == null) return;

    _currentConversation = await _persistence!.getConversation(conversationId);
    if (_currentConversation != null) {
      final messages = await _persistence!.getMessages(conversationId);
      _messages.clear();
      for (final msg in messages) {
        _messages.add(
          ChatMessage(
            role: msg.role,
            content: msg.content,
            timestamp: msg.timestamp,
          ),
        );
      }
    }

    notifyListeners();
  }

  Future<void> deleteConversation(int conversationId) async {
    if (_persistence == null) return;

    await _persistence!.deleteConversation(conversationId);
    _conversations = await _persistence!.getAllConversations();

    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
      _messages.clear();
    }

    notifyListeners();
  }

  Future<void> deleteAllConversations() async {
    if (_persistence == null) return;

    await _persistence!.deleteAllConversations();
    _conversations = [];
    _currentConversation = null;
    _messages.clear();

    notifyListeners();
  }

  Future<void> sendMessage(String content, {String? language}) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    _errorMessage = null;
    _isSendingMessage = true;
    notifyListeners();

    // Apenas prefixamos a primeira mensagem da conversa para definir o idioma
    final isFirstMessage = _messages.isEmpty;
    final String apiContent;
    
    if (isFirstMessage && language != null) {
      apiContent =
          'Idioma: ${_getLanguageCode(language)}; User: ${content.trim()}';
    } else {
      apiContent = content.trim();
    }

    final userMessage = ChatMessage(
      role: 'user',
      content: content.trim(), // O que aparece no balão (limpo)
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    try {
      if (_groqKey.isEmpty) {
        throw Exception('API key do Groq não configurada');
      }

      final groqService = GroqService(apiKey: _groqKey);

      // Garante que a conversa existe e salva a mensagem imediatamente
      if (_persistence != null) {
        if (_currentConversation == null) {
          _currentConversation = await _persistence!.createConversation(
            'Nova conversa',
            modelId: _getSelectedModelId(),
          );
          _conversations = await _persistence!.getAllConversations();
        }

        await _persistence!.addMessage(
          _currentConversation!.id,
          'user',
          content.trim(),
        );
      }

      notifyListeners();

      // Gera o título se for a 1ª mensagem (sem bloquear o resto)
      if (isFirstMessage && _persistence != null) {
        unawaited(groqService.generateTitle(content.trim()).then((title) async {
          if (_currentConversation != null) {
            _currentConversation = _currentConversation!.copyWith(
              title: title,
              updatedAt: DateTime.now(),
            );
            await _persistence!.updateConversation(_currentConversation!);
            _conversations = await _persistence!.getAllConversations();
            notifyListeners();
          }
        }).catchError((Object e) {
          debugPrint('Erro ao gerar título: $e');
        }));
      }

      final modelId = _getSelectedModelId();

      // Criamos uma lista temporária para a API
      // com o conteúdo prefixado se for a 1ª mensagem
      final apiMessages = List<ChatMessage>.from(_messages);
      if (isFirstMessage) {
        apiMessages[0] = ChatMessage(
          role: 'user',
          content: apiContent,
          timestamp: userMessage.timestamp,
        );
      }

      final assistantResponse = await groqService.sendMessage(
        messages: apiMessages,
        model: modelId,
      );

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: assistantResponse,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);

      if (_currentConversation != null && _persistence != null) {
        await _persistence!.addMessage(
          _currentConversation!.id,
          'assistant',
          assistantResponse,
        );
        _conversations = await _persistence!.getAllConversations();
      }
    } on Exception catch (e) {
      _errorMessage = e.toString();
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: 'Erro: $e',
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }
}

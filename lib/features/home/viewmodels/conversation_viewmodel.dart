import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/services/ai_service.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/core/services/open_code_zen_service.dart';
import 'package:wolfchat/core/services/open_router_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ConversationViewModel extends ChangeNotifier {
  ConversationViewModel({
    required PersistenceService? persistence,
    required String groqKey,
    required String openRouterKey,
    required String openCodeZenKey,
    required String Function() getSelectedModelId,
    required String Function() getSelectedModelProvider,
  }) : _persistence = persistence,
       _groqKey = groqKey,
       _openRouterKey = openRouterKey,
       _openCodeZenKey = openCodeZenKey,
       _getSelectedModelId = getSelectedModelId,
       _getSelectedModelProvider = getSelectedModelProvider;

  PersistenceService? _persistence;
  String _groqKey;
  String _openRouterKey;
  String _openCodeZenKey;
  final String Function() _getSelectedModelId;
  final String Function() _getSelectedModelProvider;

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

  void updateGroqKey(String key) {
    _groqKey = key;
  }

  void updateOpenRouterKey(String key) {
    _openRouterKey = key;
  }

  void updateOpenCodeZenKey(String key) {
    _openCodeZenKey = key;
  }

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

  AiService _createService(String provider) {
    switch (provider) {
      case 'OpenRouter':
        return OpenRouterService(apiKey: _openRouterKey);
      case 'OpenCode Zen':
        return OpenCodeZenService(apiKey: _openCodeZenKey);
      case 'Groq':
      default:
        return GroqService(apiKey: _groqKey);
    }
  }

  String _getApiKeyForProvider(String provider) {
    switch (provider) {
      case 'OpenRouter':
        return _openRouterKey;
      case 'OpenCode Zen':
        return _openCodeZenKey;
      case 'Groq':
      default:
        return _groqKey;
    }
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'OpenRouter':
        return 'OpenRouter';
      case 'OpenCode Zen':
        return 'OpenCode Zen';
      case 'Groq':
      default:
        return 'Groq';
    }
  }

  Future<void> sendMessage(String content, {String? language}) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    _errorMessage = null;
    _isSendingMessage = true;
    notifyListeners();

    final userMessage = ChatMessage(
      role: 'user',
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    try {
      final provider = _getSelectedModelProvider();
      final apiKey = _getApiKeyForProvider(provider);

      if (apiKey.isEmpty) {
        throw Exception(
          'API key do $_getProviderName(provider) não configurada',
        );
      }

      final service = _createService(provider);

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

      final modelId = _getSelectedModelId();

      final assistantBuffer = StringBuffer();
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: '',
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();

      final stream = service.sendMessageStream(
        messages: _messages,
        model: modelId,
      );

      await for (final chunk in stream) {
        assistantBuffer.write(chunk);
        _messages[_messages.length - 1] = assistantMessage.copyWith(
          content: assistantBuffer.toString(),
        );
        notifyListeners();
      }

      if (_currentConversation != null && _persistence != null) {
        await _persistence!.addMessage(
          _currentConversation!.id,
          'assistant',
          assistantBuffer.toString(),
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

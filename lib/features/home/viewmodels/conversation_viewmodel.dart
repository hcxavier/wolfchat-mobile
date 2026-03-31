import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/constants/system_prompts.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/services/ai_service.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/core/services/open_code_zen_service.dart';
import 'package:wolfchat/core/services/open_router_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ConversationViewModel extends ChangeNotifier {
  ConversationViewModel({
    required this.persistence,
    required this.groqKey,
    required this.openRouterKey,
    required this.openCodeZenKey,
    required String Function() getSelectedModelId,
    required String Function() getSelectedModelName,
    required String Function() getSelectedModelProvider,
  }) : _getSelectedModelId = getSelectedModelId,
       _getSelectedModelName = getSelectedModelName,
       _getSelectedModelProvider = getSelectedModelProvider;

  PersistenceService? persistence;
  String groqKey;
  String openRouterKey;
  String openCodeZenKey;
  final String Function() _getSelectedModelId;
  final String Function() _getSelectedModelName;
  final String Function() _getSelectedModelProvider;

  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
  String? _errorMessage;
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  AiService? _currentService;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get currentConversation => _currentConversation;

  void cancelCurrentRequest() {
    _currentService?.cancel();
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
    if (persistence != null) {
      _conversations = await persistence!.getAllConversations();
      notifyListeners();
    }
  }

  Future<void> createNewConversation() async {
    _currentConversation = null;
    _messages.clear();
    _errorMessage = null;

    if (persistence != null) {
      _currentConversation = await persistence!.createConversation(
        'Nova conversa',
        modelId: _getSelectedModelId(),
      );
      _conversations = await persistence!.getAllConversations();
    }

    notifyListeners();
  }

  Future<void> loadConversation(int conversationId) async {
    if (persistence == null) return;

    _currentConversation = await persistence!.getConversation(conversationId);
    if (_currentConversation != null) {
      final messages = await persistence!.getMessages(conversationId);
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
    if (persistence == null) return;

    await persistence!.deleteConversation(conversationId);
    _conversations = await persistence!.getAllConversations();

    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
      _messages.clear();
    }

    notifyListeners();
  }

  Future<void> deleteAllConversations() async {
    if (persistence == null) return;

    await persistence!.deleteAllConversations();
    _conversations = [];
    _currentConversation = null;
    _messages.clear();

    notifyListeners();
  }

  AiService _createService(String provider) {
    switch (provider) {
      case 'OpenRouter':
        return OpenRouterService(apiKey: openRouterKey);
      case 'OpenCode Zen':
        return OpenCodeZenService(apiKey: openCodeZenKey);
      case 'Groq':
      default:
        return GroqService(apiKey: groqKey);
    }
  }

  String _getApiKeyForProvider(String provider) {
    switch (provider) {
      case 'OpenRouter':
        return openRouterKey;
      case 'OpenCode Zen':
        return openCodeZenKey;
      case 'Groq':
      default:
        return groqKey;
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

  Future<void> retryLastMessage({String? language}) async {
    if (_isSendingMessage || _messages.length < 2) return;

    final lastMessage = _messages.last;
    if (lastMessage.role != 'assistant') return;

    _messages.removeLast();
    notifyListeners();

    final lastUserMessage = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () =>
          ChatMessage(role: '', content: '', timestamp: DateTime.now()),
    );

    if (lastUserMessage.content.isEmpty) return;

    await _sendToAI(lastUserMessage.content, language: language);
  }

  Future<void> _sendToAI(String content, {String? language}) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    _errorMessage = null;
    _isSendingMessage = true;
    notifyListeners();

    try {
      final provider = _getSelectedModelProvider();
      final apiKey = _getApiKeyForProvider(provider);

      if (apiKey.isEmpty) {
        throw Exception(
          'API key do $_getProviderName(provider) não configurada',
        );
      }

      final service = _createService(provider);
      _currentService = service;

      final modelId = _getSelectedModelId();
      final modelName = _getSelectedModelName();
      final systemPrompt = buildSystemPrompt(
        modelName,
        language ?? 'Português (Brasil)',
      );

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
        systemPrompt: systemPrompt,
      );

      notifyListeners();

      await for (final chunk in stream) {
        assistantBuffer.write(chunk);
        _messages[_messages.length - 1] = assistantMessage.copyWith(
          content: assistantBuffer.toString(),
        );
      }

      notifyListeners();

      if (_currentConversation != null && persistence != null) {
        await persistence!.addMessage(
          _currentConversation!.id,
          'assistant',
          assistantBuffer.toString(),
        );
        _conversations = await persistence!.getAllConversations();
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
      _currentService = service;

      if (persistence != null) {
        if (_currentConversation == null) {
          _currentConversation = await persistence!.createConversation(
            content.trim(),
            modelId: _getSelectedModelId(),
          );
          _conversations = await persistence!.getAllConversations();
        } else if (_currentConversation!.title == 'Nova conversa') {
          _currentConversation = _currentConversation!.copyWith(
            title: content.trim(),
          );
          await persistence!.updateConversation(_currentConversation!);
          _conversations = await persistence!.getAllConversations();
        }

        await persistence!.addMessage(
          _currentConversation!.id,
          'user',
          content.trim(),
        );
      }

      notifyListeners();

      final modelId = _getSelectedModelId();
      final modelName = _getSelectedModelName();
      final systemPrompt = buildSystemPrompt(
        modelName,
        language ?? 'Português (Brasil)',
      );

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
        systemPrompt: systemPrompt,
      );

      notifyListeners();

      await for (final chunk in stream) {
        assistantBuffer.write(chunk);
        _messages[_messages.length - 1] = assistantMessage.copyWith(
          content: assistantBuffer.toString(),
        );
      }

      notifyListeners();

      if (_currentConversation != null && persistence != null) {
        await persistence!.addMessage(
          _currentConversation!.id,
          'assistant',
          assistantBuffer.toString(),
        );
        _conversations = await persistence!.getAllConversations();
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

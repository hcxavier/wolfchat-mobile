import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';

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

  void updateGroqKey(String key) {
    _groqKey = key;
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

  Future<void> sendMessage(String content) async {
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

    if (_currentConversation == null && _persistence != null) {
      final firstContent = content.trim().length > 50
          ? '${content.trim().substring(0, 50)}...'
          : content.trim();
      _currentConversation = await _persistence!.createConversation(
        firstContent,
        modelId: _getSelectedModelId(),
      );
      _conversations = await _persistence!.getAllConversations();
    }

    if (_currentConversation != null && _persistence != null) {
      await _persistence!.addMessage(
        _currentConversation!.id,
        'user',
        content.trim(),
      );
    }

    notifyListeners();

    try {
      if (_groqKey.isEmpty) {
        throw Exception('API key do Groq não configurada');
      }

      final groqService = GroqService(apiKey: _groqKey);
      final modelId = _getSelectedModelId();

      final assistantResponse = await groqService.sendMessage(
        messages: _messages,
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

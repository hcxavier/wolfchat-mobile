import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';
import 'package:wolfchat/features/home/models/home_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _init();
  }

  PersistenceService? _persistence;
  final HomeModel _model = const HomeModel();
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSidebarOpen = false;
  bool _isSettingsModalOpen = false;
  String _userName = 'Usuário';
  String _openRouterKey = '';
  String _groqKey = '';
  String _openCodeZenKey = '';
  final List<CustomModel> _customModels = [];
  int _selectedModelIndex = 0;
  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
  String? _errorMessage;
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;

  static const List<CustomModel> _defaultModels = [
    CustomModel(
      id: 'moonshotai/kimi-k2-instruct',
      name: 'Kimi K2 Instruct',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'llama-3.3-70b-versatile',
      name: 'Llama 3.3 70B',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'llama-3.1-70b-versatile',
      name: 'Llama 3.1 70B',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'llama-3.1-8b-instant',
      name: 'Llama 3.1 8B',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'mixtral-8x7b-32768',
      name: 'Mixtral 8x7B',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'gemma2-9b-it',
      name: 'Gemma 2 9B',
      provider: 'Groq',
    ),
  ];

  HomeModel get model => _model;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isSettingsModalOpen => _isSettingsModalOpen;
  String get userName => _userName;
  String get openRouterKey => _openRouterKey;
  String get groqKey => _groqKey;
  String get openCodeZenKey => _openCodeZenKey;
  List<CustomModel> get customModels => List.unmodifiable(_customModels);
  List<CustomModel> get availableModels => [
    ..._defaultModels,
    ..._customModels,
  ];
  CustomModel get selectedModel => availableModels[_selectedModelIndex];
  int get selectedModelIndex => _selectedModelIndex;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  bool get hasApiKey => _groqKey.isNotEmpty;
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get currentConversation => _currentConversation;

  Future<void> _init() async {
    _persistence = await PersistenceService.getInstance();
    await _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_persistence != null) {
        debugPrint('Loading conversations from database...');
        _conversations = await _persistence!.getAllConversations();
        debugPrint('Loaded ${_conversations.length} conversations');

        final apiKeys = await _persistence!.getAllApiKeys();
        _openRouterKey = apiKeys['open_router'] ?? '';
        _groqKey = apiKeys['groq'] ?? '';
        _openCodeZenKey = apiKeys['open_code_zen'] ?? '';

        final savedUserName = await _persistence!.getUserName();
        if (savedUserName != null && savedUserName.isNotEmpty) {
          _userName = savedUserName;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    _isSidebarOpen = false;
    notifyListeners();
  }

  void openSettingsModal() {
    _isSettingsModalOpen = true;
    notifyListeners();
  }

  void closeSettingsModal() {
    _isSettingsModalOpen = false;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    _persistence?.saveUserName(name);
    notifyListeners();
  }

  Future<void> saveApiKeys({
    required String openRouter,
    required String groq,
    required String openCodeZen,
  }) async {
    _openRouterKey = openRouter;
    _groqKey = groq;
    _openCodeZenKey = openCodeZen;

    if (_persistence != null) {
      if (openRouter.isNotEmpty) {
        await _persistence!.saveApiKey('open_router', openRouter);
      } else {
        await _persistence!.deleteApiKey('open_router');
      }
      if (groq.isNotEmpty) {
        await _persistence!.saveApiKey('groq', groq);
      } else {
        await _persistence!.deleteApiKey('groq');
      }
      if (openCodeZen.isNotEmpty) {
        await _persistence!.saveApiKey('open_code_zen', openCodeZen);
      } else {
        await _persistence!.deleteApiKey('open_code_zen');
      }
    }

    notifyListeners();
  }

  void addCustomModel({
    required String name,
    required String modelId,
    required ModelProvider provider,
  }) {
    final model = CustomModel(
      id: modelId,
      name: name,
      provider: provider.displayName,
    );
    _customModels.add(model);
    notifyListeners();
  }

  void removeCustomModel(int index) {
    if (index >= 0 && index < _customModels.length) {
      _customModels.removeAt(index);
      if (_selectedModelIndex >= availableModels.length) {
        _selectedModelIndex = availableModels.length - 1;
      }
      notifyListeners();
    }
  }

  void selectModel(int index) {
    if (index >= 0 && index < availableModels.length) {
      _selectedModelIndex = index;
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
        modelId: selectedModel.id,
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

  void onGetStartedPressed() {}

  void onLearnMorePressed() {}

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
        modelId: selectedModel.id,
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
      final modelId = selectedModel.id;

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
}

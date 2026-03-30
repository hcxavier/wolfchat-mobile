import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';
import 'package:wolfchat/features/home/models/home_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _loadData();
  }

  final HomeModel _model = const HomeModel();
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

  void _loadData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoading = false;
      notifyListeners();
    });
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
    notifyListeners();
  }

  void saveApiKeys({
    required String openRouter,
    required String groq,
    required String openCodeZen,
  }) {
    _openRouterKey = openRouter;
    _groqKey = groq;
    _openCodeZenKey = openCodeZen;
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

  void onGetStartedPressed() {
    // TODO(proxjie): Implementar navegação para tela principal do chat
  }

  void onLearnMorePressed() {
    // TODO(proxjie): Implementar navegação para tela de informações
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

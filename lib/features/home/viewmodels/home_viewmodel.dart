import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';
import 'package:wolfchat/features/home/models/home_model.dart';
import 'package:wolfchat/features/home/viewmodels/conversation_viewmodel.dart';
import 'package:wolfchat/features/home/viewmodels/settings_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    // ignore: discarded_futures - async init called in constructor
    _init();
  }

  PersistenceService? _persistence;
  final HomeModel _model = const HomeModel();
  bool _isInitialized = false;

  late final SettingsViewModel settings;
  late final ConversationViewModel conversation;

  HomeModel get model => _model;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isInitialized && settings.isLoading;
  bool get isSidebarOpen => _isInitialized && settings.isSidebarOpen;
  bool get isSettingsModalOpen =>
      _isInitialized && settings.isSettingsModalOpen;
  String get userName => _isInitialized ? settings.userName : 'Usuário';
  String get groqKey => _isInitialized ? settings.groqKey : '';
  String get openRouterKey => _isInitialized ? settings.openRouterKey : '';
  String get openCodeZenKey => _isInitialized ? settings.openCodeZenKey : '';
  String get language =>
      _isInitialized ? settings.language : 'Português (Brasil)';
  List<CustomModel> get customModels =>
      _isInitialized ? settings.customModels : [];
  List<CustomModel> get availableModels =>
      _isInitialized ? settings.availableModels : [];
  CustomModel get selectedModel => _isInitialized
      ? settings.selectedModel
      : const CustomModel(name: 'Selecione', modelId: '', provider: '');
  int get selectedModelIndex =>
      _isInitialized ? settings.selectedModelIndex : 0;
  List<ConversationViewModel> get conversationList =>
      _isInitialized ? [conversation] : [];
  bool get isSendingMessage => _isInitialized && conversation.isSendingMessage;
  String? get errorMessage => _isInitialized ? conversation.errorMessage : null;
  bool get hasApiKey => _isInitialized && settings.hasApiKey;
  List<Conversation> get conversations =>
      _isInitialized ? conversation.conversations : [];
  Conversation? get currentConversation =>
      _isInitialized ? conversation.currentConversation : null;
  List<ChatMessage> get messages => _isInitialized ? conversation.messages : [];

  bool get isThinkingEnabled =>
      _isInitialized && conversation.isThinkingEnabled;

  Future<void> _init() async {
    _persistence = await PersistenceService.getInstance();

    settings = SettingsViewModel(persistence: _persistence);
    conversation = ConversationViewModel(
      persistence: _persistence,
      groqKey: '',
      openRouterKey: '',
      openCodeZenKey: '',
      getSelectedModelId: () => settings.selectedModelId,
      getSelectedModelName: () => settings.selectedModelName,
      getSelectedModelProvider: () => settings.selectedModelProvider,
    );

    settings.addListener(_onSettingsChanged);
    conversation.addListener(_onConversationChanged);

    await settings.loadSettings();
    await conversation.loadConversations();

    // Sincroniza as chaves inicialmente após o carregamento das configurações
    _onSettingsChanged();

    _isInitialized = true;
    notifyListeners();
  }

  void _onSettingsChanged() {
    conversation
      ..groqKey = settings.groqKey
      ..openRouterKey = settings.openRouterKey
      ..openCodeZenKey = settings.openCodeZenKey;
    if (_isInitialized) {
      notifyListeners();
    }
  }

  void _onConversationChanged() {
    if (!_isInitialized) return;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      settings.removeListener(_onSettingsChanged);
      conversation.removeListener(_onConversationChanged);
      settings.dispose();
      conversation.dispose();
    }
    super.dispose();
  }

  void toggleSidebar() {
    if (!_isInitialized) return;
    settings.toggleSidebar();
  }

  void closeSidebar() {
    if (!_isInitialized) return;
    settings.closeSidebar();
  }

  void openSettingsModal() {
    if (!_isInitialized) return;
    settings.openSettingsModal();
  }

  void closeSettingsModal() {
    if (!_isInitialized) return;
    settings.closeSettingsModal();
  }

  Future<void> updateUserName(String name) async {
    if (!_isInitialized) return;
    await settings.updateUserName(name);
  }

  Future<void> updateLanguage(String language) async {
    if (!_isInitialized) return;
    await settings.updateLanguage(language);
  }

  Future<void> saveApiKeys({
    required String openRouter,
    required String groq,
    required String openCodeZen,
  }) async {
    if (!_isInitialized) return;
    await settings.saveApiKeys(
      openRouter: openRouter,
      groq: groq,
      openCodeZen: openCodeZen,
    );
  }

  Future<void> addCustomModel({
    required String name,
    required String modelId,
    required ModelProvider provider,
  }) async {
    if (!_isInitialized) return;
    await settings.addCustomModel(
      name: name,
      modelId: modelId,
      provider: provider,
    );
  }

  Future<void> removeCustomModel(int index) async {
    if (!_isInitialized) return;
    await settings.removeCustomModel(index);
  }

  void selectModel(int index) {
    if (!_isInitialized) return;
    settings.selectModel(index);
  }

  Future<void> createNewConversation() async {
    if (!_isInitialized) return;
    await conversation.createNewConversation();
  }

  Future<void> loadConversation(int conversationId) async {
    if (!_isInitialized) return;
    await conversation.loadConversation(conversationId);
  }

  Future<void> deleteConversation(int conversationId) async {
    if (!_isInitialized) return;
    await conversation.deleteConversation(conversationId);
  }

  Future<void> deleteAllConversations() async {
    if (!_isInitialized) return;
    await conversation.deleteAllConversations();
  }

  void onGetStartedPressed() {}

  void onLearnMorePressed() {}

  Future<void> sendMessage(String content) async {
    if (!_isInitialized) return;
    await conversation.sendMessage(content, language: settings.language);
  }

  void cancelCurrentRequest() {
    if (!_isInitialized) return;
    conversation.cancelCurrentRequest();
  }

  void toggleThinking() {
    if (!_isInitialized) return;
    conversation.toggleThinking();
  }

  Future<void> retryLastMessage() async {
    if (!_isInitialized) return;
    await conversation.retryLastMessage(language: settings.language);
  }

  void clearError() {
    if (!_isInitialized) return;
    conversation.clearError();
  }

  void clearMessages() {
    if (!_isInitialized) return;
    conversation.clearMessages();
  }
}

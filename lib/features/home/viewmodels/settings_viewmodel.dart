import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required PersistenceService? persistence,
  }) : _persistence = persistence;

  final PersistenceService? _persistence;

  bool _isLoading = false;
  bool _isSidebarOpen = false;
  bool _isSettingsModalOpen = false;
  String _userName = 'Usuário';
  String _openRouterKey = '';
  String _groqKey = '';
  String _openCodeZenKey = '';
  String _language = 'Português (Brasil)';
  final List<CustomModel> _customModels = [];
  int _selectedModelIndex = 0;

  static const List<CustomModel> _defaultModels = [
    CustomModel(
      id: 'moonshotai/kimi-k2-instruct',
      name: 'Kimi K2',
      provider: 'Groq',
    ),
    CustomModel(
      id: 'meta-llama/llama-3.3-70b-instruct:free',
      name: 'Llama 3.3 70B',
      provider: 'OpenRouter',
    ),
    CustomModel(
      id: 'google/gemma-3-12b-it:free',
      name: 'Gemma 3 12B',
      provider: 'OpenRouter',
    ),
    CustomModel(
      id: 'openrouter/free',
      name: 'OpenRouter Free',
      provider: 'OpenRouter',
    ),
    CustomModel(
      id: 'big-pickle',
      name: 'Big Pickle',
      provider: 'OpenCode Zen',
    ),
    CustomModel(
      id: 'qwen3.6-plus-free',
      name: 'Qwen 3.6 Plus',
      provider: 'OpenCode Zen',
    ),
    CustomModel(
      id: 'minimax-m2.5-free',
      name: 'MiniMax M2.5',
      provider: 'OpenCode Zen',
    ),
    CustomModel(
      id: 'mimo-v2-pro-free',
      name: 'Mimo V2 Pro',
      provider: 'OpenCode Zen',
    ),
  ];

  bool get isLoading => _isLoading;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isSettingsModalOpen => _isSettingsModalOpen;
  String get userName => _userName;
  String get openRouterKey => _openRouterKey;
  String get groqKey => _groqKey;
  String get openCodeZenKey => _openCodeZenKey;
  String get language => _language;
  List<CustomModel> get customModels => List.unmodifiable(_customModels);
  List<CustomModel> get availableModels => [
    ..._defaultModels,
    ..._customModels,
  ];
  CustomModel get selectedModel => availableModels[_selectedModelIndex];
  int get selectedModelIndex => _selectedModelIndex;
  bool get hasApiKey =>
      _groqKey.isNotEmpty ||
      _openRouterKey.isNotEmpty ||
      _openCodeZenKey.isNotEmpty;

  String get selectedModelId => selectedModel.id;
  String get selectedModelProvider => selectedModel.provider;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_persistence != null) {
        final apiKeys = await _persistence.getAllApiKeys();
        _openRouterKey = apiKeys['open_router'] ?? '';
        _groqKey = apiKeys['groq'] ?? '';
        _openCodeZenKey = apiKeys['open_code_zen'] ?? '';

        final savedUserName = await _persistence.getUserName();
        if (savedUserName != null && savedUserName.isNotEmpty) {
          _userName = savedUserName;
        }

        final savedLanguage = await _persistence.getLanguage();
        if (savedLanguage != null && savedLanguage.isNotEmpty) {
          _language = savedLanguage;
        }
      }
    } on Exception catch (e, stackTrace) {
      debugPrint('Error loading settings: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    _isLoading = false;
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

  Future<void> updateUserName(String name) async {
    _userName = name;
    await _persistence?.saveUserName(name);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _language = language;
    await _persistence?.saveLanguage(language);
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
        await _persistence.saveApiKey('open_router', openRouter);
      } else {
        await _persistence.deleteApiKey('open_router');
      }
      if (groq.isNotEmpty) {
        await _persistence.saveApiKey('groq', groq);
      } else {
        await _persistence.deleteApiKey('groq');
      }
      if (openCodeZen.isNotEmpty) {
        await _persistence.saveApiKey('open_code_zen', openCodeZen);
      } else {
        await _persistence.deleteApiKey('open_code_zen');
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
}

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
  final List<CustomModel> _customModels = [];
  int _selectedModelIndex = 0;

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
  bool get hasApiKey => _groqKey.isNotEmpty;

  String get selectedModelId => selectedModel.id;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_persistence != null) {
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
}

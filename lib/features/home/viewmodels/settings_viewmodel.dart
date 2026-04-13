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
  String _nvidiaNimKey = '';
  String _language = 'Português (Brasil)';
  final List<CustomModel> _customModels = [];
  int _selectedModelIndex = 0;

  static const List<CustomModel> _defaultModels = [
    CustomModel(
      name: 'GPT OSS 120B',
      modelId: 'openai/gpt-oss-120b',
      provider: 'Groq',
      isDefault: true,
    ),
    CustomModel(
      name: 'Llama 3.3 70B',
      modelId: 'meta-llama/llama-3.3-70b-instruct:free',
      provider: 'OpenRouter',
      isDefault: true,
    ),
    CustomModel(
      name: 'Gemma 3 12B',
      modelId: 'google/gemma-3-12b-it:free',
      provider: 'OpenRouter',
      isDefault: true,
    ),
    CustomModel(
      name: 'OpenRouter Free',
      modelId: 'openrouter/free',
      provider: 'OpenRouter',
      isDefault: true,
    ),
    CustomModel(
      name: 'Big Pickle',
      modelId: 'big-pickle',
      provider: 'OpenCode Zen',
      isDefault: true,
    ),
    CustomModel(
      name: 'Qwen 3.6 Plus',
      modelId: 'qwen3.6-plus-free',
      provider: 'OpenCode Zen',
      isDefault: true,
    ),
    CustomModel(
      name: 'MiniMax M2.5',
      modelId: 'minimax-m2.5-free',
      provider: 'OpenCode Zen',
      isDefault: true,
    ),
    CustomModel(
      name: 'Mimo V2 Pro',
      modelId: 'mimo-v2-pro-free',
      provider: 'OpenCode Zen',
      isDefault: true,
    ),
  ];

  bool get isLoading => _isLoading;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isSettingsModalOpen => _isSettingsModalOpen;
  String get userName => _userName;
  String get openRouterKey => _openRouterKey;
  String get groqKey => _groqKey;
  String get openCodeZenKey => _openCodeZenKey;
  String get nvidiaNimKey => _nvidiaNimKey;
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
      _openCodeZenKey.isNotEmpty ||
      _nvidiaNimKey.isNotEmpty;

  String get selectedModelId => selectedModel.modelId;
  String get selectedModelName => selectedModel.name;
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
        _nvidiaNimKey = apiKeys['nvidia_nim'] ?? '';

        final savedUserName = await _persistence.getUserName();
        if (savedUserName != null && savedUserName.isNotEmpty) {
          _userName = savedUserName;
        }

        final savedLanguage = await _persistence.getLanguage();
        if (savedLanguage != null && savedLanguage.isNotEmpty) {
          _language = savedLanguage;
        }

        final savedModels = await _persistence.getAllCustomModels();
        _customModels
          ..clear()
          ..addAll(savedModels);

        _selectedModelIndex = await _persistence.getSelectedModelIndex();
        if (_selectedModelIndex >= availableModels.length) {
          _selectedModelIndex = 0;
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
    String nvidiaNim = '',
  }) async {
    _openRouterKey = openRouter;
    _groqKey = groq;
    _openCodeZenKey = openCodeZen;
    _nvidiaNimKey = nvidiaNim;

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
      if (nvidiaNim.isNotEmpty) {
        await _persistence.saveApiKey('nvidia_nim', nvidiaNim);
      } else {
        await _persistence.deleteApiKey('nvidia_nim');
      }
    }

    notifyListeners();
  }

  Future<void> addCustomModel({
    required String name,
    required String modelId,
    required ModelProvider provider,
  }) async {
    final model = CustomModel(
      name: name,
      modelId: modelId,
      provider: provider.displayName,
    );
    final persistence = _persistence;
    if (persistence != null) {
      final dbId = await persistence.saveCustomModel(model);
      _customModels.add(
        CustomModel(
          id: dbId,
          name: name,
          modelId: modelId,
          provider: provider.displayName,
        ),
      );
      _selectedModelIndex = _defaultModels.length + _customModels.length - 1;
      await persistence.saveSelectedModelIndex(_selectedModelIndex);
    } else {
      _customModels.add(model);
      _selectedModelIndex = _defaultModels.length + _customModels.length - 1;
    }
    notifyListeners();
  }

  Future<void> removeCustomModel(int index) async {
    if (index < 0 || index >= _customModels.length) return;
    final model = _customModels[index];
    final persistence = _persistence;
    final modelId = model.id;
    if (persistence != null && modelId != null) {
      await persistence.deleteCustomModel(modelId);
    }
    _customModels.removeAt(index);

    final customModelStartIndex = _defaultModels.length;
    final wasSelectedCustom = _selectedModelIndex >= customModelStartIndex;
    if (wasSelectedCustom) {
      final customIndex = _selectedModelIndex - customModelStartIndex;
      if (customIndex > index) {
        _selectedModelIndex--;
      } else if (customIndex == index) {
        if (_customModels.isEmpty) {
          _selectedModelIndex = _defaultModels.length - 1;
        } else if (index >= _customModels.length) {
          _selectedModelIndex =
              _defaultModels.length + _customModels.length - 1;
        }
      }
    }

    if (_selectedModelIndex >= availableModels.length) {
      _selectedModelIndex = availableModels.length - 1;
    }

    await _persistence?.saveSelectedModelIndex(_selectedModelIndex);
    notifyListeners();
  }

  void selectModel(int index) {
    if (index >= 0 && index < availableModels.length) {
      _selectedModelIndex = index;
      // ignore: discarded_futures - save asynchronously without blocking UI
      _persistence?.saveSelectedModelIndex(_selectedModelIndex);
      notifyListeners();
    }
  }
}

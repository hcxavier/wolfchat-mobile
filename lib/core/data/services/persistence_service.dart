import 'package:wolfchat/core/data/models/api_key.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/models/message.dart';
import 'package:wolfchat/core/data/services/cache_service.dart';
import 'package:wolfchat/core/data/services/database_service.dart';
import 'package:wolfchat/core/exceptions/app_exceptions.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';

class PersistenceService {
  PersistenceService._();
  static PersistenceService? _instance;
  static final DatabaseService _database = DatabaseService();
  static CacheService? _cache;
  static Future<PersistenceService> getInstance() async {
    if (_instance != null) return _instance!;
    _instance = PersistenceService._();
    _cache = await CacheService.getInstance();
    return _instance!;
  }

  Future<void> saveApiKey(String provider, String key) async {
    final apiKey = ApiKey(
      id: 0,
      provider: provider,
      key: key,
      createdAt: DateTime.now(),
    );
    await _database.insertApiKey(apiKey);
    if (_cache != null && _cache!.isConnected) {
      await _cache!.set('api_key:$provider', key);
    }
  }

  Future<String?> getApiKey(String provider) async {
    if (_cache != null && _cache!.isConnected) {
      final cached = await _cache!.get('api_key:$provider');
      if (cached != null) return cached;
    }
    final apiKey = await _database.getApiKey(provider);
    if (apiKey != null) {
      if (_cache != null && _cache!.isConnected) {
        await _cache!.set('api_key:$provider', apiKey.key);
      }
      return apiKey.key;
    }
    return null;
  }

  Future<Map<String, String>> getAllApiKeys() async {
    final apiKeys = await _database.getAllApiKeys();
    final result = <String, String>{};
    for (final apiKey in apiKeys) {
      result[apiKey.provider] = apiKey.key;
    }
    return result;
  }

  Future<void> deleteApiKey(String provider) async {
    await _database.deleteApiKey(provider);
    if (_cache != null && _cache!.isConnected) {
      await _cache!.delete('api_key:$provider');
    }
  }

  Future<Conversation> createConversation(
    String title, {
    String? modelId,
  }) async {
    try {
      final now = DateTime.now();
      final conversation = Conversation(
        id: 0,
        title: title,
        createdAt: now,
        updatedAt: now,
        modelId: modelId,
      );
      final id = await _database.insertConversation(conversation);
      return conversation.copyWith(id: id);
    } on Exception catch (_) {
      throw const PersistenceException(
        'Não foi possível criar a conversa. '
        'Tente novamente.',
      );
    }
  }

  Future<List<Conversation>> getAllConversations() async {
    try {
      return _database.getAllConversations();
    } on Exception catch (_) {
      throw const PersistenceException(
        'Não foi possível carregar suas conversas.',
      );
    }
  }

  Future<Conversation?> getConversation(int id) async {
    return _database.getConversation(id);
  }

  Future<void> updateConversation(Conversation conversation) async {
    await _database.updateConversation(
      conversation.copyWith(
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteConversation(int id) async {
    try {
      await _database.deleteConversation(id);
    } on Exception catch (_) {
      throw const PersistenceException(
        'Não foi possível excluir a conversa.',
      );
    }
  }

  Future<void> deleteAllConversations() async {
    try {
      await _database.deleteAllConversations();
    } on Exception catch (_) {
      throw const PersistenceException(
        'Não foi possível excluir as conversas.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> searchConversations(String query) async {
    return _database.searchConversations(query);
  }

  Future<Message> addMessage(
    int conversationId,
    String role,
    String content,
  ) async {
    try {
      final message = Message(
        id: 0,
        conversationId: conversationId,
        role: role,
        content: content,
        timestamp: DateTime.now(),
      );
      final id = await _database.insertMessage(message);
      return message.copyWith(id: id);
    } on Exception catch (_) {
      throw const PersistenceException(
        'Não foi possível salvar a mensagem.',
      );
    }
  }

  Future<List<Message>> getMessages(int conversationId) async {
    return _database.getMessagesByConversation(conversationId);
  }

  Future<void> clearCache() async {
    if (_cache != null) {
      await _cache!.clearAll();
    }
  }

  Future<void> saveUserName(String name) async {
    await _database.saveUserSetting('user_name', name);
  }

  Future<String?> getUserName() async {
    return _database.getUserSetting('user_name');
  }

  Future<void> saveLanguage(String language) async {
    await _database.saveUserSetting('language', language);
  }

  Future<String?> getLanguage() async {
    return _database.getUserSetting('language');
  }

  Future<int> saveCustomModel(CustomModel model) async {
    return _database.insertCustomModel(model);
  }

  Future<List<CustomModel>> getAllCustomModels() async {
    return _database.getAllCustomModels();
  }

  Future<void> deleteCustomModel(int id) async {
    await _database.deleteCustomModel(id);
  }

  Future<void> saveSelectedModelIndex(int index) async {
    await _database.saveUserSetting('selected_model_index', index.toString());
  }

  Future<int> getSelectedModelIndex() async {
    final value = await _database.getUserSetting('selected_model_index');
    if (value != null) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> saveSystemPrompt(String prompt) async {
    await _database.saveUserSetting('system_prompt', prompt);
  }

  Future<String?> getSystemPrompt() async {
    return _database.getUserSetting('system_prompt');
  }
}

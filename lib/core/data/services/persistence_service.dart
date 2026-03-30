import 'package:wolfchat/core/data/models/api_key.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/models/message.dart';
import 'package:wolfchat/core/data/services/cache_service.dart';
import 'package:wolfchat/core/data/services/database_service.dart';

class PersistenceService {
  static PersistenceService? _instance;
  static final DatabaseService _database = DatabaseService();
  static CacheService? _cache;

  PersistenceService._();

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
  }

  Future<List<Conversation>> getAllConversations() async {
    return _database.getAllConversations();
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
    await _database.deleteConversation(id);
  }

  Future<void> deleteAllConversations() async {
    await _database.deleteAllConversations();
  }

  Future<Message> addMessage(
    int conversationId,
    String role,
    String content,
  ) async {
    final message = Message(
      id: 0,
      conversationId: conversationId,
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );
    final id = await _database.insertMessage(message);
    return message.copyWith(id: id);
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
}

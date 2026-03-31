import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wolfchat/core/data/models/api_key.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/data/models/message.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'wolfchat.db';
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_models (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          model_id TEXT NOT NULL,
          provider TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE api_keys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provider TEXT NOT NULL UNIQUE,
        key TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        model_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_messages_conversation ON messages(conversation_id)',
    );
    await db.execute(
      'CREATE INDEX idx_conversations_updated '
      'ON conversations(updated_at DESC)',
    );

    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        model_id TEXT NOT NULL,
        provider TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertApiKey(ApiKey apiKey) async {
    final db = await database;
    return db.insert(
      'api_keys',
      apiKey.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ApiKey?> getApiKey(String provider) async {
    final db = await database;
    final results = await db.query(
      'api_keys',
      where: 'provider = ?',
      whereArgs: [provider],
    );
    if (results.isEmpty) return null;
    return ApiKey.fromMap(results.first);
  }

  Future<List<ApiKey>> getAllApiKeys() async {
    final db = await database;
    final results = await db.query('api_keys');
    return results.map(ApiKey.fromMap).toList();
  }

  Future<int> deleteApiKey(String provider) async {
    final db = await database;
    return db.delete(
      'api_keys',
      where: 'provider = ?',
      whereArgs: [provider],
    );
  }

  Future<int> insertConversation(Conversation conversation) async {
    try {
      final db = await database;
      debugPrint('Inserting conversation: ${conversation.title}');
      final map = conversation.toMap()..remove('id');
      debugPrint('Map: $map');
      final id = await db.insert('conversations', map);
      debugPrint('Inserted conversation with id: $id');
      return id;
    } catch (e, stack) {
      debugPrint('Error inserting conversation: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  Future<Conversation?> getConversation(int id) async {
    final db = await database;
    final results = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return Conversation.fromMap(results.first);
  }

  Future<List<Conversation>> getAllConversations() async {
    try {
      final db = await database;
      debugPrint('Database opened, querying conversations...');
      final results = await db.query(
        'conversations',
        orderBy: 'updated_at DESC',
      );
      debugPrint('Found ${results.length} conversations');
      return results.map(Conversation.fromMap).toList();
    } catch (e, stack) {
      debugPrint('Error getting conversations: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  Future<int> updateConversation(Conversation conversation) async {
    final db = await database;
    return db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<int> deleteConversation(int id) async {
    final db = await database;
    await db.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
    return db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllConversations() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('conversations');
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    final id = await db.insert('messages', message.toMap()..remove('id'));

    await db.rawUpdate(
      '''
      UPDATE conversations 
      SET updated_at = ? 
      WHERE id = ?
    ''',
      [message.timestamp.millisecondsSinceEpoch, message.conversationId],
    );

    return id;
  }

  Future<List<Message>> getMessagesByConversation(int conversationId) async {
    final db = await database;
    final results = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return results.map(Message.fromMap).toList();
  }

  Future<int> deleteMessagesByConversation(int conversationId) async {
    final db = await database;
    return db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> saveUserSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getUserSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isEmpty) return null;
    final value = results.first['value'];
    return value as String?;
  }

  Future<int> insertCustomModel(CustomModel model) async {
    final db = await database;
    return db.insert('custom_models', model.toMap()..remove('id'));
  }

  Future<List<CustomModel>> getAllCustomModels() async {
    final db = await database;
    final results = await db.query('custom_models');
    return results.map(CustomModel.fromMap).toList();
  }

  Future<int> deleteCustomModel(int id) async {
    final db = await database;
    return db.delete('custom_models', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

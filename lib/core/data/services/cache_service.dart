import 'dart:convert';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static CacheService? _instance;
  static Command? _command;
  static String? _redisHost;
  static int? _redisPort;

  CacheService._();

  static Future<CacheService> getInstance() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();
    _redisHost = prefs.getString('redis_host') ?? 'localhost';
    _redisPort = prefs.getInt('redis_port') ?? 6379;

    _instance = CacheService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    try {
      _command = await RedisConnection().connect(_redisHost!, _redisPort!);
    } catch (e) {
      _command = null;
    }
  }

  bool get isConnected => _command != null;

  Future<void> setRedisConfig(String host, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('redis_host', host);
    await prefs.setInt('redis_port', port);

    _redisHost = host;
    _redisPort = port;

    await _init();
  }

  Future<void> set(String key, String value, {Duration? expiry}) async {
    if (_command == null) {
      await _fallbackToMemory(key, value, expiry);
      return;
    }

    try {
      if (expiry != null) {
        await _command!.send_object(['SETEX', key, expiry.inSeconds, value]);
      } else {
        await _command!.send_object(['SET', key, value]);
      }
    } catch (e) {
      await _fallbackToMemory(key, value, expiry);
    }
  }

  Future<String?> get(String key) async {
    if (_command == null) {
      return _getFromMemory(key);
    }

    try {
      final result = await _command!.send_object(['GET', key]);
      if (result is String) return result;
      return null;
    } catch (e) {
      return _getFromMemory(key);
    }
  }

  Future<void> delete(String key) async {
    if (_command == null) {
      await _deleteFromMemory(key);
      return;
    }

    try {
      await _command!.send_object(['DEL', key]);
    } catch (e) {
      await _deleteFromMemory(key);
    }
  }

  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    Duration? expiry,
  }) async {
    await set(key, jsonEncode(value), expiry: expiry);
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = await get(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> addToList(String key, String value) async {
    if (_command == null) {
      await _addToMemoryList(key, value);
      return;
    }

    try {
      await _command!.send_object(['RPUSH', key, value]);
    } catch (e) {
      await _addToMemoryList(key, value);
    }
  }

  Future<List<String>> getList(String key) async {
    if (_command == null) {
      return _getMemoryList(key);
    }

    try {
      final result = await _command!.send_object(['LRANGE', key, '0', '-1']);
      if (result is List) {
        return result.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return _getMemoryList(key);
    }
  }

  Future<void> clearAll() async {
    if (_command == null) {
      _memoryCache.clear();
      return;
    }

    try {
      await _command!.send_object(['FLUSHDB']);
    } catch (e) {
      _memoryCache.clear();
    }
  }

  static final Map<String, _MemoryEntry> _memoryCache = {};

  Future<void> _fallbackToMemory(
    String key,
    String value,
    Duration? expiry,
  ) async {
    _memoryCache[key] = _MemoryEntry(
      value: value,
      expiry: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  Future<String?> _getFromMemory(String key) async {
    final entry = _memoryCache[key];
    if (entry == null) return null;
    if (entry.expiry != null && entry.expiry!.isBefore(DateTime.now())) {
      _memoryCache.remove(key);
      return null;
    }
    return entry.value;
  }

  Future<void> _deleteFromMemory(String key) async {
    _memoryCache.remove(key);
  }

  Future<void> _addToMemoryList(String key, String value) async {
    final list = _memoryCache[key];
    if (list == null) {
      _memoryCache[key] = _MemoryEntry(value: '[$value]');
    } else {
      final current = list.value;
      if (current.startsWith('[') && current.endsWith(']')) {
        final inner = current.substring(1, current.length - 1);
        _memoryCache[key] = _MemoryEntry(value: '$inner,$value]');
      }
    }
  }

  List<String> _getMemoryList(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return [];
    final value = entry.value;
    if (value.startsWith('[') && value.endsWith(']')) {
      final inner = value.substring(1, value.length - 1);
      if (inner.isEmpty) return [];
      return inner.split(',');
    }
    return [value];
  }

  Future<void> close() async {
    _command = null;
    _instance = null;
  }
}

class _MemoryEntry {
  _MemoryEntry({required this.value, this.expiry});
  final String value;
  final DateTime? expiry;
}

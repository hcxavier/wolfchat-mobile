import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/utils/error_message_mapper.dart';
import 'package:wolfchat/features/search/models/search_result.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({PersistenceService? persistence})
    : _persistence = persistence {
    _init();
  }
  PersistenceService? _persistence;
  bool _isInitialized = false;
  bool _isDisposed = false;
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _query = '';
  String? _errorMessage;
  Timer? _debounceTimer;
  List<SearchResult> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Future<void> _init() async {
    try {
      _persistence ??= await PersistenceService.getInstance();
      _isInitialized = true;
      await search('');
    } on Exception catch (e) {
      if (_isDisposed) return;
      _errorMessage = ErrorMessageMapper.from(e);
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (_isDisposed) return;
    if (!_isInitialized) {
      final success = await _waitForInitialization();
      if (!success || _isDisposed) return;
    }
    _query = query;
    _errorMessage = null;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => _performSearch(query),
    );
  }

  Future<bool> _waitForInitialization() async {
    const maxAttempts = 50;
    var attempts = 0;
    while (!_isInitialized && attempts < maxAttempts && !_isDisposed) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    return _isInitialized && !_isDisposed;
  }

  Future<void> _performSearch(String query) async {
    if (_isDisposed) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final rawResults = await _persistence!.searchConversations(query);
      if (_isDisposed) return;
      _results = rawResults.map((data) {
        final title = data['title'] as String? ?? 'Nova conversa';
        final updatedAtValue = data['updated_at'];
        final updatedAt = updatedAtValue != null
            ? DateTime.fromMillisecondsSinceEpoch(updatedAtValue as int)
            : DateTime.now();
        String preview;
        String? matchedContent;
        if (query.isEmpty) {
          final lastMessageContent = data['last_message_content'] as String?;
          final lastMessageRole = data['last_message_role'] as String?;
          if (lastMessageRole == 'assistant' && lastMessageContent != null) {
            preview = _truncateContent(lastMessageContent);
          } else {
            preview = 'Nenhuma mensagem ainda';
          }
        } else {
          matchedContent = data['matched_content'] as String?;
          if (matchedContent != null) {
            preview = _extractPreview(matchedContent, query);
          } else {
            preview = 'Nenhum resultado encontrado';
          }
        }
        return SearchResult(
          conversationId: data['id'] as int,
          title: title,
          preview: preview,
          updatedAt: updatedAt,
          matchedContent: matchedContent,
        );
      }).toList();
      _errorMessage = null;
    } on Exception catch (e) {
      if (!_isDisposed) {
        debugPrint('Error searching conversations: $e');
        _errorMessage = ErrorMessageMapper.from(e);
        _results = [];
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  String _truncateContent(String content, {int maxLength = 100}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  String _extractPreview(String content, String query) {
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerContent.indexOf(lowerQuery);
    if (index == -1) {
      return _truncateContent(content);
    }
    const contextLength = 40;
    final start = (index - contextLength).clamp(0, content.length);
    final end = (index + query.length + contextLength).clamp(0, content.length);
    var preview = content.substring(start, end);
    if (start > 0) preview = '...$preview';
    if (end < content.length) preview = '$preview...';
    return preview;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/features/search/models/search_result.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({PersistenceService? persistence})
    : _persistence = persistence {
    if (_persistence == null) {
      // ignore: discarded_futures - async init called in constructor
      _init();
    }
  }

  PersistenceService? _persistence;
  bool _isInitialized = false;

  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _query = '';
  Timer? _debounceTimer;

  List<SearchResult> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String get query => _query;

  Future<void> _init() async {
    _persistence = await PersistenceService.getInstance();
    _isInitialized = true;
  }

  Future<void> search(String query) async {
    if (!_isInitialized) return;

    _query = query;

    // Debounce search to avoid too many database queries
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawResults = await _persistence!.searchConversations(query);

      _results = rawResults.map((data) {
        final title = data['title'] as String? ?? 'Nova conversa';
        final updatedAt = DateTime.fromMillisecondsSinceEpoch(
          data['updated_at'] as int,
        );

        String preview;
        String? matchedContent;

        if (query.isEmpty) {
          // When search is empty, show last assistant message
          final lastMessageContent = data['last_message_content'] as String?;
          final lastMessageRole = data['last_message_role'] as String?;

          if (lastMessageRole == 'assistant' && lastMessageContent != null) {
            preview = _truncateContent(lastMessageContent);
          } else {
            preview = 'Nenhuma mensagem ainda';
          }
        } else {
          // When searching, show matched content
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
    } on Exception catch (e) {
      debugPrint('Error searching conversations: $e');
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    // Extract context around the match
    const contextLength = 40;
    final start = (index - contextLength).clamp(0, content.length);
    final end = (index + query.length + contextLength).clamp(0, content.length);

    var preview = content.substring(start, end);

    // Add ellipsis if truncated
    if (start > 0) preview = '...$preview';
    if (end < content.length) preview = '$preview...';

    return preview;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

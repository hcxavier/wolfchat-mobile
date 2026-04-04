class SearchResult {
  const SearchResult({
    required this.conversationId,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.matchedContent,
  });

  final int conversationId;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String? matchedContent;
}

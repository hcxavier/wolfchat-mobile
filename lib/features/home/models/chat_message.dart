class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.thinking,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.now(),
      thinking: json['thinking'] as String?,
    );
  }

  final String role;
  final String content;
  final DateTime timestamp;
  final String? thinking;

  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
    String? thinking,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      thinking: thinking ?? this.thinking,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

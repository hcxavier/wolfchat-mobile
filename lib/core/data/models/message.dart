class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      conversationId: map['conversation_id'] as int,
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  final int id;
  final int conversationId;
  final String role;
  final String content;
  final DateTime timestamp;

  Message copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// Pseudo-update for commit 13 at 2026-04-05 06:19:27

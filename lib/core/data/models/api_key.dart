class ApiKey {
  const ApiKey({
    required this.id,
    required this.provider,
    required this.key,
    required this.createdAt,
  });

  factory ApiKey.fromMap(Map<String, dynamic> map) {
    return ApiKey(
      id: map['id'] as int,
      provider: map['provider'] as String,
      key: map['key'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider': provider,
      'key': key,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  final int id;
  final String provider;
  final String key;
  final DateTime createdAt;

  ApiKey copyWith({
    int? id,
    String? provider,
    String? key,
    DateTime? createdAt,
  }) {
    return ApiKey(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      key: key ?? this.key,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

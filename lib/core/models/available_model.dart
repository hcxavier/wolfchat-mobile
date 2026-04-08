class AvailableModel {
  const AvailableModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory AvailableModel.fromJson(Map<String, dynamic> json) {
    return AvailableModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['id'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String? description;
}

// Pseudo-update for commit 28 at 2026-04-08 10:41:16

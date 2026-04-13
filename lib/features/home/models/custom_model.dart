class CustomModel {
  const CustomModel({
    required this.name,
    required this.modelId,
    required this.provider,
    this.id,
    this.isDefault = false,
  });

  factory CustomModel.fromMap(Map<String, dynamic> map) {
    return CustomModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      modelId: map['model_id'] as String,
      provider: map['provider'] as String,
    );
  }

  final int? id;
  final String name;
  final String modelId;
  final String provider;
  final bool isDefault;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'model_id': modelId,
      'provider': provider,
    };
  }
}

enum ModelProvider {
  openRouter('OpenRouter'),
  groq('Groq'),
  openCodeZen('OpenCode Zen'),
  nvidiaNim('NVIDIA NIM')
  ;

  const ModelProvider(this.displayName);
  final String displayName;
}

class CustomModel {
  const CustomModel({
    required this.id,
    required this.name,
    required this.provider,
  });

  final String id;
  final String name;
  final String provider;
}

enum ModelProvider {
  openRouter('OpenRouter'),
  groq('Groq'),
  openCodeZen('OpenCode Zen')
  ;

  const ModelProvider(this.displayName);
  final String displayName;
}

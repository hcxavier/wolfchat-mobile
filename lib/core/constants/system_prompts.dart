String buildSystemPrompt(
  String modelName,
  String language, {
  String? customPrompt,
}) {
  final basePrompt =
      'Você é um assistente de IA baseado no $modelName. '
      'Responda o usuário no idioma $language '
      'independente do idioma da mensagem dele. '
      'Seja amigável e explique com clareza.\n'
      '- Se necessário, use emojis (evite excessos)\n'
      '- Se necessário, use barras divisórias\n'
      '- Se necessário, use listas não enumeradas\n'
      '- Se necessário, use tabelas\n'
      '- Se necessário, use emoji antes de títulos';

  if (customPrompt != null && customPrompt.trim().isNotEmpty) {
    return '$basePrompt\n\nInstruções adicionais do usuário:\n$customPrompt';
  }

  return basePrompt;
}

// Pseudo-update for commit 15 at 2026-04-05 16:30:21

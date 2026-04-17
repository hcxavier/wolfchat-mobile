# Plano de Desenvolvimento: Fix Thinking Collapse Button no OpenRouter

## Visão Geral do Problema

A feature de "Thinking" já foi pré-implementada, mas quando o botão de pensar é ativado no input, a IA não retorna o thinking. O problema está na forma como o parâmetro `include_reasoning` está sendo enviado para a API do OpenRouter.

**Problema Raiz:** O OpenRouter espera o parâmetro `include_reasoning` como um **header HTTP** (`X-Include-Reasoning`), mas o código atual está tentando enviá-lo no body da requisição.

---

## Diagnóstico Detalhado

### Arquivos Afetados

| Arquivo | Linha(s) | Problema |
|---------|----------|----------|
| `lib/core/services/open_router_service.dart` | 101-108, 110-115 | `include_reasoning` está no body em vez de ser header |
| `lib/core/services/open_router_service.dart` | 137 | Campo de resposta pode estar diferente |

### Análise da Implementação Atual (Incorreta)

```dart
// Linhas 101-115 em open_router_service.dart
final body = jsonEncode({
  'model': model,
  'messages': allMessages,
  'temperature': 0.7,
  'max_tokens': 2048,
  'stream': true,
  if (enableThinking) 'include_reasoning': true,  // ❌ ERRADO: Deve ser header
});

final request = http.Request('POST', url)
  ..headers.addAll({
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  ])
  ..body = body;
```

### Implementação Correta (Esperada pelo OpenRouter)

```dart
final body = jsonEncode({
  'model': model,
  'messages': allMessages,
  'temperature': 0.7,
  'max_tokens': 2048,
  'stream': true,
});

final request = http.Request('POST', url)
  ..headers.addAll({
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    if (enableThinking) 'X-Include-Reasoning': 'true',  // ✅ CORRETO: Header HTTP
  })
  ..body = body;
```

---

## Plano de Correção

### Arquivo 1: `lib/core/services/open_router_service.dart`

#### Edição 1: Corrigir o método `sendMessageStream` (Linhas 86-162)

**Local:** Método `sendMessageStream`, aproximadamente linha 101-115

**Ação:** Mover o parâmetro `include_reasoning` do body para o header

**Código atual (linhas 101-115):**
```dart
final body = jsonEncode({
  'model': model,
  'messages': allMessages,
  'temperature': 0.7,
  'max_tokens': 2048,
  'stream': true,
  if (enableThinking) 'include_reasoning': true,
});

final request = http.Request('POST', url)
  ..headers.addAll({
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  })
  ..body = body;
```

**Código corrigido:**
```dart
final body = jsonEncode({
  'model': model,
  'messages': allMessages,
  'temperature': 0.7,
  'max_tokens': 2048,
  'stream': true,
});

final request = http.Request('POST', url)
  ..headers.addAll({
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    if (enableThinking) 'X-Include-Reasoning': 'true',
  })
  ..body = body;
```

#### Edição 2: Verificar campo de resposta (Linha 137)

**Local:** Linha 137 no parsing da resposta

**Ação:** Verificar se o campo `reasoning` na resposta está correto

**Código atual (linhas 134-140):**
```dart
final delta = choice['delta'] as Map<String, dynamic>;
final content = delta['content'] as String?;
final reasoning = delta['reasoning'] as String?;
if (content != null || reasoning != null) {
  yield AiStreamChunk(content: content, thinking: reasoning);
}
```

**Possíveis campos na resposta do OpenRouter:**
- `reasoning` (formato atual)
- `thinking`
- `reasoning_content`

**Verificação recomendada:** O campo atual `reasoning` está correto segundo a documentação do OpenRouter.

---

## Fluxo de Dados da Feature

```
┌─────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│  bottom_input   │────▶│  conversation_viewmodel │────▶│  open_router_service    │
│                 │     │                         │     │                         │
│ Botão Thinking  │     │ toggleThinking()        │     │ sendMessageStream()     │
│ (lightBulb)     │     │ _isThinkingEnabled      │     │ Header: X-Include-      │
└─────────────────┘     └─────────────────────────┘     │ Reasoning: true         │
                                                        └─────────────────────────┘
                                                                    │
                                                                    ▼
┌─────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│ thinking_panel  │◄────│  conversation_viewmodel │◄────│  Stream<AiStreamChunk>  │
│                 │     │                         │     │                         │
│ Collapse/Expand │     │ thinkingBuffer          │     │ chunk.thinking          │
│ Visualização    │     │ _messages[].thinking    │     │                         │
└─────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

---

## Resumo das Alterações

| Arquivo | Tipo | Linha(s) | Descrição |
|---------|------|----------|-----------|
| `lib/core/services/open_router_service.dart` | Edição | 101-108 | Remover `include_reasoning` do body |
| `lib/core/services/open_router_service.dart` | Edição | 110-115 | Adicionar header `X-Include-Reasoning` |
| `lib/core/services/open_router_service.dart` | Verificar | 137 | Confirmar campo `reasoning` na resposta |

---

## Teste Recomendado

Após aplicar as correções:

1. Abrir o aplicativo
2. Selecionar um modelo do OpenRouter (ex: `openrouter/free`)
3. Ativar o botão de thinking (lâmpada) na barra de input
4. Enviar uma mensagem
5. Verificar se o painel de thinking aparece com conteúdo colapsável

---

## Notas Importantes

1. **Provider Support:** A feature de thinking só funciona com modelos que suportam reasoning. No OpenRouter, verifique se o modelo selecionado suporta essa funcionalidade.

2. **Outros Serviços:** Os serviços Groq e OpenCode Zen não implementam thinking (eles ignoram o parâmetro `enableThinking`), o que é comportamento esperado.

3. **Persistência:** O thinking não está sendo salvo no banco de dados (apenas o conteúdo principal é persistido), o que é um comportamento conhecido e pode ser melhorado futuramente.

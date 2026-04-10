# Plano de Desenvolvimento: Thinking Collapse + Toggle de Thinking

## Visão Geral

A feature consiste em dois componentes integrados:
1. **Botão de Toggle na Input Bar** — permite ao usuário ativar/desativar o modo de "thinking" antes de enviar a mensagem
2. **Thinking Panel Colapsível** — exibe o raciocínio interno da IA em cada mensagem, com botão para expandir/recolher

### Fluxo de Dados (MVVM)

```
BottomInput
  isThinkingEnabled (toggle)
      │
      ▼
HomeViewModel.isThinkingEnabled / toggleThinking()
      │
      ▼
ConversationViewModel.sendMessage(enableThinking: bool)
      │
      ▼
AiService.sendMessageStream(enableThinking: bool) → Stream<AiStreamChunk>
      │  (AiStreamChunk = { content: String?, thinking: String? })
      ▼
ChatMessage.thinking: String? (campo separado)
      │
      ▼
_MessageBubble → ThinkingPanel (colapsível) + MarkdownBody (content)
```

---

## Arquivos a CRIAR

### 1. `lib/core/models/ai_stream_chunk.dart` *(novo)*

Modelo imutável que carrega o chunk de stream, separando o conteúdo da resposta e o conteúdo do pensamento.

```dart
class AiStreamChunk {
  const AiStreamChunk({this.content, this.thinking});

  final String? content;
  final String? thinking;
}
```

---

### 2. `lib/features/home/views/widgets/thinking_panel.dart` *(novo)*

Widget colapsível que exibe o bloco de "thinking" de uma mensagem do assistente.

**Responsabilidades:**
- Exibir cabeçalho com ícone (`HeroIcons.lightBulb`) e label "Pensamento"
- Animar a expansão/colapso com `AnimatedCrossFade`
- Exibir o conteúdo do thinking em texto preformatado (cor `AppColors.textSecondary`, fonte JetBrains Mono)
- Manter estado local `_isExpanded` (começa `false`, i.e., colapsado por padrão)

**Estrutura do Widget:**

```dart
class ThinkingPanel extends StatefulWidget {
  const ThinkingPanel({required this.thinking, super.key});
  final String thinking;
  // ...
}
```

**Layout visual (dentro do build):**

```
[ lightBulb icon ] Pensamento   [ chevronDown/Up ]
─────────────────────────────────────────────────
(quando expandido)
  <texto do thinking em textSecondary, fonte mono>
```

- Container com `color: AppColors.accentDark`, `borderRadius: 12`
- Borda: `Border.all(color: AppColors.accentLight)`
- Header: `InkWell` com `onTap` que alterna `_isExpanded`
- Conteúdo: `AnimatedCrossFade` com duração `200ms`

---

## Arquivos a EDITAR

### 3. `lib/features/home/models/chat_message.dart`

**Linha 2 — Adicionar campo `thinking` no construtor:**

```
// ANTES (linha 2-6):
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

// DEPOIS:
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.thinking,
  });
```

**Linha 8-13 — Atualizar `factory fromJson`:**

```
// ANTES:
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.now(),
    );
  }

// DEPOIS:
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.now(),
      thinking: json['thinking'] as String?,
    );
  }
```

**Linha 16-18 — Adicionar campo `thinking`:**

```
// ANTES:
  final String role;
  final String content;
  final DateTime timestamp;

// DEPOIS:
  final String role;
  final String content;
  final DateTime timestamp;
  final String? thinking;
```

**Linha 20-30 — Atualizar `copyWith`:**

```
// ANTES:
  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

// DEPOIS:
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
```

---

### 4. `lib/core/services/ai_service.dart`

**Linha 13-17 — Alterar assinatura de `sendMessageStream`:**

O stream agora retorna `AiStreamChunk` em vez de `String`, e aceita o parâmetro `enableThinking`.

```
// ANTES:
  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  });

// DEPOIS:
  Stream<AiStreamChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
    bool enableThinking = false,
  });
```

**Linha 1 — Adicionar import:**

```
// ADICIONAR após os imports existentes:
import 'package:wolfchat/core/models/ai_stream_chunk.dart';
```

---

### 5. `lib/core/services/open_router_service.dart`

**Linha 1 — Adicionar import:**

```
// ADICIONAR no topo, junto aos imports existentes:
import 'package:wolfchat/core/models/ai_stream_chunk.dart';
```

**Linha 86-96 — Atualizar assinatura e corpo da requisição:**

```
// ANTES:
  @override
  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async* {
    final url = Uri.parse('$_baseUrl/chat/completions');
    // ...
    final body = jsonEncode({
      'model': model,
      'messages': allMessages,
      'temperature': 0.7,
      'max_tokens': 2048,
      'stream': true,
    });

// DEPOIS:
  @override
  Stream<AiStreamChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
    bool enableThinking = false,
  }) async* {
    final url = Uri.parse('$_baseUrl/chat/completions');
    // ...
    final body = jsonEncode({
      'model': model,
      'messages': allMessages,
      'temperature': 0.7,
      'max_tokens': 2048,
      'stream': true,
      if (enableThinking) 'include_reasoning': true,
    });
```

**Linha 127-138 — Atualizar parsing do stream para capturar `reasoning`:**

```
// ANTES:
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>;
          if (choices.isNotEmpty) {
            final choice = choices[0] as Map<String, dynamic>;
            final delta = choice['delta'] as Map<String, dynamic>;
            final content = delta['content'] as String?;
            if (content != null) {
              yield content;
            }
          }
        }

// DEPOIS:
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>;
          if (choices.isNotEmpty) {
            final choice = choices[0] as Map<String, dynamic>;
            final delta = choice['delta'] as Map<String, dynamic>;
            final content = delta['content'] as String?;
            final reasoning = delta['reasoning'] as String?;
            if (content != null || reasoning != null) {
              yield AiStreamChunk(content: content, thinking: reasoning);
            }
          }
        }
```

---

### 6. `lib/core/services/groq_service.dart`

**Linha 1 — Adicionar import:**

```
import 'package:wolfchat/core/models/ai_stream_chunk.dart';
```

**Linha 86-96 — Atualizar assinatura:**

```
// ANTES:
  @override
  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async* {

// DEPOIS:
  @override
  Stream<AiStreamChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
    bool enableThinking = false,
  }) async* {
```

**Linha 127-138 — Atualizar yield:**

```
// ANTES:
            final content = delta['content'] as String?;
            if (content != null) {
              yield content;
            }

// DEPOIS:
            final content = delta['content'] as String?;
            if (content != null) {
              yield AiStreamChunk(content: content);
            }
```

> **Nota sobre Groq thinking:** Modelos Groq como DeepSeek R1 retornam o raciocínio com tags `<think>...</think>` embutidas no content. O parsing dessas tags será responsabilidade do `ConversationViewModel`, que fará o split após acumular o conteúdo completo — mantendo os serviços simples.

---

### 7. `lib/core/services/open_code_zen_service.dart`

Mesmas alterações análogas ao `groq_service.dart`:

**Linha 1 — import `AiStreamChunk`**

**Linha 86-96 — Assinatura com `Stream<AiStreamChunk>` e `bool enableThinking = false`**

**Linha 127-138 — yield `AiStreamChunk(content: content)`**

---

### 8. `lib/features/home/viewmodels/conversation_viewmodel.dart`

**Linha 36-40 — Adicionar estado `_isThinkingEnabled`:**

```
// ADICIONAR junto às variáveis de estado privado:
  bool _isThinkingEnabled = false;
```

**Linha 42-46 — Adicionar getter:**

```
// ADICIONAR junto aos getters públicos:
  bool get isThinkingEnabled => _isThinkingEnabled;
```

**Após linha 50 `cancelCurrentRequest()` — Adicionar método `toggleThinking`:**

```dart
  void toggleThinking() {
    _isThinkingEnabled = !_isThinkingEnabled;
    notifyListeners();
  }
```

**Linha 191 e 291 — Nas funções `_sendToAI` e `sendMessage`, alterar chamada do stream:**

```
// ANTES (em ambas as funções, linha ~242 e ~373):
      final stream = service.sendMessageStream(
        messages: _messages,
        model: modelId,
        systemPrompt: systemPrompt,
      );

// DEPOIS:
      final stream = service.sendMessageStream(
        messages: _messages,
        model: modelId,
        systemPrompt: systemPrompt,
        enableThinking: _isThinkingEnabled,
      );
```

**Linha ~233-256 e ~364-388 — Atualizar loop de streaming para acumular thinking:**

Em `_sendToAI`, alterar o buffer e o loop `await for`:

```
// ANTES:
      final assistantBuffer = StringBuffer();
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: '',
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();
      // ...
      await for (final chunk in stream) {
        assistantBuffer.write(chunk);
        _messages[_messages.length - 1] = assistantMessage.copyWith(
          content: assistantBuffer.toString(),
        );
        notifyListeners();
      }

// DEPOIS:
      final assistantBuffer = StringBuffer();
      final thinkingBuffer = StringBuffer();
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: '',
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();
      // ...
      await for (final chunk in stream) {
        if (chunk.thinking != null) {
          thinkingBuffer.write(chunk.thinking);
        }
        if (chunk.content != null) {
          assistantBuffer.write(chunk.content);
        }
        _messages[_messages.length - 1] = assistantMessage.copyWith(
          content: assistantBuffer.toString(),
          thinking: thinkingBuffer.isNotEmpty
              ? thinkingBuffer.toString()
              : null,
        );
        notifyListeners();
      }
```

> Aplicar as mesmas alterações no método `sendMessage` (~linha 364-388).

---

### 9. `lib/features/home/viewmodels/home_viewmodel.dart`

**Linha 46 — Adicionar getter `isThinkingEnabled`:**

```
// ADICIONAR junto aos getters delegados ao conversation:
  bool get isThinkingEnabled =>
      _isInitialized && conversation.isThinkingEnabled;
```

**Após linha 203 `cancelCurrentRequest()` — Adicionar método `toggleThinking`:**

```dart
  void toggleThinking() {
    if (!_isInitialized) return;
    conversation.toggleThinking();
  }
```

---

### 10. `lib/features/home/views/widgets/bottom_input.dart`

**Linha 6-12 — Adicionar parâmetros ao widget:**

```
// ANTES:
class BottomInput extends StatefulWidget {
  const BottomInput({
    required this.onSendMessage,
    required this.isLoading,
    this.onCancel,
    super.key,
  });

  final void Function(String) onSendMessage;
  final bool isLoading;
  final void Function()? onCancel;

// DEPOIS:
class BottomInput extends StatefulWidget {
  const BottomInput({
    required this.onSendMessage,
    required this.isLoading,
    required this.isThinkingEnabled,
    required this.onToggleThinking,
    this.onCancel,
    super.key,
  });

  final void Function(String) onSendMessage;
  final bool isLoading;
  final bool isThinkingEnabled;
  final VoidCallback onToggleThinking;
  final void Function()? onCancel;
```

**Linha 88-96 — Adicionar botão de thinking na Row (entre o ícone `plusCircle` e o `TextField`):**

Substituir o bloco do `HeroIcon(plusCircle)` + `SizedBox` mantendo-os e inserindo o botão de thinking a seguir:

```
// SUBSTITUIR (linhas ~89-96):
            const HeroIcon(
              HeroIcons.plusCircle,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 8),

// POR:
            const HeroIcon(
              HeroIcons.plusCircle,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 4),
            _ThinkingToggleButton(
              isEnabled: widget.isThinkingEnabled,
              onTap: widget.onToggleThinking,
            ),
            const SizedBox(width: 8),
```

**Após o build, adicionar widget privado `_ThinkingToggleButton`:**

```dart
class _ThinkingToggleButton extends StatelessWidget {
  const _ThinkingToggleButton({
    required this.isEnabled,
    required this.onTap,
  });

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isEnabled ? 'Desativar thinking' : 'Ativar thinking',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.brand500.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? AppColors.brand400
                  : Colors.transparent,
            ),
          ),
          child: HeroIcon(
            HeroIcons.lightBulb,
            size: 20,
            color: isEnabled
                ? AppColors.brand400
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
```

---

### 11. `lib/features/home/views/widgets/chat_messages_list.dart`

**Linha 1 — Adicionar import do `ThinkingPanel`:**

```
// ADICIONAR junto aos imports:
import 'package:wolfchat/features/home/views/widgets/thinking_panel.dart';
```

**Linha 409-435 (`_buildBotMessage`) — Adicionar `ThinkingPanel` no topo do `Column`:**

```
// ANTES:
  Widget _buildBotMessage(BuildContext context) {
    if (message.content.isEmpty && isLoading) {
      return const _AnimatedEllipsis();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          // ...
        ),
        if (message.content.isNotEmpty)
          _MessageActions(text: message.content, onRetry: onRetry),
      ],
    );
  }

// DEPOIS:
  Widget _buildBotMessage(BuildContext context) {
    if (message.content.isEmpty && isLoading) {
      return const _AnimatedEllipsis();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.thinking != null && message.thinking!.isNotEmpty) ...[
          ThinkingPanel(thinking: message.thinking!),
          const SizedBox(height: 12),
        ],
        MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyler.getStyleSheet(context),
          selectable: true,
          builders: {
            'code': CodeBuilder(),
            'hr': HrBuilder(),
          },
          onTapLink: (text, href, title) {
            if (href != null) {
              // Handle link tap
            }
          },
        ),
        if (message.content.isNotEmpty)
          _MessageActions(text: message.content, onRetry: onRetry),
      ],
    );
  }
```

---

### 12. `lib/features/home/views/widgets/main_chat_view.dart`

**Linha 66-70 — Passar novas props ao `BottomInput`:**

```
// ANTES:
              BottomInput(
                onSendMessage: viewModel.sendMessage,
                isLoading: viewModel.isSendingMessage,
                onCancel: viewModel.cancelCurrentRequest,
              ),

// DEPOIS:
              BottomInput(
                onSendMessage: viewModel.sendMessage,
                isLoading: viewModel.isSendingMessage,
                isThinkingEnabled: viewModel.isThinkingEnabled,
                onToggleThinking: viewModel.toggleThinking,
                onCancel: viewModel.cancelCurrentRequest,
              ),
```

---

## Conteúdo Completo do `thinking_panel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class ThinkingPanel extends StatefulWidget {
  const ThinkingPanel({required this.thinking, super.key});

  final String thinking;

  @override
  State<ThinkingPanel> createState() => _ThinkingPanelState();
}

class _ThinkingPanelState extends State<ThinkingPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentLight),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            splashColor: AppColors.brand500.withAlpha(20),
            highlightColor: AppColors.brand500.withAlpha(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const HeroIcon(
                    HeroIcons.lightBulb,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pensamento',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0.0,
                    child: const HeroIcon(
                      HeroIcons.chevronDown,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
              ),
              child: SelectableText(
                widget.thinking,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Resumo das Alterações

| Ação   | Arquivo                                                  | Descrição                                              |
|--------|----------------------------------------------------------|--------------------------------------------------------|
| CRIAR  | `lib/core/models/ai_stream_chunk.dart`                   | Modelo do chunk de stream com campos `content` e `thinking` |
| CRIAR  | `lib/features/home/views/widgets/thinking_panel.dart`    | Widget colapsível para exibir o reasoning da IA        |
| EDITAR | `lib/features/home/models/chat_message.dart`             | Adicionar campo `thinking: String?` (linhas 4, 13, 18, 20-30) |
| EDITAR | `lib/core/services/ai_service.dart`                      | Assinatura `Stream<AiStreamChunk>` + `enableThinking` (linha 13) |
| EDITAR | `lib/core/services/open_router_service.dart`             | Stream retorna `AiStreamChunk`, captura `reasoning` do delta (linhas 86, 99, 127) |
| EDITAR | `lib/core/services/groq_service.dart`                    | Stream retorna `AiStreamChunk` (linhas 86, 134)        |
| EDITAR | `lib/core/services/open_code_zen_service.dart`           | Stream retorna `AiStreamChunk` (linhas 86, 134)        |
| EDITAR | `lib/features/home/viewmodels/conversation_viewmodel.dart` | Adicionar `_isThinkingEnabled`, `toggleThinking()`, buffers de thinking (linhas 36, 42, 50, 242, 373) |
| EDITAR | `lib/features/home/viewmodels/home_viewmodel.dart`       | Getter `isThinkingEnabled` e método `toggleThinking()` (linhas 46, 203) |
| EDITAR | `lib/features/home/views/widgets/bottom_input.dart`      | Adicionar `isThinkingEnabled`, `onToggleThinking`, widget `_ThinkingToggleButton` (linhas 7, 14, 89) |
| EDITAR | `lib/features/home/views/widgets/chat_messages_list.dart`| Adicionar `ThinkingPanel` no `_buildBotMessage` (linha 409) |
| EDITAR | `lib/features/home/views/widgets/main_chat_view.dart`    | Passar `isThinkingEnabled` e `onToggleThinking` ao `BottomInput` (linha 66) |

---

## Ordem de Implementação Recomendada

1. **`ai_stream_chunk.dart`** — Define o tipo base; sem dependências
2. **`chat_message.dart`** — Adiciona o campo `thinking`; sem dependências externas
3. **`ai_service.dart`** — Atualiza a interface abstrata
4. **`open_router_service.dart`, `groq_service.dart`, `open_code_zen_service.dart`** — Implementam a nova interface (podem ser feitos em paralelo)
5. **`conversation_viewmodel.dart`** — Usa os serviços atualizados e gerencia o estado
6. **`home_viewmodel.dart`** — Delega ao conversation
7. **`thinking_panel.dart`** — Widget sem dependência de estado externo
8. **`bottom_input.dart`** — Usa os novos props
9. **`chat_messages_list.dart`** — Usa `ThinkingPanel`
10. **`main_chat_view.dart`** — Conecta tudo

---

## Notas Técnicas

- **OpenRouter** suporta `include_reasoning: true` nativamente, retornando `delta.reasoning` no stream SSE
- **Groq** (modelos como DeepSeek R1) retorna raciocínio via tags `<think>...</think>` no content — pode ser parseado no ViewModel futuramente com uma regex se necessário
- **OpenCode Zen** — sem documentação conhecida de reasoning; o parâmetro `enableThinking` é aceito mas ignorado na implementação inicial
- O campo `thinking` em `ChatMessage` é `nullable`, portanto nenhuma mensagem existente é quebrada
- O estado `_isThinkingEnabled` vive no `ConversationViewModel` e persiste durante a sessão (não é salvo em banco — comportamento intencional, reset ao reiniciar o app)

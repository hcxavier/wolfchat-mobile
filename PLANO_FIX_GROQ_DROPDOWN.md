# Plano detalhado de correção - bug dos modelos Groq adicionados pelo dropdown

## Objetivo

Corrigir o cenário em que modelos **Groq** adicionados pelo dropdown em **Gerenciar Modelos** não retornam resposta no chat.

---

## Diagnóstico técnico (hipótese raiz)

Com o código atual, a lista de modelos do Groq é carregada de `GET /models` e exibida no dropdown sem filtro de compatibilidade para chat.

- Arquivo: `lib/core/services/groq_service.dart`
- Trecho atual: `getAvailableModels()` em `lib/core/services/groq_service.dart:163` até `lib/core/services/groq_service.dart:216`
- Ponto crítico: mapeamento direto de todos os modelos retornados (`lib/core/services/groq_service.dart:179` até `lib/core/services/groq_service.dart:184`)

Impacto esperado:

1. O dropdown pode incluir modelos que não são próprios para `chat/completions` (ex.: áudio/moderação).
2. Quando o usuário seleciona um desses modelos, a chamada em streaming falha com HTTP 400, mas hoje a mensagem final é genérica.
3. O usuário interpreta como “modelo não responde”.

---

## Arquivos que devem ser criados

### 1) Arquivo de teste unitário

- **Criar:** `test/core/services/groq_service_test.dart`
- **Objetivo:** validar o filtro de modelos Groq compatíveis com chat e o mapeamento de erro 400 para mensagem amigável.
- **Linhas:** arquivo novo (iniciar na linha 1).

### 2) (Opcional, recomendado) arquivo de documentação interna rápida

- **Criar:** `docs/groq-model-compatibility.md`
- **Objetivo:** registrar regras de filtro aplicadas para modelos Groq (chat x não chat), para manutenção futura.
- **Linhas:** arquivo novo (iniciar na linha 1).

> Se o projeto não usar pasta `docs`, este item pode ser omitido sem impacto na correção funcional.

---

## Arquivos que devem ser editados

## 1) `lib/core/services/groq_service.dart`

### Edição A - filtrar modelos do dropdown para apenas modelos de chat

- **Onde editar:** `lib/core/services/groq_service.dart:177` até `lib/core/services/groq_service.dart:184`
- **Alteração:** após mapear `AvailableModel`, filtrar por uma regra de compatibilidade de chat.

Implementar helper privado no mesmo arquivo:

- **Inserir método novo:** próximo de `lib/core/services/groq_service.dart:162` (antes de `getAvailableModels` ou no fim da classe)
  - Exemplo de assinatura: `_isLikelyChatModelId(String modelId)`
  - Regra inicial sugerida: excluir IDs com padrões como `whisper`, `tts`, `speech`, `transcribe`, `guard`.

### Edição B - melhorar tratamento de erro 400 no streaming

- **Onde editar:** `lib/core/services/groq_service.dart:142` até `lib/core/services/groq_service.dart:159`
- **Alteração:** trocar descarte do body (`await response.stream.bytesToString();`) por leitura em variável e parsing da mensagem de erro.

Comportamento desejado:

- Se `statusCode == 400` e o body indicar incompatibilidade do modelo com chat/completions, lançar `ModelException` com mensagem clara (ex.: “Este modelo Groq não suporta chat. Escolha outro no Gerenciar Modelos.”).
- Manter os tratamentos existentes de 401/429/5xx.

### Edição C - aplicar o mesmo mapeamento de erro 400 no modo não-stream

- **Onde editar:** `lib/core/services/groq_service.dart:66` até `lib/core/services/groq_service.dart:83`
- **Alteração:** em `sendMessage()`, incluir parsing de body para HTTP 400 com a mesma mensagem amigável usada no streaming.

Resultado: comportamento consistente independentemente do modo de requisição.

---

## 2) `lib/features/home/views/widgets/dialogs/manage_models_modal.dart`

### Edição D - mensagem de erro específica quando não houver modelos de chat

- **Onde editar:** `lib/features/home/views/widgets/dialogs/manage_models_modal.dart:84` até `lib/features/home/views/widgets/dialogs/manage_models_modal.dart:86`
- **Alteração:** substituir “Nenhum modelo disponível” por texto específico de chat, ex.: “Nenhum modelo de chat disponível para esta chave.”

### Edição E - hint do dropdown mais explícito (UX)

- **Onde editar:** `lib/features/home/views/widgets/dialogs/manage_models_modal.dart:451` até `lib/features/home/views/widgets/dialogs/manage_models_modal.dart:455`
- **Alteração:** quando lista estiver vazia, mostrar hint contextual (ex.: “Nenhum modelo de chat compatível”).

---

## 3) `lib/core/utils/error_message_mapper.dart` (opcional)

### Edição F - reforçar mapeamento para mensagens com “chat/completions”

- **Onde editar:** `lib/core/utils/error_message_mapper.dart:41` até `lib/core/utils/error_message_mapper.dart:57`
- **Alteração:** incluir regra textual adicional para converter mensagens cruas de incompatibilidade de endpoint em texto amigável ao usuário.

> Esta edição é opcional se o `GroqService` já lançar `ModelException` amigável.

---

## Sequência de execução recomendada

1. Editar `groq_service.dart` (Edições A, B, C).
2. Editar `manage_models_modal.dart` (Edições D, E).
3. Criar teste unitário `test/core/services/groq_service_test.dart`.
4. (Opcional) editar `error_message_mapper.dart` e criar `docs/groq-model-compatibility.md`.
5. Rodar validações:
   - `flutter analyze`
   - `flutter test`

---

## Critérios de aceite

1. Dropdown de Groq não exibe modelos incompatíveis com chat.
2. Modelo Groq escolhido no dropdown responde normalmente no chat.
3. Se houver tentativa de usar modelo incompatível (ex.: cadastro manual), o app mostra erro claro e acionável.
4. Não há regressão para OpenRouter e OpenCode Zen.

---

## Cenários de validação manual

1. Abrir **Configurações > Gerenciar Modelos**.
2. Selecionar provedor **Groq**.
3. Adicionar um modelo vindo do dropdown.
4. Selecionar esse modelo no topo da tela principal.
5. Enviar mensagem e confirmar resposta da IA.
6. Cadastrar manualmente um ID inválido/incompatível e confirmar mensagem de erro amigável.

---

## Risco e mitigação

- **Risco:** filtro muito agressivo esconder modelo válido.
  - **Mitigação:** manter campo “Outro” no dropdown para entrada manual de ID.
- **Risco:** mudança de catálogo da Groq quebrar heurística de filtro.
  - **Mitigação:** centralizar regra em helper único e cobrir com teste unitário.

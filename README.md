# WolfChat Mobile

O WolfChat Mobile é uma aplicação de chat moderna e de alto desempenho desenvolvida com Flutter. Possui integração profunda com modelos de IA avançados via Groq, OpenRouter e OpenCodeZen, proporcionando uma experiência de chat rica e interativa.

## Funcionalidades

- **Conversas Potencializadas por IA**: Converse com diversos modelos de IA usando os serviços Groq e OpenRouter.
- **Painel de Pensamento (Thinking Panel)**: Representação visual do processo de raciocínio da IA.
- **Temas Dinâmicos**: Temas cuidadosamente elaborados com suporte a modo escuro e claro.
- **Arquitetura Limpa**: Construído usando uma arquitetura robusta para facilitar a manutenção e escalabilidade.
- **Suporte a Múltiplos Serviços**: Integrado com vários provedores de IA para maior flexibilidade.

## Stack Tecnológica

- **Framework**: [Flutter](https://flutter.dev/)
- **Gerenciamento de Estado**: Padrão Provider / ViewModel
- **Serviços de IA**: Groq, OpenRouter, OpenCodeZen
- **Estilização**: Abordagem de estilo semelhante ao Vanilla CSS no Flutter com temas personalizados

## Primeiros Passos

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/wolfchat-mobile.git
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Configure as Chaves de API**:
   Abra as configurações do aplicativo e insira suas chaves de API do Groq ou OpenRouter.

4. **Execute o app**:
   ```bash
   flutter run
   ```

## Estrutura do Projeto

- `lib/core`: Utilitários principais, modelos e serviços.
- `lib/features`: Lógica específica de funcionalidades e componentes de UI (Home, Search).
- `lib/shared`: Widgets compartilhados e componentes comuns.

## Licença

Este projeto está licenciado sob o arquivo LICENSE presente no diretório raiz.

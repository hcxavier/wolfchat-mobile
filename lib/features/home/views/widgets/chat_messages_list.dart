import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/core/theme/markdown_styler.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({
    required this.messages,
    this.isSendingMessage = false,
    this.onRetry,
    super.key,
  });

  final List<ChatMessage> messages;
  final bool isSendingMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    var lastAssistantIndex = -1;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == 'assistant') {
        lastAssistantIndex = i;
        break;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MessageBubble(
            message: message,
            isUser: isUser,
            isLoading: isSendingMessage,
            onRetry: index == lastAssistantIndex ? onRetry : null,
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.isLoading,
    this.onRetry,
  });

  final ChatMessage message;
  final bool isUser;
  final bool isLoading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUser)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.brand500,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildUserMessage(),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildBotMessage(context),
            ),
          ),
      ],
    );
  }

  Widget _buildUserMessage() {
    final lines = message.content.split('\n');

    return Wrap(
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          _buildUserLine(lines[i]),
          if (i < lines.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildUserLine(String line) {
    if (line.startsWith('> ')) {
      return Container(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.brand500,
              width: 3,
            ),
          ),
          color: Color(0x0DFFFFFF),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(
          line.substring(2),
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontStyle: FontStyle.italic,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      );
    }

    final commandMatch = RegExp(r'^(\/[\w-]+)(\s.*)?$').firstMatch(line);
    if (commandMatch != null) {
      final command = commandMatch.group(1)!;
      final args = commandMatch.group(2);
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: command,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (args != null)
              TextSpan(
                text: args,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      );
    }

    return Text(
      line,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildBotMessage(BuildContext context) {
    if (message.content.isEmpty && isLoading) {
      return const _AnimatedEllipsis();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
}

class _MessageActions extends StatelessWidget {
  const _MessageActions({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _CopyButton(text: text),
          if (onRetry != null) _RetryButton(onRetry: onRetry!),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.brand500.withAlpha(26),
      highlightColor: AppColors.brand500.withAlpha(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceHover),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeroIcon(
              HeroIcons.arrowPath,
              size: 18,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              'Tentar novamente',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});

  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copy,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.brand500.withAlpha(26),
      highlightColor: AppColors.brand500.withAlpha(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.brand500.withAlpha(26)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _copied ? AppColors.brand400 : AppColors.surfaceHover,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: HeroIcon(
                _copied ? HeroIcons.check : HeroIcons.documentDuplicate,
                key: ValueKey(_copied),
                size: 18,
                color: _copied ? AppColors.brand400 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _copied ? AppColors.brand400 : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: _copied ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(_copied ? 'Copiado!' : 'Copiar mensagem'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEllipsis extends StatefulWidget {
  const _AnimatedEllipsis();

  @override
  State<_AnimatedEllipsis> createState() => _AnimatedEllipsisState();
}

class _AnimatedEllipsisState extends State<_AnimatedEllipsis>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )
          // ignore: discarded_futures - repeat is fire-and-forget in initState
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index / 3;
            final value = (_controller.value + delay) % 1.0;
            final opacity = value < 0.5
                ? (0.3 + (value * 2) * 0.7)
                : (1.0 - ((value - 0.5) * 2) * 0.7);
            return Padding(
              padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/core/theme/markdown_styler.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({
    required this.messages,
    this.isSendingMessage = false,
    super.key,
  });

  final List<ChatMessage> messages;
  final bool isSendingMessage;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
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
  });

  final ChatMessage message;
  final bool isUser;
  final bool isLoading;

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
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: commandMatch.group(1),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (commandMatch.group(2) != null)
              TextSpan(
                text: commandMatch.group(2),
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

    return MarkdownBody(
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

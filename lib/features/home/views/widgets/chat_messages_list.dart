import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/core/theme/markdown_styler.dart';
import 'package:wolfchat/features/home/models/chat_message.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({required this.messages, super.key});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MessageBubble(
            message: message,
            isUser: isUser,
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
  });

  final ChatMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brand500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.brand500 : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: isUser
                  ? null
                  : Border.all(
                      color: const Color(0x1AFFFFFF),
                      width: 1,
                    ),
            ),
            child: isUser ? _buildUserMessage() : _buildBotMessage(context),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUserMessage() {
    final lines = message.content.split('\n');

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
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
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.brand500,
              width: 3,
            ),
          ),
          color: const Color(0x0DFFFFFF),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(
          line.substring(2),
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontStyle: FontStyle.italic,
            fontSize: 14,
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
                fontSize: 14,
              ),
            ),
            if (commandMatch.group(2) != null)
              TextSpan(
                text: commandMatch.group(2),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
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
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildBotMessage(BuildContext context) {
    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyler.getStyleSheet(context),
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          // Handle link tap
        }
      },
    );
  }
}

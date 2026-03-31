import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SidebarConversationList extends StatelessWidget {
  const SidebarConversationList({
    required this.conversations,
    required this.currentConversationId,
    required this.onConversationSelected,
    super.key,
  });

  final List<Conversation> conversations;
  final int? currentConversationId;
  final void Function(int) onConversationSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: conversations.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nenhuma conversa ainda.\nClique em + para começar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return SidebarItem(
                  title: conversation.title,
                  isSelected: conversation.id == currentConversationId,
                  onTap: () => onConversationSelected(conversation.id),
                );
              },
            ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    required this.title,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.surfaceHover,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.surfaceHover : Colors.transparent,
          ),
          child: Row(
            children: [
              HeroIcon(
                HeroIcons.chatBubbleLeft,
                size: 16,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

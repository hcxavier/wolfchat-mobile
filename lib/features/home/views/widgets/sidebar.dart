import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/views/widgets/sidebar_conversation_widgets.dart';
import 'package:wolfchat/features/home/views/widgets/sidebar_footer_widget.dart';
import 'package:wolfchat/features/home/views/widgets/sidebar_header_widgets.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.onClose,
    required this.onOpenSettings,
    required this.onSearchTap,
    required this.userName,
    required this.conversations,
    required this.currentConversationId,
    required this.onConversationSelected,
    required this.onNewConversation,
    required this.onDeleteConversation,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenSettings;
  final VoidCallback onSearchTap;
  final String userName;
  final List<Conversation> conversations;
  final int? currentConversationId;
  final void Function(int) onConversationSelected;
  final VoidCallback onNewConversation;
  final void Function(int) onDeleteConversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.surfaceCard,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SidebarHeader(onClose: onClose),
            SidebarSearch(onTap: onSearchTap),
            const SizedBox(height: 16),
            const _RecentSectionLabel(),
            _SidebarNewChatButton(onTap: onNewConversation),
            const SizedBox(height: 16),
            SidebarConversationList(
              conversations: conversations,
              currentConversationId: currentConversationId,
              onConversationSelected: onConversationSelected,
              onDeleteConversation: onDeleteConversation,
            ),
            SidebarFooter(
              userName: userName,
              onOpenSettings: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSectionLabel extends StatelessWidget {
  const _RecentSectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'RECENTES',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNewChatButton extends StatelessWidget {
  const _SidebarNewChatButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: AppColors.brand500,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.brand600,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeroIcon(
                  HeroIcons.plus,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  'Novo chat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

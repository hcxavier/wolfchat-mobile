import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/data/models/conversation.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SidebarConversationList extends StatelessWidget {
  const SidebarConversationList({
    required this.conversations,
    required this.currentConversationId,
    required this.onConversationSelected,
    required this.onDeleteConversation,
    super.key,
  });

  final List<Conversation> conversations;
  final int? currentConversationId;
  final void Function(int) onConversationSelected;
  final void Function(int) onDeleteConversation;

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
                  conversationId: conversation.id,
                  title: conversation.title,
                  isSelected: conversation.id == currentConversationId,
                  onTap: () => onConversationSelected(conversation.id),
                  onDelete: onDeleteConversation,
                );
              },
            ),
    );
  }
}

class SidebarItem extends StatefulWidget {
  const SidebarItem({
    required this.conversationId,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final int conversationId;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;
  final void Function(int)? onDelete;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    if (_overlayEntry != null) {
      _removeMenu();
      return;
    }

    final renderButton =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final renderOverlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderButton == null || renderOverlay == null) return;

    final buttonSize = renderButton.size;
    final buttonPosition = renderButton.localToGlobal(
      Offset.zero,
      ancestor: renderOverlay,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeMenu,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: buttonPosition.dx - 150,
            top: buttonPosition.dy + buttonSize.height + 4,
            width: 180,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(76),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DeleteMenuItem(
                      onTap: () {
                        _removeMenu();
                        widget.onDelete?.call(widget.conversationId);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.surfaceHover,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected
                ? AppColors.surfaceHover
                : Colors.transparent,
          ),
          child: Row(
            children: [
              HeroIcon(
                HeroIcons.chatBubbleLeft,
                size: 16,
                color: widget.isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: widget.isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onDelete != null)
                Material(
                  key: _buttonKey,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: _showMenu,
                    borderRadius: BorderRadius.circular(6),
                    hoverColor: AppColors.surfaceHover,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: HeroIcon(
                        HeroIcons.ellipsisHorizontal,
                        size: 18,
                        color: widget.isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteMenuItem extends StatefulWidget {
  const _DeleteMenuItem({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_DeleteMenuItem> createState() => _DeleteMenuItemState();
}

class _DeleteMenuItemState extends State<_DeleteMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.brand500.withAlpha(25)
                : Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              HeroIcon(
                HeroIcons.trash,
                size: 16,
                color: _isHovered ? AppColors.brand500 : AppColors.brand400,
              ),
              const SizedBox(width: 10),
              Text(
                'Excluir conversa',
                style: TextStyle(
                  color: _isHovered ? AppColors.brand500 : AppColors.brand400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

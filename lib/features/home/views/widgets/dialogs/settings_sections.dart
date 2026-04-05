import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/settings_button.dart';
import 'package:wolfchat/shared/widgets/animated_dialog.dart';

class MainSettingsContent extends StatelessWidget {
  const MainSettingsContent({
    required this.nameController,
    required this.selectedLanguage,
    required this.onClose,
    required this.onShowApiKeys,
    required this.onShowManageModels,
    required this.onShowSystemPrompt,
    required this.onLanguageChanged,
    required this.onDeleteAllChats,
    required this.onSave,
    super.key,
  });

  final TextEditingController nameController;
  final String selectedLanguage;
  final VoidCallback onClose;
  final ValueChanged<BuildContext> onShowApiKeys;
  final ValueChanged<BuildContext> onShowManageModels;
  final ValueChanged<BuildContext> onShowSystemPrompt;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onDeleteAllChats;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsHeader(onClose: onClose),
        const SizedBox(height: 24),
        _buildSectionTitle('Perfil'),
        const SizedBox(height: 10),
        _UserNameField(controller: nameController),
        const SizedBox(height: 24),
        _SettingsButtonsGroup(
          onShowApiKeys: onShowApiKeys,
          onShowManageModels: onShowManageModels,
          onShowSystemPrompt: onShowSystemPrompt,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Preferências'),
        const SizedBox(height: 10),
        _LanguageSelector(
          selectedLanguage: selectedLanguage,
          onChanged: onLanguageChanged,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Dados'),
        const SizedBox(height: 10),
        SettingsButton(
          icon: HeroIcons.trash,
          title: 'Excluir todos os chats',
          onTap: onDeleteAllChats,
          isDestructive: true,
        ),
        const SizedBox(height: 28),
        _SaveButton(onSave: onSave),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.surfaceHover,
            ),
          ),
          child: const HeroIcon(
            HeroIcons.cog6Tooth,
            size: 20,
            color: AppColors.brand400,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Personalize sua experiência',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppColors.surfaceHover,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.surfaceHover,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: HeroIcon(
                  HeroIcons.xMark,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserNameField extends StatelessWidget {
  const _UserNameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14, right: 12),
            child: HeroIcon(
              HeroIcons.user,
              size: 18,
              color: AppColors.brand400,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintText: 'Seu nome',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SettingsButtonsGroup extends StatelessWidget {
  const _SettingsButtonsGroup({
    required this.onShowApiKeys,
    required this.onShowManageModels,
    required this.onShowSystemPrompt,
  });
  final ValueChanged<BuildContext> onShowApiKeys;
  final ValueChanged<BuildContext> onShowManageModels;
  final ValueChanged<BuildContext> onShowSystemPrompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: Column(
        children: [
          _SettingsButtonItem(
            icon: HeroIcons.key,
            title: 'Configurar API Keys',
            onTap: () => onShowApiKeys(context),
          ),
          Container(
            height: 1,
            color: AppColors.surfaceHover.withValues(alpha: 0.5),
          ),
          _SettingsButtonItem(
            icon: HeroIcons.cpuChip,
            title: 'Gerenciar Modelos',
            onTap: () => onShowManageModels(context),
          ),
          Container(
            height: 1,
            color: AppColors.surfaceHover.withValues(alpha: 0.5),
          ),
          _SettingsButtonItem(
            icon: HeroIcons.adjustmentsHorizontal,
            title: 'Personalização (System Prompt)',
            onTap: () => onShowSystemPrompt(context),
          ),
          Container(
            height: 1,
            color: AppColors.surfaceHover.withValues(alpha: 0.5),
          ),
          _SettingsButtonItem(
            icon: HeroIcons.bolt,
            title: 'Prompts Dinâmicos',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsButtonItem extends StatelessWidget {
  const _SettingsButtonItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });
  final HeroIcons icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(14),
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand900.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HeroIcon(
                  icon,
                  size: 18,
                  color: AppColors.brand400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const HeroIcon(
                HeroIcons.chevronRight,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onChanged,
  });
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  static const _languages = [
    'Português (Brasil)',
    'English',
    'Español',
    'Français',
    'Deutsch',
    '日本語',
    '中文',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLanguageMenu(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brand900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const HeroIcon(
                    HeroIcons.language,
                    size: 18,
                    color: AppColors.brand400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedLanguage,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const HeroIcon(
                  HeroIcons.chevronDown,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageMenu(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomLeft(const Offset(0, 8)),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(const Offset(0, 8)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(
        minWidth: button.size.width,
        maxWidth: button.size.width,
        maxHeight: 250,
      ),
      items: _languages.map((lang) {
        final isSelected = lang == selectedLanguage;
        return PopupMenuItem<String>(
          value: lang,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  lang,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.brand400
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const HeroIcon(
                  HeroIcons.check,
                  size: 18,
                  color: AppColors.brand400,
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) onChanged(result);
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSave,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brand500, AppColors.brand600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand500.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Salvar',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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

Future<void> showDeleteAllChatsDialog(
  BuildContext context,
  HomeViewModel viewModel,
) async {
  await showAnimatedDialog<void>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 480),
      child: AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir todos os chats?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Esta ação não pode ser desfeita. '
          'Todos os seus chats serão excluídos permanentemente.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await viewModel.deleteAllConversations();
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ),
  );
}

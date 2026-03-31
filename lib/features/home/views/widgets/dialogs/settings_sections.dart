import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/settings_button.dart';

class MainSettingsContent extends StatelessWidget {
  const MainSettingsContent({
    required this.nameController,
    required this.selectedLanguage,
    required this.onClose,
    required this.onShowApiKeys,
    required this.onShowManageModels,
    required this.onLanguageChanged,
    required this.onDeleteAllChats,
    required this.onSave,
    super.key,
  });

  final TextEditingController nameController;
  final String selectedLanguage;
  final VoidCallback onClose;
  final VoidCallback onShowApiKeys;
  final VoidCallback onShowManageModels;
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
        _UserNameField(controller: nameController),
        const SizedBox(height: 24),
        _SettingsButtonsGroup(
          onShowApiKeys: onShowApiKeys,
          onShowManageModels: onShowManageModels,
        ),
        const SizedBox(height: 24),
        _LanguageSelector(
          selectedLanguage: selectedLanguage,
          onChanged: onLanguageChanged,
        ),
        const SizedBox(height: 24),
        SettingsButton(
          icon: HeroIcons.trash,
          title: 'Excluir todos os chats',
          onTap: onDeleteAllChats,
          isDestructive: true,
        ),
        const SizedBox(height: 24),
        _SaveButton(onSave: onSave),
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
        const HeroIcon(
          HeroIcons.cog6Tooth,
          size: 24,
          color: AppColors.brand300,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Configurações',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            hoverColor: AppColors.surfaceHover,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: HeroIcon(
                HeroIcons.xMark,
                size: 20,
                color: AppColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nome do usuário',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsButtonsGroup extends StatelessWidget {
  const _SettingsButtonsGroup({
    required this.onShowApiKeys,
    required this.onShowManageModels,
  });
  final VoidCallback onShowApiKeys;
  final VoidCallback onShowManageModels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsButton(
          icon: HeroIcons.key,
          title: 'Configurar API Keys',
          onTap: onShowApiKeys,
        ),
        const SizedBox(height: 8),
        SettingsButton(
          icon: HeroIcons.cpuChip,
          title: 'Gerenciar Modelos',
          onTap: onShowManageModels,
        ),
        const SizedBox(height: 8),
        SettingsButton(
          icon: HeroIcons.adjustmentsHorizontal,
          title: 'Personalização (System Prompt)',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        SettingsButton(
          icon: HeroIcons.bolt,
          title: 'Prompts Dinâmicos',
          onTap: () {},
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Idioma da Resposta',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLanguageMenu(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLanguage,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
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
      ],
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
      height: 48,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Salvar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

Future<void> showDeleteAllChatsDialog(
  BuildContext context,
  HomeViewModel viewModel,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
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
  );
}

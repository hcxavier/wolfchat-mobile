import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/settings_button.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/api_keys_modal.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({required this.viewModel, required this.onClose});

  final HomeViewModel viewModel;
  final VoidCallback onClose;

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late final TextEditingController _nameController;
  String _selectedLanguage = 'Português (Brasil)';

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.viewModel.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                        onTap: widget.onClose,
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
                ),
                const SizedBox(height: 24),
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
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
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
                const SizedBox(height: 24),
                SettingsButton(
                  icon: HeroIcons.key,
                  title: 'Configurar API Keys',
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (apiDialogContext) => ApiKeysModal(
                        initialOpenRouter: widget.viewModel.openRouterKey,
                        initialGroq: widget.viewModel.groqKey,
                        initialOpenCodeZen: widget.viewModel.openCodeZenKey,
                        onClose: () => Navigator.of(apiDialogContext).pop(),
                        onSave: (openRouter, groq, openCodeZen) {
                          widget.viewModel.saveApiKeys(
                            openRouter: openRouter,
                            groq: groq,
                            openCodeZen: openCodeZen,
                          );
                          Navigator.of(apiDialogContext).pop();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SettingsButton(
                  icon: HeroIcons.cpuChip,
                  title: 'Gerenciar Modelos',
                  onTap: () {},
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
                const SizedBox(height: 24),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      icon: const HeroIcon(
                        HeroIcons.chevronDown,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      items: _languages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SettingsButton(
                  icon: HeroIcons.trash,
                  title: 'Excluir todos os chats',
                  onTap: () {},
                  isDestructive: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.viewModel.updateUserName(_nameController.text);
                      widget.onClose();
                    },
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

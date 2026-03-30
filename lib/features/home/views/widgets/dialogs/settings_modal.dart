import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/manage_models_modal.dart';
import 'package:wolfchat/features/home/views/widgets/settings_button.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({
    required this.viewModel,
    required this.onClose,
    super.key,
  });

  final HomeViewModel viewModel;
  final VoidCallback onClose;

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _openRouterController;
  late final TextEditingController _groqController;
  late final TextEditingController _openCodeZenController;
  bool _obscureOpenRouter = true;
  bool _obscureGroq = true;
  bool _obscureOpenCodeZen = true;
  String _selectedLanguage = 'Português (Brasil)';
  bool _showApiKeys = false;
  bool _showManageModels = false;

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
    _openRouterController = TextEditingController(
      text: widget.viewModel.openRouterKey,
    );
    _groqController = TextEditingController(text: widget.viewModel.groqKey);
    _openCodeZenController = TextEditingController(
      text: widget.viewModel.openCodeZenKey,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openRouterController.dispose();
    _groqController.dispose();
    _openCodeZenController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surfaceInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildKeyField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          scrollPadding: const EdgeInsets.only(bottom: 120),
          decoration: _inputDecoration(hint).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: HeroIcon(
                obscure ? HeroIcons.eyeSlash : HeroIcons.eye,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => setState(() => _showApiKeys = false),
                customBorder: const CircleBorder(),
                hoverColor: AppColors.surfaceHover,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: HeroIcon(
                    HeroIcons.arrowLeft,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Configurar API Keys',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildKeyField(
          label: 'OpenRouter',
          controller: _openRouterController,
          obscure: _obscureOpenRouter,
          onToggleObscure: () =>
              setState(() => _obscureOpenRouter = !_obscureOpenRouter),
          hint: 'sk-or-v1-...',
        ),
        const SizedBox(height: 16),
        _buildKeyField(
          label: 'Groq',
          controller: _groqController,
          obscure: _obscureGroq,
          onToggleObscure: () => setState(() => _obscureGroq = !_obscureGroq),
          hint: 'gsk_...',
        ),
        const SizedBox(height: 16),
        _buildKeyField(
          label: 'Opencode Zen',
          controller: _openCodeZenController,
          obscure: _obscureOpenCodeZen,
          onToggleObscure: () => setState(
            () => _obscureOpenCodeZen = !_obscureOpenCodeZen,
          ),
          hint: 'oz-...',
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              await widget.viewModel.saveApiKeys(
                openRouter: _openRouterController.text,
                groq: _groqController.text,
                openCodeZen: _openCodeZenController.text,
              );
              setState(() => _showApiKeys = false);
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
              'Concluído',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteAllChatsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
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
              await widget.viewModel.deleteAllConversations();
              if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    if (_showManageModels) {
      return ManageModelsModal(
        viewModel: widget.viewModel,
        onClose: () => setState(() => _showManageModels = false),
      );
    }

    return DialogWrapper(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: _showApiKeys ? _buildApiKeysSection() : _buildMainContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
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
          onTap: () => setState(() => _showApiKeys = true),
        ),
        const SizedBox(height: 8),
        SettingsButton(
          icon: HeroIcons.cpuChip,
          title: 'Gerenciar Modelos',
          onTap: () => setState(() => _showManageModels = true),
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
          onTap: _showDeleteAllChatsDialog,
          isDestructive: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              await widget.viewModel.updateUserName(_nameController.text);
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/api_keys_modal.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/manage_models_modal.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_sections.dart';
import 'package:wolfchat/shared/widgets/animated_dialog.dart';

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
    _selectedLanguage = widget.viewModel.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openRouterController.dispose();
    _groqController.dispose();
    _openCodeZenController.dispose();
    super.dispose();
  }

  void _onSave() {
    // ignore: discarded_futures, Intentional background update
    widget.viewModel.updateUserName(_nameController.text);
    // ignore: discarded_futures, Intentional background update
    widget.viewModel.updateLanguage(_selectedLanguage);
    widget.onClose();
  }

  void _onShowApiKeys(BuildContext context) {
    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => ApiKeysModal(
        openRouterController: _openRouterController,
        groqController: _groqController,
        openCodeZenController: _openCodeZenController,
        obscureOpenRouter: _obscureOpenRouter,
        obscureGroq: _obscureGroq,
        obscureOpenCodeZen: _obscureOpenCodeZen,
        onToggleOpenRouter: () =>
            setState(() => _obscureOpenRouter = !_obscureOpenRouter),
        onToggleGroq: () => setState(() => _obscureGroq = !_obscureGroq),
        onToggleOpenCodeZen: () =>
            setState(() => _obscureOpenCodeZen = !_obscureOpenCodeZen),
        onClose: () => Navigator.of(dialogContext).pop(),
        onSave: () {
          widget.viewModel.saveApiKeys(
            openRouter: _openRouterController.text,
            groq: _groqController.text,
            openCodeZen: _openCodeZenController.text,
          );
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _onShowManageModels(BuildContext context) {
    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => ManageModelsModal(
        viewModel: widget.viewModel,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: 480,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentLight.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand500.withValues(alpha: 0.1),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: MainSettingsContent(
              nameController: _nameController,
              selectedLanguage: _selectedLanguage,
              onClose: widget.onClose,
              onShowApiKeys: _onShowApiKeys,
              onShowManageModels: _onShowManageModels,
              onLanguageChanged: (lang) {
                setState(() => _selectedLanguage = lang);
                // ignore: discarded_futures, Update immediately
                widget.viewModel.updateLanguage(lang);
              },
              onDeleteAllChats: () =>
                  showDeleteAllChatsDialog(context, widget.viewModel),
              onSave: _onSave,
            ),
          ),
        ),
      ),
    );
  }
}

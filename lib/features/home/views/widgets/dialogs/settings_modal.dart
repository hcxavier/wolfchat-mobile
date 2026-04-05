import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_sections.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/system_prompt_dialog.dart';
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

  Future<void> _onSave() async {
    await widget.viewModel.updateUserName(_nameController.text);
    await widget.viewModel.updateLanguage(_selectedLanguage);
    widget.onClose();
  }

  void _onShowApiKeys(BuildContext context) {
    unawaited(context.pushNamed('api-keys'));
  }

  void _onShowManageModels(BuildContext context) {
    unawaited(context.pushNamed('models'));
  }

  void _onShowSystemPrompt(BuildContext context) {
    unawaited(
      showAnimatedDialog<void>(
        context: context,
        builder: (context) => SystemPromptDialog(
          onClose: () => Navigator.of(context).pop(),
          onSave: (_) {},
        ),
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
          width: 640,
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
              onShowSystemPrompt: _onShowSystemPrompt,
              onLanguageChanged: (lang) {
                setState(() => _selectedLanguage = lang);
                unawaited(widget.viewModel.updateLanguage(lang));
              },
              onDeleteAllChats: () =>
                  showDeleteAllChatsDialog(context, widget.viewModel),
              onSave: () => unawaited(_onSave()),
            ),
          ),
        ),
      ),
    );
  }
}

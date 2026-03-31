import 'package:flutter/material.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/manage_models_modal.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_api_keys_section.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_sections.dart';

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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: _showApiKeys
                ? ApiKeysSection(
                    openRouterController: _openRouterController,
                    groqController: _groqController,
                    openCodeZenController: _openCodeZenController,
                    obscureOpenRouter: _obscureOpenRouter,
                    obscureGroq: _obscureGroq,
                    obscureOpenCodeZen: _obscureOpenCodeZen,
                    onToggleOpenRouter: () => setState(
                      () => _obscureOpenRouter = !_obscureOpenRouter,
                    ),
                    onToggleGroq: () =>
                        setState(() => _obscureGroq = !_obscureGroq),
                    onToggleOpenCodeZen: () => setState(
                      () => _obscureOpenCodeZen = !_obscureOpenCodeZen,
                    ),
                    onBack: () => setState(() => _showApiKeys = false),
                    onDone: () {
                      // ignore: discarded_futures, Intentional background update
                      widget.viewModel.saveApiKeys(
                        openRouter: _openRouterController.text,
                        groq: _groqController.text,
                        openCodeZen: _openCodeZenController.text,
                      );
                      setState(() => _showApiKeys = false);
                    },
                  )
                : MainSettingsContent(
                    nameController: _nameController,
                    selectedLanguage: _selectedLanguage,
                    onClose: widget.onClose,
                    onShowApiKeys: () => setState(() => _showApiKeys = true),
                    onShowManageModels: () =>
                        setState(() => _showManageModels = true),
                    onLanguageChanged: (lang) =>
                        setState(() => _selectedLanguage = lang),
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

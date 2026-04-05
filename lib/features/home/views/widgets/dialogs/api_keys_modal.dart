import 'package:flutter/material.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_api_keys_section.dart';

class ApiKeysModal extends StatefulWidget {
  const ApiKeysModal({
    required this.viewModel,
    required this.onClose,
    super.key,
  });

  final HomeViewModel viewModel;
  final VoidCallback onClose;

  @override
  State<ApiKeysModal> createState() => _ApiKeysModalState();
}

class _ApiKeysModalState extends State<ApiKeysModal> {
  late final TextEditingController _openRouterController;
  late final TextEditingController _groqController;
  late final TextEditingController _openCodeZenController;
  bool _obscureOpenRouter = true;
  bool _obscureGroq = true;
  bool _obscureOpenCodeZen = true;
  String? _openRouterError;
  String? _groqError;
  String? _openCodeZenError;

  @override
  void initState() {
    super.initState();
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
    _openRouterController.dispose();
    _groqController.dispose();
    _openCodeZenController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() {
      _openRouterError = null;
      _groqError = null;
      _openCodeZenError = null;
    });

    final openRouter = _openRouterController.text.trim();
    final groq = _groqController.text.trim();
    final openCodeZen = _openCodeZenController.text.trim();

    final errors = <String, String?>{};

    if (openRouter.isNotEmpty && openRouter.length < 10) {
      errors['openRouter'] = 'Chave parece inválida. Verifique o formato.';
    }
    if (groq.isNotEmpty && groq.length < 10) {
      errors['groq'] = 'Chave parece inválida. Verifique o formato.';
    }
    if (openCodeZen.isNotEmpty && openCodeZen.length < 5) {
      errors['openCodeZen'] = 'Chave parece inválida. Verifique o formato.';
    }

    if (errors.isNotEmpty) {
      setState(() {
        _openRouterError = errors['openRouter'];
        _groqError = errors['groq'];
        _openCodeZenError = errors['openCodeZen'];
      });
      return;
    }

    await widget.viewModel.saveApiKeys(
      openRouter: openRouter,
      groq: groq,
      openCodeZen: openCodeZen,
    );
    widget.onClose();
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
            child: ApiKeysSection(
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
              onBack: widget.onClose,
              onDone: _onSave,
              openRouterError: _openRouterError,
              groqError: _groqError,
              openCodeZenError: _openCodeZenError,
            ),
          ),
        ),
      ),
    );
  }
}

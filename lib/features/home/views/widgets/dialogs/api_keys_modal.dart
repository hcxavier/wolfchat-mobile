import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';

class ApiKeysModal extends StatefulWidget {
  const ApiKeysModal({
    required this.initialOpenRouter,
    required this.initialGroq,
    required this.initialOpenCodeZen,
    required this.onClose,
    required this.onSave,
    super.key,
  });

  final String initialOpenRouter;
  final String initialGroq;
  final String initialOpenCodeZen;
  final VoidCallback onClose;
  final void Function(String openRouter, String groq, String openCodeZen)
  onSave;

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

  @override
  void initState() {
    super.initState();
    _openRouterController = TextEditingController(
      text: widget.initialOpenRouter,
    );
    _groqController = TextEditingController(text: widget.initialGroq);
    _openCodeZenController = TextEditingController(
      text: widget.initialOpenCodeZen,
    );
  }

  @override
  void dispose() {
    _openRouterController.dispose();
    _groqController.dispose();
    _openCodeZenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareDialog(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ApiKeysHeader(onClose: widget.onClose),
                const SizedBox(height: 24),
                _ApiKeyField(
                  label: 'OpenRouter',
                  controller: _openRouterController,
                  obscure: _obscureOpenRouter,
                  onToggleObscure: () =>
                      setState(() => _obscureOpenRouter = !_obscureOpenRouter),
                  hint: 'sk-or-v1-...',
                ),
                const SizedBox(height: 16),
                _ApiKeyField(
                  label: 'Groq',
                  controller: _groqController,
                  obscure: _obscureGroq,
                  onToggleObscure: () =>
                      setState(() => _obscureGroq = !_obscureGroq),
                  hint: 'gsk_...',
                ),
                const SizedBox(height: 16),
                _ApiKeyField(
                  label: 'Opencode Zen',
                  controller: _openCodeZenController,
                  obscure: _obscureOpenCodeZen,
                  onToggleObscure: () => setState(
                    () => _obscureOpenCodeZen = !_obscureOpenCodeZen,
                  ),
                  hint: 'oz-...',
                ),
                const SizedBox(height: 24),
                _DoneButton(
                  onSave: () => widget.onSave(
                    _openRouterController.text,
                    _groqController.text,
                    _openCodeZenController.text,
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

class _ApiKeysHeader extends StatelessWidget {
  const _ApiKeysHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const HeroIcon(HeroIcons.key, size: 24, color: AppColors.brand300),
        const SizedBox(width: 12),
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

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String hint;

  @override
  Widget build(BuildContext context) {
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onSave});
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
          'Concluído',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

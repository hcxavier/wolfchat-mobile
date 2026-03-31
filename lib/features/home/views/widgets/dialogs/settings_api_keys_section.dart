import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class ApiKeysSection extends StatelessWidget {
  const ApiKeysSection({
    required this.openRouterController,
    required this.groqController,
    required this.openCodeZenController,
    required this.obscureOpenRouter,
    required this.obscureGroq,
    required this.obscureOpenCodeZen,
    required this.onToggleOpenRouter,
    required this.onToggleGroq,
    required this.onToggleOpenCodeZen,
    required this.onBack,
    required this.onDone,
    super.key,
  });

  final TextEditingController openRouterController;
  final TextEditingController groqController;
  final TextEditingController openCodeZenController;
  final bool obscureOpenRouter;
  final bool obscureGroq;
  final bool obscureOpenCodeZen;
  final VoidCallback onToggleOpenRouter;
  final VoidCallback onToggleGroq;
  final VoidCallback onToggleOpenCodeZen;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onBack,
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
        _ApiKeyInput(
          label: 'OpenRouter',
          controller: openRouterController,
          obscure: obscureOpenRouter,
          onToggle: onToggleOpenRouter,
          hint: 'sk-or-v1-...',
        ),
        const SizedBox(height: 16),
        _ApiKeyInput(
          label: 'Groq',
          controller: groqController,
          obscure: obscureGroq,
          onToggle: onToggleGroq,
          hint: 'gsk_...',
        ),
        const SizedBox(height: 16),
        _ApiKeyInput(
          label: 'Opencode Zen',
          controller: openCodeZenController,
          obscure: obscureOpenCodeZen,
          onToggle: onToggleOpenCodeZen,
          hint: 'oz-...',
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onDone,
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
        ),
      ],
    );
  }
}

class _ApiKeyInput extends StatelessWidget {
  const _ApiKeyInput({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.hint,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
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
              onPressed: onToggle,
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

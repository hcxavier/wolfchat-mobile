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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.surfaceHover,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  hoverColor: AppColors.surfaceHover,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: HeroIcon(
                      HeroIcons.arrowLeft,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configurar API Keys',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Suas chaves ficam armazenadas localmente',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('OpenRouter'),
        const SizedBox(height: 10),
        _ApiKeyInput(
          controller: openRouterController,
          obscure: obscureOpenRouter,
          onToggle: onToggleOpenRouter,
          hint: 'sk-or-v1-...',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Groq'),
        const SizedBox(height: 10),
        _ApiKeyInput(
          controller: groqController,
          obscure: obscureGroq,
          onToggle: onToggleGroq,
          hint: 'gsk_...',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('OpenCode Zen'),
        const SizedBox(height: 10),
        _ApiKeyInput(
          controller: openCodeZenController,
          obscure: obscureOpenCodeZen,
          onToggle: onToggleOpenCodeZen,
          hint: 'oz-...',
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDone,
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
                    HeroIcon(
                      HeroIcons.check,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Salvar API Keys',
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
        ),
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

class _ApiKeyInput extends StatelessWidget {
  const _ApiKeyInput({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.hint,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String hint;

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
        obscureText: obscure,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 12),
            child: HeroIcon(
              HeroIcons.key,
              size: 18,
              color: AppColors.brand400,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: HeroIcon(
                    obscure ? HeroIcons.eyeSlash : HeroIcons.eye,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SuggestionsGrid extends StatelessWidget {
  const SuggestionsGrid({required this.onSuggestionTap, super.key});
  final void Function(String) onSuggestionTap;
  @override
  Widget build(BuildContext context) {
    const suggestions = <({String text, HeroIcons icon})>[
      (
        text: 'Explique computação quântica de forma simples',
        icon: HeroIcons.lightBulb,
      ),
      (
        text: 'Crie um script Python para automação de tarefas',
        icon: HeroIcons.codeBracket,
      ),
      (
        text: 'Simule uma entrevista para o cargo de dev',
        icon: HeroIcons.userGroup,
      ),
      (
        text: 'Ideias para um app inovador no mercado',
        icon: HeroIcons.sparkles,
      ),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: suggestions
          .map(
            (s) => SuggestionCard(
              text: s.text,
              icon: s.icon,
              onTap: () => onSuggestionTap(s.text),
            ),
          )
          .toList(),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    required this.text,
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String text;
  final HeroIcons icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.surfaceHover,
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceHover),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroIcon(icon, size: 24, color: AppColors.brand300),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

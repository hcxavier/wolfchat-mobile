import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SuggestionsGrid extends StatelessWidget {
  const SuggestionsGrid();

  @override
  Widget build(BuildContext context) {
    final suggestions = <({String title, String subtitle, HeroIcons icon})>[
      (
        title: 'Explique computação quânt?',
        subtitle: 'quântica de forma simples',
        icon: HeroIcons.lightBulb,
      ),
      (
        title: 'Script Python para auto...',
        subtitle: 'automação de tarefas',
        icon: HeroIcons.codeBracket,
      ),
      (
        title: 'Simule uma entrevista',
        subtitle: 'para o cargo de dev',
        icon: HeroIcons.userGroup,
      ),
      (
        title: 'Ideias para um app inova...',
        subtitle: 'inovador no mercado',
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
              title: s.title,
              icon: s.icon,
            ),
          )
          .toList(),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({required this.title, required this.icon});

  final String title;
  final HeroIcons icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Container(
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
                title,
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
        );
      },
    );
  }
}

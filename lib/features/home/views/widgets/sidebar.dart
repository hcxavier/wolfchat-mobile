import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.onClose,
    required this.onOpenSettings,
    required this.userName,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenSettings;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.surfaceCard,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brand500,
                    ),
                    child: const HeroIcon(
                      HeroIcons.sparkles,
                      style: HeroIconStyle.solid,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'WolfChat',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          HeroIcons.chevronLeft,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    HeroIcon(
                      HeroIcons.magnifyingGlass,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buscar nas conversas...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'RECENTES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  SidebarItem(title: 'Saudação inicial'),
                  SidebarItem(title: 'Explique computação...'),
                  SidebarItem(title: 'Siderbar Button Creation...'),
                  SidebarItem(title: 'Como Fazer Pão Ca...'),
                  SidebarItem(title: 'O que é a vida? Per...'),
                  SidebarItem(title: 'O que é SSH - expli...'),
                  SidebarItem(title: 'Como Manipular R...'),
                  SidebarItem(title: '¿Qué es SSH y cóm...'),
                  SidebarItem(title: 'Ideias para um app...'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceHover)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentLight,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName
                                  .trim()
                                  .split('')
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                            : '',
                        style: const TextStyle(
                          color: AppColors.brand300,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onOpenSettings,
                      customBorder: const CircleBorder(),
                      hoverColor: AppColors.surfaceHover,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: HeroIcon(
                          HeroIcons.cog6Tooth,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: title == 'Saudação inicial'
            ? AppColors.surfaceHover
            : Colors.transparent,
      ),
      child: Row(
        children: [
          HeroIcon(
            HeroIcons.chatBubbleLeft,
            size: 16,
            color: title == 'Saudação inicial'
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: title == 'Saudação inicial'
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: title == 'Saudação inicial'
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

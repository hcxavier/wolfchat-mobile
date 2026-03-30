import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: Stack(
        children: [
          _MainChatView(onToggleSidebar: viewModel.toggleSidebar),
          AnimatedOpacity(
            opacity: viewModel.isSidebarOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: !viewModel.isSidebarOpen,
              child: GestureDetector(
                onTap: viewModel.closeSidebar,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withAlpha(100)),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: viewModel.isSidebarOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _Sidebar(onClose: viewModel.closeSidebar),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final VoidCallback onClose;

  const _Sidebar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.surfaceCard,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
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

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

            // Recents Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

            // Chat List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: const [
                  _SidebarItem(title: 'Saudação inicial'),
                  _SidebarItem(title: 'Explique computação...'),
                  _SidebarItem(title: 'Siderbar Button Creation...'),
                  _SidebarItem(title: 'Como Fazer Pão Ca...'),
                  _SidebarItem(title: 'O que é a vida? Per...'),
                  _SidebarItem(title: 'O que é SSH - expli...'),
                  _SidebarItem(title: 'Como Manipular R...'),
                  _SidebarItem(title: '¿Qué es SSH y cóm...'),
                  _SidebarItem(title: 'Ideias para um app...'),
                ],
              ),
            ),

            // User Footer
            Container(
              padding: const EdgeInsets.all(16.0),
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
                    child: const Center(
                      child: Text(
                        'U3',
                        style: TextStyle(
                          color: AppColors.brand300,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Usuário 3',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

class _SidebarItem extends StatelessWidget {
  final String title;

  const _SidebarItem({required this.title});

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

class _MainChatView extends StatelessWidget {
  final VoidCallback onToggleSidebar;

  const _MainChatView({required this.onToggleSidebar});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            _TopBar(onToggleSidebar: onToggleSidebar),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 48),
                    _HeaderSection(),
                    SizedBox(height: 48),
                    _SuggestionsGrid(),
                  ],
                ),
              ),
            ),
            const _BottomInput(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onToggleSidebar;

  const _TopBar({required this.onToggleSidebar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onToggleSidebar,
          icon: const HeroIcon(
            HeroIcons.bars3,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KIMI K2 INSTRUCT',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              HeroIcon(
                HeroIcons.chevronDown,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brand500,
          ),
          child: const HeroIcon(
            HeroIcons.sparkles,
            style: HeroIconStyle.solid,
            size: 40,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'WolfChat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seu assistente de IA avançado.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        const Text(
          'O que vamos criar juntos?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SuggestionsGrid extends StatelessWidget {
  const _SuggestionsGrid();

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {
        'title': 'Explique computação quânt?',
        'subtitle': 'quântica de forma simples',
        'icon': HeroIcons.lightBulb,
      },
      {
        'title': 'Script Python para auto...',
        'subtitle': 'automação de tarefas',
        'icon': HeroIcons.codeBracket,
      },
      {
        'title': 'Simule uma entrevista',
        'subtitle': 'para o cargo de dev',
        'icon': HeroIcons.userGroup,
      },
      {
        'title': 'Ideias para um app inova...',
        'subtitle': 'inovador no mercado',
        'icon': HeroIcons.sparkles,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: suggestions
          .map(
            (s) => _SuggestionCard(
              title: s['title'] as String,
              icon: s['icon'] as HeroIcons,
            ),
          )
          .toList(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final HeroIcons icon;

  const _SuggestionCard({required this.title, required this.icon});

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

class _BottomInput extends StatelessWidget {
  const _BottomInput();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const HeroIcon(
            HeroIcons.paperClip,
            color: AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Envie uma mensagem...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textPrimary,
            ),
            child: const HeroIcon(
              HeroIcons.arrowUp,
              size: 20,
              color: AppColors.surfaceMain,
              style: HeroIconStyle.solid,
            ),
          ),
        ],
      ),
    );
  }
}

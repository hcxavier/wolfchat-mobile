import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _wasSettingsModalOpen = false;

  void _checkAndShowSettingsModal(HomeViewModel viewModel) {
    if (viewModel.isSettingsModalOpen && !_wasSettingsModalOpen) {
      _wasSettingsModalOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => _SettingsModal(
              viewModel: viewModel,
              onClose: () {
                Navigator.of(dialogContext).pop();
                viewModel.closeSettingsModal();
              },
            ),
            // The .then() callback is intentional for post-close cleanup
            // ignore: discarded_futures
          ).then((_) {
            // The callback runs after dialog closes, checking mounted is safe
            if (mounted && viewModel.isSettingsModalOpen) {
              viewModel.closeSettingsModal();
            }
            _wasSettingsModalOpen = false;
          });
        }
      });
    } else if (!viewModel.isSettingsModalOpen) {
      _wasSettingsModalOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    _checkAndShowSettingsModal(viewModel);

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
            child: _Sidebar(
              onClose: viewModel.closeSidebar,
              onOpenSettings: viewModel.openSettingsModal,
              userName: viewModel.userName,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.onClose,
    required this.onOpenSettings,
    required this.userName,
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
            // Header
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

            // Search
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

            // Recents Title
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

            // Chat List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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

class _KeyboardAwareDialog extends StatelessWidget {
  const _KeyboardAwareDialog({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: child,
    );
  }
}

class _SettingsModal extends StatefulWidget {
  const _SettingsModal({required this.viewModel, required this.onClose});

  final HomeViewModel viewModel;
  final VoidCallback onClose;

  @override
  State<_SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<_SettingsModal> {
  late final TextEditingController _nameController;
  String _selectedLanguage = 'Português (Brasil)';

  static const _languages = [
    'Português (Brasil)',
    'English',
    'Español',
    'Français',
    'Deutsch',
    '日本語',
    '中文',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.viewModel.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KeyboardAwareDialog(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const HeroIcon(
                      HeroIcons.cog6Tooth,
                      size: 24,
                      color: AppColors.brand300,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Configurações',
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
                        onTap: widget.onClose,
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
                ),
                const SizedBox(height: 24),

                const Text(
                  'Nome do usuário',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
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
                  ),
                ),
                const SizedBox(height: 24),

                _SettingsButton(
                  icon: HeroIcons.key,
                  title: 'Configurar API Keys',
                  onTap: () {
                    // Result not needed, dialog is for user interaction
                    // ignore: discarded_futures
                    showDialog<void>(
                      context: context,
                      builder: (apiDialogContext) => _ApiKeysModal(
                        initialOpenRouter: widget.viewModel.openRouterKey,
                        initialGroq: widget.viewModel.groqKey,
                        initialOpenCodeZen: widget.viewModel.openCodeZenKey,
                        onClose: () => Navigator.of(apiDialogContext).pop(),
                        onSave: (openRouter, groq, openCodeZen) {
                          widget.viewModel.saveApiKeys(
                            openRouter: openRouter,
                            groq: groq,
                            openCodeZen: openCodeZen,
                          );
                          Navigator.of(apiDialogContext).pop();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _SettingsButton(
                  icon: HeroIcons.cpuChip,
                  title: 'Gerenciar Modelos',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _SettingsButton(
                  icon: HeroIcons.adjustmentsHorizontal,
                  title: 'Personalização (System Prompt)',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _SettingsButton(
                  icon: HeroIcons.bolt,
                  title: 'Prompts Dinâmicos',
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                const Text(
                  'Idioma da Resposta',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      icon: const HeroIcon(
                        HeroIcons.chevronDown,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      items: _languages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _SettingsButton(
                  icon: HeroIcons.trash,
                  title: 'Excluir todos os chats',
                  onTap: () {},
                  isDestructive: true,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.viewModel.updateUserName(_nameController.text);
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand500,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final HeroIcons icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHover,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              HeroIcon(
                icon,
                size: 20,
                color: isDestructive
                    ? AppColors.brand500
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.brand500
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              HeroIcon(
                HeroIcons.chevronRight,
                size: 16,
                color: isDestructive
                    ? AppColors.brand500
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiKeysModal extends StatefulWidget {
  const _ApiKeysModal({
    required this.initialOpenRouter,
    required this.initialGroq,
    required this.initialOpenCodeZen,
    required this.onClose,
    required this.onSave,
  });

  final String initialOpenRouter;
  final String initialGroq;
  final String initialOpenCodeZen;
  final VoidCallback onClose;
  final void Function(String openRouter, String groq, String openCodeZen)
  onSave;

  @override
  State<_ApiKeysModal> createState() => _ApiKeysModalState();
}

class _ApiKeysModalState extends State<_ApiKeysModal> {
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surfaceInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _KeyboardAwareDialog(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const HeroIcon(
                      HeroIcons.key,
                      size: 24,
                      color: AppColors.brand300,
                    ),
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
                        onTap: widget.onClose,
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
                ),
                const SizedBox(height: 24),

                _buildKeyField(
                  label: 'OpenRouter',
                  controller: _openRouterController,
                  obscure: _obscureOpenRouter,
                  onToggleObscure: () =>
                      setState(() => _obscureOpenRouter = !_obscureOpenRouter),
                  hint: 'sk-or-v1-...',
                ),
                const SizedBox(height: 16),

                _buildKeyField(
                  label: 'Groq',
                  controller: _groqController,
                  obscure: _obscureGroq,
                  onToggleObscure: () =>
                      setState(() => _obscureGroq = !_obscureGroq),
                  hint: 'gsk_...',
                ),
                const SizedBox(height: 16),

                _buildKeyField(
                  label: 'Opencode Zen',
                  controller: _openCodeZenController,
                  obscure: _obscureOpenCodeZen,
                  onToggleObscure: () => setState(
                    () => _obscureOpenCodeZen = !_obscureOpenCodeZen,
                  ),
                  hint: 'oz-...',
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _openRouterController.text,
                        _groqController.text,
                        _openCodeZenController.text,
                      );
                    },
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String hint,
  }) {
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
          decoration: _inputDecoration(hint).copyWith(
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.title});

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

class _MainChatView extends StatelessWidget {
  const _MainChatView({required this.onToggleSidebar});

  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _TopBar(
                onToggleSidebar: () {
                  FocusScope.of(context).unfocus();
                  onToggleSidebar();
                },
              ),
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
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onToggleSidebar});

  final VoidCallback onToggleSidebar;

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
            (s) => _SuggestionCard(
              title: s.title,
              icon: s.icon,
            ),
          )
          .toList(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.title, required this.icon});

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

class _BottomInput extends StatelessWidget {
  const _BottomInput();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: HeroIcon(
                HeroIcons.paperClip,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 4,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Envie uma mensagem...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
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
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_modal.dart';
import 'package:wolfchat/features/home/views/widgets/main_chat_view.dart';
import 'package:wolfchat/features/home/views/widgets/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _wasSettingsModalOpen = false;
  late AnimationController _animationController;
  double _dragOffset = 0;
  static const double _sidebarWidth = 280;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAndShowSettingsModal(HomeViewModel viewModel) {
    if (viewModel.isSettingsModalOpen && !_wasSettingsModalOpen) {
      _wasSettingsModalOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => SettingsModal(
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

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    HomeViewModel viewModel,
  ) {
    if (!viewModel.isSidebarOpen) return;

    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_sidebarWidth, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, HomeViewModel viewModel) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > 500 || _dragOffset > -_sidebarWidth / 2) {
      setState(() {
        _dragOffset = 0;
      });
    } else {
      viewModel.closeSidebar();
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    _checkAndShowSettingsModal(viewModel);

    if (!viewModel.isSidebarOpen && _dragOffset != 0) {
      _dragOffset = 0;
    }

    if (!viewModel.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceMain,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.brand500,
          ),
        ),
      );
    }

    final sidebarOffset = viewModel.isSidebarOpen
        ? _dragOffset
        : -_sidebarWidth;
    final overlayOpacity = ((sidebarOffset + _sidebarWidth) / _sidebarWidth)
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: Stack(
        children: [
          MainChatView(onToggleSidebar: viewModel.toggleSidebar),
          IgnorePointer(
            ignoring: !viewModel.isSidebarOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: overlayOpacity,
              child: GestureDetector(
                onTap: viewModel.closeSidebar,
                onHorizontalDragUpdate: (details) =>
                    _onHorizontalDragUpdate(details, viewModel),
                onHorizontalDragEnd: (details) =>
                    _onHorizontalDragEnd(details, viewModel),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withAlpha(100),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _dragOffset == 0
                ? const Duration(milliseconds: 300)
                : Duration.zero,
            curve: Curves.easeOut,
            left: sidebarOffset,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) =>
                  _onHorizontalDragUpdate(details, viewModel),
              onHorizontalDragEnd: (details) =>
                  _onHorizontalDragEnd(details, viewModel),
              child: Sidebar(
                onClose: viewModel.closeSidebar,
                onOpenSettings: viewModel.openSettingsModal,
                userName: viewModel.userName,
                conversations: viewModel.conversations,
                currentConversationId: viewModel.currentConversation?.id,
                onConversationSelected: (id) {
                  viewModel.loadConversation(id);
                  viewModel.closeSidebar();
                },
                onNewConversation: () {
                  viewModel.createNewConversation();
                  viewModel.closeSidebar();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _HomePageState extends State<HomePage> {
  bool _wasSettingsModalOpen = false;

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    _checkAndShowSettingsModal(viewModel);

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

    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: Stack(
        children: [
          MainChatView(onToggleSidebar: viewModel.toggleSidebar),
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
        ],
      ),
    );
  }
}

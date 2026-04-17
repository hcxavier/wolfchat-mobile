import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/main_chat_view.dart';
import 'package:wolfchat/features/home/views/widgets/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.conversationId, super.key});
  final int? conversationId;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final viewModel = context.read<HomeViewModel>();
          if (viewModel.isInitialized) {
            unawaited(viewModel.loadConversation(widget.conversationId!));
          } else {
            void onInit() {
              if (viewModel.isInitialized) {
                unawaited(viewModel.loadConversation(widget.conversationId!));
                viewModel.removeListener(onInit);
              }
            }

            viewModel.addListener(onInit);
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conversationId != oldWidget.conversationId &&
        widget.conversationId != null) {
      final viewModel = context.read<HomeViewModel>();
      if (viewModel.isInitialized) {
        unawaited(viewModel.loadConversation(widget.conversationId!));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      resizeToAvoidBottomInset: true,
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
                onOpenSettings: () {
                  viewModel.closeSidebar();
                  unawaited(context.pushNamed('settings'));
                },
                onSearchTap: () {
                  viewModel.closeSidebar();
                  unawaited(context.pushNamed('search'));
                },
                userName: viewModel.userName,
                conversations: viewModel.conversations,
                currentConversationId: viewModel.currentConversation?.id,
                onConversationSelected: (id) {
                  context.goNamed(
                    'chat',
                    pathParameters: {'id': id.toString()},
                  );
                  viewModel.closeSidebar();
                },
                onNewConversation: () async {
                  await viewModel.createNewConversation();
                  if (viewModel.currentConversation != null) {
                    if (context.mounted) {
                      context.goNamed(
                        'chat',
                        pathParameters: {
                          'id': viewModel.currentConversation!.id.toString(),
                        },
                      );
                    }
                  }
                  if (context.mounted) {
                    viewModel.closeSidebar();
                  }
                },
                onDeleteConversation: (id) async {
                  await viewModel.deleteConversation(id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

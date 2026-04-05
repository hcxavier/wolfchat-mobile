import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/bottom_input.dart';
import 'package:wolfchat/features/home/views/widgets/chat_messages_list.dart';
import 'package:wolfchat/features/home/views/widgets/header_section.dart';
import 'package:wolfchat/features/home/views/widgets/suggestions.dart';
import 'package:wolfchat/features/home/views/widgets/top_bar.dart';

class MainChatView extends StatelessWidget {
  const MainChatView({required this.onToggleSidebar, super.key});

  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final hasMessages = viewModel.messages.isNotEmpty;

    return SafeArea(
      bottom: false,
      maintainBottomViewPadding: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 24,
          ),
          child: Column(
            children: [
              TopBar(
                onToggleSidebar: () {
                  FocusScope.of(context).unfocus();
                  onToggleSidebar();
                },
                selectedModelName: viewModel.selectedModel.name,
                availableModels: viewModel.availableModels,
                selectedModelIndex: viewModel.selectedModelIndex,
                onModelSelected: viewModel.selectModel,
              ),
              Expanded(
                child: hasMessages
                    ? ChatMessagesList(
                        conversationId: viewModel.currentConversation?.id,
                        messages: viewModel.messages,
                        isSendingMessage: viewModel.isSendingMessage,
                        onRetry: viewModel.retryLastMessage,
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 48),
                            const HeaderSection(),
                            const SizedBox(height: 48),
                            SuggestionsGrid(
                              onSuggestionTap: viewModel.sendMessage,
                            ),
                          ],
                        ),
                      ),
              ),
              BottomInput(
                onSendMessage: viewModel.sendMessage,
                isLoading: viewModel.isSendingMessage,
                onCancel: viewModel.cancelCurrentRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

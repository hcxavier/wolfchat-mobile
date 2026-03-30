import 'package:flutter/material.dart';
import 'package:wolfchat/features/home/views/widgets/header_section.dart';
import 'package:wolfchat/features/home/views/widgets/suggestions.dart';
import 'package:wolfchat/features/home/views/widgets/bottom_input.dart';
import 'package:wolfchat/features/home/views/widgets/top_bar.dart';

class MainChatView extends StatelessWidget {
  const MainChatView({required this.onToggleSidebar});

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
              TopBar(
                onToggleSidebar: () {
                  FocusScope.of(context).unfocus();
                  onToggleSidebar();
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      SizedBox(height: 48),
                      HeaderSection(),
                      SizedBox(height: 48),
                      SuggestionsGrid(),
                    ],
                  ),
                ),
              ),
              const BottomInput(),
            ],
          ),
        ),
      ),
    );
  }
}

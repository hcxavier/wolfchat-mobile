import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class BottomInput extends StatefulWidget {
  const BottomInput({
    required this.onSendMessage,
    required this.isLoading,
    super.key,
  });

  final void Function(String) onSendMessage;
  final bool isLoading;

  @override
  State<BottomInput> createState() => _BottomInputState();
}

class _BottomInputState extends State<BottomInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

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
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                enabled: !widget.isLoading,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
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
            GestureDetector(
              onTap: widget.isLoading ? null : _sendMessage,
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isLoading
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surfaceMain,
                        ),
                      )
                    : const HeroIcon(
                        HeroIcons.arrowUp,
                        size: 20,
                        color: AppColors.surfaceMain,
                        style: HeroIconStyle.solid,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

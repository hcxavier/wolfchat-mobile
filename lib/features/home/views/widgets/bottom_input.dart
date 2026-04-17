import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class BottomInput extends StatefulWidget {
  const BottomInput({
    required this.onSendMessage,
    required this.isLoading,
    required this.isThinkingEnabled,
    required this.onToggleThinking,
    this.onCancel,
    super.key,
  });
  final void Function(String) onSendMessage;
  final bool isLoading;
  final bool isThinkingEnabled;
  final VoidCallback onToggleThinking;
  final void Function()? onCancel;
  @override
  State<BottomInput> createState() => _BottomInputState();
}

class _BottomInputState extends State<BottomInput> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _wasKeyboardOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;
    if (_wasKeyboardOpen && !isKeyboardOpen) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _wasKeyboardOpen = isKeyboardOpen;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      if (isEnter && !isShiftPressed) {
        _sendMessage();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
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
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceInput,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            const HeroIcon(
              HeroIcons.plusCircle,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 4),
            _ThinkingToggleButton(
              isEnabled: widget.isThinkingEnabled,
              onTap: widget.onToggleThinking,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: AppColors.textPrimary),
                enabled: !widget.isLoading,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Envie uma mensagem...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isLoading)
              GestureDetector(
                onTap: widget.onCancel,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.brand500,
                  ),
                  child: const HeroIcon(
                    HeroIcons.stop,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.brand500,
                  ),
                  child: const HeroIcon(
                    HeroIcons.arrowUp,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingToggleButton extends StatelessWidget {
  const _ThinkingToggleButton({required this.isEnabled, required this.onTap});
  final bool isEnabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isEnabled ? 'Desativar thinking' : 'Ativar thinking',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.brand500.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? AppColors.brand400 : Colors.transparent,
            ),
          ),
          child: HeroIcon(
            HeroIcons.lightBulb,
            size: 20,
            color: isEnabled ? AppColors.brand400 : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

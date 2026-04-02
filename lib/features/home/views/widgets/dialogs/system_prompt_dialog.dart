import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/data/services/persistence_service.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/shared/widgets/animated_clickable.dart';

class SystemPromptDialog extends StatefulWidget {
  const SystemPromptDialog({
    required this.onClose,
    required this.onSave,
    super.key,
  });

  final VoidCallback onClose;
  final ValueChanged<String> onSave;

  @override
  State<SystemPromptDialog> createState() => _SystemPromptDialogState();
}

class _SystemPromptDialogState extends State<SystemPromptDialog> {
  late final TextEditingController _promptController;
  late final FocusNode _focusNode;
  bool _isLoading = true;
  bool _isInputFocused = false;
  int _characterCount = 0;
  int _estimatedTokens = 0;

  static const int _maxCharacters = 4000;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController()..addListener(_updateCounts);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    // ignore: discarded_futures - async init called in constructor
    _loadExistingPrompt();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && !_isInputFocused) {
      setState(() {
        _isInputFocused = true;
      });
    }
  }

  Future<void> _loadExistingPrompt() async {
    final persistence = await PersistenceService.getInstance();
    final existingPrompt = await persistence.getSystemPrompt();
    if (mounted) {
      setState(() {
        if (existingPrompt != null) {
          _promptController.text = existingPrompt;
        }
        _isLoading = false;
      });
    }
  }

  void _updateCounts() {
    final text = _promptController.text;
    setState(() {
      _characterCount = text.length;
      // Rough token estimation: ~4 characters per token for Portuguese
      _estimatedTokens = (text.length / 4).ceil();
    });
  }

  @override
  void dispose() {
    _promptController
      ..removeListener(_updateCounts)
      ..dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final prompt = _promptController.text.trim();
    final persistence = await PersistenceService.getInstance();
    await persistence.saveSystemPrompt(prompt);
    widget.onSave(prompt);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: 800,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentLight.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand500.withValues(alpha: 0.1),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brand400,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SystemPromptHeader(onClose: widget.onClose),
                      const SizedBox(height: 24),
                      if (!_isInputFocused) ...[
                        const _ExplanationCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionTitle('Suas instruções'),
                      const SizedBox(height: 10),
                      _PromptInputField(
                        controller: _promptController,
                        focusNode: _focusNode,
                        maxCharacters: _maxCharacters,
                      ),
                      const SizedBox(height: 12),
                      _UsageCounter(
                        characterCount: _characterCount,
                        maxCharacters: _maxCharacters,
                        estimatedTokens: _estimatedTokens,
                      ),
                      const SizedBox(height: 24),
                      _SaveButton(onSave: _handleSave),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SystemPromptHeader extends StatelessWidget {
  const _SystemPromptHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.surfaceHover,
            ),
          ),
          child: const HeroIcon(
            HeroIcons.adjustmentsHorizontal,
            size: 20,
            color: AppColors.brand400,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalização',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Customize o comportamento da IA',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AnimatedClickable(
          onTap: onClose,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.surfaceHover,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: HeroIcon(
                HeroIcons.xMark,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brand900.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brand700.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brand800.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const HeroIcon(
              HeroIcons.informationCircle,
              size: 18,
              color: AppColors.brand400,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Personalize como a IA deve se comportar. Suas instruções serão '
              'adicionadas ao prompt principal do sistema. Nota: Você não pode '
              'alterar as instruções base de segurança e formatação, apenas '
              'adicionar novas diretrizes.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptInputField extends StatelessWidget {
  const _PromptInputField({
    required this.controller,
    required this.focusNode,
    required this.maxCharacters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxCharacters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 8,
        maxLength: maxCharacters,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) => null,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        decoration: const InputDecoration(
          hintText:
              'Ex: Responda sempre em português brasileiro. '
              'Seja objetivo e direto nas respostas. '
              'Use exemplos de código quando apropriado.',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          hintMaxLines: 3,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _UsageCounter extends StatelessWidget {
  const _UsageCounter({
    required this.characterCount,
    required this.maxCharacters,
    required this.estimatedTokens,
  });

  final int characterCount;
  final int maxCharacters;
  final int estimatedTokens;

  @override
  Widget build(BuildContext context) {
    final isNearLimit = characterCount > maxCharacters * 0.8;
    final isAtLimit = characterCount >= maxCharacters;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const HeroIcon(
              HeroIcons.documentText,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '$characterCount / $maxCharacters caracteres',
              style: TextStyle(
                color: isAtLimit
                    ? AppColors.brand500
                    : isNearLimit
                    ? AppColors.brand400
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const HeroIcon(
              HeroIcons.cpuChip,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '~$estimatedTokens tokens',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSave,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.brand500,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand500.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeroIcon(
                  HeroIcons.check,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10),
                Text(
                  'Concluído',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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

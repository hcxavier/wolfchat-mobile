import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/dracula.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wolfchat/core/theme/app_colors.dart';

class MarkdownStyler {
  static MarkdownStyleSheet getStyleSheet(BuildContext context) {
    const defaultText = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: AppColors.textPrimary,
      letterSpacing: 0.2,
    );

    return MarkdownStyleSheet(
      p: defaultText,
      pPadding: const EdgeInsets.only(bottom: 12),
      h1: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      h1Padding: const EdgeInsets.only(top: 24, bottom: 12),
      h2: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 10),
      h3: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h4: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      h4Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h5: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      h5Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h6: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      h6Padding: const EdgeInsets.only(top: 16, bottom: 8),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      del: const TextStyle(
        decoration: TextDecoration.lineThrough,
        color: AppColors.textSecondary,
      ),
      blockquote: const TextStyle(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        height: 1.6,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.brand500.withValues(alpha: 0.05),
        border: const Border(
          left: BorderSide(color: AppColors.brand500, width: 4),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      code: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 13,
        color: AppColors.brand300,
      ),
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: const BoxDecoration(),
      listBullet: const TextStyle(
        color: AppColors.brand500,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      listBulletPadding: const EdgeInsets.only(right: 8),
      listIndent: 24,
      blockSpacing: 12,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      tableHead: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.brand300,
        fontSize: 14,
      ),
      tableBody: defaultText.copyWith(fontSize: 14),
      tableBorder: TableBorder.all(color: Colors.white.withValues(alpha: 0.1)),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableCellsDecoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
      ),
      tableHeadAlign: TextAlign.left,
      a: const TextStyle(
        color: AppColors.brand400,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class CodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Handle code blocks (multi-line)
    if (element.textContent.contains('\n')) {
      var language = 'text';
      if (element.attributes['class'] != null) {
        final lgPattern = element.attributes['class'] ?? '';
        if (lgPattern.startsWith('language-')) {
          language = lgPattern.substring(9);
        }
      }

      return CodeBlockWidget(
        language: language,
        code: element.textContent.trimRight(),
      );
    }

    // Handle inline code
    return InlineCodeWidget(code: element.textContent);
  }
}

class InlineCodeWidget extends StatelessWidget {
  const InlineCodeWidget({required this.code, super.key});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.brand500.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 13,
          color: AppColors.brand300,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (!element.textContent.contains('\n')) return null;

    var language = 'text';
    if (element.attributes['class'] != null) {
      final lgPattern = element.attributes['class'] ?? '';
      if (lgPattern.startsWith('language-')) language = lgPattern.substring(9);
    }

    return CodeBlockWidget(
      language: language,
      code: element.textContent.trimRight(),
    );
  }
}

class HrBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        height: 1,
      ),
    );
  }
}

class CodeBlockWidget extends StatefulWidget {
  const CodeBlockWidget({
    required this.language,
    required this.code,
    super.key,
  });
  final String language;
  final String code;

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF282A36), // Dracula background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CodeBlockHeader(
            language: widget.language,
            copied: _copied,
            onCopy: _handleCopy,
          ),
          _CodeContent(code: widget.code, language: widget.language),
        ],
      ),
    );
  }
}

class _CodeBlockHeader extends StatelessWidget {
  const _CodeBlockHeader({
    required this.language,
    required this.copied,
    required this.onCopy,
  });
  final String language;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                language.isEmpty ? 'TEXT' : language.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    copied ? Icons.check : Icons.copy,
                    size: 14,
                    color: copied
                        ? AppColors.brand400
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    copied ? 'Copiado' : 'Copiar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: copied
                          ? AppColors.brand400
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeContent extends StatelessWidget {
  const _CodeContent({required this.code, required this.language});
  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          code,
          language: language.isEmpty ? 'text' : language,
          theme: draculaTheme,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class MarkdownStyler {
  static MarkdownStyleSheet getStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: AppColors.textPrimary,
      ),
      pPadding: const EdgeInsets.only(bottom: 16),
      h1: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h1Padding: const EdgeInsets.only(bottom: 16),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h2Padding: const EdgeInsets.only(bottom: 12),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h3Padding: const EdgeInsets.only(bottom: 8),
      h4: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h4Padding: const EdgeInsets.only(bottom: 8),
      h5: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h5Padding: const EdgeInsets.only(bottom: 8),
      h6: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      h6Padding: const EdgeInsets.only(bottom: 8),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      del: const TextStyle(
        decoration: TextDecoration.lineThrough,
        color: AppColors.textSecondary,
      ),
      blockquote: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Color(0xB3FFFFFF),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.brand500,
            width: 4,
          ),
        ),
        color: const Color(0x0DFFFFFF),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      code: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 13,
        backgroundColor: const Color(0x1AFFFFFF),
        color: AppColors.brand300,
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF282A36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      codeblockAlign: WrapAlignment.start,
      listBullet: const TextStyle(
        color: AppColors.brand500,
        fontWeight: FontWeight.bold,
      ),
      listBulletPadding: const EdgeInsets.only(left: 8),
      listIndent: 24,
      blockSpacing: 16,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0x0DFFFFFF),
            width: 1,
          ),
        ),
      ),
      tableHead: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF818CF8),
      ),
      tableBody: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      tableBorder: TableBorder.all(
        color: const Color(0x0DFFFFFF),
        width: 1,
      ),
      tableCellsPadding: const EdgeInsets.all(12),
      tableCellsDecoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
      ),
      tableHeadAlign: TextAlign.left,
      tablePadding: const EdgeInsets.all(8),
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableVerticalAlignment: TableCellVerticalAlignment.middle,
      a: const TextStyle(
        color: AppColors.brand400,
        decoration: TextDecoration.underline,
      ),
      checkbox: const TextStyle(
        color: AppColors.brand500,
      ),
    );
  }
}

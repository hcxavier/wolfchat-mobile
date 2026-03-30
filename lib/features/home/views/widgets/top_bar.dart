import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    required this.onToggleSidebar,
    required this.selectedModelName,
    required this.availableModels,
    required this.selectedModelIndex,
    required this.onModelSelected,
    super.key,
  });

  final VoidCallback onToggleSidebar;
  final String selectedModelName;
  final List<CustomModel> availableModels;
  final int selectedModelIndex;
  final void Function(int) onModelSelected;

  Future<void> _showModelSelector(BuildContext context) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final button = context.findRenderObject() as RenderBox?;
    if (overlay == null || button == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomLeft(const Offset(0, 8)),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(const Offset(0, 8)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final item = await showMenu<int>(
      context: context,
      position: position,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 300,
      ),
      items: List.generate(availableModels.length, (index) {
        final model = availableModels[index];
        final isSelected = index == selectedModelIndex;
        return PopupMenuItem<int>(
          value: index,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.name,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.brand400
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.provider,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const HeroIcon(
                  HeroIcons.check,
                  size: 18,
                  color: AppColors.brand400,
                ),
            ],
          ),
        );
      }),
    );

    if (item != null) {
      onModelSelected(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onToggleSidebar,
          icon: const HeroIcon(
            HeroIcons.bars3,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Builder(
          builder: (context) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showModelSelector(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedModelName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const HeroIcon(
                      HeroIcons.chevronDown,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

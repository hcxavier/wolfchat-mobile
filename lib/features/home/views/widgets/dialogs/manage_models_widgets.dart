import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';

class ManageModelsHeader extends StatelessWidget {
  const ManageModelsHeader({required this.onClose, super.key});
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
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClose,
              customBorder: const CircleBorder(),
              hoverColor: AppColors.surfaceHover,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: HeroIcon(
                  HeroIcons.arrowLeft,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gerenciar Modelos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Adicione modelos personalizados',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ModelProviderSelector extends StatelessWidget {
  const ModelProviderSelector({
    required this.selectedProvider,
    required this.onChanged,
    super.key,
  });

  final ModelProvider selectedProvider;
  final ValueChanged<ModelProvider> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModelProvider>(
          value: selectedProvider,
          isExpanded: true,
          dropdownColor: AppColors.surfaceCard,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const HeroIcon(
              HeroIcons.chevronDown,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
          items: ModelProvider.values
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getProviderColor(p),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(p.displayName),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }

  Color _getProviderColor(ModelProvider provider) {
    switch (provider) {
      case ModelProvider.openRouter:
        return AppColors.brand400;
      case ModelProvider.groq:
        return const Color(0xFF6366F1);
      case ModelProvider.openCodeZen:
        return const Color(0xFF8AB4F8);
    }
  }
}

class CustomModelsList extends StatelessWidget {
  const CustomModelsList({required this.viewModel, super.key});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Text(
              'MODELOS ADICIONADOS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final models = viewModel.customModels;
            if (models.isEmpty) return const _EmptyState();
            return _ModelsListView(models: models, viewModel: viewModel);
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHover.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const HeroIcon(
              HeroIcons.cube,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nenhum modelo adicionado',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adicione um modelo acima para começar',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelsListView extends StatelessWidget {
  const _ModelsListView({required this.models, required this.viewModel});
  final List<CustomModel> models;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceHover,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return _ModelListItem(
            model: model,
            isLast: index == models.length - 1,
            onDelete: () => viewModel.removeCustomModel(index),
          );
        },
      ),
    );
  }
}

class _ModelListItem extends StatelessWidget {
  const _ModelListItem({
    required this.model,
    required this.isLast,
    required this.onDelete,
  });

  final CustomModel model;
  final bool isLast;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.surfaceHover.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brand900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: HeroIcon(
                HeroIcons.cube,
                size: 18,
                color: AppColors.brand400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${model.provider} • ${model.id}',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: onDelete,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hoverColor: AppColors.brand700.withValues(alpha: 0.2),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const HeroIcon(
                  HeroIcons.trash,
                  size: 16,
                  color: AppColors.brand500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            hoverColor: AppColors.surfaceHover,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: HeroIcon(
                HeroIcons.arrowLeft,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Gerenciar Modelos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provedor',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ModelProvider>(
              value: selectedProvider,
              isExpanded: true,
              dropdownColor: AppColors.surfaceCard,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              icon: const HeroIcon(
                HeroIcons.chevronDown,
                size: 16,
                color: AppColors.textSecondary,
              ),
              items: ModelProvider.values
                  .map(
                    (p) =>
                        DropdownMenuItem(value: p, child: Text(p.displayName)),
                  )
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
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
        const Text(
          'Modelos adicionados',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Nenhum modelo adicionado',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
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
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.surfaceHover)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${model.provider} • ${model.id}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onDelete,
              customBorder: const CircleBorder(),
              hoverColor: AppColors.surfaceHover,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: HeroIcon(
                  HeroIcons.trash,
                  size: 18,
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

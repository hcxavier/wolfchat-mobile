import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/models/home_model.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';

class ManageModelsModal extends StatefulWidget {
  const ManageModelsModal({
    required this.viewModel,
    required this.onClose,
    super.key,
  });

  final HomeViewModel viewModel;
  final VoidCallback onClose;

  @override
  State<ManageModelsModal> createState() => _ManageModelsModalState();
}

class _ManageModelsModalState extends State<ManageModelsModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _modelIdController;
  ModelProvider _selectedProvider = ModelProvider.openRouter;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _modelIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelIdController.dispose();
    super.dispose();
  }

  void _addModel() {
    final name = _nameController.text.trim();
    final modelId = _modelIdController.text.trim();

    if (name.isEmpty || modelId.isEmpty) {
      return;
    }

    widget.viewModel.addCustomModel(
      name: name,
      modelId: modelId,
      provider: _selectedProvider,
    );

    _nameController.clear();
    _modelIdController.clear();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surfaceInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: Dialog(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: widget.onClose,
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
                    const HeroIcon(
                      HeroIcons.cpuChip,
                      size: 24,
                      color: AppColors.brand300,
                    ),
                    const SizedBox(width: 12),
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
                ),
                const SizedBox(height: 24),
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
                      value: _selectedProvider,
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
                            (provider) => DropdownMenuItem(
                              value: provider,
                              child: Text(provider.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedProvider = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nome do modelo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: _inputDecoration('Llama 3'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ID do modelo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _modelIdController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: _inputDecoration('ex: llama3-70b-8192'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addModel,
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppColors.brand500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HeroIcon(
                              HeroIcons.plus,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Adicionar',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    final models = widget.viewModel.customModels;
                    if (models.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceInput,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Nenhum modelo adicionado',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
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
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: index < models.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                        color: AppColors.surfaceHover,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    onTap: () => widget.viewModel
                                        .removeCustomModel(index),
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
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand500,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Concluído',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

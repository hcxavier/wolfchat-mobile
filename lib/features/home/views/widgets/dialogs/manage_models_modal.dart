import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/models/custom_model.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/manage_models_widgets.dart';

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

    if (name.isEmpty || modelId.isEmpty) return;

    widget.viewModel.addCustomModel(
      name: name,
      modelId: modelId,
      provider: _selectedProvider,
    );

    _nameController.clear();
    _modelIdController.clear();
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
                ManageModelsHeader(onClose: widget.onClose),
                const SizedBox(height: 24),
                ModelProviderSelector(
                  selectedProvider: _selectedProvider,
                  onChanged: (val) => setState(() => _selectedProvider = val),
                ),
                const SizedBox(height: 16),
                _ModelInputField(
                  label: 'Nome do modelo',
                  controller: _nameController,
                  hint: 'Llama 3',
                ),
                const SizedBox(height: 16),
                _ModelInputField(
                  label: 'ID do modelo',
                  controller: _modelIdController,
                  hint: 'ex: llama3-70b-8192',
                ),
                const SizedBox(height: 16),
                _AddButton(onTap: _addModel),
                const SizedBox(height: 24),
                CustomModelsList(viewModel: widget.viewModel),
                const SizedBox(height: 24),
                _DoneButton(onTap: widget.onClose),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModelInputField extends StatelessWidget {
  const _ModelInputField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            filled: true,
            fillColor: AppColors.surfaceInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

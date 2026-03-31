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

  Future<void> _addModel() async {
    final name = _nameController.text.trim();
    final modelId = _modelIdController.text.trim();

    if (name.isEmpty || modelId.isEmpty) return;

    await widget.viewModel.addCustomModel(
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
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: 480,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ManageModelsHeader(onClose: widget.onClose),
                const SizedBox(height: 24),
                _buildSectionTitle('Provedor'),
                const SizedBox(height: 10),
                ModelProviderSelector(
                  selectedProvider: _selectedProvider,
                  onChanged: (val) => setState(() => _selectedProvider = val),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Nome do modelo'),
                const SizedBox(height: 10),
                _ModelInputField(
                  controller: _nameController,
                  hint: 'Llama 3',
                  icon: HeroIcons.cpuChip,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('ID do modelo'),
                const SizedBox(height: 10),
                _ModelInputField(
                  controller: _modelIdController,
                  hint: 'ex: llama3-70b-8192',
                  icon: HeroIcons.codeBracket,
                ),
                const SizedBox(height: 24),
                _AddButton(onTap: _addModel),
                const SizedBox(height: 28),
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
          title,
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

class _ModelInputField extends StatelessWidget {
  const _ModelInputField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final HeroIcons icon;

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
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: HeroIcon(
              icon,
              size: 18,
              color: AppColors.brand400,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brand500, AppColors.brand600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                  HeroIcons.plus,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10),
                Text(
                  'Adicionar Modelo',
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

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.surfaceHover),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: const Text(
          'Concluído',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

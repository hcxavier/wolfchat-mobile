import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/models/available_model.dart';
import 'package:wolfchat/core/services/groq_service.dart';
import 'package:wolfchat/core/services/open_code_zen_service.dart';
import 'package:wolfchat/core/services/open_router_service.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/core/utils/error_message_mapper.dart';
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
  List<AvailableModel> _availableModels = [];
  bool _isLoadingModels = false;
  bool _useCustomModelId = false;
  String? _selectedModelId;
  String? _fetchError;
  String? _nameError;
  String? _customIdError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _modelIdController = TextEditingController();
    // ignore: discarded_futures - async init called in constructor
    _loadAvailableModels();
  }

  Future<void> _loadAvailableModels() async {
    final apiKey = switch (_selectedProvider) {
      ModelProvider.openRouter => widget.viewModel.openRouterKey,
      ModelProvider.groq => widget.viewModel.groqKey,
      ModelProvider.openCodeZen => widget.viewModel.openCodeZenKey,
    };

    if (apiKey.isEmpty) {
      setState(() {
        _availableModels = [];
        _isLoadingModels = false;
        _fetchError =
            'Chave de API não configurada para '
            '${_selectedProvider.displayName}';
      });
      return;
    }

    setState(() {
      _isLoadingModels = true;
      _fetchError = null;
    });

    final service = switch (_selectedProvider) {
      ModelProvider.openRouter => OpenRouterService(apiKey: apiKey),
      ModelProvider.groq => GroqService(apiKey: apiKey),
      ModelProvider.openCodeZen => OpenCodeZenService(apiKey: apiKey),
    };

    try {
      final models = await service.getAvailableModels();
      if (mounted) {
        setState(() {
          _availableModels = models;
          _isLoadingModels = false;
          if (models.isEmpty) {
            _fetchError = 'Nenhum modelo disponível';
          }
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
          _fetchError = ErrorMessageMapper.from(e);
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelIdController.dispose();
    super.dispose();
  }

  Future<void> _addModel() async {
    setState(() {
      _nameError = null;
      _customIdError = null;
    });

    final name = _nameController.text.trim();
    final modelId = _useCustomModelId
        ? _modelIdController.text.trim()
        : _selectedModelId ?? '';

    var hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Informe um nome para o modelo.');
      hasError = true;
    }

    if (modelId.isEmpty) {
      if (_useCustomModelId) {
        setState(() => _customIdError = 'Informe o ID do modelo.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selecione um modelo da lista.'),
            backgroundColor: AppColors.brand700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      hasError = true;
    }

    if (hasError) return;

    await widget.viewModel.addCustomModel(
      name: name,
      modelId: modelId,
      provider: _selectedProvider,
    );

    _nameController.clear();
    _modelIdController.clear();
    setState(() {
      _selectedModelId = null;
      _useCustomModelId = false;
      _nameError = null;
      _customIdError = null;
    });
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
          width: 640,
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
                  onChanged: _onProviderChanged,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Nome do modelo'),
                const SizedBox(height: 10),
                _ModelInputField(
                  controller: _nameController,
                  hint: 'Llama 3',
                  icon: HeroIcons.cpuChip,
                  error: _nameError,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('ID do modelo'),
                const SizedBox(height: 10),
                _ModelIdSelector(
                  availableModels: _availableModels,
                  isLoading: _isLoadingModels,
                  useCustomModelId: _useCustomModelId,
                  selectedModelId: _selectedModelId,
                  customModelIdController: _modelIdController,
                  onModelSelected: _onModelSelected,
                  onUseCustomChanged: _onUseCustomChanged,
                  error: _fetchError,
                  customIdError: _customIdError,
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

  void _onProviderChanged(ModelProvider newProvider) {
    setState(() {
      _selectedProvider = newProvider;
      _selectedModelId = null;
      _useCustomModelId = false;
      _modelIdController.clear();
    });
    // ignore: discarded_futures - async call without blocking UI
    _loadAvailableModels();
  }

  void _onModelSelected(String? modelId) {
    setState(() {
      _useCustomModelId = false;
      _modelIdController.clear();
      _selectedModelId = modelId;
      if (modelId?.isNotEmpty ?? false) {
        final model = _availableModels.firstWhere(
          (m) => m.id == modelId,
          orElse: () => AvailableModel(id: modelId!, name: modelId),
        );
        _nameController.text = model.name;
      }
    });
  }

  void _onUseCustomChanged(bool useCustom) {
    setState(() {
      _useCustomModelId = useCustom;
      if (useCustom) {
        _selectedModelId = null;
      }
    });
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
    this.error,
  });

  final TextEditingController controller;
  final String hint;
  final HeroIcons icon;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? Colors.red.shade400 : AppColors.surfaceHover,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
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
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                HeroIcon(
                  HeroIcons.exclamationCircle,
                  size: 14,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ModelIdSelector extends StatefulWidget {
  const _ModelIdSelector({
    required this.availableModels,
    required this.isLoading,
    required this.useCustomModelId,
    required this.selectedModelId,
    required this.customModelIdController,
    required this.onModelSelected,
    required this.onUseCustomChanged,
    this.error,
    this.customIdError,
  });

  final List<AvailableModel> availableModels;
  final bool isLoading;
  final bool useCustomModelId;
  final String? selectedModelId;
  final TextEditingController customModelIdController;
  final ValueChanged<String?> onModelSelected;
  final ValueChanged<bool> onUseCustomChanged;
  final String? error;
  final String? customIdError;

  @override
  State<_ModelIdSelector> createState() => _ModelIdSelectorState();
}

class _ModelIdSelectorState extends State<_ModelIdSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.surfaceHover,
            ),
          ),
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brand400,
                      ),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.useCustomModelId
                        ? null
                        : widget.selectedModelId,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceCard,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Selecione um modelo',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
                    items: [
                      ...widget.availableModels.map(
                        (model) => DropdownMenuItem(
                          value: model.id,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              model.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '__other__',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Outro',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: _onDropdownChanged,
                  ),
                ),
        ),
        if (widget.useCustomModelId) ...[
          const SizedBox(height: 10),
          _ModelInputField(
            controller: widget.customModelIdController,
            hint: 'ex: llama3-70b-8192',
            icon: HeroIcons.codeBracket,
            error: widget.customIdError,
          ),
        ],
        if (widget.error != null && !widget.useCustomModelId) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.brand700.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const HeroIcon(
                  HeroIcons.exclamationTriangle,
                  size: 16,
                  color: AppColors.brand400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.error!,
                    style: const TextStyle(
                      color: AppColors.brand400,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _onDropdownChanged(String? value) {
    if (value == '__other__') {
      widget.onUseCustomChanged(true);
    } else {
      widget.onModelSelected(value);
    }
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

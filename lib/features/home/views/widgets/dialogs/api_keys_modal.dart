import 'package:flutter/material.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/dialog_wrappers.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_api_keys_section.dart';

class ApiKeysModal extends StatelessWidget {
  const ApiKeysModal({
    required this.openRouterController,
    required this.groqController,
    required this.openCodeZenController,
    required this.obscureOpenRouter,
    required this.obscureGroq,
    required this.obscureOpenCodeZen,
    required this.onToggleOpenRouter,
    required this.onToggleGroq,
    required this.onToggleOpenCodeZen,
    required this.onClose,
    required this.onSave,
    super.key,
  });

  final TextEditingController openRouterController;
  final TextEditingController groqController;
  final TextEditingController openCodeZenController;
  final bool obscureOpenRouter;
  final bool obscureGroq;
  final bool obscureOpenCodeZen;
  final VoidCallback onToggleOpenRouter;
  final VoidCallback onToggleGroq;
  final VoidCallback onToggleOpenCodeZen;
  final VoidCallback onClose;
  final VoidCallback onSave;

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
            child: ApiKeysSection(
              openRouterController: openRouterController,
              groqController: groqController,
              openCodeZenController: openCodeZenController,
              obscureOpenRouter: obscureOpenRouter,
              obscureGroq: obscureGroq,
              obscureOpenCodeZen: obscureOpenCodeZen,
              onToggleOpenRouter: onToggleOpenRouter,
              onToggleGroq: onToggleGroq,
              onToggleOpenCodeZen: onToggleOpenCodeZen,
              onBack: onClose,
              onDone: onSave,
            ),
          ),
        ),
      ),
    );
  }
}

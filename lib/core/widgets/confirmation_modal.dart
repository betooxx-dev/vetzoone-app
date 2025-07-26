import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final bool isDestructive;
  final Widget? customContent;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.isDestructive = false,
    this.customContent,
  });

  // Método estático para mostrar el modal fácilmente
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    bool isDestructive = false,
    Widget? customContent,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationModal(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: iconColor,
          confirmButtonColor: confirmButtonColor,
          isDestructive: isDestructive,
          customContent: customContent,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultConfirmColor =
        isDestructive
            ? AppColors.error
            : (confirmButtonColor ?? AppColors.primary);

    final defaultIcon =
        isDestructive
            ? Icons.warning_rounded
            : (icon ?? Icons.help_outline_rounded);

    final defaultIconColor =
        isDestructive ? AppColors.error : (iconColor ?? AppColors.primary);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(defaultIcon, defaultIconColor),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMessage(),
            if (customContent != null) ...[
              const SizedBox(height: 20),
              customContent!,
            ],
            const SizedBox(height: 24),
            _buildButtons(context, defaultConfirmColor),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData iconData, Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Icon(iconData, size: AppSizes.iconL, color: color),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtons(BuildContext context, Color confirmColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                cancelText ?? 'Cancelar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: Container(
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              gradient: LinearGradient(
                colors:
                    isDestructive
                        ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                        : [confirmColor, confirmColor.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: confirmColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                confirmText ?? (isDestructive ? 'Eliminar' : 'Confirmar'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum ConfirmationType { delete, save, cancel, logout, custom }

extension ConfirmationTypeExtension on ConfirmationType {
  ConfirmationModal createModal({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? customContent,
  }) {
    switch (this) {
      case ConfirmationType.delete:
        return ConfirmationModal(
          title: title,
          message: message,
          confirmText: 'Eliminar',
          cancelText: 'Cancelar',
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.error,
          confirmButtonColor: AppColors.error,
          isDestructive: true,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        );

      case ConfirmationType.save:
        return ConfirmationModal(
          title: title,
          message: message,
          confirmText: 'Guardar',
          cancelText: 'Cancelar',
          icon: Icons.save_outlined,
          iconColor: AppColors.success,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        );

      case ConfirmationType.cancel:
        return ConfirmationModal(
          title: title,
          message: message,
          confirmText: 'Sí, cancelar',
          cancelText: 'No',
          icon: Icons.cancel_outlined,
          iconColor: AppColors.warning,
          confirmButtonColor: AppColors.warning,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        );

      case ConfirmationType.logout:
        return ConfirmationModal(
          title: title,
          message: message,
          confirmText: 'Cerrar sesión',
          cancelText: 'Cancelar',
          icon: Icons.logout_rounded,
          iconColor: AppColors.warning,
          confirmButtonColor: AppColors.warning,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        );

      case ConfirmationType.custom:
      // ignore: unreachable_switch_default
      default:
        return ConfirmationModal(
          title: title,
          message: message,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        );
    }
  }
}

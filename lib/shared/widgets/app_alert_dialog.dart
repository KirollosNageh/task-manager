import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  const AppAlertDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final iconTint =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final iconBackground = isDestructive
        ? theme.colorScheme.error.withOpacity(0.12)
        : theme.colorScheme.primary.withOpacity(0.12);

    final actions = <Widget>[];
    if (onCancel != null && cancelText.isNotEmpty) {
      actions.add(
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceVariant,
                foregroundColor: theme.colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(cancelText),
            ),
          ),
        ),
      );
    }

    if (onCancel != null && onConfirm != null && cancelText.isNotEmpty) {
      actions.add(const SizedBox(width: 12));
    }

    if (onConfirm != null && confirmText.isNotEmpty) {
      actions.add(
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextButton(
              onPressed: onConfirm,
              style: TextButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(confirmText),
            ),
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconTint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            if (actions.isNotEmpty)
              Row(
                children: actions,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

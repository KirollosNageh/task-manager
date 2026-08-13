import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Thin banner shown above a list when the current data came from local
/// cache rather than a confirmed server response (see TaskRepository's
/// use of Firestore's `metadata.isFromCache`). Reusable for any future
/// screen backed by a Firestore stream.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.warning.withValues(alpha: 0.15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 16, color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          Text(
            "You're offline — showing cached data",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
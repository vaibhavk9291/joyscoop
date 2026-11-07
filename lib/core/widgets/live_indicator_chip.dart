import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Status of the app's sync connection
enum LiveStatus { live, offline, syncing }

/// Live indicator chip (small pill, white, 8px dot, pending count when queued)
class LiveIndicatorChip extends StatelessWidget {
  final LiveStatus status;
  final int pendingCount;
  final VoidCallback? onTap;

  const LiveIndicatorChip({
    super.key,
    required this.status,
    this.pendingCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String label;

    switch (status) {
      case LiveStatus.live:
        dotColor = AppColors.liveGreen;
        label = pendingCount > 0 ? 'Syncing ($pendingCount)' : 'Live';
        break;
      case LiveStatus.syncing:
        dotColor = AppColors.primary;
        label = pendingCount > 0 ? 'Syncing ($pendingCount)' : 'Syncing...';
        break;
      case LiveStatus.offline:
        dotColor = AppColors.textSecondary;
        label = pendingCount > 0 ? 'Offline ($pendingCount)' : 'Offline';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
          boxShadow: AppShadows.circularButtonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimensions.liveDotSize,
              height: AppDimensions.liveDotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              label,
              style: AppTextStyles.captionBold.copyWith(
                color: status == LiveStatus.live
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


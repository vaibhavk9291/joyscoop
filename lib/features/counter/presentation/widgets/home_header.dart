import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/live_indicator_chip.dart';

/// Top header on Today screen strictly per DESIGN.md
class HomeHeader extends StatelessWidget {
  final String staffName;
  final LiveStatus liveStatus;
  final int pendingCount;
  final VoidCallback onLogout;
  final VoidCallback? onSyncTap;

  const HomeHeader({
    super.key,
    required this.staffName,
    required this.liveStatus,
    this.pendingCount = 0,
    required this.onLogout,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = AppDateUtils.getGreeting();

    return Row(
      children: [
        // Avatar Circle (40x40)
        Container(
          width: AppDimensions.avatarSize,
          height: AppDimensions.avatarSize,
          decoration: const BoxDecoration(
            color: AppColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.space12),

        // Greeting: "Hey, {name}" (caption) over "Good Morning/..." (cardTitle)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hey, $staffName',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                greeting,
                style: AppTextStyles.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: AppDimensions.space8),

        // Live Chip
        LiveIndicatorChip(
          status: liveStatus,
          pendingCount: pendingCount,
          onTap: onSyncTap,
        ),

        const SizedBox(width: AppDimensions.space8),

        // Circular Logout Button
        CircularIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Sign out',
          onTap: onLogout,
        ),
      ],
    );
  }
}


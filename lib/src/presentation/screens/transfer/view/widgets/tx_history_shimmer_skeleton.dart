import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Shimmer skeleton loader for Transfer and Payment history screens.
/// Matches the real transaction list row layout for smooth perceptual loading.
class TxHistoryShimmerSkeleton extends StatelessWidget {
  final int itemCount;

  const TxHistoryShimmerSkeleton({super.key, this.itemCount = 7});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
        : AppColors.lightSurfaceVariant;
    final highlightColor = isDark
        ? AppColors.darkCard
        : AppColors.white.withValues(alpha: 0.85);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 85,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Trailing amount & status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 75,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 50,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Perceptually matched shimmer skeleton loader for Transfer, Make Payment,
/// and Request Money wizard screens. Mimics the exact card-based layout
/// (wallet hero card, recipient field, hero amount card, and CTA buttons).
class TxFlowShimmerSkeleton extends StatelessWidget {
  const TxFlowShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
        : AppColors.lightSurfaceVariant;
    final highlightColor = isDark
        ? AppColors.darkCard
        : AppColors.white.withValues(alpha: 0.8);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // 1. Wallet Hero Card Skeleton
            Container(
              width: double.infinity,
              height: 148,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Recipient Label & Input Field Skeleton
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Hero Amount Input Card Skeleton
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Column(
                children: [
                  // Balance Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 90,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Hero Amount Row
                  Container(
                    width: 180,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick Percentage Chips
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 34,
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Fee Pill
                  Container(
                    width: double.infinity,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 4. Primary CTA Button Skeleton
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. Secondary Action Button Skeleton
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

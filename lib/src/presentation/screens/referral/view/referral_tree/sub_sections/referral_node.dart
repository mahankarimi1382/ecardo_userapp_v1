import 'package:flutter/material.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class ReferralNode extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isRoot;

  const ReferralNode({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color nodeBackgroundColor =
        isDark ? AppColors.darkCard : AppColors.white;

    final nodeBorder = Border.all(
      color: isRoot
          ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
          : (isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant),
      width: isRoot ? 1.6 : 1.0,
    );

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: nodeBackgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: nodeBorder,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: isRoot ? 28 : 22,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSecondaryContainer,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  onBackgroundImageError: avatarUrl.isNotEmpty
                      ? (dynamic exception, StackTrace? stackTrace) {}
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: isRoot ? 20 : 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                          ),
                        )
                      : null,
                ),
                if (isRoot)
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: nodeBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isRoot ? FontWeight.w800 : FontWeight.w600,
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

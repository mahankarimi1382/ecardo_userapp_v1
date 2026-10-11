import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

class OrderDetailsTraderHeaderWidget extends StatelessWidget {
  final String avatarText;
  final String name;
  final bool isVerified;
  final VoidCallback? onTap;

  const OrderDetailsTraderHeaderWidget({
    super.key,
    required this.avatarText,
    required this.name,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final emeraldGreen = const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trader Avatar with Online Dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF312E81), Color(0xFF4338CA)]
                        : const [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: 11.r,
                  height: 11.r,
                  decoration: BoxDecoration(
                    color: emeraldGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),

          // Name & Verification Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5.sp,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 10.5.r, color: Colors.black87),
                            SizedBox(width: 2.w),
                            Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  l10nPick(context, en: 'Counterparty Trader', fa: 'طرف معامله'),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Chat Button
          GestureDetector(
            onTap: () {
              if (onTap != null) {
                HapticFeedback.lightImpact();
                onTap!();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16.r,
                    color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    l10nPick(context, en: 'Chat', fa: 'گفتگو'),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

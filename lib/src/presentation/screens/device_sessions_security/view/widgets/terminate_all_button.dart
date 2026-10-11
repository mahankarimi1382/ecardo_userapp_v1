import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Emergency Red Action container:
/// "Terminate All Other Sessions / خروج از سایر دستگاه‌ها"
/// Designed following modern banking & privacy standards (Telegram / 1Password).
class TerminateAllButton extends StatelessWidget {
  final int otherCount;
  final bool isDark;
  final VoidCallback onTerminateAll;

  const TerminateAllButton({
    super.key,
    required this.otherCount,
    required this.isDark,
    required this.onTerminateAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasOthers = otherCount > 0;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: hasOthers
              ? AppColors.error.withValues(alpha: 0.35)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1.2,
        ),
        boxShadow: hasOthers
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (hasOthers ? AppColors.error : AppColors.softGray).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: hasOthers ? AppColors.error : AppColors.softGray,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Terminate All Other Sessions',
                        fa: 'خروج از سایر دستگاه‌ها',
                        ar: 'خروج من جميع الجلسات الأخرى',
                        zh: '终止所有其他活动会话',
                      ),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: hasOthers ? AppColors.error : (isDark ? AppColors.softGray : AppColors.greyDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      hasOthers
                          ? l10nPick(
                              context,
                              en: 'Instantly revoke access for $otherCount other active device(s).',
                              fa: 'قطع فوری دسترسی برای $otherCount نشست فعال دیگر.',
                              ar: 'إنهاء الجلسات فورًا لـ $otherCount جهاز نشط آخر.',
                              zh: '立即断开其他 $otherCount 台设备的会话连接。',
                            )
                          : l10nPick(
                              context,
                              en: 'No other active devices logged in to your account.',
                              fa: 'هیچ دستگاه دیگری در حساب شما وارد نشده است.',
                              ar: 'لا توجد أجهزة أخرى نشطة مسجلة الدخول.',
                              zh: '当前无其他在线设备。',
                            ),
                      style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasOthers
                    ? AppColors.error
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.greyLight.withValues(alpha: 0.7)),
                foregroundColor: hasOthers
                    ? AppColors.white
                    : (isDark ? AppColors.softGray : AppColors.greyDark),
                elevation: hasOthers ? 1.5 : 0,
                shadowColor: AppColors.error.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              icon: Icon(Icons.no_accounts_rounded, size: 18.sp),
              label: Text(
                l10nPick(
                  context,
                  en: 'Terminate All Other Devices',
                  fa: 'خروج از تمام دستگاه‌های دیگر',
                  ar: 'إنهاء كل الجلسات الأخرى',
                  zh: '终止所有其他设备',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: hasOthers ? onTerminateAll : null,
            ),
          ),
        ],
      ),
    );
  }
}

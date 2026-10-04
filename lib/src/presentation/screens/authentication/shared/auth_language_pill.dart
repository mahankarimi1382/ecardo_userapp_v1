import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Flagship language selector pill with frosted glass styling and native badge.
class AuthLanguagePill extends StatelessWidget {
  const AuthLanguagePill({super.key});

  static String _isoCode(String code) => switch (code.toLowerCase()) {
        'fa' => 'FA',
        'ar' => 'AR',
        'zh' => 'ZH',
        'tr' => 'TR',
        'ru' => 'RU',
        _ => 'EN',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentCode = Localizations.localeOf(context).languageCode;
    final currentName = LocaleThemeService.nativeName(currentCode);
    final iso = _isoCode(currentCode);

    final pillBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.white.withValues(alpha: 0.88);
    final pillBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.lightBorder.withValues(alpha: 0.80);
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showLanguageModal(context),
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsetsDirectional.only(
            start: 6.w,
            end: 10.w,
            top: 4.h,
            bottom: 4.h,
          ),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: pillBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF38BDF8), const Color(0xFF6366F1)]
                        : [AppColors.deepBlack, const Color(0xFF3F3F46)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  iso,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                currentName,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showLanguageModal(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentCode = Localizations.localeOf(context).languageCode;

    final sheetBg = isDark ? const Color(0xFF131826) : AppColors.white;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final selectedCode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                l10nPick(
                  context,
                  en: 'Select Language',
                  fa: 'انتخاب زبان',
                  ar: 'اختر اللغة',
                  zh: '选择语言',
                  tr: 'Dil Seçin',
                  ru: 'Выберите язык',
                ),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 14.h),
              for (final c in LocaleThemeService.supported)
                Container(
                  margin: EdgeInsets.only(bottom: 6.h),
                  decoration: BoxDecoration(
                    color: c == currentCode
                        ? (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: c == currentCode
                          ? (isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.deepBlack)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                    leading: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.lightBorder.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _isoCode(c),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                    ),
                    title: Text(
                      LocaleThemeService.nativeName(c),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: c == currentCode
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    trailing: c == currentCode
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.deepBlack,
                            size: 22.sp,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, c),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (selectedCode != null && Get.isRegistered<LocaleThemeService>()) {
      await Get.find<LocaleThemeService>().setLanguage(selectedCode);
    }
  }
}

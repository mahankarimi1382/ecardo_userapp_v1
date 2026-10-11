import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/model/device_session_model.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/pulsing_indicator.dart';

/// Hero card highlighting "This Device" with top-level security credentials:
/// - Green "This Device" badge with live pulsing beacon
/// - Dedicated OS brand icon container (Android / iOS / Windows / macOS / Web)
/// - Device model, OS build details, and App version badge
/// - Monospaced IP address with tap-to-copy
/// - Login timestamp & approximate geolocation
class ThisDeviceHeroCard extends StatelessWidget {
  final DeviceSessionItem device;
  final bool isDark;

  const ThisDeviceHeroCard({
    super.key,
    required this.device,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final osColor = device.os.brandColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: "This Device / این دستگاه" Green Badge & Verified Shield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulsingIndicator(
                      color: AppColors.success,
                      size: 8.5,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      l10nPick(
                        context,
                        en: 'This Device / همین دستگاه',
                        fa: 'همین دستگاه (نشست فعال)',
                        ar: 'هذا الجهاز (نشط الآن)',
                        zh: '本机（当前在线）',
                      ),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 20.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Row 2: OS Brand Icon + Device Name + OS & App Version Badges
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: osColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: osColor.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    device.icon,
                    color: isDark ? osColor : (device.os == DeviceOs.ios ? AppColors.deepBlack : osColor),
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${device.operatingSystem} • ${device.localizedType(context)}',
                            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (device.appVersion != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.greyLight.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              device.appVersion!,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          SizedBox(height: AppSpacing.md),

          // Row 3: IP Address & Approximate Geolocation
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: device.ipAddress));
                    HapticFeedback.selectionClick();
                    ToastHelper().showSuccessToast(
                      l10nPick(
                        context,
                        en: 'IP address copied to clipboard',
                        fa: 'آدرس IP در حافظه کپی شد',
                        ar: 'تم نسخ عنوان IP',
                        zh: 'IP地址已复制',
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 15.sp,
                          color: secondaryTextColor,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'IP: ${device.ipAddress}',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              color: primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 12.sp,
                          color: secondaryTextColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 15.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        device.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          // Row 4: Login Timestamp & App Version Metadata
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14.sp,
                color: secondaryTextColor,
              ),
              SizedBox(width: 6.w),
              Text(
                '${l10nPick(context, en: 'Logged in:', fa: 'زمان ورود:', ar: 'تسجيل الدخول:', zh: '登录时间:')} ${device.formattedLoginTime(context)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.sp,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Security check assurance banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
                  : AppColors.lightPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary).withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16.sp,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Verified session with hardware-backed digital device fingerprinting.',
                      fa: 'نشست تأییدشده با اثرانگشت دیجیتال سخت‌افزاری و احراز هویت امن.',
                      ar: 'جلسة موثقة ومحمية ببصمة الجهاز الرقمية المشفرة.',
                      zh: '基于硬件级设备数字指纹认证的高可信会话。',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

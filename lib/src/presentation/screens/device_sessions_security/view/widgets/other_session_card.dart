import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/model/device_session_model.dart';

/// Card representing a non-current active session / device:
/// - Distinctive OS brand icon container
/// - Model name, operating system, and browser details
/// - Approximate location/city, IP address (with copy), and relative last active
/// - Destructive single-session revoke button
class OtherSessionCard extends StatelessWidget {
  final DeviceSessionItem session;
  final bool isDark;
  final VoidCallback onRevoke;

  const OtherSessionCard({
    super.key,
    required this.session,
    required this.isDark,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final osColor = session.os.brandColor;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () {
            HapticFeedback.lightImpact();
            onRevoke();
          },
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OS / Device Icon Container
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: osColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: osColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          session.icon,
                          color: isDark ? osColor : (session.os == DeviceOs.ios ? AppColors.deepBlack : osColor),
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),

                    // Device Model & OS/Browser Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.deviceName,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${session.operatingSystem} • ${session.clientVersion}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondaryTextColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Single Revoke Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.h),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(Icons.logout_rounded, size: 14.sp),
                      label: Text(
                        l10nPick(
                          context,
                          en: 'Log Out',
                          fa: 'خروج',
                          ar: 'إنهاء',
                          zh: '登出',
                        ),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onRevoke();
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                SizedBox(height: AppSpacing.sm),

                // Metadata row: IP, Location, Last active relative time
                Row(
                  children: [
                    // Monospaced IP address with tap-to-copy
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: session.ipAddress));
                        HapticFeedback.selectionClick();
                        ToastHelper().showSuccessToast(
                          l10nPick(context, en: 'IP copied', fa: 'IP کپی شد', ar: 'تم النسخ', zh: '已复制'),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              size: 13.sp,
                              color: secondaryTextColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              session.ipAddress,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontFamily: 'monospace',
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.md),

                    // Geolocation
                    Icon(
                      Icons.place_outlined,
                      size: 13.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        session.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11.5.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // Relative last active (Jalali + relative)
                    Icon(
                      Icons.access_time_rounded,
                      size: 13.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      session.formattedJalaliOrRelative(context),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

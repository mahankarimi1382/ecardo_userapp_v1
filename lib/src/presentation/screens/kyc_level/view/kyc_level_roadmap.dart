import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

/// KycLevelRoadmap — نمایش بصری سطوح KYC به‌صورت کارت‌های افقی
///
/// هر کارت شامل:
///   - شماره سطح + آیکون
///   - نام سطح
///   - وضعیت (✓ تکمیل‌شده / ⏳ فعلی / 🔒 قفل / ⚠ ردشده)
///   - مدارک لازم (اگر قابل دسترسی یا فعلی است)
///
/// استفاده:
///   KycLevelRoadmap()  — در صفحه‌ی ID Verification یا Settings
class KycLevelRoadmap extends StatelessWidget {
  final VoidCallback? onLevelTap;

  const KycLevelRoadmap({super.key, this.onLevelTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycLevelController>();

    return Obx(() {
      if (controller.isLoading.value && controller.levels.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.levels.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Text(
              'مسیر احراز هویت',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // لیست سطوح
          ...controller.levels.map((level) => _LevelCard(
                level: level,
                onTap: onLevelTap,
              )),

          // دکمه‌ی ادامه‌ی احراز هویت (اگر سطح بعدی موجود است)
          if (controller.nextLevel != null && !controller.isPending) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onLevelTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ادامه احراز هویت — سطح ${controller.nextLevel!.level}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // پیام در حال بررسی
          if (controller.isPending) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top, color: AppColors.warning, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'مدارک شما در حال بررسی است. این فرآیند معمولاً ۱-۲ روز کاری طول می‌کشد.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // پیام رد شدن
          if (controller.isRejected) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'احراز هویت شما رد شده است. ${controller.status.value?.rejectionReason ?? "لطفاً مدارک را مجدداً ارسال کنید."}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

/// کارت یک سطح KYC
class _LevelCard extends StatelessWidget {
  final KycLevel level;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(level.colorValue);
    final statusColor = _statusColor(level, color);
    final statusIcon = _statusIcon(level);

    return GestureDetector(
      onTap: level.isAvailable ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h, left: 18.w, right: 18.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: level.isLocked ? AppColors.lightBackground : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: level.isCurrent ? color : AppColors.lightBorder,
            width: level.isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // شماره سطح / آیکون وضعیت
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // اطلاعات سطح
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'سطح ${level.level}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // badge وضعیت
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(level),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: level.isLocked
                          ? AppColors.lightTextHint
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (level.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // مدارک لازم (فقط برای سطح فعلی یا قابل دسترسی)
                  if ((level.isCurrent || level.isAvailable) &&
                      level.requiredDocs.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: level.requiredDocs.map((doc) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _docLabel(doc),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // آیکون قفل / فلش
            if (level.isLocked)
              Icon(Icons.lock_outline, color: AppColors.lightTextHint, size: 18.sp)
            else if (level.isAvailable)
              Icon(Icons.chevron_right, color: color, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Color _statusColor(KycLevel level, Color levelColor) {
    if (level.isCompleted) return AppColors.success;
    if (level.isCurrent) return levelColor;
    if (level.isAvailable) return AppColors.info;
    return AppColors.lightTextHint;
  }

  IconData _statusIcon(KycLevel level) {
    if (level.isCompleted) return Icons.check_circle;
    if (level.isCurrent) return Icons.play_circle;
    if (level.isAvailable) return Icons.lock_open;
    return Icons.lock;
  }

  String _statusLabel(KycLevel level) {
    if (level.isCompleted) return 'تکمیل شده';
    if (level.isCurrent) return 'فعلی';
    if (level.isAvailable) return 'آماده ارتقا';
    return 'قفل';
  }

  String _docLabel(String doc) {
    switch (doc) {
      case 'selfie':
        return 'سلفی';
      case 'govt_id':
        return 'مدرک شناسایی';
      case 'personal_info':
        return 'اطلاعات شخصی';
      case 'trade_license':
        return 'جواز تجارت';
      case 'business_info':
        return 'اطلاعات کسب‌وکار';
      case 'company_docs':
        return 'مدارک شرکت';
      default:
        return doc;
    }
  }
}

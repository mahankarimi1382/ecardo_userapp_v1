import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';

/// UpgradeRequiredScreen — صفحه‌ی "ارتقا مورد نیاز" به‌جای error
///
/// وقتی کاربر سعی می‌کند به ماژول قفل‌شده دسترسی یابد،
/// این صفحه نمایش داده می‌شود.
class UpgradeRequiredScreen extends StatelessWidget {
  final int requiredLevel;
  final int currentLevel;
  final String featureName;

  const UpgradeRequiredScreen({
    super.key,
    this.requiredLevel = 2,
    this.currentLevel = 1,
    this.featureName = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.warning,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                'ارتقا مورد نیاز',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                'برای دسترسی به «$featureName» باید به سطح $requiredLevel احراز هویت برسید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightTextSecondary,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24.h),

              // Level comparison
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LevelInfo(label: 'سطح فعلی شما', level: currentLevel, color: AppColors.warning),
                    Container(width: 1, height: 40, color: AppColors.lightBorder),
                    _LevelInfo(label: 'سطح لازم', level: requiredLevel, color: AppColors.lightPrimary),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(BaseRoute.navigation);
                    // Navigate to KYC verification
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.toNamed(BaseRoute.idVerification);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'شروع احراز هویت',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Secondary button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'بعداً انجام می‌دهم',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelInfo extends StatelessWidget {
  final String label;
  final int level;
  final Color color;

  const _LevelInfo({required this.label, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'سطح $level',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

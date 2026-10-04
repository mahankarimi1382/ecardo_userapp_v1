import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'visa_catalog_screen.dart';
import 'visa_list_screen.dart';

/// Screen introducing specialized visa and consular services.
class VisaIntroScreen extends StatelessWidget {
  const VisaIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'راهنمای خدمات اخذ ویزا',
              en: 'Visa & Consular Services',
              ar: 'دليل خدمات التأشيرات والقنصلية',
              zh: '签证与领事事务指南',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                ),
                tooltip: l10nPick(context, fa: 'درخواست‌های من', en: 'My Visas', ar: 'تأشيراتي', zh: '我的签证'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const VisaListScreen());
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'مشاهده کاتالوگ کشورها و ثبت درخواست',
              en: 'Explore Countries & Apply',
              ar: 'استعراض الدول وتقديم الطلب',
              zh: '浏览目的地国家并申请',
            ),
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            textColor: isDark ? AppColors.deepBlack : AppColors.white,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => const VisaCatalogScreen());
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.xl.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlack, AppColors.darkGray],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm.r),
                        decoration: BoxDecoration(
                          color: AppColors.mainSoftBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff_rounded, color: AppColors.mainSoftBlue, size: 26.sp),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'صدور ویزای الکترونیک (e-Visa) و خدمات کنسولی',
                            en: 'Electronic Visa & Consular Desk',
                            ar: 'التأشيرات الإلكترونية والخدمات القنصلية',
                            zh: '电子签证（e-Visa）与领事実务',
                          ),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'پشتیبانی تخصصی از اخذ ویزای بیش از ۱۲۰ کشور جهان. بررسی مدارک توسط کارشناسان امور بین‌الملل، نوبت‌دهی سفارت و تحویل دیجیتال ویزا.',
                      en: 'Specialized visa processing for 120+ destinations. Expert document pre-check, embassy scheduling, and digital e-visa issuance.',
                      ar: 'معالجة تأشيرات لأكثر من ۱۲۰ وجهة عالمية مع تدقيق الوثائق وحجز مواعيد السفارات.',
                      zh: '覆盖全球120多个目的地的专业签证代办服务，提供权威文件预审、使馆预约及电子签证快速签发。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Visa Types
            Text(
              l10nPick(
                context,
                fa: 'انواع ویزاهای قابل اخذ',
                en: 'Available Visa Categories',
                ar: 'أنواع التأشيرات المتاحة',
                zh: '可申请签证类别',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildTypeCard(
              context,
              isDark: isDark,
              icon: Icons.beach_access_rounded,
              titleFa: 'ویزای توریستی و گردشگری (Tourist eVisa)',
              titleEn: 'Tourist eVisa',
              descFa: 'صدور سریع الکترونیکی بدون نیاز به ارسال فیزیکی گذرنامه برای مقاصد منتخب.',
              descEn: 'Instant electronic issuance with zero passport mailing for qualifying countries.',
            ),
            _buildTypeCard(
              context,
              isDark: isDark,
              icon: Icons.business_center_rounded,
              titleFa: 'ویزای تجاری و بازرگانی (Business Visa)',
              titleEn: 'Business & Commercial Visa',
              descFa: 'اخذ دعوت‌نامه رسمی، ویزای نمایشگاهی و جلسات بازرگانی بین‌المللی.',
              descEn: 'Official business invitation letters, trade expo entry, and corporate meetings.',
            ),
            _buildTypeCard(
              context,
              isDark: isDark,
              icon: Icons.school_rounded,
              titleFa: 'ویزای تحصیلی و دانشجویی (Student Visa)',
              titleEn: 'Study & Student Visa',
              descFa: 'مشاوره پذیرش دانشگاهی، استعلام سفارت و بررسی تمکن مالی متقاضی.',
              descEn: 'University admission advisory, embassy interview prep, and financial proofing.',
            ),
            _buildTypeCard(
              context,
              isDark: isDark,
              icon: Icons.work_outline_rounded,
              titleFa: 'ویزای کاری و جاب‌آفر (Work Permit)',
              titleEn: 'Work & Employment Permit',
              descFa: 'ارزیابی قراردادهای استخدامی خارجی و پیگیری تأییدیه اداره مهاجرت کشور مقصد.',
              descEn: 'Overseas employment contract evaluation and destination immigration approval.',
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Steps
            Text(
              l10nPick(
                context,
                fa: 'مراحل ثبت و دریافت ویزا',
                en: 'Application Workflow',
                ar: 'خطوات استخراج التأشيرة',
                zh: '签证办理流程',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildStepRow(context, isDark: isDark, step: '۱', titleFa: 'انتخاب کشور مقصد و نوع ویزا', titleEn: 'Select Destination & Type'),
            _buildStepRow(context, isDark: isDark, step: '۲', titleFa: 'تکمیل مشخصات مسافر و پاسپورت', titleEn: 'Enter Passenger Details'),
            _buildStepRow(context, isDark: isDark, step: '۳', titleFa: 'آپلود مدارک هویتی و عکس پرسنلی', titleEn: 'Upload Passport & Documents'),
            _buildStepRow(context, isDark: isDark, step: '۴', titleFa: 'پرداخت امن هزینه کنسولی از والت', titleEn: 'Secure Wallet Payment'),
            _buildStepRow(context, isDark: isDark, step: '۵', titleFa: 'بررسی کارشناس و صدور نهایی e-Visa', titleEn: 'Consultant Audit & e-Visa Issue'),
            SizedBox(height: AppSpacing.xxxl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.r),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightSecondary).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
              size: AppSpacing.iconSm.r,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required bool isDark,
    required String step,
    required String titleFa,
    required String titleEn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(
                color: isDark ? AppColors.deepBlack : AppColors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

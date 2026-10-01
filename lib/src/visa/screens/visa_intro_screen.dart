import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'راهنمای خدمات اخذ ویزا',
              en: 'Visa & Consular Services',
              ar: 'دليل خدمات التأشيرات القنصلية',
              zh: '签证与领事服务指南',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'درخواست‌های من', en: 'My Visas', ar: 'تأشيراتي', zh: '我的签证'),
                onPressed: () => Get.to(() => const VisaListScreen()),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'مشاهده کاتالوگ کشورها و ثبت درخواست',
              en: 'Explore Countries & Apply',
              ar: 'استعراض الدول وتقديم الطلب',
              zh: '浏览目的地国家并申请',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () => Get.to(() => const VisaCatalogScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff_rounded, color: const Color(0xFFA5B4FC), size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'صدور ویزای الکترونیک (e-Visa) و خدمات کنسولی',
                            en: 'Electronic Visa & Consular Desk',
                            ar: 'التأشيرات الإلكترونية والخدمات القنصلية',
                            zh: '电子签证（e-Visa）与领事实务',
                          ),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'پشتیبانی تخصصی از اخذ ویزای بیش از ۱۲۰ کشور جهان. بررسی مدارک توسط کارشناسان امور بین‌الملل، نوبت‌دهی سفارت و تحویل دیجیتال ویزا.',
                      en: 'Specialized visa processing for 120+ destinations. Expert document pre-check, embassy scheduling, and digital e-visa issuance.',
                      ar: 'معالجة تأشيرات لأكثر من ١٢٠ وجهة عالمية مع تدقيق الوثائق وحجز مواعيد السفارات.',
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

            SizedBox(height: 20.h),

            // Visa Types
            Text(
              l10nPick(
                context,
                fa: 'انواع ویزاهای قابل اخذ',
                en: 'Available Visa Categories',
                ar: 'أنواع التأشيرات المتاحة',
                zh: '可申请签证类别',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildTypeCard(
              context,
              icon: Icons.beach_access_rounded,
              titleFa: 'ویزای توریستی و گردشگری (Tourist eVisa)',
              titleEn: 'Tourist eVisa',
              descFa: 'صدور سریع الکترونیکی بدون نیاز به ارسال فیزیکی گذرنامه برای مقاصد منتخب.',
              descEn: 'Instant electronic issuance with zero passport mailing for qualifying countries.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.business_center_rounded,
              titleFa: 'ویزای تجاری و بازرگانی (Business Visa)',
              titleEn: 'Business & Commercial Visa',
              descFa: 'اخذ دعوت‌نامه رسمی، ویزای نمایشگاهی و جلسات بازرگانی بین‌المللی.',
              descEn: 'Official business invitation letters, trade expo entry, and corporate meetings.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.school_rounded,
              titleFa: 'ویزای تحصیلی و دانشجویی (Student Visa)',
              titleEn: 'Study & Student Visa',
              descFa: 'مشاوره پذیرش دانشگاهی، استعلام سفارت و بررسی تمکن مالی متقاضی.',
              descEn: 'University admission advisory, embassy interview prep, and financial proofing.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.work_outline_rounded,
              titleFa: 'ویزای کاری و جاب‌آفر (Work Permit)',
              titleEn: 'Work & Employment Permit',
              descFa: 'ارزیابی قراردادهای استخدامی خارجی و پیگیری تأییدیه اداره مهاجرت کشور مقصد.',
              descEn: 'Overseas employment contract evaluation and destination immigration approval.',
            ),

            SizedBox(height: 20.h),

            // Steps
            Text(
              l10nPick(
                context,
                fa: 'مراحل ثبت و دریافت ویزا',
                en: 'Application Workflow',
                ar: 'خطوات استخراج التأشيرة',
                zh: '签证办理流程',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildStepRow(context, step: '۱', titleFa: 'انتخاب کشور مقصد و نوع ویزا', titleEn: 'Select Destination & Type'),
            _buildStepRow(context, step: '۲', titleFa: 'تکمیل مشخصات مسافر و پاسپورت', titleEn: 'Enter Passenger Details'),
            _buildStepRow(context, step: '۳', titleFa: 'آپلود مدارک هویتی و عکس پرسنلی', titleEn: 'Upload Passport & Documents'),
            _buildStepRow(context, step: '۴', titleFa: 'پرداخت امن هزینه کنسولی از والت', titleEn: 'Secure Wallet Payment'),
            _buildStepRow(context, step: '۵', titleFa: 'بررسی کارشناس و صدور نهایی e-Visa', titleEn: 'Consultant Audit & e-Visa Issue'),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFF4338CA).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4338CA), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, {required String step, required String titleFa, required String titleEn}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF4338CA),
              shape: BoxShape.circle,
            ),
            child: Text(step, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10.w),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

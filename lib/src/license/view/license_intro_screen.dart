import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'license_store_screen.dart';
import 'license_my_licenses_screen.dart';

/// Screen introducing the genuine software license store and digital delivery guarantees.
class LicenseIntroScreen extends StatelessWidget {
  const LicenseIntroScreen({super.key});

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
              fa: 'راهنمای فروشگاه لایسنس‌های اورجینال',
              en: 'Software Licenses Guide',
              ar: 'دليل متجر التراخيص الأصلية',
              zh: '正版软件许可证购买指南',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.lg.w),
              child: IconButton(
                icon: Icon(
                  Icons.vpn_key_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconMd.sp,
                ),
                tooltip: l10nPick(context, fa: 'لایسنس‌های من', en: 'My Licenses', ar: 'تراخيصي', zh: '我的许可证'),
                onPressed: () => Get.to(() => const LicenseMyLicensesScreen()),
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
              fa: 'ورود به فروشگاه لایسنس‌ها',
              en: 'Enter License Store',
              ar: 'الدخول إلى متجر التراخيص',
              zh: '进入许可证商城',
            ),
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            textColor: isDark ? AppColors.deepBlack : AppColors.white,
            onPressed: () => Get.to(() => const LicenseStoreScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
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
                          color: AppColors.success.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_rounded, color: const Color(0xFF34D399), size: 26.sp),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'تضمین اصالت ۱۰۰٪ لایسنس‌های دیجیتال',
                            en: '100% Genuine Digital License Guarantee',
                            ar: 'ضمان أصالة التراخيص الرقمية بنسبة ١٠٠٪',
                            zh: '100% 正版官方数字授权保障',
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
                      fa: 'تحویل فوری کلید لایسنس بلافاصله پس از تسویه کیف پول، همراه با راهنمای فعال‌سازی گام‌به‌گام و ضمانت جایگزینی ۴۸ ساعته در صورت بروز هرگونه مغایرت.',
                      en: 'Instant key delivery immediately after wallet settlement, complete with step-by-step activation guides and 48-hour replacement warranty.',
                      ar: 'تسليم فوري للمفتاح فور الخصم من المحفظة مع دليل تفعيل وضمان استبدال لمدة ٤٨ ساعة.',
                      zh: '钱包结算后秒级自动发货，配发官方激活指引，并享有48小时换货及售后争议保障。',
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

            // Product Categories
            Text(
              l10nPick(
                context,
                fa: 'دسته‌بندی‌های نرم‌افزاری تحت پوشش',
                en: 'License Categories',
                ar: 'فئات البرمجيات المدعومة',
                zh: '支持的软件与服务类目',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildCategoryTile(
              context,
              isDark: isDark,
              icon: Icons.window_rounded,
              titleFa: 'سیستم‌عامل و آفیس (Windows & Office)',
              titleEn: 'OS & Productivity',
              descFa: 'لایسنس‌های دائمی Windows 11 Pro، Microsoft Office 365 و ابزارهای اداری اورجینال.',
              descEn: 'Retail & OEM lifetime licenses for Windows 11 Pro, Office 365, and enterprise suites.',
            ),
            _buildCategoryTile(
              context,
              isDark: isDark,
              icon: Icons.code_rounded,
              titleFa: 'ابزارهای توسعه و برنامه‌نویسی (Developer Tools)',
              titleEn: 'Developer & Cloud Tools',
              descFa: 'اشتراک‌های رسمی JetBrains All Products Pack، GitHub Copilot و ابزارهای DevOps.',
              descEn: 'Official developer seats for JetBrains All Products, GitHub Copilot, and cloud IDEs.',
            ),
            _buildCategoryTile(
              context,
              isDark: isDark,
              icon: Icons.auto_awesome_rounded,
              titleFa: 'سرویس‌های هوش مصنوعی (AI Subscriptions)',
              titleEn: 'AI Platform Seats',
              descFa: 'اکانت‌های اختصاصی ChatGPT Plus، Claude Pro، Midjourney با شارژ قانونی ارزی.',
              descEn: 'Dedicated seats for ChatGPT Plus, Claude Pro, and Midjourney with compliant settlement.',
            ),
            _buildCategoryTile(
              context,
              isDark: isDark,
              icon: Icons.security_rounded,
              titleFa: 'امنیت و آنتی‌ویروس (Antivirus & Security)',
              titleEn: 'Cybersecurity & Antivirus',
              descFa: 'لایسنس رسمی ESET Internet Security، Kaspersky و VPNهای سازمانی اختصاصی.',
              descEn: 'Genuine multi-device seats for ESET Internet Security, Kaspersky, and secure tunnels.',
            ),

            SizedBox(height: AppSpacing.xl.h),

            // How delivery works
            Text(
              l10nPick(
                context,
                fa: 'فرآیند خرید و تحویل آنی',
                en: 'Instant Delivery Workflow',
                ar: 'آلية الشراء والتسليم الفوري',
                zh: '自动化交付流转机制',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildStepRow(context, isDark: isDark, step: '۱', titleFa: 'انتخاب نسخه نرم‌افزار و مدت اعتبار', titleEn: 'Choose Edition & Duration'),
            _buildStepRow(context, isDark: isDark, step: '۲', titleFa: 'کسر وجه از کیف پول ریالی یا ارزی', titleEn: 'Seamless Wallet Settlement'),
            _buildStepRow(context, isDark: isDark, step: '۳', titleFa: 'تحویل خودکار کد لایسنس در صندوق امن', titleEn: 'Instant Key Reveal in Vault'),
            _buildStepRow(context, isDark: isDark, step: '۴', titleFa: 'پشتیبانی و امکان ثبت اختلاف تا ۴۸ ساعت', titleEn: '48h Warranty & Dispute Protection'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
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
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.r),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              size: AppSpacing.iconSm.sp,
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
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(
                color: isDark ? AppColors.deepBlack : AppColors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

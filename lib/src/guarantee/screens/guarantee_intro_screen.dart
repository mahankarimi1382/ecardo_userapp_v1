import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import 'guarantee_application_screen.dart';

/// Informational guide and fee estimator for Bank Guarantee & LC services.
class GuaranteeIntroScreen extends StatefulWidget {
  const GuaranteeIntroScreen({super.key});

  @override
  State<GuaranteeIntroScreen> createState() => _GuaranteeIntroScreenState();
}

class _GuaranteeIntroScreenState extends State<GuaranteeIntroScreen> {
  final GuaranteeController controller = Get.isRegistered<GuaranteeController>()
      ? Get.find<GuaranteeController>()
      : Get.put(GuaranteeController());

  double _sampleAmount = 100000000; // 100M
  final double _marginPct = 10.0;
  final double _feePct = 1.5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final margin = _sampleAmount * (_marginPct / 100.0);
    final fee = _sampleAmount * (_feePct / 100.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'راهنمای ضمانت‌نامه‌ها و اعتبارات اسنادی',
              en: 'Bank Guarantee & LC Guide',
              ar: 'دليل خطابات الضمان والاعتمادات',
              zh: '保函与信用证业务指南',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'شروع صدور ضمانت‌نامه آنلاین',
              en: 'Apply for Guarantee',
              ar: 'إصدار خطاب ضمان جديد',
              zh: '立即申请开立保函',
            ),
            backgroundColor: primaryAccent,
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.amountInput.value = _sampleAmount.toStringAsFixed(0);
              Get.to(() => const GuaranteeApplicationScreen());
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.all(AppSpacing.xl.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF161614), const Color(0xFF1E2E38)]
                      : [const Color(0xFF161614), const Color(0xFF263238)],
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
                        padding: EdgeInsetsDirectional.all(AppSpacing.sm.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_user_rounded, color: const Color(0xFF2DD4BF), size: 26.sp),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'صدور معتبر از طریق سامانه سپام بانک مرکزی',
                            en: 'SEPAM Certified Bank Guarantees',
                            ar: 'خطابات ضمان معتمدة ومسجلة في سبام',
                            zh: '央行SEPAM认证电子银行保函',
                          ),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'صدور انواع ضمانت‌نامه‌های رسمی بانکی با حداقل سپرده نقدی، توثیق آنلاین دارایی‌ها و استعلام اصالت الکترونیک آنی برای کارفرمایان.',
                      en: 'Issuance of official bank guarantees with minimum cash margin, online collateral pledge, and real-time electronic verification for employers.',
                      ar: 'إصدار مختلف أنواع خطابات الضمان المصرفية بهامش نقدي ميسر وتوثيق إلكتروني فوري.',
                      zh: '提供具有极低保函保证金比例的官方电子保函，支持线上资产抵质押及雇主端实时真伪查验。',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Types of instruments
            Text(
              l10nPick(
                context,
                fa: 'انواع ابزارهای ضمانت بانکی',
                en: 'Guarantee Instruments',
                ar: 'أنواع خطابات الضمان',
                zh: '保函与信用证分类',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildInstrumentCard(
              context,
              isDark: isDark,
              titleFa: 'ضمانت‌نامه شرکت در مناقصه و مزایده (Bid Bond)',
              titleEn: 'Bid Bond (Tender Guarantee)',
              descFa: 'حداقل سپرده نقدی ۵٪ تا ۱۰٪. تضمین پیشنهاد قیمت در مناقصات دولتی و خصوصی.',
              descEn: '5-10% margin. Guarantees quotation validity in corporate & public tenders.',
            ),
            _buildInstrumentCard(
              context,
              isDark: isDark,
              titleFa: 'ضمانت‌نامه حسن انجام تعهدات (Performance Bond)',
              titleEn: 'Performance Bond',
              descFa: 'تضمین اجرای صحیح مفاد قرارداد کاری، پروژه‌های پیمانکاری و ساختمانی.',
              descEn: 'Guarantees execution of project contracts according to agreed technical specs.',
            ),
            _buildInstrumentCard(
              context,
              isDark: isDark,
              titleFa: 'ضمانت‌نامه پیش‌پرداخت (Advance Payment)',
              titleEn: 'Advance Payment Guarantee',
              descFa: 'تضمین بازپرداخت مبالغ واریز شده کارفرما قبل از تحویل کار.',
              descEn: 'Secures advance funds disbursed by employer prior to milestone delivery.',
            ),
            _buildInstrumentCard(
              context,
              isDark: isDark,
              titleFa: 'اعتبار اسنادی داخلی و بین‌المللی (LC)',
              titleEn: 'Letter of Credit (LC)',
              descFa: 'تسهیل تبادلات بازرگانی کالا با تسویه مشروط به ارائه اسناد حمل معتبر.',
              descEn: 'Facilitates commercial transactions conditioned upon shipping document presentation.',
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Cost calculation preview
            Text(
              l10nPick(
                context,
                fa: 'محاسبه‌گر تخمینی وجه‌الضمان و کارمزد',
                en: 'Margin & Issuance Fee Estimator',
                ar: 'حاسبة التأمين والعمولة التقديرية',
                zh: '保证金与开立费估算器',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'مبلغ اسمی ضمانت‌نامه', en: 'Face Amount', ar: 'المبلغ الاسمي', zh: '保函面额'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${_sampleAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sampleAmount,
                    min: 20000000,
                    max: 500000000,
                    divisions: 24,
                    activeColor: primaryAccent,
                    onChanged: (val) {
                      setState(() => _sampleAmount = val);
                    },
                  ),
                  Divider(
                    height: 20,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'وجه التزام نقدی (۱۰٪):', en: 'Cash Margin (10%):', ar: 'التأمين النقدي (١٠٪):', zh: '现金保证金（10%）：'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '${margin.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ریال',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: primaryAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'کارمزد صدور سالانه (۱.۵٪):', en: 'Issuance Fee (1.5%):', ar: 'عمولة الإصدار (١.٥٪):', zh: '年化开立费（1.5%）：'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${fee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ریال',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context, {
    required bool isDark,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
      padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: const Color(0xFF0D9488), size: 20.sp),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: AppTextStyles.bodySmall.copyWith(
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
}

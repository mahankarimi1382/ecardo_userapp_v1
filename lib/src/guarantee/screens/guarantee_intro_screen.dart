import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import 'guarantee_application_screen.dart';

/// Screen explaining bank guarantee instruments, LC facilities, and terms.
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
  double _marginPct = 10.0;
  double _feePct = 1.5;

  @override
  Widget build(BuildContext context) {
    final margin = _sampleAmount * (_marginPct / 100.0);
    final fee = _sampleAmount * (_feePct / 100.0);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'شروع صدور ضمانت‌نامه آنلاین',
              en: 'Apply for Guarantee',
              ar: 'إصدار خطاب ضمان جديد',
              zh: '立即申请开立保函',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () {
              controller.amountInput.value = _sampleAmount.toStringAsFixed(0);
              Get.to(() => const GuaranteeApplicationScreen());
            },
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
                  colors: [Color(0xFF161614), Color(0xFF263238)],
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
                          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_user_rounded, color: const Color(0xFF2DD4BF), size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'صدور معتبر از طریق سامانه سپام بانک مرکزی',
                            en: 'SEPAM Certified Bank Guarantees',
                            ar: 'خطابات ضمان معتمدة ومسجلة في سبام',
                            zh: '央行SEPAM认证电子银行保函',
                          ),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'صدور انواع ضمانت‌نامه‌های رسمی بانکی با حداقل سپرده نقدی، توثیق آنلاین دارایی‌ها و استعلام اصالت الکترونیک آنی برای کارفرمایان.',
                      en: 'Issuance of official bank guarantees with minimum cash margin, online collateral pledge, and real-time electronic verification for employers.',
                      ar: 'إصدار مختلف أنواع خطابات الضمان المصرفية بهامش نقدي ميسر وتوثيق إلكتروني فوري.',
                      zh: '提供具有极低保函保证金比例的官方电子保函，支持线上资产抵质押及雇主端实时真伪查验。',
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

            // Types of instruments
            Text(
              l10nPick(
                context,
                fa: 'انواع ابزارهای ضمانت بانکی',
                en: 'Guarantee Instruments',
                ar: 'أنواع خطابات الضمان',
                zh: '保函与信用证分类',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildInstrumentCard(
              context,
              titleFa: 'ضمانت‌نامه شرکت در مناقصه و مزایده (Bid Bond)',
              titleEn: 'Bid Bond (Tender Guarantee)',
              descFa: 'حداقل سپرده نقدی ۵٪ تا ۱۰٪. تضمین پیشنهاد قیمت در مناقصات دولتی و خصوصی.',
              descEn: '5-10% margin. Guarantees quotation validity in corporate & public tenders.',
            ),
            _buildInstrumentCard(
              context,
              titleFa: 'ضمانت‌نامه حسن انجام تعهدات (Performance Bond)',
              titleEn: 'Performance Bond',
              descFa: 'تضمین اجرای صحیح مفاد قرارداد کاری، پروژه‌های پیمانکاری و ساختمانی.',
              descEn: 'Guarantees execution of project contracts according to agreed technical specs.',
            ),
            _buildInstrumentCard(
              context,
              titleFa: 'ضمانت‌نامه پیش‌پرداخت (Advance Payment)',
              titleEn: 'Advance Payment Guarantee',
              descFa: 'تضمین بازپرداخت مبالغ واریز شده کارفرما قبل از تحویل کار.',
              descEn: 'Secures advance funds disbursed by employer prior to milestone delivery.',
            ),
            _buildInstrumentCard(
              context,
              titleFa: 'اعتبار اسنادی داخلی و بین‌المللی (LC)',
              titleEn: 'Letter of Credit (LC)',
              descFa: 'تسهیل تبادلات بازرگانی کالا با تسویه مشروط به ارائه اسناد حمل معتبر.',
              descEn: 'Facilitates commercial transactions conditioned upon shipping document presentation.',
            ),

            SizedBox(height: 20.h),

            // Cost calculation preview
            Text(
              l10nPick(
                context,
                fa: 'محاسبه‌گر تخمینی وجه‌الضمان و کارمزد',
                en: 'Margin & Issuance Fee Estimator',
                ar: 'حاسبة التأمين والعمولة التقديرية',
                zh: '保证金与开立费估算器',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'مبلغ اسمی ضمانت‌نامه', en: 'Face Amount', ar: 'المبلغ الاسمي', zh: '保函面额'),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                      Text(
                        '${_sampleAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                            l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sampleAmount,
                    min: 20000000,
                    max: 500000000,
                    divisions: 24,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) {
                      setState(() => _sampleAmount = val);
                    },
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'وجه التزام نقدی (۱۰٪):', en: 'Cash Margin (10%):', ar: 'التأمين النقدي (١٠٪):', zh: '现金保证金（10%）：'),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Text(
                        '${margin.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ریال',
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'کارمزد صدور سالانه (۱.۵٪):', en: 'Issuance Fee (1.5%):', ar: 'عمولة الإصدار (١.٥٪):', zh: '年化开立费（1.5%）：'),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                      Text(
                        '${fee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ریال',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context, {
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
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: const Color(0xFF0D9488), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
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
}

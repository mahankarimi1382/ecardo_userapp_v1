import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import 'loan_application_screen.dart';

/// Screen introducing the Loan & Credit service with an interactive calculator
/// and clear step-by-step guidance.
class LoanIntroScreen extends StatefulWidget {
  const LoanIntroScreen({super.key});

  @override
  State<LoanIntroScreen> createState() => _LoanIntroScreenState();
}

class _LoanIntroScreenState extends State<LoanIntroScreen> {
  final LoanController controller = Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  double _calcAmount = 50000000; // 50M Tomans / units
  int _calcTenure = 12; // 12 months
  double _calcRate = 18.0; // 18% annual

  @override
  Widget build(BuildContext context) {
    final monthlyEmi = controller.calculateMonthlyInstallment(
      principal: _calcAmount,
      annualInterestRatePct: _calcRate,
      tenureMonths: _calcTenure,
    );
    final totalRepayment = monthlyEmi * _calcTenure;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'راهنمای تسهیلات و اعتبارات',
              en: 'Loan & Credit Guide',
              ar: 'دليل التسهيلات والقروض',
              zh: '贷款与信用指南',
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
              fa: 'شروع فرآیند درخواست وام',
              en: 'Apply for Loan',
              ar: 'تقديم طلب التسهيلات',
              zh: '立即申请贷款',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () {
              controller.amountInput.value = _calcAmount.toStringAsFixed(0);
              controller.selectedTenure.value = _calcTenure;
              Get.to(() => const LoanApplicationScreen());
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF161614), Color(0xFF2E333D)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.mainSoftBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.mainSoftBlue,
                          size: 26.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'تسهیلات هوشمند و آنلاین eCardo',
                            en: 'eCardo Smart Credit Facility',
                            ar: 'تسهيلات ذكية من eCardo',
                            zh: 'eCardo 智能信贷融通',
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
                  SizedBox(height: 14.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'بدون نیاز به ضامن فیزیکی برای سطوح اعتباری بالا. امکان تودیع وثیقه نقدی، طلا و رمزارز با فرایند کاملاً دیجیتال.',
                      en: 'No guarantor required for high credit tiers. Support for cash, gold, and crypto collateral via a 100% digital journey.',
                      ar: 'بدون ضامن تقليدي للمستويات الائتمانية المتقدمة، مع إمكانية التوثيق الرقمي الكامل.',
                      zh: '高信用评级客户无需传统担保人。支持现金、黄金及数字资产抵押的全流程数字化贷款。',
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

            // Calculator section
            Text(
              l10nPick(
                context,
                fa: 'محاسبه‌گر تخمینی اقساط و سود',
                en: 'Installment & Interest Calculator',
                ar: 'حاسبة الأقساط والفائدة التقديرية',
                zh: '分期与利息测算器',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'مبلغ درخواستی',
                          en: 'Requested Amount',
                          ar: 'المبلغ المطلوب',
                          zh: '申请金额',
                        ),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                      Text(
                        '${_calcAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                            l10nPick(context, fa: 'واحد', en: 'Units', ar: 'وحدة', zh: '单位'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Slider(
                    value: _calcAmount,
                    min: 10000000,
                    max: 200000000,
                    divisions: 19,
                    activeColor: AppColors.lightPrimary,
                    onChanged: (val) {
                      setState(() => _calcAmount = val);
                    },
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'مدت بازپرداخت',
                          en: 'Tenure (Months)',
                          ar: 'مدة السداد (أشهر)',
                          zh: '分期月数',
                        ),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                      Text(
                        '$_calcTenure ' + l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [6, 12, 18, 24, 36].map((months) {
                      final selected = _calcTenure == months;
                      return ChoiceChip(
                        label: Text('$months'),
                        selected: selected,
                        onSelected: (val) {
                          if (val) setState(() => _calcTenure = months);
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'قسط ماهیانه تخمینی:',
                          en: 'Estimated Monthly EMI:',
                          ar: 'القسط الشهري التقديري:',
                          zh: '预估月供：',
                        ),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${monthlyEmi.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                            l10nPick(context, fa: 'واحد', en: 'Units', ar: 'وحدة', zh: '单位'),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'مجموع بازپرداخت:',
                          en: 'Total Repayment:',
                          ar: 'إجمالي السداد:',
                          zh: '还款总额：',
                        ),
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
                      ),
                      Text(
                        '${totalRepayment.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // How it works
            Text(
              l10nPick(
                context,
                fa: 'مراحل دریافت تسهیلات',
                en: 'How It Works',
                ar: 'خطوات الحصول على التسهيل',
                zh: '贷款办理步骤',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            _buildStepCard(
              context,
              step: '۱',
              titleFa: 'ثبت آنلاین فرم درخواست',
              titleEn: 'Submit Online Application',
              descFa: 'انتخاب طرح، مشخص‌کردن مبلغ و بارگذاری اطلاعات اولیه درآمدی.',
              descEn: 'Select product, enter amount and supply income indicators.',
            ),
            _buildStepCard(
              context,
              step: '۲',
              titleFa: 'اعتبارسنجی خودکار و صدور آفر',
              titleEn: 'Automated Scoring & Offer',
              descFa: 'سنجش شاخص ریسک و اعلام سقف مصوب و نرخ بهره نهایی در کارتابل.',
              descEn: 'Risk-engine evaluates limits and generates official loan offer.',
            ),
            _buildStepCard(
              context,
              step: '۳',
              titleFa: 'تودیع وثیقه و امضای دیجیتال',
              titleEn: 'Collateral & Digital Signature',
              descFa: 'تودیع وثیقه انتخابی و امضای الکترونیک قرارداد بدون مراجعه حضوری.',
              descEn: 'Pledge collateral and sign digital loan contract seamlessly.',
            ),
            _buildStepCard(
              context,
              step: '۴',
              titleFa: 'واریز آنی به کیف پول',
              titleEn: 'Instant Wallet Disbursement',
              descFa: 'واریز وجه تسهیلات به والت اصلی و فعال‌سازی جدول بازپرداخت اقساط.',
              descEn: 'Funds credited directly to primary wallet with automated schedule.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String step,
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
            width: 26.w,
            height: 26.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightPrimaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.deepBlack,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
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

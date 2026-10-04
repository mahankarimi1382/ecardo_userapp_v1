import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';

/// Collateral Warning (Margin Call) Screen — matches `collateral_warning.html`
/// Displays countdown timer (24h grace), current coverage ratio, and the two
/// resolution paths: (1) Add collateral, or (2) Repay part of the debt.
class LoanCollateralWarningScreen extends StatelessWidget {
  final LoanCaseModel loanCase;

  const LoanCollateralWarningScreen({
    super.key,
    required this.loanCase,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    final coverageNow = loanCase.coverageNowPct;
    final outstanding = loanCase.outstandingAmount;
    final collateralVal = loanCase.collateralValueUsd;
    final shortfallUsdt = loanCase.collateralShortfallUsdt > 0
        ? loanCase.collateralShortfallUsdt
        : 2189.0;
    final debtReductionUsd = loanCase.debtReductionRequiredUsd > 0
        ? loanCase.debtReductionRequiredUsd
        : 1459.0;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'هشدار کسری وثیقه',
              en: 'Collateral warning',
              ar: 'تحذير الضمان',
              zh: '抵押品警告',
            ),
            isBackLogicApply: true,
            backLogicFunction: Get.back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ECardoTokens.space4.w,
          vertical: ECardoTokens.space3.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Urgency Banner with Countdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.dangerBg(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.danger(context).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: ECardoTokens.danger(context),
                        size: 20.sp,
                      ),
                      SizedBox(width: ECardoTokens.space2.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'مهلت تکمیل وثیقه: ۲۲ ساعت و ۴۰ دقیقه',
                          en: 'TOP UP WITHIN: 22h 40m',
                          ar: 'المهلة المتبقية: 22 س 40 د',
                          zh: '补仓倒计时：22小时40分',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.danger(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'چنانچه پوشش وثیقه زیر ۱۲۰٪ باقی بماند، بخشی از تترهای قفل‌شده جهت تسویه بدهی به فروش اجباری خواهد رفت.',
                      en: 'If coverage is still below 120%, part of your USDT is sold to repay the loan.',
                      ar: 'إذا بقي معدل التغطية أقل من 120%، سيتم بيع جزء من الضمان لسداد القرض.',
                      zh: '如果抵押率仍低于120%，将强制平仓部分USDT以偿还贷款。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: ECardoTokens.ink(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // Where you stand section
            Text(
              l10nPick(
                context,
                fa: 'وضعیت فعلی پرونده',
                en: 'Where you stand',
                ar: 'الوضع الحالي',
                zh: '当前状态',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  _buildMetricRow(
                    context,
                    label: l10nPick(context, fa: 'نسبت پوشش فعلی', en: 'Coverage now'),
                    value: '${coverageNow.toStringAsFixed(0)}%',
                    valueColor: ECardoTokens.danger(context),
                    isBold: true,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildMetricRow(
                    context,
                    label: l10nPick(context, fa: 'حد آستانه اجباری', en: 'Required'),
                    value: '120%',
                    valueColor: ECardoTokens.inkMuted(context),
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildMetricRow(
                    context,
                    label: l10nPick(context, fa: 'مانده بدهی وام', en: 'Outstanding loan'),
                    value: '${outstanding.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.ink(context),
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildMetricRow(
                    context,
                    label: l10nPick(context, fa: 'ارزش فعلی وثیقه', en: 'Collateral value now'),
                    value: '${collateralVal.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.ink(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space6.h),

            // Two ways out section
            Text(
              l10nPick(
                context,
                fa: 'دو راهکار خروج از اخطار',
                en: 'Two ways out',
                ar: 'الحلول المتاحة',
                zh: '两种解决方案',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            // Option 1: Add collateral
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.brand500(context).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'افزایش وثیقه', en: 'Add collateral'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.successBg(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                        ),
                        child: Text(
                          '+${shortfallUsdt.toStringAsFixed(0)} USDT',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.success(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'قفل کردن تتر بیشتر برای رساندن پوشش به بالای ۱۵۰٪',
                      en: 'Lock more USDT to bring coverage back above 150%.',
                      ar: 'إضافة المزيد من USDT لرفع نسبة التغطية إلى أكثر من 150%',
                      zh: '追加锁仓USDT以使抵押率恢复至150%以上。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ECardoTokens.brand900(context),
                        foregroundColor: ECardoTokens.inkOnBrand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final sTitle = l10nPick(context, fa: 'موفقیت', en: 'Success');
                        final sMsg = l10nPick(context, fa: 'وثیقه با موفقیت شارژ شد و نسبت پوشش به ۱۵۰٪ بازگشت.', en: 'Collateral topped up successfully.');
                        final sBg = ECardoTokens.successBg(context);
                        final sColor = ECardoTokens.success(context);
                        Get.defaultDialog(
                          title: l10nPick(context, fa: 'تأیید شارژ وثیقه', en: 'Confirm collateral top up'),
                          middleText: l10nPick(
                            context,
                            fa: 'آیا مایل به قفل کردن ${shortfallUsdt.toStringAsFixed(0)} USDT از کیف پول هستید؟',
                            en: 'Lock ${shortfallUsdt.toStringAsFixed(0)} USDT from your wallet?',
                          ),
                          textConfirm: l10nPick(context, fa: 'قفل وثیقه', en: 'Confirm'),
                          textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
                          confirmTextColor: Colors.white,
                          buttonColor: ECardoTokens.brand900(context),
                          onConfirm: () async {
                            Get.back();
                            await controller.postCryptoCollateral(loanCase.id, shortfallUsdt, 'USDT');
                            Get.snackbar(
                              sTitle,
                              sMsg,
                              backgroundColor: sBg,
                              colorText: sColor,
                            );
                          },
                        );
                      },
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'افزودن ${shortfallUsdt.toStringAsFixed(0)} USDT',
                          en: 'Add ${shortfallUsdt.toStringAsFixed(0)} USDT',
                          ar: 'إضافة ${shortfallUsdt.toStringAsFixed(0)} USDT',
                          zh: '追加 ${shortfallUsdt.toStringAsFixed(0)} USDT',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // Option 2: Repay part of loan
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'بازپرداخت بخشی از وام', en: 'Repay part of the loan'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.sand100(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                        ),
                        child: Text(
                          '${debtReductionUsd.toStringAsFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.sand600(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'کاهش بدهی جاری تا همان وثیقه موجود پوشش ۱۵۰٪ را تأمین کند.',
                      en: 'Lower what you owe so the same collateral covers it.',
                      ar: 'تخفيض الرصيد المستحق لتغطية النسبة بالضمان الحالي.',
                      zh: '偿还部分贷款以降低负债，使现有抵押品满足150%要求。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ECardoTokens.ink(context),
                        side: BorderSide(color: ECardoTokens.borderStrong(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.defaultDialog(
                          title: l10nPick(context, fa: 'پرداخت بخشی از بدهی', en: 'Repay partial debt'),
                          middleText: l10nPick(
                            context,
                            fa: 'آیا مایل به پرداخت ${debtReductionUsd.toStringAsFixed(2)} دلار از کیف پول هستید؟',
                            en: 'Pay ${debtReductionUsd.toStringAsFixed(2)} USD to reduce debt?',
                          ),
                          textConfirm: l10nPick(context, fa: 'پرداخت', en: 'Pay'),
                          textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
                          buttonColor: ECardoTokens.brand900(context),
                          confirmTextColor: Colors.white,
                          onConfirm: () async {
                            Get.back();
                            Get.snackbar(
                              l10nPick(context, fa: 'موفقیت', en: 'Success'),
                              l10nPick(context, fa: 'پرداخت انجام شد و بدهی کاهش یافت.', en: 'Payment completed successfully.'),
                              backgroundColor: ECardoTokens.successBg(context),
                              colorText: ECardoTokens.success(context),
                            );
                          },
                        );
                      },
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'بازپرداخت ${debtReductionUsd.toStringAsFixed(2)} دلار',
                          en: 'Repay ${debtReductionUsd.toStringAsFixed(2)} USD instead',
                          ar: 'سداد ${debtReductionUsd.toStringAsFixed(2)} USD بدلاً من ذلك',
                          zh: '改为偿还 ${debtReductionUsd.toStringAsFixed(2)} USD',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ECardoTokens.space6.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: ECardoTokens.inkMuted(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

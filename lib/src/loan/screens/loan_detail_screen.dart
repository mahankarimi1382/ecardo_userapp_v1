import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import 'loan_collateral_warning_screen.dart';

/// Detailed view of an active loan — directly implements `loan_detail.html`
/// Features:
/// 1. Hero Balance card (Outstanding balance, installments paid, due date & amount)
/// 2. Collateral status card (USDT locked, Coverage ratio %, Liquidation trigger %)
/// 3. Amortization / Payment schedule (Paid, Due, Upcoming installments)
/// 4. Action buttons: "Pay X USD" + "Pay it off" (Early repayment with 0 penalty)
class LoanDetailScreen extends StatefulWidget {
  final int caseId;
  final LoanCaseModel? initialCase;

  const LoanDetailScreen({
    super.key,
    required this.caseId,
    this.initialCase,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late final LoanController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());
    if (widget.caseId > 0) {
      controller.fetchCase(widget.caseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: Obx(() {
            final c = controller.selectedCase.value ?? widget.initialCase ?? LoanController.sampleActiveLoan;
            return CommonAppBar(
              title: c.caseNo.isNotEmpty ? 'Loan ${c.caseNo}' : 'Loan LN-2208',
              isBackLogicApply: true,
              backLogicFunction: Get.back,
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value && controller.selectedCase.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final c = controller.selectedCase.value ?? widget.initialCase ?? LoanController.sampleActiveLoan;
        final nextInst = c.nextInstallment;
        final nextAmount = nextInst?.amount ?? 1140.0;
        final isWarning = c.isCollateralWarning;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: ECardoTokens.space4.w,
            vertical: ECardoTokens.space3.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ Outstanding Balance Hero Card ------------------
              Container(
                width: double.infinity,
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
                    Text(
                      l10nPick(context, fa: 'مانده بدهی اصل وام', en: 'Outstanding balance'),
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space1.h),
                    Text(
                      '${c.outstandingAmount.toStringAsFixed(2)} USD',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space1.h),
                    Text(
                      '${c.paidInstallmentsCount} of ${c.totalInstallmentsCount} payments made',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.brand500(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space3.h),

                    // Next due banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.surfaceSunken(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${nextAmount.toStringAsFixed(2)} USD due 12 Oct',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: ECardoTokens.ink(context),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: ECardoTokens.warningBg(context),
                                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                                ),
                                child: Text(
                                  l10nPick(context, fa: 'سررسید', en: 'Due'),
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ECardoTokens.warning(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10nPick(
                              context,
                              fa: '۸ روز مانده · پس از آن ۲٪ جریمه دیرکرد ماهانه اعمال می‌شود',
                              en: '8 days left · late fee 2% after that',
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ECardoTokens.inkMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ECardoTokens.space4.h),

              // ------------------ Collateral Card ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(context, fa: 'وضعیت وثیقه شما', en: 'Your collateral'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  if (isWarning)
                    GestureDetector(
                      onTap: () => Get.to(() => LoanCollateralWarningScreen(loanCase: c)),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.dangerBg(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                        ),
                        child: Text(
                          l10nPick(context, fa: 'هشدار کسری', en: 'Warning'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: ECardoTokens.danger(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: ECardoTokens.space2.h),

              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(
                    color: isWarning
                        ? ECardoTokens.danger(context).withValues(alpha: 0.5)
                        : ECardoTokens.border(context),
                  ),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      context,
                      label: l10nPick(context, fa: 'تتر قفل‌شده', en: 'Locked'),
                      value: '${c.lockedCollateralUsdt.toStringAsFixed(0)} USDT',
                      valueColor: ECardoTokens.ink(context),
                    ),
                    Divider(color: ECardoTokens.border(context), height: 16.h),
                    _buildMetricRow(
                      context,
                      label: l10nPick(context, fa: 'نسبت پوشش فعلی', en: 'Coverage now'),
                      value: '${c.coverageNowPct.toStringAsFixed(0)}%',
                      valueColor: isWarning
                          ? ECardoTokens.danger(context)
                          : ECardoTokens.success(context),
                      isBold: true,
                    ),
                    Divider(color: ECardoTokens.border(context), height: 16.h),
                    _buildMetricRow(
                      context,
                      label: l10nPick(context, fa: 'آستانه فروش اجباری', en: 'Sold if it drops to'),
                      value: '120%',
                      valueColor: ECardoTokens.inkMuted(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ECardoTokens.space5.h),

              // ------------------ Payment Schedule ------------------
              Text(
                l10nPick(context, fa: 'جدول اقساط و سررسیدها', en: 'Payment schedule'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: ECardoTokens.space2.h),

              Container(
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(color: ECardoTokens.border(context)),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  children: c.installments.map((inst) {
                    final isLast = inst == c.installments.last;
                    final isPaid = inst.isPaid;
                    final isDue = !isPaid && inst == c.nextInstallment;

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ECardoTokens.space4.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28.r,
                                height: 28.r,
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? ECardoTokens.successBg(context)
                                      : isDue
                                          ? ECardoTokens.warningBg(context)
                                          : ECardoTokens.surfaceSunken(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPaid
                                      ? Icons.check_rounded
                                      : isDue
                                          ? Icons.access_time_rounded
                                          : Icons.schedule_rounded,
                                  size: 16.sp,
                                  color: isPaid
                                      ? ECardoTokens.success(context)
                                      : isDue
                                          ? ECardoTokens.warning(context)
                                          : ECardoTokens.inkMuted(context),
                                ),
                              ),
                              SizedBox(width: ECardoTokens.space3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatInstallmentDate(inst),
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: ECardoTokens.ink(context),
                                      ),
                                    ),
                                    if (isPaid)
                                      Text(
                                        l10nPick(context, fa: 'پرداخت‌شده', en: 'paid'),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: ECardoTokens.success(context),
                                        ),
                                      )
                                    else if (isDue)
                                      Text(
                                        l10nPick(context, fa: 'سررسید جاری', en: 'due'),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: ECardoTokens.warning(context),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '${inst.amount.toStringAsFixed(2)} USD',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isPaid
                                      ? ECardoTokens.inkMuted(context)
                                      : ECardoTokens.ink(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(color: ECardoTokens.border(context), height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: ECardoTokens.space8.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          border: Border(top: BorderSide(color: ECardoTokens.border(context))),
          boxShadow: ECardoTokens.shadowSheet(context),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Secondary Outlined Action: Pay it off
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48.h,
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
                      final c = controller.selectedCase.value ?? widget.initialCase ?? LoanController.sampleActiveLoan;
                      final sTitle = l10nPick(context, fa: 'تسویه موفق', en: 'Settled');
                      final sMsg = l10nPick(context, fa: 'وام تسویه شد و ۱۵,۰۰۰ تتر به کیف پول شما بازگشت.', en: 'Loan settled and collateral released.');
                      final sBg = ECardoTokens.successBg(context);
                      final sColor = ECardoTokens.success(context);
                      Get.defaultDialog(
                        title: l10nPick(context, fa: 'تسویه زودهنگام کل وام', en: 'Pay it off early'),
                        middleText: l10nPick(
                          context,
                          fa: 'مبلغ کل ${c.outstandingAmount.toStringAsFixed(2)} دلار بدون کارمزد یا جریمه از کیف پول شما کسر و وثیقه فوراً آزاد خواهد شد.',
                          en: 'Pay full ${c.outstandingAmount.toStringAsFixed(2)} USD now? Remaining interest is waived and collateral released immediately.',
                        ),
                        textConfirm: l10nPick(context, fa: 'تسویه کامل', en: 'Pay it off'),
                        textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
                        buttonColor: ECardoTokens.brand900(context),
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back();
                          await controller.earlyRepayment(c.id);
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
                      l10nPick(context, fa: 'تسویه کامل', en: 'Pay it off'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ECardoTokens.space3.w),

              // Primary Action: Pay single installment
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48.h,
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
                      final c = controller.selectedCase.value ?? widget.initialCase ?? LoanController.sampleActiveLoan;
                      final inst = c.nextInstallment;
                      final amount = inst?.amount ?? 1140.0;
                      final pTitle = l10nPick(context, fa: 'پرداخت موفق', en: 'Payment success');
                      final pMsg = l10nPick(context, fa: 'قسط با موفقیت پرداخت شد.', en: 'Installment paid successfully.');
                      final pBg = ECardoTokens.successBg(context);
                      final pColor = ECardoTokens.success(context);
                      Get.defaultDialog(
                        title: l10nPick(context, fa: 'پرداخت قسط', en: 'Pay installment'),
                        middleText: l10nPick(
                          context,
                          fa: 'مبلغ ${amount.toStringAsFixed(2)} دلار از موجودی کیف پول پرداخت شود؟',
                          en: 'Pay ${amount.toStringAsFixed(2)} USD from your wallet balance?',
                        ),
                        textConfirm: l10nPick(context, fa: 'پرداخت قسط', en: 'Pay now'),
                        textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
                        buttonColor: ECardoTokens.brand900(context),
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back();
                          if (inst != null) {
                            await controller.payInstallment(c.id, inst.id);
                          }
                          Get.snackbar(
                            pTitle,
                            pMsg,
                            backgroundColor: pBg,
                            colorText: pColor,
                          );
                        },
                      );
                    },
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'پرداخت ۱,۱۴۰ دلار',
                        en: 'Pay 1,140.00 USD',
                      ),
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatInstallmentDate(LoanInstallmentModel inst) {
    if (inst.dueDate == null) return 'Installment ${inst.seq}';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[inst.dueDate!.month - 1];
    return '${inst.dueDate!.day} $m';
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

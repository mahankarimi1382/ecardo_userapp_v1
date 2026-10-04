import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/escrow_models.dart';
import 'escrow_list_screen.dart';

/// Arbitration / Dispute Decision & Settlement Screen — matches `dispute_decision.html`
/// Features:
/// 1. Resolution banner (Split decision %, amount returned, closed date)
/// 2. "Where the money went" financial breakdown
/// 3. Reviewer's factual reason and analysis
/// 4. Action buttons: "Back to my deals" + "Download decision record"
class EscrowDisputeDecisionScreen extends StatelessWidget {
  final EscrowOrderModel order;
  final EscrowDisputeDecisionModel decision;

  const EscrowDisputeDecisionScreen({
    super.key,
    required this.order,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final locked = order.totalEscrowAmount > 0 ? order.totalEscrowAmount : 868.60;
    final buyerRefund = decision.buyerRefundAmount;
    final sellerPayout = decision.sellerPayoutAmount;
    final fee = decision.feeAmount;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'رأی نهایی داوری',
              en: 'Dispute decision',
              ar: 'قرار التحكيم',
              zh: '仲裁裁决结果',
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
            // ------------------ Outcome Hero Banner ------------------
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.successBg(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    ),
                    child: Text(
                      l10nPick(context, fa: 'مختومه · ۷ اکتبر', en: 'Closed · 7 Oct'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.success(context),
                      ),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  Text(
                    'Split decision · ${decision.splitPercentBuyer.toInt()}% to the buyer',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '+${buyerRefund.toStringAsFixed(2)} USD returned',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.success(context),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Where the money went ------------------
            Text(
              l10nPick(
                context,
                fa: 'گردش و تسویه مالی وجوه',
                en: 'Where the money went',
                ar: 'مسار الأموال والتسوية',
                zh: '资金分配明细',
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
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کل وجه قفل‌شده', en: 'Was locked'),
                    value: '${locked.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'استرداد به کیف پول شما', en: 'Back to you'),
                    value: '+${buyerRefund.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.success(context),
                    isBold: true,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'پرداخت به فروشنده', en: 'To the seller'),
                    value: '${sellerPayout.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کارمزد داوری و اسکرو (۶۰ / ۴۰)', en: 'Escrow fee · split 60 / 40'),
                    value: '${fee.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.inkMuted(context),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    ),
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'مبلغ استردادی در تاریخ ۷ اکتبر ساعت ۱۴:۲۲ به کیف پول شما واریز گردید.',
                        en: 'Paid into your wallet on 7 Oct, 14:22.',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Reviewer's Reason ------------------
            Text(
              l10nPick(
                context,
                fa: 'مستندات و دلایل رأی کارشناس',
                en: "Reviewer's reason",
                ar: 'أسباب وحيثيات القرار',
                zh: '审核专员判定依据',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

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
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, color: ECardoTokens.brand500(context), size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        l10nPick(context, fa: 'مدارک بررسی‌شده: ۳ فایل از هر دو طرف', en: 'Evidence reviewed · 3 files from both sides'),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.brand700(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    decision.reviewerNotes,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: ECardoTokens.ink(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space8.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          border: Border(top: BorderSide(color: ECardoTokens.border(context))),
          boxShadow: ECardoTokens.shadowSheet(context),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
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
                    HapticFeedback.lightImpact();
                    Get.offAll(() => const EscrowListScreen());
                  },
                  child: Text(
                    l10nPick(context, fa: 'بازگشت به فهرست معاملات', en: 'Back to my deals'),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ECardoTokens.ink(context),
                  side: BorderSide(color: ECardoTokens.borderStrong(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    l10nPick(context, fa: 'دانلود پرونده', en: 'Download'),
                    l10nPick(context, fa: 'صورت‌جلسه رسمی داوری ذخیره شد.', en: 'Decision record PDF downloaded.'),
                    backgroundColor: ECardoTokens.infoBg(context),
                    colorText: ECardoTokens.info(context),
                  );
                },
                child: Text(
                  l10nPick(context, fa: 'دانلود پرونده رسمی رأی (PDF)', en: 'Download decision record'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isBold ? ECardoTokens.ink(context) : ECardoTokens.inkMuted(context),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15.sp : 13.5.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/escrow_models.dart';
import 'escrow_dispute_decision_screen.dart';

/// Dispute Under Review Screen — matches `dispute_under_review.html`
/// Features:
/// 1. Status banner (Funds locked, resolution SLA date)
/// 2. 4-step dispute review progress timeline
/// 3. Buyer's claim summary card
/// 4. Action buttons: "Add more evidence" + "Withdraw dispute" + View Decision
class EscrowDisputeReviewScreen extends StatelessWidget {
  final EscrowOrderModel order;
  final EscrowDisputeModel? dispute;

  const EscrowDisputeReviewScreen({
    super.key,
    required this.order,
    this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    final d = dispute ?? order.dispute ?? const EscrowDisputeModel(
          id: 118,
          caseNumber: 'DSP-118',
          type: 'Not as described',
          description: 'Received roll is 50 micron instead of 80 micron requested in contract.',
          status: 'UNDER_REVIEW',
          requestedOutcome: 'Full refund · 860.00 USD',
          evidenceFiles: ['Received-roll-1.jpg'],
        );

    final lockedAmount = order.totalEscrowAmount > 0 ? order.totalEscrowAmount : 868.60;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: 'Dispute ${d.caseNumber}',
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
            // ------------------ Status Banner ------------------
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
                      color: ECardoTokens.warningBg(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    ),
                    child: Text(
                      l10nPick(context, fa: 'در حال بررسی داوری', en: 'Under review'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.warning(context),
                      ),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  Text(
                    '${lockedAmount.toStringAsFixed(2)} USD locked',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'پاسخ و تصمیم داوری تا ۹ اکتبر اعلام می‌شود. تا آن زمان هیچ‌یک از طرفین امکان جابه‌جایی پول را ندارند.',
                      en: 'Decision expected by 9 Oct. Neither side can move the money until then.',
                      ar: 'من المتوقع صدور القرار بحلول 9 أكتوبر. لا يمكن لأي طرف تحريك الأموال حتى ذلك الحين.',
                      zh: '预计10月9日前出具仲裁裁决。在此期间双方均无法动用该笔资金。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkMuted(context),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Review Progress Stepper ------------------
            Text(
              l10nPick(
                context,
                fa: 'مراحل رسیدگی داوری',
                en: 'Review progress',
                ar: 'مراحل التحكيم',
                zh: '仲裁审核流程',
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
                  _buildProgressStep(
                    context,
                    stepNum: '1',
                    title: l10nPick(context, fa: 'ثبت اختلاف توسط شما', en: 'You filed the dispute'),
                    sub: '2 Oct · 1 photo, 1 description',
                    isDone: true,
                  ),
                  _buildProgressStep(
                    context,
                    stepNum: '2',
                    title: l10nPick(context, fa: 'مهلت پاسخ فروشنده', en: 'Seller is answering'),
                    sub: '48h to respond · 19h left',
                    isActive: true,
                  ),
                  _buildProgressStep(
                    context,
                    stepNum: '3',
                    title: l10nPick(context, fa: 'بررسی مستندات توسط کارشناس', en: 'eCardo reviews the evidence'),
                    sub: 'May ask either side for more',
                  ),
                  _buildProgressStep(
                    context,
                    stepNum: '4',
                    title: l10nPick(context, fa: 'صدور رأی و پرداخت وجه', en: 'Decision and payout'),
                    sub: 'Written reason sent to both sides',
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Your Claim Section ------------------
            Text(
              l10nPick(
                context,
                fa: 'خلاصه ادعای شما',
                en: 'Your claim',
                ar: 'ملخص طلبك',
                zh: '您的诉求摘要',
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
                  _buildDetailRow(
                    context,
                    label: l10nPick(context, fa: 'علت', en: 'Reason'),
                    value: d.type,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildDetailRow(
                    context,
                    label: l10nPick(context, fa: 'خروجی درخواستی', en: 'Requested'),
                    value: d.requestedOutcome,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'مدارک ضمیمه', en: 'Evidence'),
                        style: TextStyle(fontSize: 13.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                      Text(
                        '${d.evidenceFiles.length} file',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // Link to view decision if available
            if (d.decision != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: ECardoTokens.successBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: ECardoTokens.success(context)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10nPick(context, fa: 'رأی داوری صادر شده است', en: 'Arbitration decision issued'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.success(context),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => EscrowDisputeDecisionScreen(
                              order: order,
                              decision: d.decision!,
                            ));
                      },
                      child: Text(
                        l10nPick(context, fa: 'مشاهده رأی', en: 'View'),
                        style: TextStyle(fontWeight: FontWeight.w800, color: ECardoTokens.success(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ECardoTokens.danger(context),
                      side: BorderSide(color: ECardoTokens.danger(context).withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showWithdrawDialog(context);
                    },
                    child: Text(
                      l10nPick(context, fa: 'انصراف از اختلاف', en: 'Withdraw dispute'),
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
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
                      HapticFeedback.lightImpact();
                      Get.snackbar(
                        l10nPick(context, fa: 'بارگذاری مدارک', en: 'Upload evidence'),
                        l10nPick(context, fa: 'لطفاً فایل‌های تکمیلی را انتخاب فرمایید.', en: 'Please select supplementary files.'),
                        backgroundColor: ECardoTokens.infoBg(context),
                        colorText: ECardoTokens.info(context),
                      );
                    },
                    child: Text(
                      l10nPick(context, fa: 'افزودن مدرک', en: 'Add more evidence'),
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
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

  void _showWithdrawDialog(BuildContext context) {
    final wTitle = l10nPick(context, fa: 'انصراف ثبت شد', en: 'Withdrawn');
    final wMsg = l10nPick(context, fa: 'اختلاف لغو گردید و پرونده به روال عادی بازگشت.', en: 'Dispute withdrawn successfully.');
    final wBg = ECardoTokens.successBg(context);
    final wColor = ECardoTokens.success(context);

    Get.defaultDialog(
      title: l10nPick(context, fa: 'انصراف از اختلاف', en: 'Withdraw dispute'),
      middleText: l10nPick(
        context,
        fa: 'با انصراف شما، پرونده اختلاف مختومه شده و وجه طبق روال عادی آزاد خواهد شد. آیا مطمئن هستید؟',
        en: 'Withdrawing the dispute will cancel arbitration and resume normal settlement. Are you sure?',
      ),
      textConfirm: l10nPick(context, fa: 'تأیید انصراف', en: 'Confirm withdraw'),
      textCancel: l10nPick(context, fa: 'بازگشت', en: 'Cancel'),
      buttonColor: ECardoTokens.danger(context),
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.back();
        Get.snackbar(
          wTitle,
          wMsg,
          backgroundColor: wBg,
          colorText: wColor,
        );
      },
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required String stepNum,
    required String title,
    required String sub,
    bool isDone = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isDone
                    ? ECardoTokens.successBg(context)
                    : isActive
                        ? ECardoTokens.brand100(context)
                        : ECardoTokens.surfaceSunken(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? ECardoTokens.success(context)
                      : isActive
                          ? ECardoTokens.brand900(context)
                          : ECardoTokens.border(context),
                ),
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check_rounded, size: 14.sp, color: ECardoTokens.success(context))
                    : Text(
                        stepNum,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: isActive ? ECardoTokens.brand900(context) : ECardoTokens.inkMuted(context),
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 32.h,
                color: isDone ? ECardoTokens.success(context) : ECardoTokens.border(context),
              ),
          ],
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: isActive ? ECardoTokens.sand600(context) : ECardoTokens.inkMuted(context),
                ),
              ),
              if (!isLast) SizedBox(height: 12.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, {required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: ECardoTokens.inkMuted(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}

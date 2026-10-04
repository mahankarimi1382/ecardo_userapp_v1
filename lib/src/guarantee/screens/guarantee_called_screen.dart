import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/guarantee_models.dart';

/// Guarantee Called (Claim / Demand Response) Screen — matches `guarantee_called.html`
/// Features:
/// 1. 5-day objection countdown badge ("TIME TO OBJECT: 4d 11h")
/// 2. Detailed claim card (Beneficiary, reason, date, attached letter)
/// 3. Financial breakdown:
///    - Claim amount ($10,000)
///    - Covered by margin ($2,000)
///    - You must pay ($8,000)
/// 4. Action buttons: "Object with evidence" + "Accept and pay now"
class GuaranteeCalledScreen extends StatelessWidget {
  final GuaranteeCaseModel guaranteeCase;

  const GuaranteeCalledScreen({
    super.key,
    required this.guaranteeCase,
  });

  @override
  Widget build(BuildContext context) {
    final claimAmount = guaranteeCase.claimAmount ?? guaranteeCase.amount;
    final marginCovered = guaranteeCase.marginAmount;
    final remainingPayable = claimAmount > marginCovered ? claimAmount - marginCovered : 0.0;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'مطالبه ضمانت‌نامه',
              en: 'Guarantee called',
              ar: 'مطالبة الضمان',
              zh: '保函索赔',
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
            // ------------------ Urgency Countdown Banner ------------------
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
                          fa: 'مهلت اعتراض: ۴ روز و ۱۱ ساعت',
                          en: 'TIME TO OBJECT: 4d 11h',
                          ar: 'مهلة الاعتراض: 4 أيام 11 س',
                          zh: '异议倒计时：4天11小时',
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
                  SizedBox(height: 6.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'ذینفع رسماً درخواست مطالبه وجه ضمانت‌نامه را ثبت نموده است. عدم پاسخ در این مهلت به منزله پذیرش و پرداخت مبلغ به ذینفع تلقی خواهد شد.',
                      en: 'The beneficiary has formally called this guarantee. Silence within this period implies acceptance and payment to the beneficiary.',
                      ar: 'طلب المستفيد رسمياً مصادرة الضمان. عدم الرد يعتبر قبولاً بالمطالبة.',
                      zh: '受益人已正式发起索赔。若在此期限内未提出有效异议，将视为同意并直接划付资金。',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: ECardoTokens.ink(context),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ The Claim Section ------------------
            Text(
              l10nPick(
                context,
                fa: 'مشخصات ادعای ذینفع',
                en: 'The claim',
                ar: 'تفاصيل المطالبة',
                zh: '索赔详情',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guaranteeCase.instrument?.name ?? 'Advance payment bond',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  _buildDetailRow(
                    context,
                    label: l10nPick(context, fa: 'مطالبه‌کننده (ذینفع)', en: 'Called by'),
                    value: guaranteeCase.beneficiaryName,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildDetailRow(
                    context,
                    label: l10nPick(context, fa: 'علت مطالبه', en: 'Reason given'),
                    value: guaranteeCase.claimReason ?? 'Goods not delivered',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildDetailRow(
                    context,
                    label: l10nPick(context, fa: 'تاریخ ثبت مطالبه', en: 'Called on'),
                    value: '4 Oct 2026',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_rounded,
                        color: ECardoTokens.brand500(context),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        guaranteeCase.claimDocumentUrl ?? 'Demand-letter.pdf',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ What it costs you ------------------
            Text(
              l10nPick(
                context,
                fa: 'تعهدات مالی و مابه‌التفاوت',
                en: 'What it costs you',
                ar: 'الالتزامات المالية',
                zh: '您的应付金额',
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
                    label: l10nPick(context, fa: 'مبلغ کل مطالبه', en: 'Claim amount'),
                    value: '${claimAmount.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.ink(context),
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'پوشش از محل مارجین بلوکه‌شده', en: 'Covered by your margin'),
                    value: '${marginCovered.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.brand700(context),
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'مبلغی که باید پرداخت کنید', en: 'You must pay'),
                    value: '${remainingPayable.toStringAsFixed(2)} USD',
                    valueColor: ECardoTokens.danger(context),
                    isBold: true,
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
          child: Row(
            children: [
              // Outlined Action: Object with evidence
              Expanded(
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
                      _showObjectDialog(context);
                    },
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'اعتراض با ارائه مدرک',
                        en: 'Object with evidence',
                        ar: 'اعتراض مع مستندات',
                        zh: '提交异议凭据',
                      ),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ECardoTokens.space3.w),

              // Primary Action: Accept and pay now
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
                      HapticFeedback.mediumImpact();
                      _showAcceptPaymentDialog(context, remainingPayable);
                    },
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'پذیرش و پرداخت فوری',
                        en: 'Accept and pay now',
                        ar: 'قبول وسداد فوري',
                        zh: '同意并立即划付',
                      ),
                      style: TextStyle(
                        fontSize: 13.5.sp,
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

  void _showObjectDialog(BuildContext context) {
    final noteController = TextEditingController();
    final oTitle = l10nPick(context, fa: 'ثبت شد', en: 'Submitted');
    final oMsg = l10nPick(context, fa: 'اعتراض شما ثبت شد و کارشناس ظرف ۳ روز کاری بررسی خواهد کرد.', en: 'Objection submitted for 3-day review.');
    final oBg = ECardoTokens.successBg(context);
    final oColor = ECardoTokens.success(context);

    Get.defaultDialog(
      title: l10nPick(context, fa: 'اعتراض به مطالبه', en: 'Object to claim'),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            Text(
              l10nPick(
                context,
                fa: 'شرح دلایل و عدم نقض قرارداد را بنویسید. بارگذاری مدرک الزامی است.',
                en: 'State your reasons and attach proof of fulfillment.',
              ),
              style: TextStyle(fontSize: 12.sp, color: ECardoTokens.inkMuted(context)),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10nPick(context, fa: 'توضیحات و مستندات...', en: 'Notes and evidence...'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
      ),
      textConfirm: l10nPick(context, fa: 'ارسال اعتراض', en: 'Submit'),
      textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
      buttonColor: ECardoTokens.brand900(context),
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          oTitle,
          oMsg,
          backgroundColor: oBg,
          colorText: oColor,
        );
      },
    );
  }

  void _showAcceptPaymentDialog(BuildContext context, double remainingPayable) {
    final aTitle = l10nPick(context, fa: 'تکمیل شد', en: 'Completed');
    final aMsg = l10nPick(context, fa: 'وجه مطالبه‌شده پرداخت گردید.', en: 'Payment sent to beneficiary.');
    final aBg = ECardoTokens.successBg(context);
    final aColor = ECardoTokens.success(context);

    Get.defaultDialog(
      title: l10nPick(context, fa: 'تأیید پرداخت به ذینفع', en: 'Confirm payment to beneficiary'),
      middleText: l10nPick(
        context,
        fa: 'آیا مایل به پرداخت مبلغ ${remainingPayable.toStringAsFixed(2)} دلار از کیف پول به همراه مارجین هستید؟',
        en: 'Pay ${remainingPayable.toStringAsFixed(2)} USD from your wallet to beneficiary?',
      ),
      textConfirm: l10nPick(context, fa: 'پرداخت', en: 'Pay'),
      textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
      buttonColor: ECardoTokens.brand900(context),
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          aTitle,
          aMsg,
          backgroundColor: aBg,
          colorText: aColor,
        );
      },
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

  Widget _buildCostRow(
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
            color: isBold ? ECardoTokens.ink(context) : ECardoTokens.inkMuted(context),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

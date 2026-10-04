import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/escrow_models.dart';

/// Seller Response to Dispute Screen — matches `respond_to_dispute.html`
/// Features:
/// 1. 48h response countdown banner ("TIME TO RESPOND: 19h 04m")
/// 2. Buyer's claim card (reason, evidence, refund amount requested)
/// 3. Position selector: Disagree / Accept Full Refund / Offer Partial Refund
/// 4. Explanatory text & Mandatory seller evidence upload
/// 5. "Send my response" CTA
class EscrowDisputeRespondScreen extends StatefulWidget {
  final EscrowOrderModel order;
  final EscrowDisputeModel? dispute;

  const EscrowDisputeRespondScreen({
    super.key,
    required this.order,
    this.dispute,
  });

  @override
  State<EscrowDisputeRespondScreen> createState() => _EscrowDisputeRespondScreenState();
}

class _EscrowDisputeRespondScreenState extends State<EscrowDisputeRespondScreen> {
  final _answerController = TextEditingController();
  int _selectedPositionIndex = 0;
  String? _uploadedEvidence = 'Mill-certificate.pdf';

  final List<Map<String, String>> _positions = [
    {
      'fa': 'مخالفم — کالا کاملاً مطابق قرارداد و فاکتور تحویل شده است',
      'en': 'I disagree — goods match the order',
    },
    {
      'fa': 'می‌پذیرم — استرداد کامل وجه به خریدار انجام شود',
      'en': 'I accept — refund the buyer in full',
    },
    {
      'fa': 'پیشنهاد تخفیف و استرداد جزئی وجه را دارم',
      'en': 'I offer a partial refund',
    },
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitResponse() {
    HapticFeedback.mediumImpact();
    final rTitle = l10nPick(context, fa: 'پاسخ ارسال شد', en: 'Response sent');
    final rMsg = l10nPick(context, fa: 'دفاعیه و مدارک شما جهت داوری ثبت گردید.', en: 'Your response and evidence recorded for review.');
    final rBg = ECardoTokens.successBg(context);
    final rColor = ECardoTokens.success(context);

    Get.back();
    Get.snackbar(
      rTitle,
      rMsg,
      backgroundColor: rBg,
      colorText: rColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute ?? widget.order.dispute;
    final buyerClaimReason = d?.type ?? 'Not as described';
    final buyerRequestedRefund = d?.requestedOutcome ?? 'Full refund · 860.00 USD';

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'پاسخ فروشنده به اختلاف',
              en: 'Respond to dispute',
              ar: 'الرد على النزاع',
              zh: '回应争议申诉',
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
            // ------------------ Countdown Banner ------------------
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
                      Icon(Icons.timer_outlined, color: ECardoTokens.danger(context), size: 20.sp),
                      SizedBox(width: ECardoTokens.space2.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'مهلت پاسخگویی: ۱۹ ساعت و ۰۴ دقیقه',
                          en: 'TIME TO RESPOND: 19h 04m',
                          ar: 'الوقت المتبقي للرد: 19 س 04 د',
                          zh: '答复倒计时：19小时04分',
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
                      fa: 'چنانچه در مهلت مقرر پاسخی ارسال نکنید، داور تنها بر مبنای مستندات خریدار تصمیم‌گیری خواهد کرد.',
                      en: 'If you do not answer, the reviewer decides on the buyer\'s evidence alone.',
                      ar: 'إذا لم تقم بالرد، سيتخذ المحكم قراره بناءً على أدلة المشتري وحدها.',
                      zh: '若未在此期限内作出答复，审核专员将仅依据买方提交的证据作出判定。',
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

            // ------------------ The Buyer's Claim Section ------------------
            Text(
              l10nPick(
                context,
                fa: 'ادعای خریدار',
                en: "The buyer's claim",
                ar: 'ادعاء المشتري',
                zh: '买方的诉求及证据',
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
                    buyerClaimReason,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.photo_outlined, size: 16.sp, color: ECardoTokens.brand500(context)),
                      SizedBox(width: 6.w),
                      Text(
                        'Received-roll-1.jpg',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: ECardoTokens.border(context), height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'درخواست خریدار', en: 'Buyer asks for'),
                        style: TextStyle(fontSize: 12.5.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                      Text(
                        buyerRequestedRefund,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.danger(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Your Position Section ------------------
            Text(
              l10nPick(
                context,
                fa: 'موضع و پاسخ شما',
                en: 'Your position',
                ar: 'موقفك وردك',
                zh: '您的立场与答复',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            ...List.generate(_positions.length, (index) {
              final isSelected = _selectedPositionIndex == index;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedPositionIndex = index);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? ECardoTokens.surfaceSunken(context) : ECardoTokens.surfaceCard(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(
                        color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          size: 18.sp,
                          color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.inkMuted(context),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            l10nPick(context, fa: _positions[index]['fa']!, en: _positions[index]['en']!),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Answer Notes ------------------
            Text(
              l10nPick(context, fa: 'شرح توضیحات و دفاعیه', en: 'Your answer'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                border: Border.all(color: ECardoTokens.borderStrong(context)),
              ),
              child: TextField(
                controller: _answerController,
                maxLines: 3,
                style: TextStyle(fontSize: 13.sp, color: ECardoTokens.ink(context)),
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    fa: 'دلایل صحت کالا یا شرایط پذیرش را شرح دهید...',
                    en: 'Goods were tested and certified according to standard specifications.',
                  ),
                  hintStyle: TextStyle(fontSize: 12.sp, color: ECardoTokens.inkMuted(context).withValues(alpha: 0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Evidence Upload ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(context, fa: 'مستندات دفاعیه فروشنده', en: 'Your evidence'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.dangerBg(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Text(
                    l10nPick(context, fa: 'حداقل ۱ فایل الزامی', en: 'at least one file required'),
                    style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: ECardoTokens.danger(context)),
                  ),
                ),
              ],
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                border: Border.all(color: ECardoTokens.border(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded, color: ECardoTokens.brand500(context), size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _uploadedEvidence ?? 'Mill-certificate.pdf',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ECardoTokens.ink(context)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _uploadedEvidence = 'Evidence-doc-${DateTime.now().millisecond}.pdf');
                    },
                    child: Text(l10nPick(context, fa: 'تغییر', en: 'Change'), style: TextStyle(color: ECardoTokens.brand500(context))),
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
              onPressed: _submitResponse,
              child: Text(
                l10nPick(
                  context,
                  fa: 'ارسال پاسخ و دفاعیه',
                  en: 'Send my response',
                  ar: 'إرسال الرد',
                  zh: '提交答辩意见',
                ),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

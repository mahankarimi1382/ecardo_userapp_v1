import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controller/p2p_order_details_controller.dart';
import '../model/order_details_response_model.dart' as order_details;

/// P2P Appeal & Dispute Screen — matches `appeal_order.html`
/// Features:
/// 1. Reassurance banner (USDT stays locked, payment timer paused, reviewer decides within 24h)
/// 2. Reason Category selector (4 closed categories from spec)
/// 3. Required payment receipt attachment
/// 4. Bank Reference Number field (for statement matching)
/// 5. Additional explanation notes
/// 6. Submit Appeal CTA
class P2pAppealOrderScreen extends StatefulWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const P2pAppealOrderScreen({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  State<P2pAppealOrderScreen> createState() => _P2pAppealOrderScreenState();
}

class _P2pAppealOrderScreenState extends State<P2pAppealOrderScreen> {
  final _refNumberController = TextEditingController();
  final _notesController = TextEditingController();

  int _selectedReasonIndex = 0;
  String? _uploadedReceiptName = 'Receipt-20300000.jpg';

  final List<Map<String, String>> _reasons = [
    {
      'fa': 'واریز انجام شد ولی فروشنده تتر را آزاد نکرده است',
      'en': 'I paid but the seller has not released',
    },
    {
      'fa': 'اطلاعات کارت بانکی اشتباه یا غیرقابل دسترس بود',
      'en': 'The card details are wrong or unreachable',
    },
    {
      'fa': 'تراکنش بانکی من ناموفق بود یا برگشت خورد',
      'en': 'My transfer failed or was reversed',
    },
    {
      'fa': 'فروشنده درخواست واریز به حساب دیگری داشت',
      'en': 'The seller asked me to pay elsewhere',
    },
  ];

  @override
  void dispose() {
    _refNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitAppeal() async {
    HapticFeedback.mediumImpact();
    if (_uploadedReceiptName == null) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'بارگذاری تصویر فیش واریزی الزامی است.', en: 'Payment receipt is required.'),
        backgroundColor: ECardoTokens.dangerBg(context),
        colorText: ECardoTokens.danger(context),
      );
      return;
    }

    final reasonText = _reasons[_selectedReasonIndex]['en']!;
    final bankRef = _refNumberController.text.trim();
    final notes = _notesController.text.trim();
    final combinedReason = '$reasonText | Ref: $bankRef | Note: $notes';

    final sTitle = l10nPick(context, fa: 'اعتراض ثبت شد', en: 'Appeal submitted');
    final sMsg = l10nPick(context, fa: 'پرونده با شماره پیگیری جهت بررسی ۲۴ ساعته ارسال گردید.', en: 'Dispute submitted for 24h review.');
    final sBg = ECardoTokens.successBg(context);
    final sColor = ECardoTokens.success(context);

    Get.back();
    await widget.controller.disputeOrder(reason: combinedReason);
    Get.snackbar(
      sTitle,
      sMsg,
      backgroundColor: sBg,
      colorText: sColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lockedAmount = widget.data.assetAmount ?? widget.data.sellerLockedAsset ?? '200.00';
    final cryptoSymbol = widget.data.adsAssetCurrency ?? 'USDT';

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'ثبت اعتراض به سفارش',
              en: 'Appeal this order',
              ar: 'الاعتراض على الطلب',
              zh: '订单申诉',
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
            // ------------------ Reassurance Top Banner ------------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.infoBg(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.info(context).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: ECardoTokens.info(context),
                        size: 18.sp,
                      ),
                      SizedBox(width: ECardoTokens.space2.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'مبلغ $lockedAmount $cryptoSymbol قفل باقی می‌ماند',
                          en: 'The $lockedAmount $cryptoSymbol stays locked',
                          ar: 'يبقى مبلغ $lockedAmount $cryptoSymbol مجمداً',
                          zh: '该笔 $lockedAmount $cryptoSymbol 资金将保持冻结',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.info(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'تایمر پرداخت متوقف شده و کارشناس داوری ایکاردو ظرف حداکثر ۲۴ ساعت پرونده را بررسی و اعلام نتیجه می‌نماید.',
                      en: 'The payment timer stops. A reviewer decides within 24 hours.',
                      ar: 'يتوقف مؤقت الدفع. وسيصدر فريق التحكيم قراره خلال 24 ساعة.',
                      zh: '支付计时已暂停。审核专员将在24小时内依据凭据做出裁决。',
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

            // ------------------ Reason Selection ------------------
            Text(
              l10nPick(
                context,
                fa: 'علت اعتراض چیست؟',
                en: 'What happened',
                ar: 'ماذا حدث؟',
                zh: '发生了什么情况',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            ...List.generate(_reasons.length, (index) {
              final isSelected = _selectedReasonIndex == index;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedReasonIndex = index);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ECardoTokens.surfaceSunken(context)
                          : ECardoTokens.surfaceCard(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(
                        color: isSelected
                            ? ECardoTokens.brand900(context)
                            : ECardoTokens.border(context),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 18.sp,
                          color: isSelected
                              ? ECardoTokens.brand900(context)
                              : ECardoTokens.inkMuted(context),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            l10nPick(
                              context,
                              fa: _reasons[index]['fa']!,
                              en: _reasons[index]['en']!,
                            ),
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

            // ------------------ Evidence Upload ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(
                    context,
                    fa: 'تصویر فیش واریز بانکی',
                    en: 'Payment receipt',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.dangerBg(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Text(
                    l10nPick(context, fa: 'الزامی', en: 'required'),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.danger(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                border: Border.all(color: ECardoTokens.border(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: ECardoTokens.brand500(context),
                    size: 22.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _uploadedReceiptName ?? l10nPick(context, fa: 'انتخاب تصویر فیش...', en: 'Select receipt...'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _uploadedReceiptName = 'Receipt-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.jpg';
                      });
                    },
                    child: Text(
                      l10nPick(context, fa: 'تغییر فایل', en: 'Change'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.brand500(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Bank Reference Number ------------------
            Text(
              l10nPick(
                context,
                fa: 'شماره پیگیری تراکنش بانکی (کد رهگیری)',
                en: 'Bank reference number',
                ar: 'رقم المرجع المصرفي',
                zh: '银行流水号/参考号',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10nPick(
                context,
                fa: 'داور این شماره را مستقیماً با صورت‌حساب بانکی فروشنده تطبیق می‌دهد.',
                en: 'The reviewer checks this against the seller\'s statement.',
                ar: 'سيقوم المحكم بمطابقة هذا الرقم مع كشف حساب البائع.',
                zh: '审核专员将据此与卖方的银行流水明细进行严格核对。',
              ),
              style: TextStyle(
                fontSize: 11.5.sp,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                border: Border.all(color: ECardoTokens.borderStrong(context)),
              ),
              child: TextField(
                controller: _refNumberController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
                decoration: InputDecoration(
                  hintText: l10nPick(context, fa: 'مثال: ۹۹۲۸۱۴۰۲۸۴۱', en: 'e.g. 99281402841'),
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: ECardoTokens.inkMuted(context).withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Additional Notes ------------------
            Text(
              l10nPick(
                context,
                fa: 'توضیحات تکمیلی (اختیاری)',
                en: 'Anything else',
                ar: 'ملاحظات إضافية',
                zh: '其他补充说明',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
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
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: ECardoTokens.ink(context),
                ),
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    fa: 'شرح جزئیات تراکنش یا گفت‌وگو با فروشنده...',
                    en: 'Paid at 14:12 from my Melli card. Seller stopped answering in chat.',
                  ),
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: ECardoTokens.inkMuted(context).withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
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
                backgroundColor: ECardoTokens.danger(context),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                ),
              ),
              onPressed: _submitAppeal,
              child: Text(
                l10nPick(
                  context,
                  fa: 'ثبت و ارسال اعتراض',
                  en: 'Submit appeal',
                  ar: 'إرسال الاعتراض',
                  zh: '提交申诉',
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

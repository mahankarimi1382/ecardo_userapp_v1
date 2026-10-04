import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import 'escrow_dispute_review_screen.dart';

/// Open a Dispute Screen — matches `open_a_dispute.html`
/// Features:
/// 1. Alert banner (Funds stay locked, auto-release stops, 5-day review SLA)
/// 2. 4 closed dispute categories from spec
/// 3. Problem description
/// 4. Mandatory evidence upload
/// 5. Desired outcome (Full refund / Partial refund)
/// 6. Submit dispute button
class EscrowDisputeScreen extends StatefulWidget {
  final int? orderId;
  final EscrowOrderModel? order;

  const EscrowDisputeScreen({
    super.key,
    this.orderId,
    this.order,
  });

  @override
  State<EscrowDisputeScreen> createState() => _EscrowDisputeScreenState();
}

class _EscrowDisputeScreenState extends State<EscrowDisputeScreen> {
  late final EscrowController controller;

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _partialAmountController = TextEditingController();

  int _selectedReasonIndex = 0;
  bool _isFullRefund = true;
  String? _uploadedEvidence = 'Received-roll-1.jpg';

  final List<Map<String, String>> _categories = [
    {
      'fa': 'کالا با توضیحات و مشخصات قرارداد مطابقت ندارد',
      'en': 'Goods do not match the description',
    },
    {
      'fa': 'تعداد یا حجم ارسالی ناقص و دارای کسری است',
      'en': 'Quantity is short or incomplete',
    },
    {
      'fa': 'کالا دارای شکستگی، خرابی یا آسیب‌دیدگی فیزیکی است',
      'en': 'Goods arrived damaged',
    },
    {
      'fa': 'هیچ کالایی توسط فروشنده ارسال و تحویل نشده است',
      'en': 'Nothing was delivered',
    },
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
  }

  @override
  void dispose() {
    _descController.dispose();
    _partialAmountController.dispose();
    super.dispose();
  }

  void _handleSubmit(double totalLocked) async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'لطفاً شرح مشکل را بنویسید.', en: 'Please describe the problem.'),
        backgroundColor: ECardoTokens.dangerBg(context),
        colorText: ECardoTokens.danger(context),
      );
      return;
    }

    if (_uploadedEvidence == null) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'بارگذاری حداقل یک فایل مستندات الزامی است.', en: 'At least one evidence file is required.'),
        backgroundColor: ECardoTokens.dangerBg(context),
        colorText: ECardoTokens.danger(context),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final effectiveOrderId = widget.order?.id ?? widget.orderId ?? 2042;
    final cat = _categories[_selectedReasonIndex]['en']!;

    await controller.openDispute(
      effectiveOrderId,
      type: cat,
      description: desc,
      evidenceFiles: [_uploadedEvidence!],
    );

    if (!mounted) return;
    Get.back(); // close dispute form
    if (widget.order != null) {
      Get.to(() => EscrowDisputeReviewScreen(order: widget.order!));
    }
    Get.snackbar(
      l10nPick(context, fa: 'پرونده ثبت شد', en: 'Dispute opened'),
      l10nPick(context, fa: 'وجه معامله فریز شد و پرونده به داوری ارسال گردید.', en: 'Funds frozen and case sent to arbitration.'),
      backgroundColor: ECardoTokens.successBg(context),
      colorText: ECardoTokens.success(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order ?? EscrowController.defaultOrders.first;
    final totalLocked = o.totalEscrowAmount > 0 ? o.totalEscrowAmount : 868.60;
    final dealAmount = o.amount > 0 ? o.amount : 860.0;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'ثبت اختلاف معامله',
              en: 'Open a dispute',
              ar: 'فتح نزاع واعتراض',
              zh: '发起争议申诉',
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
            // ------------------ Alert Banner ------------------
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
                      Icon(Icons.shield_outlined, color: ECardoTokens.danger(context), size: 20.sp),
                      SizedBox(width: ECardoTokens.space2.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'مبلغ ${totalLocked.toStringAsFixed(2)} دلار قفل باقی می‌ماند',
                          en: 'The ${totalLocked.toStringAsFixed(2)} USD stays locked',
                          ar: 'يبقى مبلغ ${totalLocked.toStringAsFixed(2)} USD مجمداً',
                          zh: '${totalLocked.toStringAsFixed(2)} USD 资金将保持冻结',
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
                      fa: 'تایمر آزادسازی خودکار بلافاصله متوقف شد. کارشناس حقوقی ایکاردو ظرف ۵ روز کاری پرونده را بررسی و رأی نهایی را صادر می‌نماید.',
                      en: 'Auto-release stops now. An eCardo reviewer decides within 5 business days.',
                      ar: 'توقف الإفراج التلقائي فوراً. وسيصدر قرار التحكيم خلال 5 أيام عمل.',
                      zh: '自动放款流程已立即中止。审核专员将在5个工作日内依据证据做出终审裁决。',
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

            // ------------------ Reason Category ------------------
            Text(
              l10nPick(
                context,
                fa: 'علت و منشأ اختلاف',
                en: 'What went wrong',
                ar: 'سبب النزاع',
                zh: '争议原因分类',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            ...List.generate(_categories.length, (index) {
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
                            l10nPick(context, fa: _categories[index]['fa']!, en: _categories[index]['en']!),
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

            // ------------------ Problem Description ------------------
            Text(
              l10nPick(context, fa: 'شرح دقیق مشکل', en: 'Describe the problem'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
            ),
            SizedBox(height: 4.h),
            Text(
              l10nPick(
                context,
                fa: 'دقیق باشید. داور تنها مستنداتی را بررسی می‌کند که هر دو طرف آپلود کرده‌اند.',
                en: 'Be specific. The reviewer only sees what both sides upload.',
              ),
              style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
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
                controller: _descController,
                maxLines: 4,
                style: TextStyle(fontSize: 13.sp, color: ECardoTokens.ink(context)),
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    fa: 'توضیحات و مغایرت‌های مشاهده‌شده...',
                    en: 'Received roll is 50 micron instead of 80 micron requested in contract.',
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
                  l10nPick(context, fa: 'مدارک و شواهد', en: 'Evidence'),
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
                  Icon(Icons.photo_outlined, color: ECardoTokens.brand500(context), size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _uploadedEvidence ?? 'Received-roll-1.jpg',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ECardoTokens.ink(context)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _uploadedEvidence = 'Evidence-photo-${DateTime.now().millisecond}.jpg');
                    },
                    child: Text(l10nPick(context, fa: 'تغییر', en: 'Change'), style: TextStyle(color: ECardoTokens.brand500(context))),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Requested Outcome ------------------
            Text(
              l10nPick(context, fa: 'خروجی مورد درخواست شما', en: 'What outcome do you want'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(l10nPick(context, fa: 'استرداد کامل وجه', en: 'Full refund'))),
                    selected: _isFullRefund,
                    selectedColor: ECardoTokens.brand900(context),
                    backgroundColor: ECardoTokens.surfaceSunken(context),
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _isFullRefund ? Colors.white : ECardoTokens.ink(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      side: BorderSide(color: _isFullRefund ? ECardoTokens.brand900(context) : ECardoTokens.border(context)),
                    ),
                    onSelected: (_) => setState(() => _isFullRefund = true),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(l10nPick(context, fa: 'استرداد جزئی وجه', en: 'Partial refund'))),
                    selected: !_isFullRefund,
                    selectedColor: ECardoTokens.brand900(context),
                    backgroundColor: ECardoTokens.surfaceSunken(context),
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: !_isFullRefund ? Colors.white : ECardoTokens.ink(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      side: BorderSide(color: !_isFullRefund ? ECardoTokens.brand900(context) : ECardoTokens.border(context)),
                    ),
                    onSelected: (_) => setState(() => _isFullRefund = false),
                  ),
                ),
              ],
            ),

            SizedBox(height: ECardoTokens.space3.h),

            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'مبلغ استردادی به شما', en: 'You get back'),
                        style: TextStyle(fontSize: 13.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                      Text(
                        _isFullRefund ? '${dealAmount.toStringAsFixed(2)} USD' : '400.00 USD',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: ECardoTokens.success(context)),
                      ),
                    ],
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'کارمزد داوری', en: 'Escrow fee'),
                        style: TextStyle(fontSize: 13.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                      Text(
                        l10nPick(context, fa: 'از طرف بازنده کسر می‌شود', en: 'Charged to the losing side'),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
                      ),
                    ],
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
                    backgroundColor: ECardoTokens.danger(context),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                    ),
                  ),
                  onPressed: () => _handleSubmit(totalLocked),
                  child: Text(
                    l10nPick(context, fa: 'ثبت و ارسال اختلاف (Submit dispute)', en: 'Submit dispute'),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              TextButton(
                onPressed: Get.back,
                child: Text(
                  l10nPick(context, fa: 'انصراف و بازگشت (Cancel and go back)', en: 'Cancel and go back'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: ECardoTokens.inkMuted(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

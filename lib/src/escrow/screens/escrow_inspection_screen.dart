import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import 'escrow_dispute_screen.dart';

/// Inspection and Release Screen — matches `inspection_and_release.html`
/// Features:
/// 1. Auto-release countdown banner ("AUTO-RELEASE IN: 68h 12m")
/// 2. Deal financial summary (amount, fee, total locked)
/// 3. Seller's delivery proof (waybill, photos)
/// 4. Release funds button + Open dispute link
class EscrowInspectionScreen extends StatelessWidget {
  final EscrowOrderModel order;

  const EscrowInspectionScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EscrowController>();
    final amount = order.amount;
    final fee = order.feeAmount > 0 ? order.feeAmount : amount * 0.01;
    final totalLocked = amount + fee;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'بازرسی و تحویل کالا',
              en: 'Inspect delivery',
              ar: 'فحص واستلام البضاعة',
              zh: '验收与放款',
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
            // ------------------ Auto-release Countdown Banner ------------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.warningBg(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.warning(context).withValues(alpha: 0.35),
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
                        color: ECardoTokens.warning(context),
                        size: 20.sp,
                      ),
                      SizedBox(width: ECardoTokens.space2.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'آزادسازی خودکار در: ۶۸ ساعت و ۱۲ دقیقه',
                          en: 'AUTO-RELEASE IN: 68h 12m',
                          ar: 'الإفراج التلقائي خلال: 68 س 12 د',
                          zh: '自动放款倒计时：68小时12分',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.warning(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'چنانچه تا پایان این مهلت اقدامی انجام ندهید، وجه قفل‌شده به صورت خودکار به حساب فروشنده واریز خواهد شد.',
                      en: 'If you do nothing, the funds go to the seller when this runs out.',
                      ar: 'إذا لم تقم بأي إجراء، سيتم تحويل الأموال تلقائياً إلى البائع عند انتهاء الوقت.',
                      zh: '若在此倒计时结束前未进行任何操作，系统将自动将资金划拨至卖家账户。',
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

            // ------------------ Deal Summary Card ------------------
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
                    order.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Seller · ${order.seller?.name ?? 'Mina Fabrics'} · delivered 1 Oct',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  Divider(color: ECardoTokens.border(context), height: 1),
                  SizedBox(height: ECardoTokens.space3.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'مبلغ معامله', en: 'Deal amount'),
                    value: '${amount.toStringAsFixed(2)} USD',
                  ),
                  SizedBox(height: 8.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کارمزد ۱٪ اسکرو', en: 'Escrow fee 1% · you pay'),
                    value: '${fee.toStringAsFixed(2)} USD',
                  ),
                  SizedBox(height: 8.h),
                  Divider(color: ECardoTokens.border(context), height: 1),
                  SizedBox(height: 8.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کل وجه قفل‌شده فعلی', en: 'Currently locked'),
                    value: '${totalLocked.toStringAsFixed(2)} USD',
                    isBold: true,
                    valueColor: ECardoTokens.brand900(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space5.h),

            // ------------------ Seller's Delivery Proof ------------------
            Text(
              l10nPick(
                context,
                fa: 'مستندات تحویل فروشنده',
                en: "Seller's delivery proof",
                ar: 'إثبات التسليم من البائع',
                zh: '卖家发货及交付凭证',
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
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: ECardoTokens.brand500(context), size: 22.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          order.sellerDeliveryWaybill ?? 'Waybill-4471.pdf',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: ECardoTokens.brand500(context),
                          ),
                        ),
                      ),
                      Icon(Icons.download_rounded, color: ECardoTokens.inkMuted(context), size: 20.sp),
                    ],
                  ),
                  Divider(color: ECardoTokens.border(context), height: 18.h),
                  Row(
                    children: [
                      Icon(Icons.collections_outlined, color: ECardoTokens.sand600(context), size: 22.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Batch photos (6)',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: ECardoTokens.inkMuted(context), size: 20.sp),
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
                    backgroundColor: ECardoTokens.brand900(context),
                    foregroundColor: ECardoTokens.inkOnBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showReleaseDialog(context, controller, totalLocked);
                  },
                  child: Text(
                    l10nPick(
                      context,
                      fa: 'تأیید تحویل و آزادسازی ${totalLocked.toStringAsFixed(2)} دلار به فروشنده',
                      en: 'Release ${totalLocked.toStringAsFixed(2)} USD to seller',
                    ),
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => EscrowDisputeScreen(order: order));
                },
                child: Text(
                  l10nPick(
                    context,
                    fa: 'ثبت اختلاف و عدم تأیید کالا (Open a dispute)',
                    en: 'Open a dispute',
                    ar: 'فتح نزاع واعتراض',
                    zh: '发起争议申诉',
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.danger(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, EscrowController controller, double amount) {
    final sTitle = l10nPick(context, fa: 'آزادسازی موفق', en: 'Funds released');
    final sMsg = l10nPick(context, fa: 'وجه معامله به حساب فروشنده واریز شد.', en: 'Funds successfully released to seller.');
    final sBg = ECardoTokens.successBg(context);
    final sColor = ECardoTokens.success(context);

    Get.defaultDialog(
      title: l10nPick(context, fa: 'تأیید تحویل کالا', en: 'Confirm delivery acceptance'),
      middleText: l10nPick(
        context,
        fa: 'آیا از سلامت کالا و تحویل کامل اطمینان دارید؟ با تأیید شما وجه به صورت برگشت‌ناپذیر به فروشنده پرداخت می‌شود.',
        en: 'Release ${amount.toStringAsFixed(2)} USD to seller? This action is irreversible.',
      ),
      textConfirm: l10nPick(context, fa: 'آزادسازی وجه', en: 'Release funds'),
      textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
      buttonColor: ECardoTokens.brand900(context),
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.releaseFunds(order.id);
        Get.back();
        Get.snackbar(
          sTitle,
          sMsg,
          backgroundColor: sBg,
          colorText: sColor,
        );
      },
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

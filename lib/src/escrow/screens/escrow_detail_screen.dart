import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import 'escrow_inspection_screen.dart';
import 'escrow_dispute_review_screen.dart';

/// Detailed view of an Escrow Deal — matches `escrow_deal_detail.html`
/// Features:
/// 1. Funds held status banner (locked amount, delivery deadline, dispute rights)
/// 2. 5-step transaction progress stepper (Accepted, Funded, Awaiting delivery, Inspection, Released)
/// 3. Counterparty & Deal metadata (documents, inspection window)
/// 4. Dynamic action buttons based on user role and state (Mark as delivered / Inspect / Dispute)
class EscrowDetailScreen extends StatefulWidget {
  final int orderId;
  final EscrowOrderModel? initialOrder;

  const EscrowDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<EscrowDetailScreen> createState() => _EscrowDetailScreenState();
}

class _EscrowDetailScreenState extends State<EscrowDetailScreen> {
  late final EscrowController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
    if (widget.initialOrder != null) {
      controller.activeOrder.value = widget.initialOrder;
    }
    if (widget.orderId > 0) {
      controller.loadOrderDetails(widget.orderId);
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
            final o = controller.activeOrder.value ?? widget.initialOrder ?? EscrowController.defaultOrders.first;
            return CommonAppBar(
              title: 'Deal ${o.contractNo}',
              isBackLogicApply: true,
              backLogicFunction: Get.back,
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isActionLoading.value && controller.activeOrder.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final o = controller.activeOrder.value ?? widget.initialOrder ?? EscrowController.defaultOrders.first;
        final isFundsHeld = o.isFundsHeld;
        final isInspection = o.isInspection;
        final isDisputed = o.isDisputed;
        final lockedAmount = o.totalEscrowAmount > 0 ? o.totalEscrowAmount : 2400.0;

        return SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isFundsHeld
                                ? ECardoTokens.successBg(context)
                                : isInspection
                                    ? ECardoTokens.sand100(context)
                                    : isDisputed
                                        ? ECardoTokens.dangerBg(context)
                                        : ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                          ),
                          child: Text(
                            o.statusLabel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: isFundsHeld
                                  ? ECardoTokens.success(context)
                                  : isInspection
                                      ? ECardoTokens.sand600(context)
                                      : isDisputed
                                          ? ECardoTokens.danger(context)
                                          : ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                        Text(
                          'Locked since 28 Sep',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: ECardoTokens.inkMuted(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ECardoTokens.space3.h),
                    Text(
                      '${lockedAmount.toStringAsFixed(2)} USD',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(
                        context,
                        fa: 'وجه نزد ایکاردو قفل است. تا زمان تأیید تحویل، هیچ‌یک از طرفین امکان برداشت آن را ندارند.',
                        en: 'Held by eCardo. Neither side can move it until delivery is approved.',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space3.h),

                    // Delivery due pill
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.surfaceSunken(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, fa: 'مهلت ارسال: ۳ روز مانده', en: 'Delivery due in 3 days'),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(context, fa: 'پس از تاریخ ۷ اکتبر خریدار حق ثبت اختلاف خواهد داشت.', en: 'After 7 Oct the buyer may open a dispute.'),
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

              SizedBox(height: ECardoTokens.space5.h),

              // ------------------ Progress Stepper ------------------
              Text(
                l10nPick(context, fa: 'مراحل اجرای معامله', en: 'Progress'),
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
                      title: l10nPick(context, fa: 'توافق طرفین و پذیرش شرایط', en: 'Deal accepted'),
                      sub: '27 Sep · Delta Trading Co.',
                      isDone: true,
                    ),
                    _buildProgressStep(
                      context,
                      stepNum: '2',
                      title: l10nPick(context, fa: 'تأمین وجه توسط خریدار در حساب امانی', en: 'Buyer funded escrow'),
                      sub: '28 Sep · 2,424.00 USD received',
                      isDone: true,
                    ),
                    _buildProgressStep(
                      context,
                      stepNum: '3',
                      title: l10nPick(context, fa: 'در انتظار ارسال کالا توسط فروشنده', en: 'Awaiting your delivery'),
                      sub: l10nPick(context, fa: 'پس از تحویل به باربری علامت بزنید', en: 'Mark as shipped once goods leave'),
                      isActive: true,
                    ),
                    _buildProgressStep(
                      context,
                      stepNum: '4',
                      title: l10nPick(context, fa: 'مهلت بازرسی خریدار', en: 'Buyer inspection'),
                      sub: '72 hours after delivery',
                    ),
                    _buildProgressStep(
                      context,
                      stepNum: '5',
                      title: l10nPick(context, fa: 'آزادسازی وجه به حساب شما', en: 'Funds released to you'),
                      sub: '2,400.00 USD · fee paid by buyer',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: ECardoTokens.space5.h),

              // ------------------ Metadata Section ------------------
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
                      label: l10nPick(context, fa: 'طرف مقابل معامله', en: 'Counterparty'),
                      value: o.counterpartyLabel,
                    ),
                    Divider(color: ECardoTokens.border(context), height: 16.h),
                    _buildDetailRow(
                      context,
                      label: l10nPick(context, fa: 'مهلت بازرسی', en: 'Inspection window'),
                      value: '${o.inspectionHours} hours',
                    ),
                    Divider(color: ECardoTokens.border(context), height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(context, fa: 'مدارک ضمیمه', en: 'Documents'),
                          style: TextStyle(fontSize: 13.sp, color: ECardoTokens.inkMuted(context)),
                        ),
                        Text(
                          '2 files',
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
          child: Obx(() {
            final o = controller.activeOrder.value ?? widget.initialOrder ?? EscrowController.defaultOrders.first;
            if (o.isInspection) {
              return SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ECardoTokens.brand900(context),
                    foregroundColor: ECardoTokens.inkOnBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
                  ),
                  onPressed: () => Get.to(() => EscrowInspectionScreen(order: o)),
                  child: Text(
                    l10nPick(context, fa: 'بررسی و آزادسازی کالا (Inspect delivery)', en: 'Inspect delivery'),
                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              );
            }

            if (o.isDisputed) {
              return SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ECardoTokens.danger(context),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
                  ),
                  onPressed: () => Get.to(() => EscrowDisputeReviewScreen(order: o)),
                  child: Text(
                    l10nPick(context, fa: 'مشاهده پرونده اختلاف (Dispute review)', en: 'Dispute review'),
                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              );
            }

            return SizedBox(
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
                  final sTitle = l10nPick(context, fa: 'موفقیت', en: 'Success');
                  final sMsg = l10nPick(context, fa: 'ارسال با موفقیت ثبت شد و تایمر بازرسی خریدار فعال گردید.', en: 'Delivery recorded.');
                  final sBg = ECardoTokens.successBg(context);
                  final sColor = ECardoTokens.success(context);
                  Get.defaultDialog(
                    title: l10nPick(context, fa: 'تأیید ارسال کالا', en: 'Mark as delivered'),
                    middleText: l10nPick(
                      context,
                      fa: 'آیا کالا را به خریدار یا باربری تحویل داده‌اید؟ با تأیید این مورد، تایمر مهلت بازرسی خریدار آغاز خواهد شد.',
                      en: 'Mark goods as delivered? This will start the buyer inspection countdown.',
                    ),
                    textConfirm: l10nPick(context, fa: 'تأیید تحویل', en: 'Confirm'),
                    textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel'),
                    buttonColor: ECardoTokens.brand900(context),
                    confirmTextColor: Colors.white,
                    onConfirm: () async {
                      Get.back();
                      await controller.submitShipment(
                        o.id,
                        carrier: 'Karun Logistics',
                        trackingNumber: 'TRK-99182',
                      );
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
                    fa: 'علامت‌گذاری به عنوان تحویل‌شده (Mark as delivered)',
                    en: 'Mark as delivered',
                  ),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
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

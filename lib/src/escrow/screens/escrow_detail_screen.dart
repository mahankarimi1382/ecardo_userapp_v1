import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import '../widgets/escrow_widgets.dart';
import 'escrow_payment_screen.dart';
import 'escrow_shipment_screen.dart';
import 'escrow_dispute_screen.dart';

class EscrowDetailScreen extends StatefulWidget {
  final int orderId;

  const EscrowDetailScreen({super.key, required this.orderId});

  @override
  State<EscrowDetailScreen> createState() => _EscrowDetailScreenState();
}

class _EscrowDetailScreenState extends State<EscrowDetailScreen> {
  // QA-2026-09-29 (escrow): deep navigation (BaseRoute.escrowDetail from a
  // deep-link) never passes through EscrowListScreen, so Get.find used to
  // throw and render a dead error page. Register on demand instead.
  late final EscrowController controller = Get.isRegistered<EscrowController>()
      ? Get.find<EscrowController>()
      : Get.put(EscrowController());

  @override
  void initState() {
    super.initState();
    controller.loadOrderDetails(widget.orderId);
  }

  void _showRequestChangesDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(l10nPick(context, fa: 'درخواست اصلاح شرایط', en: 'Request Changes')),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10nPick(context, fa: 'توضیحات موارد نیازمند اصلاح...', en: 'Describe requested changes...'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              Get.back();
              await controller.requestChanges(widget.orderId, textController.text.trim());
            },
            child: Text(l10nPick(context, fa: 'ارسال درخواست', en: 'Submit'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    int stars = 5;
    final textController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            title: Text(l10nPick(context, fa: 'ثبت امتیاز معامله', en: 'Rate Deal')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final s = index + 1;
                    return IconButton(
                      icon: Icon(s <= stars ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 32.w),
                      onPressed: () => setDlgState(() => stars = s),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: l10nPick(context, fa: 'نظر شما درباره این معامله...', en: 'Comment...'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                onPressed: () async {
                  Get.back();
                  await controller.submitRating(widget.orderId, rating: stars, comment: textController.text.trim());
                },
                child: Text(l10nPick(context, fa: 'ثبت امتیاز', en: 'Submit'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              controller.activeOrder.value?.contractNo ?? 'جزئیات معامله',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: AppColors.lightTextPrimary),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadOrderDetails(widget.orderId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isActionLoading.value && controller.activeOrder.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary));
        }

        final deal = controller.activeOrder.value;
        if (deal == null) {
          return Center(child: Text(l10nPick(context, fa: 'معامله یافت نشد.', en: 'Deal not found.')));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EscrowStatusBadge(status: deal.status, label: deal.statusLabel),
                        Text(
                          '${deal.amount.toStringAsFixed(0)} ${deal.currency}',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.lightPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      deal.title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
                    ),
                    if (deal.description.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        deal.description,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Parties & Terms Info
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10nPick(context, fa: 'مشخصات و شرایط معامله', en: 'Deal Terms & Parties'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                    const Divider(height: 20),
                    _buildInfoRow(l10nPick(context, fa: 'طرف خریدار', en: 'Buyer'), deal.buyer?.name ?? '-'),
                    _buildInfoRow(l10nPick(context, fa: 'طرف فروشنده', en: 'Seller'), deal.seller?.name ?? '-'),
                    _buildInfoRow(l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection Period'), l10nPick(context, fa: '${deal.inspectionHours} ساعت پس از تحویل', en: '${deal.inspectionHours} hours after delivery')),
                    _buildInfoRow(l10nPick(context, fa: 'پرداخت‌کننده کارمزد', en: 'Fee Payer'), deal.feePayer == 'BUYER' ? 'خریدار' : (deal.feePayer == 'SELLER' ? 'فروشنده' : '۵۰-۵۰')),
                    if (deal.shippingCompany != null)
                      _buildInfoRow(l10nPick(context, fa: 'شرکت حمل‌ونقل', en: 'Carrier'), deal.shippingCompany!),
                    if (deal.trackingNumber != null)
                      _buildInfoRow(l10nPick(context, fa: 'شماره بارنامه/رهگیری', en: 'Tracking No'), deal.trackingNumber!),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Action Buttons Box (Dynamic based on State Machine)
              _buildActionButtons(context, deal),
              SizedBox(height: 14.h),

              // Timeline
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10nPick(context, fa: 'تایم‌لاین رویدادهای معامله', en: 'Deal Timeline'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                    const Divider(height: 20),
                    EscrowTimelineWidget(events: deal.events),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(BuildContext context, EscrowOrderModel deal) {
    final status = deal.status;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // G1: DRAFT
          if (status == 'DRAFT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => controller.sendForApproval(deal.id),
              child: Text(
                l10nPick(context, fa: 'ارسال برای تأیید (Send for Approval)', en: 'Send for Approval'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],

          // G2: AWAITING_AGREEMENT
          if (status == 'AWAITING_AGREEMENT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => controller.acceptTerms(deal.id),
              child: Text(
                l10nPick(context, fa: 'می‌پذیرم (I Accept)', en: 'I Accept Terms'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8.h),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: _showRequestChangesDialog,
              child: Text(l10nPick(context, fa: 'درخواست اصلاح شرایط', en: 'Request Changes')),
            ),
          ],

          // G3: AWAITING_PAYMENT
          if (status == 'AWAITING_PAYMENT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => Get.to(() => EscrowPaymentScreen(order: deal)),
              child: Text(
                l10nPick(context, fa: 'پرداخت به حساب امانی (Pay into Escrow)', en: 'Pay into Escrow'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8.h),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => controller.cancelDeal(deal.id),
              child: Text(l10nPick(context, fa: 'لغو معامله (Cancel Deal)', en: 'Cancel Deal')),
            ),
          ],

          // G4: FUNDS_HELD
          if (status == 'FUNDS_HELD') ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14.r)),
              child: Text(
                l10nPick(
                  context,
                  fa: 'وجه معامله با موفقیت در حساب امانی قفل شد. فروشنده موظف است کالا را ارسال و بارنامه را ثبت نماید.',
                  en: 'Funds safely held in escrow. Seller must ship and submit tracking details.',
                ),
                style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade900),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => Get.to(() => EscrowShipmentScreen(orderId: deal.id)),
              child: Text(
                l10nPick(context, fa: 'ثبت اطلاعات ارسال (Submit Shipment)', en: 'Submit Shipment Details'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],

          // G5: IN_DELIVERY
          if (status == 'IN_DELIVERY') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => controller.confirmDelivery(deal.id),
              child: Text(
                l10nPick(context, fa: 'کالا را دریافت کردم (Confirm Delivery)', en: 'Confirm Delivery'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],

          // G6: DELIVERED (Inspection Period)
          if (status == 'DELIVERED') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: () => controller.approveRelease(deal.id),
              child: Text(
                l10nPick(context, fa: 'تأیید و آزادسازی وجه (Approve & Release)', en: 'Approve & Release Funds'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: () => Get.to(() => EscrowDisputeScreen(orderId: deal.id)),
                    child: Text(l10nPick(context, fa: 'ثبت اختلاف', en: 'Open Dispute'), style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: () => controller.extendInspection(deal.id, hours: 48),
                    child: Text(l10nPick(context, fa: 'تمدید بازرسی (+۴۸h)', en: '+48h Extension'), style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
              ],
            ),
          ],

          // G7: COMPLETED / RELEASED
          if (status == 'COMPLETED' || status == 'RELEASED') ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              icon: const Icon(Icons.star_rounded, color: Colors.white),
              onPressed: _showRatingDialog,
              label: Text(
                l10nPick(context, fa: 'ثبت امتیاز معامله (Submit Rating)', en: 'Submit Rating'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],

          // DISPUTED
          if (status == 'DISPUTED') ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14.r)),
              child: Text(
                l10nPick(
                  context,
                  fa: 'پرونده اختلاف برای این معامله ثبت شده و وجه توسط پلتفرم فریز گردیده است. داور پلتفرم به زودی بررسی و رأی نهایی را صادر می‌نماید.',
                  en: 'Dispute is open. Funds are frozen pending arbitration ruling.',
                ),
                style: TextStyle(fontSize: 11.sp, color: Colors.red.shade900),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
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
  final EscrowController controller = Get.find<EscrowController>();

  @override
  void initState() {
    super.initState();
    controller.loadOrderDetails(widget.orderId);
  }

  void _showRequestChangesDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(
          l10nPick(context, fa: 'درخواست اصلاح شرایط', en: 'Request Changes'),
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10nPick(context, fa: 'توضیحات موارد نیازمند اصلاح...', en: 'Describe requested changes...'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            ),
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              HapticFeedback.lightImpact();
              Get.back();
              await controller.requestChanges(widget.orderId, textController.text.trim());
            },
            child: Text(
              l10nPick(context, fa: 'ارسال درخواست', en: 'Submit'),
              style: const TextStyle(color: AppColors.white),
            ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
            title: Text(
              l10nPick(context, fa: 'ثبت امتیاز معامله', en: 'Rate Deal'),
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final s = index + 1;
                    return IconButton(
                      icon: Icon(
                        s <= stars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppColors.warning,
                        size: 32.sp,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setDlgState(() => stars = s);
                      },
                    );
                  }),
                ),
                SizedBox(height: AppSpacing.md.h),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: l10nPick(context, fa: 'نظر شما درباره این معامله...', en: 'Comment...'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Get.back();
                  await controller.submitRating(widget.orderId, rating: stars, comment: textController.text.trim());
                },
                child: Text(
                  l10nPick(context, fa: 'ثبت امتیاز', en: 'Submit'),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Obx(() => Text(
              controller.activeOrder.value?.contractNo ?? l10nPick(context, fa: 'جزئیات معامله', en: 'Deal Details'),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            )),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            tooltip: l10nPick(context, fa: 'تازه‌سازی', en: 'Refresh'),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.loadOrderDetails(widget.orderId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isActionLoading.value && controller.activeOrder.value == null) {
          return const EscrowSkeletonLoader(itemCount: 2);
        }

        final deal = controller.activeOrder.value;
        if (deal == null) {
          return Center(
            child: EcardoEmptyState(
              iconData: Icons.search_off_rounded,
              title: l10nPick(context, fa: 'معامله یافت نشد', en: 'Deal not found'),
              description: l10nPick(context, fa: 'اطلاعات این معامله در دسترس نیست یا لغو شده است.', en: 'This deal is unavailable or cancelled.'),
              primaryActionLabel: l10nPick(context, fa: 'بازگشت', en: 'Back'),
              onPrimaryAction: () => Get.back(),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadOrderDetails(widget.orderId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Milestone Stepper Card
                EscrowMilestoneStepper(currentStatus: deal.status),
                SizedBox(height: AppSpacing.md.h),

                // 2. Status & Hero Overview Card
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w900,
                              color: primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        deal.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (deal.description.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          deal.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),

                // 3. Parties & Terms Card
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, fa: 'مشخصات و شرایط معامله', en: 'Deal Terms & Parties'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      _buildInfoRow(context, isDark, l10nPick(context, fa: 'طرف خریدار', en: 'Buyer'), deal.buyer?.name ?? '-'),
                      _buildInfoRow(context, isDark, l10nPick(context, fa: 'طرف فروشنده', en: 'Seller'), deal.seller?.name ?? '-'),
                      _buildInfoRow(context, isDark, l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection Period'), '${deal.inspectionHours} ساعت پس از تحویل'),
                      _buildInfoRow(
                        context,
                        isDark,
                        l10nPick(context, fa: 'پرداخت‌کننده کارمزد', en: 'Fee Payer'),
                        deal.feePayer == 'BUYER' ? 'خریدار' : (deal.feePayer == 'SELLER' ? 'فروشنده' : '۵۰-۵۰'),
                      ),
                      if (deal.shippingCompany != null)
                        _buildInfoRow(context, isDark, l10nPick(context, fa: 'شرکت حمل‌ونقل', en: 'Carrier'), deal.shippingCompany!),
                      if (deal.trackingNumber != null)
                        _buildInfoRow(context, isDark, l10nPick(context, fa: 'شماره بارنامه/رهگیری', en: 'Tracking No'), deal.trackingNumber!),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),

                // 4. Action Buttons Box (Dynamic based on State Machine)
                _buildActionButtons(context, deal, isDark, primaryAccent),
                SizedBox(height: AppSpacing.md.h),

                // 5. Timeline Card
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, fa: 'تایم‌لاین رویدادهای معامله', en: 'Deal Timeline'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Divider(
                        height: 24,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      EscrowTimelineWidget(events: deal.events),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    EscrowOrderModel deal,
    bool isDark,
    Color primaryAccent,
  ) {
    final status = deal.status;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // G1: DRAFT
          if (status == 'DRAFT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.sendForApproval(deal.id);
              },
              child: Text(
                l10nPick(context, fa: 'ارسال برای تأیید (Send for Approval)', en: 'Send for Approval'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.deepBlack : AppColors.white,
                ),
              ),
            ),
          ],

          // G2: AWAITING_AGREEMENT
          if (status == 'AWAITING_AGREEMENT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.acceptTerms(deal.id);
              },
              child: Text(
                l10nPick(context, fa: 'می‌پذیرم (I Accept)', en: 'I Accept Terms'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showRequestChangesDialog();
              },
              child: Text(
                l10nPick(context, fa: 'درخواست اصلاح شرایط', en: 'Request Changes'),
                style: AppTextStyles.labelLarge,
              ),
            ),
          ],

          // G3: AWAITING_PAYMENT
          if (status == 'AWAITING_PAYMENT') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.to(() => EscrowPaymentScreen(order: deal));
              },
              child: Text(
                l10nPick(context, fa: 'پرداخت به حساب امانی (Pay into Escrow)', en: 'Pay into Escrow'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.deepBlack : AppColors.white,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.cancelDeal(deal.id);
              },
              child: Text(
                l10nPick(context, fa: 'لغو معامله (Cancel Deal)', en: 'Cancel Deal'),
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
              ),
            ),
          ],

          // G4: FUNDS_HELD
          if (status == 'FUNDS_HELD') ...[
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132838) : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
              ),
              child: Text(
                l10nPick(
                  context,
                  fa: 'وجه معامله با موفقیت در حساب امانی قفل شد. فروشنده موظف است کالا را ارسال و بارنامه را ثبت نماید.',
                  en: 'Funds safely held in escrow. Seller must ship and submit tracking details.',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.to(() => EscrowShipmentScreen(orderId: deal.id));
              },
              child: Text(
                l10nPick(context, fa: 'ثبت اطلاعات ارسال (Submit Shipment)', en: 'Submit Shipment Details'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.deepBlack : AppColors.white,
                ),
              ),
            ),
          ],

          // G5: IN_DELIVERY
          if (status == 'IN_DELIVERY') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.confirmDelivery(deal.id);
              },
              child: Text(
                l10nPick(context, fa: 'کالا را دریافت کردم (Confirm Delivery)', en: 'Confirm Delivery'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],

          // G6: DELIVERED (Inspection Period)
          if (status == 'DELIVERED') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.approveRelease(deal.id);
              },
              child: Text(
                l10nPick(context, fa: 'تأیید و آزادسازی وجه (Approve & Release)', en: 'Approve & Release Funds'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => EscrowDisputeScreen(orderId: deal.id));
                    },
                    child: Text(
                      l10nPick(context, fa: 'ثبت اختلاف', en: 'Open Dispute'),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      controller.extendInspection(deal.id, hours: 48);
                    },
                    child: Text(
                      l10nPick(context, fa: 'تمدید بازرسی (+۴۸h)', en: '+48h Extension'),
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // G7: COMPLETED / RELEASED
          if (status == 'COMPLETED' || status == 'RELEASED') ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFB45309),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
              ),
              icon: const Icon(Icons.star_rounded, color: AppColors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showRatingDialog();
              },
              label: Text(
                l10nPick(context, fa: 'ثبت امتیاز معامله (Submit Rating)', en: 'Submit Rating'),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],

          // DISPUTED
          if (status == 'DISPUTED') ...[
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF36181B) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
              ),
              child: Text(
                l10nPick(
                  context,
                  fa: 'پرونده اختلاف برای این معامله ثبت شده و وجه توسط پلتفرم فریز گردیده است. داور پلتفرم به زودی بررسی و رأی نهایی را صادر می‌نماید.',
                  en: 'Dispute is open. Funds are frozen pending arbitration ruling.',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, bool isDark, String label, String value) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

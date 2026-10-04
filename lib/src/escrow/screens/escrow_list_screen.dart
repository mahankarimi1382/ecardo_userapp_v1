import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import 'escrow_create_screen.dart';
import 'escrow_detail_screen.dart';
import 'escrow_inspection_screen.dart';
import 'escrow_dispute_review_screen.dart';

/// Escrow Deals List Screen — matches `escrow_deals.html`
/// Features:
/// 1. Header: Escrow
/// 2. Filter tabs: All | Awaiting | Held | Dispute
/// 3. Deal cards with title, role, status chip, amount in USD, and subtext
/// 4. Tap routing based on status (Inspection -> Inspect screen, Dispute -> Dispute screen, Held -> Detail)
/// 5. Sticky Bottom CTA: "New escrow deal"
class EscrowListScreen extends StatefulWidget {
  const EscrowListScreen({super.key});

  @override
  State<EscrowListScreen> createState() => _EscrowListScreenState();
}

class _EscrowListScreenState extends State<EscrowListScreen> {
  late final EscrowController controller;
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['All', 'Awaiting', 'Held', 'Dispute'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
    controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'معاملات امن (اسکرو)',
              en: 'Escrow',
              ar: 'حساب الضمان (إسكرو)',
              zh: '担保交易',
            ),
            isBackLogicApply: true,
            backLogicFunction: Get.back,
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: ECardoTokens.space4.w),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ECardoTokens.ink(context),
                  size: 22.sp,
                ),
                tooltip: l10nPick(context, fa: 'تازه‌سازی', en: 'Refresh'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.loadOrders(refresh: true);
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = controller.orders.isNotEmpty
            ? controller.orders
            : EscrowController.defaultOrders;

        // Filter list
        List<EscrowOrderModel> filteredOrders;
        switch (_selectedFilterIndex) {
          case 1: // Awaiting
            filteredOrders = allOrders.where((o) => o.isPendingAgreement).toList();
            break;
          case 2: // Held
            filteredOrders = allOrders.where((o) => o.isFundsHeld || o.isInspection).toList();
            break;
          case 3: // Dispute
            filteredOrders = allOrders.where((o) => o.isDisputed).toList();
            break;
          default:
            filteredOrders = allOrders.toList();
        }

        return RefreshIndicator(
          color: ECardoTokens.brand900(context),
          onRefresh: () => controller.loadOrders(refresh: true),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: ECardoTokens.space4.w,
              vertical: ECardoTokens.space3.h,
            ),
            children: [
              // ------------------ Filter Chips ------------------
              SizedBox(
                height: 36.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedFilterIndex = index);
                        controller.setFilter(_filters[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ECardoTokens.brand900(context)
                              : ECardoTokens.surfaceCard(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusFull.r),
                          border: Border.all(
                            color: isSelected
                                ? ECardoTokens.brand900(context)
                                : ECardoTokens.border(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _filterLabel(context, _filters[index]),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: ECardoTokens.space4.h),

              // ------------------ Deals Cards ------------------
              ...filteredOrders.map((o) => Padding(
                    padding: EdgeInsets.only(bottom: ECardoTokens.space3.h),
                    child: _buildDealCard(context, o),
                  )),

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
                Get.to(() => const EscrowCreateScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'ایجاد معامله جدید (New escrow deal)',
                  en: 'New escrow deal',
                  ar: 'معاملة ضمان جديدة',
                  zh: '发起新的担保交易',
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

  Widget _buildDealCard(BuildContext context, EscrowOrderModel o) {
    final isDisputed = o.isDisputed;
    final isInspection = o.isInspection;
    final isFundsHeld = o.isFundsHeld;

    return InkWell(
      borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        if (isInspection) {
          Get.to(() => EscrowInspectionScreen(order: o));
        } else if (isDisputed) {
          Get.to(() => EscrowDisputeReviewScreen(order: o));
        } else {
          Get.to(() => EscrowDetailScreen(orderId: o.id, initialOrder: o));
        }
      },
      child: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
          border: Border.all(
            color: isDisputed
                ? ECardoTokens.danger(context).withValues(alpha: 0.5)
                : ECardoTokens.border(context),
            width: isDisputed ? 1.5 : 1.0,
          ),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title and Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    o.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDisputed
                        ? ECardoTokens.dangerBg(context)
                        : isInspection
                            ? ECardoTokens.sand100(context)
                            : isFundsHeld
                                ? ECardoTokens.successBg(context)
                                : ECardoTokens.brand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Text(
                    _statusChipText(context, o),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: isDisputed
                          ? ECardoTokens.danger(context)
                          : isInspection
                              ? ECardoTokens.sand600(context)
                              : isFundsHeld
                                  ? ECardoTokens.success(context)
                                  : ECardoTokens.brand700(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Counterparty
            Text(
              o.counterpartyLabel,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            // Amount
            Text(
              '${o.amount.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: 4.h),

            // Subtext (countdown / due / review)
            Text(
              o.dynamicSubtext,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: isDisputed
                    ? ECardoTokens.danger(context)
                    : isInspection
                        ? ECardoTokens.sand600(context)
                        : ECardoTokens.inkMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusChipText(BuildContext context, EscrowOrderModel o) {
    if (o.isDisputed) return l10nPick(context, fa: 'در اختلاف', en: 'Dispute');
    if (o.isInspection) return l10nPick(context, fa: 'بازرسی', en: 'Inspection');
    if (o.isFundsHeld) return l10nPick(context, fa: 'وجه قفل‌شده', en: 'Funds held');
    return l10nPick(context, fa: 'در انتظار', en: 'Pending');
  }

  String _filterLabel(BuildContext context, String filter) {
    switch (filter) {
      case 'Awaiting':
        return l10nPick(context, fa: 'در انتظار', en: 'Awaiting');
      case 'Held':
        return l10nPick(context, fa: 'امان پلتفرم', en: 'Held');
      case 'Dispute':
        return l10nPick(context, fa: 'در اختلاف', en: 'Dispute');
      default:
        return l10nPick(context, fa: 'همه', en: 'All');
    }
  }
}

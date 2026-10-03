import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';
import '../widgets/escrow_widgets.dart';
import 'escrow_create_screen.dart';
import 'escrow_detail_screen.dart';

class EscrowListScreen extends StatelessWidget {
  const EscrowListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EscrowController controller = Get.put(EscrowController());

    final filterTabs = [
      {'key': 'ALL', 'label': l10nPick(context, fa: 'همه معاملات', en: 'All')},
      {'key': 'AWAITING_PAYMENT', 'label': l10nPick(context, fa: 'در انتظار پرداخت', en: 'Payment')},
      {'key': 'FUNDS_HELD', 'label': l10nPick(context, fa: 'امان نزد پلتفرم', en: 'Held')},
      {'key': 'IN_DELIVERY', 'label': l10nPick(context, fa: 'در حال ارسال', en: 'Delivery')},
      {'key': 'DELIVERED', 'label': l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection')},
      {'key': 'COMPLETED', 'label': l10nPick(context, fa: 'تکمیل‌شده', en: 'Completed')},
      {'key': 'DISPUTED', 'label': l10nPick(context, fa: 'در اختلاف', en: 'Disputed')},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10nPick(context, fa: 'معاملات امانی (Escrow)', en: 'Escrow Transactions'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadOrders(refresh: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.lightPrimary,
        elevation: 4,
        onPressed: () => Get.to(() => const EscrowCreateScreen()),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          l10nPick(context, fa: 'ایجاد معامله جدید', en: 'New Deal'),
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs (Horizontal scroll)
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: filterTabs.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (ctx, i) {
                  final tab = filterTabs[i];
                  return Obx(() {
                    final isSel = controller.selectedFilter.value == tab['key'];
                    return InkWell(
                      onTap: () => controller.setFilter(tab['key']!),
                      borderRadius: BorderRadius.circular(18.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.lightPrimary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Center(
                          child: Text(
                            tab['label']!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
          const Divider(height: 1),

          // Main list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary));
              }

              if (controller.orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel_rounded, size: 54.w, color: Colors.grey.shade300),
                        SizedBox(height: 14.h),
                        Text(
                          l10nPick(context, fa: 'معامله امانی یافت نشد', en: 'No Escrow Deals Found'),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          l10nPick(
                            context,
                            fa: 'با ایجاد معامله امانی جدید، وجه معامله تا زمان تایید تحویل کالا نزد پلتفرم با امنیت کامل قفل می‌ماند.',
                            en: 'Create a deal to secure funds until buyer delivery approval.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadOrders(refresh: true),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (ctx, idx) {
                    final deal = controller.orders[idx];
                    return _buildDealCard(context, deal);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, EscrowOrderModel deal) {
    return InkWell(
      onTap: () {
        Get.to(() => EscrowDetailScreen(orderId: deal.id));
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Contract No + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 16.w, color: AppColors.lightPrimary),
                    SizedBox(width: 6.w),
                    Text(
                      deal.contractNo,
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                EscrowStatusBadge(status: deal.status, label: deal.statusLabel),
              ],
            ),
            SizedBox(height: 10.h),

            // Title
            Text(
              deal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
            ),
            SizedBox(height: 6.h),

            // Parties: Buyer / Seller
            Row(
              children: [
                Expanded(
                  child: Text(
                    'خریدار: ${deal.buyer?.name ?? "..."}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    'فروشنده: ${deal.seller?.name ?? "..."}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Amount & Currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${deal.amount.toStringAsFixed(0)} ${deal.currency}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightPrimary),
                ),
                Row(
                  children: [
                    Text(
                      l10nPick(context, fa: 'مشاهده جزئیات', en: 'View Details'),
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    Icon(Icons.chevron_left_rounded, size: 18.w, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
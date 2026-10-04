import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
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
    final EscrowController controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterTabs = [
      {'key': 'ALL', 'label': l10nPick(context, fa: 'همه معاملات', en: 'All')},
      {'key': 'AWAITING_PAYMENT', 'label': l10nPick(context, fa: 'در انتظار پرداخت', en: 'Payment')},
      {'key': 'FUNDS_HELD', 'label': l10nPick(context, fa: 'امان نزد پلتفرم', en: 'Held')},
      {'key': 'IN_DELIVERY', 'label': l10nPick(context, fa: 'در حال ارسال', en: 'Delivery')},
      {'key': 'DELIVERED', 'label': l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection')},
      {'key': 'COMPLETED', 'label': l10nPick(context, fa: 'تکمیل‌شده', en: 'Completed')},
      {'key': 'DISPUTED', 'label': l10nPick(context, fa: 'در اختلاف', en: 'Disputed')},
    ];

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
        title: Text(
          l10nPick(context, fa: 'معاملات امانی (Escrow)', en: 'Escrow Transactions'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            tooltip: l10nPick(context, fa: 'تازه‌سازی', en: 'Refresh'),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.loadOrders(refresh: true);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryAccent,
        foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
        elevation: 4,
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.to(() => const EscrowCreateScreen());
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10nPick(context, fa: 'ایجاد معامله جدید', en: 'New Deal'),
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.deepBlack : AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs (Horizontal scroll)
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm.h),
            child: SizedBox(
              height: 42.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w),
                itemCount: filterTabs.length,
                separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
                itemBuilder: (ctx, i) {
                  final tab = filterTabs[i];
                  return Obx(() {
                    final isSel = controller.selectedFilter.value == tab['key'];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.setFilter(tab['key']!);
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSel
                              ? primaryAccent
                              : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            tab['label']!,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel
                                  ? (isDark ? AppColors.deepBlack : AppColors.white)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // Main list & States
          Expanded(
            child: Obx(() {
              // 1. Loading State
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const EscrowSkeletonLoader();
              }

              // 2. Error State
              if (controller.errorMessage.value.isNotEmpty && controller.orders.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.loadOrders(refresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsetsDirectional.all(AppSpacing.xl.w),
                    child: EcardoErrorView(
                      title: l10nPick(context, fa: 'خطا در بارگذاری معاملات', en: 'Failed to Load Deals'),
                      message: controller.errorMessage.value,
                      onRetry: () {
                        HapticFeedback.lightImpact();
                        controller.loadOrders(refresh: true);
                      },
                    ),
                  ),
                );
              }

              // 3. Empty State
              if (controller.orders.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.loadOrders(refresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsetsDirectional.all(AppSpacing.xl.w),
                    child: EcardoEmptyState(
                      iconData: Icons.gavel_rounded,
                      title: l10nPick(context, fa: 'معامله امانی یافت نشد', en: 'No Escrow Deals Found'),
                      description: l10nPick(
                        context,
                        fa: 'با ایجاد معامله امانی جدید، وجه معامله تا زمان تایید تحویل کالا نزد پلتفرم با امنیت کامل قفل می‌ماند.',
                        en: 'Create a deal to secure funds until buyer delivery approval.',
                      ),
                      primaryActionLabel: l10nPick(context, fa: 'ایجاد معامله جدید', en: 'New Escrow Deal'),
                      onPrimaryAction: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => const EscrowCreateScreen());
                      },
                    ),
                  ),
                );
              }

              // 4. Content State
              return RefreshIndicator(
                onRefresh: () => controller.loadOrders(refresh: true),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.page.w,
                    AppSpacing.page.h,
                    AppSpacing.page.w,
                    80.h,
                  ),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                  itemBuilder: (ctx, idx) {
                    final deal = controller.orders[idx];
                    return _buildDealCard(context, deal, isDark, primaryAccent);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(
    BuildContext context,
    EscrowOrderModel deal,
    bool isDark,
    Color primaryAccent,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => EscrowDetailScreen(orderId: deal.id));
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
      child: Container(
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
            // Top: Contract No + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: AppSpacing.iconXs.sp,
                      color: primaryAccent,
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Text(
                      deal.contractNo,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                EscrowStatusBadge(status: deal.status, label: deal.statusLabel),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Title
            Text(
              deal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Parties: Buyer / Seller monograms
            Row(
              children: [
                Expanded(
                  child: EscrowCounterpartyAvatar(
                    name: deal.buyer?.name ?? '...',
                    role: l10nPick(context, fa: 'خریدار', en: 'Buyer'),
                    isBuyer: true,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: EscrowCounterpartyAvatar(
                    name: deal.seller?.name ?? '...',
                    role: l10nPick(context, fa: 'فروشنده', en: 'Seller'),
                    isBuyer: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Amount & Currency + View Details CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, fa: 'مبلغ امانی', en: 'Escrow Amount'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      '${deal.amount.toStringAsFixed(0)} ${deal.currency}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: primaryAccent,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10nPick(context, fa: 'مشاهده جزئیات', en: 'View Details'),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
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

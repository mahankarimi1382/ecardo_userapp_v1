import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_ad_card.dart';

/// Modernized P2P Sell Sub-Section.
///
/// Displays verified peer-to-peer sell advertisements with competitive exchange
/// spreads, escrow protection badges, and responsive dark/light theme integration.
/// Adopts [EcardoEmptyState] for empty offer states and enforces minimum 44x44
/// accessible touch targets with full Semantics labelling.
class SellSubSection extends StatelessWidget {
  final P2pController? controller;
  final VoidCallback? onSwitchToBuy;
  final VoidCallback? onCreateAd;

  const SellSubSection({
    super.key,
    this.controller,
    this.onSwitchToBuy,
    this.onCreateAd,
  });

  P2pController get _controller =>
      controller ??
      (Get.isRegistered<P2pController>()
          ? Get.find<P2pController>()
          : Get.put(P2pController()));

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p2pController = _controller;

    return Obx(() {
      final isLoading =
          (p2pController.isMarketplaceLoading.value &&
              p2pController.p2pAds.isEmpty) ||
          p2pController.isCurrenciesLoading.value;

      // 1. Shimmer Loading State
      if (isLoading) {
        return _buildSellShimmer(isDark);
      }

      // 2. Empty State adopting EcardoEmptyState
      if (p2pController.p2pAds.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: AppSpacing.xxl.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EcardoEmptyState(
                  iconData: Icons.sell_outlined,
                  iconColor: AppColors.error,
                  glowColor: AppColors.error,
                  title: l10nPick(
                    context,
                    en: 'No Sell Offers Available',
                    fa: 'آگهی فروشی یافت نشد',
                  ),
                  description: l10nPick(
                    context,
                    en: 'There are currently no active sell advertisements matching your filters. Try adjusting your amount or payment method.',
                    fa: 'در حال حاضر هیچ آگهی فروشی متناسب با فیلترهای انتخابی شما یافت نشد. مبلغ یا روش پرداخت دیگری را انتخاب کنید.',
                  ),
                  primaryActionLabel: l10nPick(
                    context,
                    en: 'Refresh Offers',
                    fa: 'تازه‌سازی آگهی‌ها',
                  ),
                  onPrimaryAction: () {
                    HapticFeedback.lightImpact();
                    p2pController.fetchMarketplaceAds(isRefresh: true);
                  },
                  secondaryActionLabel: l10nPick(
                    context,
                    en: 'Create Ad',
                    fa: 'ایجاد آگهی جدید',
                  ),
                  onSecondaryAction: () {
                    HapticFeedback.lightImpact();
                    if (onCreateAd != null) {
                      onCreateAd!();
                    } else {
                      p2pController.onTopTabSelected(4);
                    }
                  },
                ),
                if (onSwitchToBuy != null) ...[
                  SizedBox(height: AppSpacing.md.h),
                  Semantics(
                    button: true,
                    label: localization.p2pBuy,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 44.w,
                        minHeight: 44.h,
                      ),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.brandViolet,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onSwitchToBuy!();
                        },
                        icon: Icon(Icons.swap_horiz_rounded, size: 18.r),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Browse Buy Offers',
                            fa: 'مشاهده آگهی‌های خرید',
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      // 3. Populated Sell Offers Marketplace List
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 200 &&
              p2pController.hasMoreMarketplaceData.value &&
              !p2pController.isMarketplacePaginationLoading.value) {
            p2pController.loadMoreMarketplaceAds();
          }
          return false;
        },
        child: RefreshIndicator(
          color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          onRefresh: () => p2pController.fetchMarketplaceAds(isRefresh: true),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsetsDirectional.only(
              top: 12.h,
              start: 18.w,
              end: 18.w,
              bottom: 24.h,
            ),
            itemBuilder: (context, index) {
              if (index == p2pController.p2pAds.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandViolet,
                      size: 28.sp,
                    ),
                  ),
                );
              }
              return P2pAdCard(item: p2pController.p2pAds[index]);
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: AppSpacing.cardGap.h);
            },
            itemCount:
                p2pController.p2pAds.length +
                (p2pController.isMarketplacePaginationLoading.value ? 1 : 0),
          ),
        ),
      );
    });
  }

  Widget _buildSellShimmer(bool isDark) {
    final baseColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final highlightColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final dividerColor = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 80.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              Divider(height: 1, color: dividerColor),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 100.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 110.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 70.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm.r,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 90.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

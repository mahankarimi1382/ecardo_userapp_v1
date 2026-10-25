import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_ads/widgets/my_ads_card.dart';

/// Modernized P2P My Ads Sub-Section.
///
/// Manages user-created P2P advertisements with status toggles, real-time volume
/// indicators, and rapid ad creation triggers.
/// Adopts [EcardoEmptyState] for zero-ad states and enforces minimum 44x44
/// accessible touch targets with full Semantics labelling.
class MyAdsSubSection extends StatefulWidget {
  final MyAdsController? controller;
  final VoidCallback? onCreateAd;

  const MyAdsSubSection({super.key, this.controller, this.onCreateAd});

  @override
  State<MyAdsSubSection> createState() => _MyAdsSubSectionState();
}

class _MyAdsSubSectionState extends State<MyAdsSubSection> {
  MyAdsController get _controller =>
      widget.controller ??
      (Get.isRegistered<MyAdsController>()
          ? Get.find<MyAdsController>()
          : Get.put(MyAdsController()));

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreMyAds();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCreateAdTap() {
    HapticFeedback.lightImpact();
    if (widget.onCreateAd != null) {
      widget.onCreateAd!();
    } else {
      Get.toNamed(BaseRoute.p2pTrading, arguments: {'initial_tab': 4});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _controller;

    return Column(
      children: [
        // Top Action Bar with "Create Ad" button
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 18.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Active Advertisements',
                  fa: 'آگهی‌های فعال شما',
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Semantics(
                button: true,
                label: l10nPick(
                  context,
                  en: 'Create New Advertisement',
                  fa: 'ایجاد آگهی جدید',
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: _handleCreateAdTap,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd.r,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.brandViolet,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd.r,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 18.r,
                              color: isDark
                                  ? AppColors.deepBlack
                                  : AppColors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              l10nPick(
                                context,
                                en: 'Create Ad',
                                fa: 'ایجاد آگهی',
                              ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.deepBlack
                                    : AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            // 1. Loading State
            if (controller.isLoading.value && controller.adsList.isEmpty) {
              return _buildMyAdsShimmer(isDark);
            }

            // 2. Empty State adopting EcardoEmptyState
            if (controller.adsList.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: AppSpacing.xxl.h,
                  ),
                  child: EcardoEmptyState(
                    iconData: FluentIcons.megaphone_24_regular,
                    iconColor: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.brandViolet,
                    glowColor: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.brandViolet,
                    title: l10nPick(
                      context,
                      en: 'No P2P Ads Posted Yet',
                      fa: 'هنوز آگهی ثبت نکرده‌اید',
                    ),
                    description: l10nPick(
                      context,
                      en: 'Post your custom buy or sell ad with your preferred pricing, currency limits, and payment methods.',
                      fa: 'آگهی خرید یا فروش اختصاصی خود را با نرخ، سقف مبلغ و روش‌های پرداخت دلخواه منتشر کنید.',
                    ),
                    primaryActionLabel: l10nPick(
                      context,
                      en: 'Create Ad',
                      fa: 'ایجاد آگهی جدید',
                    ),
                    onPrimaryAction: _handleCreateAdTap,
                    secondaryActionLabel: l10nPick(
                      context,
                      en: 'Refresh',
                      fa: 'تازه‌سازی',
                    ),
                    onSecondaryAction: () {
                      HapticFeedback.lightImpact();
                      controller.fetchMyAds(isRefresh: true);
                    },
                  ),
                ),
              );
            }

            // 3. Populated My Ads List
            return RefreshIndicator(
              color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              onRefresh: () => controller.fetchMyAds(isRefresh: true),
              child: ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsetsDirectional.only(
                  start: 18.w,
                  end: 18.w,
                  top: 4.h,
                  bottom: 24.h,
                ),
                itemBuilder: (context, index) {
                  if (index == controller.adsList.length) {
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
                  return MyAdsCard(
                    ad: controller.adsList[index],
                    controller: controller,
                  );
                },
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSpacing.cardGap.h),
                itemCount:
                    controller.adsList.length +
                    (controller.isPaginationLoading.value ? 1 : 0),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMyAdsShimmer(bool isDark) {
    final baseColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final highlightColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        itemCount: 3,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          height: 140.h,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
                    ),
                  ),
                  Container(
                    width: 60.w,
                    height: 20.h,
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
              Container(
                width: 150.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 110.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

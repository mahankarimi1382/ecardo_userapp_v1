import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/model/gift_card_product_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_details_section.dart';

class GiftCardListSection extends StatefulWidget {
  const GiftCardListSection({super.key});

  @override
  State<GiftCardListSection> createState() => _GiftCardListSectionState();
}

class _GiftCardListSectionState extends State<GiftCardListSection> {
  final GiftCardController controller = Get.find<GiftCardController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreGiftCardProducts();
    }
  }

  Future<void> loadData() async {
    controller.isGiftCardLoading.value = true;
    await controller.getGiftCardProducts(isRefresh: true);

    if (!controller.isInitialized.value) {
      await controller.getGiftCardCountry();
      await controller.getGiftCardCategory();
      controller.isInitialized.value = true;
    }

    controller.isGiftCardLoading.value = false;
  }

  Future<void> _onRefresh() async {
    await controller.getGiftCardProducts(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final cardProductList = controller.giftCardProductList;

            // 1. Loading State
            if (controller.isGiftCardLoading.value && cardProductList.isEmpty) {
              return _buildLoadingGrid(isDark);
            }

            // 2. Error State
            if (controller.isGiftCardError.value && cardProductList.isEmpty) {
              return Center(
                child: EcardoErrorView(
                  title: localization.allControllerLoadError,
                  message: 'Could not load gift card catalog. Check your connection.',
                  retryLabel: localization.noInternetConnectionRetryButton,
                  onRetry: loadData,
                ),
              );
            }

            // 3. Empty State
            if (cardProductList.isEmpty) {
              return Center(
                child: EcardoEmptyState(
                  iconData: Icons.card_giftcard_rounded,
                  title: 'No Gift Cards Found',
                  description: 'No brand gift cards match your filter. Try adjusting your search.',
                  primaryActionLabel: localization.noInternetConnectionRetryButton,
                  onPrimaryAction: loadData,
                ),
              );
            }

            // 4. Content State: Grid of Branded Tiles
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: EdgeInsetsDirectional.only(
                  top: AppSpacing.lg.h,
                  start: AppSpacing.lg.w,
                  end: AppSpacing.lg.w,
                  bottom: AppSpacing.xxxl.h,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.lg.w,
                  mainAxisSpacing: AppSpacing.lg.h,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final Content card = cardProductList[index];
                  return _buildBrandTile(context, card, isDark);
                },
                itemCount: cardProductList.length,
              ),
            );
          }),
          Obx(
            () => Visibility(
              visible: controller.isGiftCardLoadingMore.value,
              child: const Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandTile(BuildContext context, Content card, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(
          () => GiftCardDetailsSection(
            giftCardId: card.productId.toString(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : AppColors.mutedBlue.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Gradient Badge
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        imageUrl: card.logoUrls?.first ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 28,
                            color: AppColors.softGray,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Instant Delivery Badge
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                            isDark ? AppColors.mutedBlue : AppColors.darkGray,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 11,
                            color: isDark ? AppColors.deepBlack : Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'DIGITAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.deepBlack : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Product Title & Currency
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.productName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.recipientCurrencyCode ?? 'USD',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.mainSoftBlue
                              : AppColors.mutedBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSecondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(
        top: AppSpacing.lg.h,
        start: AppSpacing.lg.w,
        end: AppSpacing.lg.w,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.lg.w,
        mainAxisSpacing: AppSpacing.lg.h,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

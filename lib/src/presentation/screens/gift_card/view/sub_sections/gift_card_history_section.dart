import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/model/gift_card_history_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_details.dart';

class GiftCardHistorySection extends StatefulWidget {
  const GiftCardHistorySection({super.key});

  @override
  State<GiftCardHistorySection> createState() => _GiftCardHistorySectionState();
}

class _GiftCardHistorySectionState extends State<GiftCardHistorySection>
    with WidgetsBindingObserver {
  final GiftCardHistoryController controller = Get.find<GiftCardHistoryController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMorePages.value &&
        !controller.isPageLoading.value) {
      controller.loadMoreGiftCardHistory();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchGiftCardHistory();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchGiftCardHistory();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final giftCardList =
          controller.giftCardHistoryModel.value.data?.giftCards ?? [];

      // 1. Loading State
      if (controller.isLoading.value && giftCardList.isEmpty) {
        return const Expanded(child: CommonLoading());
      }

      // 2. Error State
      if (controller.isError.value && giftCardList.isEmpty) {
        return Expanded(
          child: Center(
            child: EcardoErrorView(
              title: localization.allControllerLoadError,
              message: 'Could not load your purchased gift card history.',
              retryLabel: localization.noInternetConnectionRetryButton,
              onRetry: loadData,
            ),
          ),
        );
      }

      // 3. Empty State
      if (giftCardList.isEmpty) {
        return Expanded(
          child: Center(
            child: EcardoEmptyState(
              iconData: Icons.history_rounded,
              title: 'No Purchased Gift Cards',
              description: 'You have not purchased any brand gift cards yet.',
              primaryActionLabel: localization.noInternetConnectionRetryButton,
              onPrimaryAction: loadData,
            ),
          ),
        );
      }

      // 4. Content State
      return Expanded(
        child: Stack(
          children: [
            RefreshIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
              onRefresh: refreshData,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: EdgeInsetsDirectional.only(
                  top: AppSpacing.lg.h,
                  start: AppSpacing.lg.w,
                  end: AppSpacing.lg.w,
                  bottom: AppSpacing.xxxl.h,
                ),
                itemBuilder: (context, index) {
                  final GiftCards giftCard = giftCardList[index];
                  DateTime? parsedDate = DateTime.tryParse(giftCard.createdAt ?? '');
                  if (parsedDate == null && giftCard.createdAt != null) {
                    try {
                      parsedDate = DateFormat('dd MMM yyyy hh:mm a').parse(giftCard.createdAt!);
                    } catch (_) {}
                  }
                  final formattedDate = parsedDate != null
                      ? DateFormat('MMM dd, yyyy').format(parsedDate)
                      : (giftCard.createdAt ?? '');

                  return GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        GiftCardHistoryDetails(giftCard: giftCard),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md.r),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder.withValues(alpha: 0.7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : AppColors.mutedBlue.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: CachedNetworkImage(
                              width: 48.w,
                              height: 48.w,
                              imageUrl: giftCard.productThumbnail ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
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
                                  size: 24,
                                  color: AppColors.softGray,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  giftCard.productName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formattedDate,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                giftCard.totalPrice ?? '',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.lightPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSecondaryContainer,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                                ),
                                child: Text(
                                  localization.giftCardHistoryQtyLabel(
                                    giftCard.quantity.toString(),
                                  ),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: AppSpacing.md.h);
                },
                itemCount: giftCardList.length,
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.isGiftCardHistoryLoading.value ||
                    controller.isPageLoading.value,
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
    });
  }
}

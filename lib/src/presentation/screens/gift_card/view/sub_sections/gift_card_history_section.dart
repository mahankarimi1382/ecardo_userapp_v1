import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_history_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_details.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class GiftCardHistorySection extends StatefulWidget {
  const GiftCardHistorySection({super.key});

  @override
  State<GiftCardHistorySection> createState() => _GiftCardHistorySectionState();
}

class _GiftCardHistorySectionState extends State<GiftCardHistorySection>
    with WidgetsBindingObserver {
  final GiftCardHistoryController controller = Get.find();
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

    return Obx(() {
      final giftCardList =
          controller.giftCardHistoryModel.value.data?.giftCards ?? [];

      if (controller.isLoading.value) {
        return Expanded(child: CommonLoading());
      }

      if (giftCardList.isEmpty) {
        return Expanded(child: NoDataFound());
      }

      return Expanded(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => refreshData(),
              child: controller.isLoading.value
                  ? CommonLoading()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsetsDirectional.only(
                        top: 30.h,
                        start: 18.w,
                        end: 18.w,
                        bottom: 30.h,
                      ),
                      itemBuilder: (context, index) {
                        final GiftCards giftCard = giftCardList[index];

                        return GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                              GiftCardHistoryDetails(giftCard: giftCard),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.lightTextPrimary.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: CachedNetworkImage(
                                    width: 50.w,
                                    height: 50.w,
                                    imageUrl: giftCard.productThumbnail ?? "",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        color: AppColors.lightPrimary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      size: 20.w,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              giftCard.productName ?? "",
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                letterSpacing: 0,
                                                fontSize: 13.sp,
                                                color:
                                                    AppColors.lightTextPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              DateFormat('MMM dd, yyyy').format(
                                                DateFormat(
                                                  'dd MMM yyyy hh:mm a',
                                                ).parse(giftCard.createdAt!),
                                              ),
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                letterSpacing: 0,
                                                fontSize: 11.sp,
                                                color:
                                                    AppColors.lightTextTertiary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              giftCard.totalPrice ?? "",
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                letterSpacing: 0,
                                                fontSize: 14.sp,
                                                color:
                                                    AppColors.lightTextPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              localization.giftCardHistoryQtyLabel(
                                                giftCard.quantity.toString(),
                                              ),
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                letterSpacing: 0,
                                                fontSize: 10.sp,
                                                color: AppColors
                                                    .lightTextPrimary
                                                    .withValues(alpha: 0.80),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 14.h);
                      },
                      itemCount: giftCardList.length,
                    ),
            ),
            Visibility(
              visible:
                  controller.isGiftCardHistoryLoading.value ||
                  controller.isPageLoading.value,
              child: const CommonLoading(),
            ),
          ],
        ),
      );
    });
  }
}

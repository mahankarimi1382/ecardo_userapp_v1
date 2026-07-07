import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_product_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_details_section.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class GiftCardListSection extends StatefulWidget {
  const GiftCardListSection({super.key});

  @override
  State<GiftCardListSection> createState() => _GiftCardListSectionState();
}

class _GiftCardListSectionState extends State<GiftCardListSection> {
  final GiftCardController controller = Get.find();
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
    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final cardProductList = controller.giftCardProductList;

            if (controller.isGiftCardLoading.value && cardProductList.isEmpty) {
              return CommonLoading();
            }

            if (cardProductList.isEmpty) {
              return NoDataFound();
            }

            return RefreshIndicator(
              onRefresh: () => _onRefresh(),
              color: AppColors.lightPrimary,
              child: GridView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: EdgeInsetsDirectional.only(
                  top: 20.h,
                  start: 18.w,
                  end: 18.w,
                  bottom: 30.h,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.w,
                  mainAxisSpacing: 18.h,
                ),
                itemBuilder: (context, index) {
                  final Content card = cardProductList[index];
                  return GestureDetector(
                    onTap: () => Get.to(
                      GiftCardDetailsSection(
                        giftCardId: card.productId.toString(),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(
                            0xFF303030,
                          ).withValues(alpha: 0.16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: card.logoUrls?.first ?? '',
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
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              12.w,
                              10.h,
                              12.w,
                              12.h,
                            ),
                            child: Text(
                              card.productName ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: cardProductList.length,
              ),
            );
          }),
          Obx(
            () => Visibility(
              visible: controller.isGiftCardLoadingMore.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}

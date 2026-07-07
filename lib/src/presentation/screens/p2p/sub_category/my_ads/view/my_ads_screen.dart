import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/widgets/my_ads_card.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final MyAdsController controller = Get.put(MyAdsController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreMyAds();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CommonLoading();
            }

            return RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => controller.fetchMyAds(isRefresh: true),
              child: controller.adsList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [SizedBox(height: 120), NoDataFound()],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 2.h,
                      ),
                      itemBuilder: (context, index) {
                        if (index == controller.adsList.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: AppColors.lightPrimary,
                                size: 32.sp,
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
                          SizedBox(height: 14.h),
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
}

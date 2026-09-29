import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/controller/my_order_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/widgets/my_order_card.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final MyOrderController controller = Get.put(MyOrderController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreMyOrders();
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const CommonLoading();
      }

      // QA-2026-09-29 (p2p states): failed load shows an Error+Retry state —
      // never the Empty view.
      if (controller.ordersLoadError.value.isNotEmpty &&
          controller.orderList.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            Icon(Icons.cloud_off_rounded, size: 48.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                controller.ordersLoadError.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Center(
              child: TextButton.icon(
                onPressed: () => controller.fetchMyOrders(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  AppLocalizations.of(context)!.commonRetry,
                ),
              ),
            ),
          ],
        );
      }

      return RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: () => controller.fetchMyOrders(isRefresh: true),
        child: controller.orderList.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 120), NoDataFound()],
              )
            : ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 2.h),
                itemBuilder: (context, index) {
                  if (index == controller.orderList.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.lightPrimary,
                          size: 32.sp,
                        ),
                      ),
                    );
                  }
                  return MyOrderCard(order: controller.orderList[index]);
                },
                separatorBuilder: (_, _) => SizedBox(height: 14.h),
                itemCount: controller.orderList.length +
                    (controller.isPaginationLoading.value ? 1 : 0),
              ),
      );
    });
  }
}


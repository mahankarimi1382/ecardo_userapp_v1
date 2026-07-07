import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_action_buttons_widget.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_timeline_section_widget.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_title_block_widget.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_trader_header_widget.dart';

import '../sub_category/my_order/chat/view/order_chat_screen.dart';

class P2pOrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const P2pOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.put(
      P2pOrderDetailsController(orderId: orderId),
      tag: 'order_details_$orderId',
    );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.orderData.value == null) {
          return const CommonLoading();
        }

        final data = controller.orderData.value;
        if (data == null) {
          return Center(
            child: Text(
              localization.p2pNoOrderDetailsFound,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        final user = data.role?.isBuyer == true
            ? data.role?.seller
            : data.role?.buyer;
        final userName = user?.name ?? user?.username ?? '--';
        final avatarText = userName.isNotEmpty
            ? userName.substring(0, 1).toUpperCase()
            : 'U';

        return Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: localization.p2pOrderDetails,
              isBackLogicApply: true,
              backLogicFunction: Get.back,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderDetailsTraderHeaderWidget(
                      avatarText: avatarText,
                      name: userName,
                      isVerified: user?.isVerifiedTrader ?? false,
                      onTap: () => Get.to(
                        () => OrderChatScreen(
                          orderId: orderId.toString(),
                          role: data.role!,
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    OrderDetailsTitleBlockWidget(
                      data: data,
                      controller: controller,
                    ),
                    SizedBox(height: 22.h),
                    OrderDetailsTimelineSectionWidget(
                      data: data,
                      controller: controller,
                    ),
                    SizedBox(height: 24.h),
                    OrderDetailsActionButtonsWidget(
                      data: data,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

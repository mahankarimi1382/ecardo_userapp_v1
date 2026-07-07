import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class ToolBarSection extends StatelessWidget {
  const ToolBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Get.find<HomeController>().openDrawer(),
          child: Image.asset(PngAssets.menuCommonIcon, width: 35),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(BaseRoute.notifications);
              },
              child: Badge(
                backgroundColor: AppColors.success,
                smallSize:
                    Get.find<HomeController>()
                            .dashboardModel
                            .value
                            .data!
                            .info!
                            .unreadNotificationsCount !=
                        0
                    ? 8
                    : 0,
                child: Image.asset(PngAssets.commonNotificationIcon, width: 30),
              ),
            ),
            SizedBox(width: 10),
            Obx(
              () => GestureDetector(
                onTap: () => Get.find<HomeController>().openEndDrawer(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    Get.find<HomeController>()
                        .dashboardModel
                        .value
                        .data!
                        .user!
                        .avatarPath!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        PngAssets.profileImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

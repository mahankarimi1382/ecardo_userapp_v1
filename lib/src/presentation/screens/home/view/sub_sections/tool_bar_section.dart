import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class ToolBarSection extends StatelessWidget {
  const ToolBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    // v1.0.40 (crash fix): the toolbar force-unwrapped dashboard data!
    .info! / .user!.avatarPath! — a failed dashboard fetch or a user
    // without an avatar crashed the ENTIRE home screen. Resolve
    // defensively with safe fallbacks instead.
    final homeController = Get.find<HomeController>();
    final info = homeController.dashboardModel.value.data?.info;
    final user = homeController.dashboardModel.value.data?.user;
    final unread = info?.unreadNotificationsCount ?? 0;
    final avatarPath = user?.avatarPath;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => homeController.openDrawer(),
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
                smallSize: unread != 0 ? 8 : 0,
                child: Image.asset(PngAssets.commonNotificationIcon, width: 30),
              ),
            ),
            SizedBox(width: 10),
            // v1.0.40: the Obx wrapper was dropped — nothing observable was
            // read inside after the defensive refactor, and GetX throws on
            // an Rx-less Obx. The avatar refreshes with the parent rebuild.
            GestureDetector(
              onTap: () => homeController.openEndDrawer(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: (avatarPath ?? '').isNotEmpty
                    ? Image.network(
                        avatarPath!,
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
                      )
                    : Image.asset(
                        PngAssets.profileImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

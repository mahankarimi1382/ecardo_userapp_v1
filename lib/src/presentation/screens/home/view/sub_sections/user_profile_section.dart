import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/tool_bar_section.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final HomeController homeController = Get.find<HomeController>();

    return Column(
      children: [
        SizedBox(height: 60),
        ToolBarSection(),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(PngAssets.homeUserShape),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.userProfileHello,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 15,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    homeController
                            .dashboardModel
                            .value
                            .data!
                            .info!
                            .timeWiseWish ??
                        "",
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 15,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    homeController.dashboardModel.value.data!.user!.userName ??
                        "",
                    maxLines: 2,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 30,
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 5),
                        child: Text(
                          "${localization.userProfileUid} ${homeController.dashboardModel.value.data!.user!.accountNumber}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: homeController
                                .dashboardModel
                                .value
                                .data!
                                .user!
                                .accountNumber!,
                          ),
                        );
                        ToastHelper().showSuccessToast(
                          localization.userProfileCopied,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          PngAssets.copyCommonIcon,
                          width: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 65),
      ],
    );
  }
}

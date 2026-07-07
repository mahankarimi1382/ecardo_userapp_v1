import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_code_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/gift_history_filter_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class GiftCodeHeaderSection extends StatelessWidget {
  const GiftCodeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final GiftCodeController controller = Get.find();
    final HomeController homeController = Get.find();

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localizations.giftCodeHeaderTitle,
                isBackLogicApply: true,
                backLogicFunction: () {
                  if (homeController.selectedIndex.value == 2) {
                    Get.delete<GiftCodeController>();
                    Get.delete<GiftRedeemController>();
                    Get.delete<GiftHistoryController>();
                    Get.delete<CreateGiftController>();
                    homeController.selectedIndex.value = 0;
                  } else if (homeController.selectedIndex.value == 0) {
                    Get.delete<GiftCodeController>();
                    Get.delete<GiftRedeemController>();
                    Get.delete<GiftHistoryController>();
                    Get.delete<CreateGiftController>();
                    Get.back();
                  }
                },
                rightSideWidget: controller.selectedScreen.value == 1
                    ? GestureDetector(
                        onTap: () {
                          Get.bottomSheet(GiftHistoryFilterBottomSheet());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsetsDirectional.only(end: 18),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Image.asset(PngAssets.commonGiftFilterIcon),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(end: 18),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _buildHistoryNavigation();
                          },
                          icon: Icon(Icons.more_vert),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          controller.selectedScreen.value = 0;
                        },
                        width: double.infinity,

                        text: localizations.giftCodeHeaderGiftRedeem,
                        fontSize: 15,
                        backgroundColor: controller.selectedScreen.value == 0
                            ? AppColors.lightPrimary
                            : AppColors.white,
                        textColor: controller.selectedScreen.value == 0
                            ? AppColors.white
                            : AppColors.lightTextPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          controller.selectedScreen.value = 1;
                        },
                        width: double.infinity,

                        text: localizations.giftCodeHeaderMyGift,
                        fontSize: 15,
                        backgroundColor: controller.selectedScreen.value != 0
                            ? AppColors.lightPrimary
                            : AppColors.white,
                        textColor: controller.selectedScreen.value != 0
                            ? AppColors.white
                            : AppColors.lightTextPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _buildHistoryNavigation() {
    final localizations = AppLocalizations.of(Get.context!)!;
    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final items = [localizations.giftCodeHeaderGiftRedeemHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();

                        if (index == 0) {
                          Get.toNamed(BaseRoute.giftRedeemHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          items[index],
                          style: TextStyle(
                            letterSpacing: 0,
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_filter_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_filter_bottom_sheet.dart';

class GiftCardHeaderSection extends StatelessWidget {
  const GiftCardHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final GiftCardController controller = Get.find();
    final localization = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localization.giftCardHeaderTitle,
                isBackLogicApply: true,
                backLogicFunction: () => Get.back(),
                rightSideWidget:
                    controller.selectedScreen.value == 0 ||
                        controller.selectedScreen.value == 1
                    ? GestureDetector(
                        onTap: controller.selectedScreen.value == 0
                            ? () {
                                Get.bottomSheet(GiftCardFilterBottomSheet());
                              }
                            : controller.selectedScreen.value == 1
                            ? () {
                                Get.bottomSheet(
                                  GiftCardHistoryFilterBottomSheet(),
                                );
                              }
                            : null,

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
                    : null,
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
                        onPressed: () async {
                          controller.selectedScreen.value = 0;
                          controller.clearInitialData();
                        },
                        width: double.infinity,

                        text: localization.giftCardHeaderTabCards,
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

                        text: localization.giftCardHeaderTabHistory,
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_history_filter_bottom_sheet.dart';

import '../../../../../../l10n/app_localizations.dart';

class PaymentLinksHeaderSection extends StatelessWidget {
  const PaymentLinksHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final PaymentLinksController controller = Get.find();

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localizations.paymentLinksAppBarTitle,
                isBackLogicApply: true,
                backLogicFunction: () => Get.back(),
                rightSideWidget: controller.selectedScreen.value == 0
                    ? GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            PaymentLinksHistoryFilterBottomSheet(),
                          );
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
                        onPressed: () {
                          controller.selectedScreen.value = 0;
                        },
                        width: double.infinity,

                        text: localizations.paymentLinksTabList,
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

                        text: localizations.paymentLinksTabCreate,
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

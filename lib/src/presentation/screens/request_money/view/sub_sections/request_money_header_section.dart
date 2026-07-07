import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';

class RequestMoneyHeaderSection extends StatelessWidget {
  const RequestMoneyHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();
    final localization = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localization.requestMoneyHeaderSectionTitle,
                backLogicFunction: () async {
                  Get.offNamed(BaseRoute.navigation);
                },
                isBackLogicApply: true,
                rightSideWidget: controller.currentStep.value == 0
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: 18),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _buildHistoryNavigation(context);
                          },
                          icon: Icon(Icons.more_vert),
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

                        text: localization
                            .requestMoneyHeaderSectionRequestMoneyButton,
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

                        text: localization
                            .requestMoneyHeaderSectionReceivedRequestButton,
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

  void _buildHistoryNavigation(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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
                  final items = [localization.requestMoneyHeaderSectionHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();

                        if (index == 0) {
                          Get.toNamed(BaseRoute.requestMoneyHistory);
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

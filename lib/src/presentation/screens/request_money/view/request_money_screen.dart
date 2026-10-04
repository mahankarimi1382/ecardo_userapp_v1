import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/received_request/received_request.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_section.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final RequestMoneyController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchWallets();
    controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Obx(
              () => Container(
                height: controller.selectedScreen.value == 0
                    ? null
                    : double.infinity,
                decoration: controller.selectedScreen.value == 0
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.darkSurfaceVariant,
                                  AppColors.darkBackground,
                                ]
                              : [
                                  AppColors.white,
                                  AppColors.lightBackground,
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 0.5],
                        ),
                      )
                    : BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                      ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CommonLoading();
                  }

                  if (controller.selectedScreen.value == 0) {
                    return Column(
                      children: [
                        controller.currentStep.value == 0
                            ? const RequestMoneyHeaderSection()
                            : controller.currentStep.value == 2
                            ? const SizedBox.shrink()
                            : Container(
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 60),
                                    CommonAppBar(
                                      title:
                                          localization.requestMoneyScreenTitle,
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                              ),
                        const Expanded(child: RequestMoneySection()),
                      ],
                    );
                  } else {
                    return const ReceivedRequest();
                  }
                }),
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.isRequestMoneyLoading.value,
                child: const CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/view/sub_sections/transfer_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/view/sub_sections/transfer_success_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/view/sub_sections/transfer_wallet_section.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TransferController controller = Get.put(TransferController());
  final HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    if (!controller.isInitialized.value) {
      controller.currentStep.value = 0;
      controller.clearFields();
      controller.isRecipientUidFocused.value = false;
      controller.isAmountFocused.value = false;
      controller.fetchTransferWallets();
      controller.fetchUser();
      controller.isInitialized.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return PopScope(
      canPop: homeController.selectedIndex.value != 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && homeController.selectedIndex.value == 1) {
          Get.delete<TransferController>();
          Get.delete<CreateBeneficiaryController>();
          homeController.selectedIndex.value = 0;
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                Obx(
                  () => Visibility(
                    visible:
                        controller.currentStep.value == 0 ||
                        controller.currentStep.value == 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Obx(
                          () => CommonAppBar(
                            title: localization.transferScreenTitle,
                            rightSideWidget: controller.currentStep.value == 0
                                ? Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8,
                                    ),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _buildHistoryNavigation();
                                      },
                                      icon: Icon(Icons.more_vert),
                                    ),
                                  )
                                : null,
                            isBackLogicApply: true,
                            backLogicFunction: () {
                              if (homeController.selectedIndex.value == 1) {
                                Get.delete<TransferController>();
                                Get.delete<CreateBeneficiaryController>();
                                homeController.selectedIndex.value = 0;
                              } else if (homeController.selectedIndex.value ==
                                  0) {
                                Get.delete<TransferController>();
                                Get.delete<CreateBeneficiaryController>();
                                Get.back();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return CommonLoading();
                    }

                    return controller.currentStep.value == 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                TransferWalletSection(),
                                SizedBox(height: 30),
                                TransferAmountStepSection(),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? TransferReviewStepSection()
                        : controller.currentStep.value == 2
                        ? TransferSuccessStepSection()
                        : SizedBox();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isTransferAmountLoading.value ||
                    controller.isBeneficiaryLoading.value,
                child: CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildHistoryNavigation() {
    final localization = AppLocalizations.of(context)!;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 12),
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
                itemCount: 2,
                itemBuilder: (context, index) {
                  final items = [
                    localization.transferHistoryTransferHistory,
                    localization.transferHistoryReceivedHistory,
                  ];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();

                        if (index == 0) {
                          Get.toNamed(BaseRoute.transferHistory);
                        } else if (index == 1) {
                          Get.toNamed(BaseRoute.transferReceivedHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
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

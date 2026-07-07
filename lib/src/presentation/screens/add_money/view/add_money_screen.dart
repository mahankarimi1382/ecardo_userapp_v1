import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/view/sub_sections/add_money_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/view/sub_sections/add_money_pending_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/view/sub_sections/add_money_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/view/sub_sections/add_money_success_step_section.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final AddMoneyController controller = Get.put(AddMoneyController());
  final String walletId = Get.arguments?["wallet_id"] ?? "";

  @override
  void initState() {
    super.initState();
    walletId.isNotEmpty
        ? controller.findWallet(walletIdQuery: walletId.toString())
        : loadData();
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchWallets();
    await controller.fetchUser();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
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
                            title: localizations.addMoneyTitle,
                            backLogicFunction: () async {
                              Get.offNamed(BaseRoute.navigation);
                            },
                            isBackLogicApply: true,
                            rightSideWidget: controller.currentStep.value == 0
                                ? GestureDetector(
                                    onTap: () =>
                                        Get.toNamed(BaseRoute.addMoneyHistory),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        end: 18,
                                      ),
                                      child: Image.asset(
                                        PngAssets.commonHistoryIcon,
                                        width: 30,
                                      ),
                                    ),
                                  )
                                : null,
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
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 18,
                            ),
                            child: Column(
                              children: [
                                _buildWallet(),
                                SizedBox(height: 30),
                                AddMoneyAmountStepSection(),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? AddMoneyReviewStepSection()
                        : controller.currentStep.value == 2
                        ? controller.gatewayMethod.value!.type == "auto"
                              ? AddMoneySuccessStepSection()
                              : AddMoneyPendingStepSection()
                        : SizedBox();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isGatewayMethodsLoading.value ||
                    controller.isPaymentLoading.value,
                child: CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallet() {
    final localization = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        Get.bottomSheet(
          CommonDropdownWalletBottomSheet(
            notFoundText: localization.addMoneyWalletsNotFound,
            dropdownItems: controller.walletsList,
            bottomSheetHeight: 450,
            currentlySelectedValue: controller.wallet.value!.name,
            onItemSelected: (value) async {
              final selectedWallet = controller.walletsList.firstWhere(
                (w) => w.name == value,
              );
              controller.wallet.value = selectedWallet;
              controller.gatewayMethod.value = GatewayMethodsData();
              controller.gatewayController.clear();
              controller.dynamicFieldControllers.clear();
              controller.selectedImages.clear();
              await controller.fetchGatewayMethods(isSetUpLoading: true);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(PngAssets.addMoneyFrame),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                controller.wallet.value!.isDefault == true
                    ? Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          controller.wallet.value!.symbol!,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.network(
                          controller.wallet.value!.icon!,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              PngAssets.commonErrorIcon,
                              color: AppColors.error.withValues(alpha: 0.7),
                            );
                          },
                        ),
                      ),
                SizedBox(width: 10),
                Text(
                  controller.wallet.value!.name!,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 16),
                Image.asset(PngAssets.commonArrowDownIcon, width: 16),
              ],
            ),
            SizedBox(height: 20),
            Text(
              localization.addMoneyBalance,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "${controller.wallet.value!.formattedBalance} ${controller.wallet.value!.code}",
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

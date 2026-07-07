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
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/view/sub_sections/make_payment_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/view/sub_sections/make_payment_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/view/sub_sections/make_payment_success_step_section.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final MakePaymentController controller = Get.find();
  final String midAccount = Get.arguments?['mid_account'] ?? '';

  @override
  void initState() {
    super.initState();
    loadData();
    controller.merchantMidController.text = midAccount;
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchWallets();
    await controller.fetchUser();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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
                            title: localization.makePaymentScreenTitle,
                            backLogicFunction: () async {
                              Get.offNamed(BaseRoute.navigation);
                            },
                            isBackLogicApply: true,
                            rightSideWidget: controller.currentStep.value == 0
                                ? GestureDetector(
                                    onTap: () => Get.toNamed(
                                      BaseRoute.makePaymentHistory,
                                    ),
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
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: _buildWallet(),
                                ),
                                const SizedBox(height: 30),
                                Container(
                                  margin: EdgeInsetsDirectional.symmetric(
                                    horizontal: 18,
                                  ),
                                  padding: EdgeInsetsDirectional.only(
                                    start: 20,
                                    end: 20,
                                    top: 2,
                                  ),
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height *
                                        0.8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadiusDirectional.only(
                                      topStart: Radius.circular(30),
                                      topEnd: Radius.circular(30),
                                    ),
                                  ),
                                  child: const MakePaymentAmountStepSection(),
                                ),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? const MakePaymentReviewStepSection()
                        : controller.currentStep.value == 2
                        ? const MakePaymentSuccessStepSection()
                        : const SizedBox();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isMakePaymentLoading.value ||
                    controller.isPaymentSettingsLoading.value ||
                    controller.isBeneficiaryLoading.value,
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
            notFoundText: localization.makePaymentScreenWalletsNotFound,
            dropdownItems: controller.paymentWalletsList,
            bottomSheetHeight: 450,
            currentlySelectedValue: controller.wallet.value!.name,
            onItemSelected: (value) async {
              final selectedWallet = controller.paymentWalletsList.firstWhere(
                (w) => w.name == value,
              );
              controller.wallet.value = selectedWallet;
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
              localization.makePaymentScreenBalance,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';

class MakePaymentSuccessStepSection extends StatefulWidget {
  const MakePaymentSuccessStepSection({super.key});

  @override
  State<MakePaymentSuccessStepSection> createState() =>
      _MakePaymentSuccessStepSectionState();
}

class _MakePaymentSuccessStepSectionState
    extends State<MakePaymentSuccessStepSection> {
  final MakePaymentController controller = Get.find();
  final settingsService = Get.find<SettingsService>();
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    totalCalculate();
  }

  void totalCalculate() {
    final amountRaw =
        controller.successPaymentData.value?["transaction"]?["amount"];
    final chargeRaw =
        controller.successPaymentData.value?["transaction"]?["charge"];

    double amount = double.tryParse(amountRaw.toString()) ?? 0.0;
    double charge = double.tryParse(chargeRaw.toString()) ?? 0.0;

    totalAmount = amount + charge;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.name!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    return Obx(
      () => controller.isMakePaymentLoading.value
          ? CommonLoading()
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      height: 192,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(PngAssets.pendingAndSuccessFrame),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(PngAssets.commonSuccessIcon, width: 80),
                          SizedBox(height: 16),
                          Text(
                            textAlign: TextAlign.center,
                            localization.makePaymentSuccessStepSectionTitle,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildSuccessDynamicContent(
                            title: localization
                                .makePaymentSuccessStepSectionAmount,
                            content:
                                "${double.tryParse(controller.amountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization
                                .makePaymentSuccessStepSectionTransactionId,
                            content: controller
                                .successPaymentData
                                .value!["transaction"]["tnx"],
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildSuccessDynamicContent(
                              title: localization
                                  .makePaymentSuccessStepSectionWalletName,
                              content: controller.wallet.value!.name!,
                              contentColor: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildSuccessDynamicContent(
                              title: localization
                                  .makePaymentSuccessStepSectionPaymentMethod,
                              content: controller.wallet.value!.code!,
                              contentColor: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildSuccessDynamicContent(
                              title: localization
                                  .makePaymentSuccessStepSectionCharge,
                              content:
                                  "${double.tryParse(controller.successPaymentData.value!["transaction"]["charge"].toString())!.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",

                              contentColor: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title:
                                localization.makePaymentSuccessStepSectionType,
                            content: controller
                                .successPaymentData
                                .value!["transaction"]["type"],
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildSuccessDynamicContent(
                              title: localization
                                  .makePaymentSuccessStepSectionFinalAmount,
                              content:
                                  "${totalAmount.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                              contentColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    CommonButton(
                      onPressed: () async {
                        controller.currentStep.value = 0;
                        controller.clearFields();
                        controller.isLoading.value = true;
                        await controller.fetchWallets();
                        controller.isLoading.value = false;
                      },
                      width: double.infinity,

                      text: localization
                          .makePaymentSuccessStepSectionPaymentAgainButton,
                    ),
                    const SizedBox(height: 20),
                    CommonButton(
                      onPressed: () async {
                        Get.delete<MakePaymentController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization
                          .makePaymentSuccessStepSectionBackHomeButton,
                      backgroundColor: AppColors.lightPrimary.withValues(
                        alpha: 0.06,
                      ),
                      borderColor: AppColors.lightPrimary.withValues(
                        alpha: 0.60,
                      ),
                      borderWidth: 2,
                      textColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  static Widget _buildSuccessDynamicContent({
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: contentColor,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

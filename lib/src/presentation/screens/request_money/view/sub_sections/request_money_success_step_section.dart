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
import 'package:qunzo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';

class RequestMoneySuccessStepSection extends StatefulWidget {
  const RequestMoneySuccessStepSection({super.key});

  @override
  State<RequestMoneySuccessStepSection> createState() =>
      _RequestMoneySuccessStepSectionState();
}

class _RequestMoneySuccessStepSectionState
    extends State<RequestMoneySuccessStepSection> {
  final RequestMoneyController controller = Get.find();
  final SettingsService settingsService = Get.find();

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
      () => controller.isRequestMoneyLoading.value
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
                            localization.requestMoneySuccessStepSectionTitle,
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
                                .requestMoneySuccessStepSectionAmount,
                            content:
                                "${double.tryParse(controller.requestAmountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
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
                                .requestMoneySuccessStepSectionRecipientName,
                            content: controller
                                .successPaymentData
                                .value!["request"]["recipient"]["name"],
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
                                .requestMoneySuccessStepSectionRequestWalletName,
                            content: controller
                                .successPaymentData
                                .value!["request"]["requester_wallet_currency_name"],
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
                                .requestMoneySuccessStepSectionCharge,
                            content:
                                "${double.tryParse(controller.successPaymentData.value!["request"]["charge"].toString())!.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: AppColors.error,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization
                                .requestMoneySuccessStepSectionFinalAmount,
                            content:
                                "${double.tryParse(controller.successPaymentData.value!["request"]["final_amount"].toString())!.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: AppColors.success,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localization
                                      .requestMoneySuccessStepSectionStatus,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.lightTextPrimary
                                        .withValues(alpha: 0.60),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    color: AppColors.warning.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                  child: Text(
                                    () {
                                      final status =
                                          (controller
                                                      .successPaymentData
                                                      .value!["request"]["status"] ??
                                                  "")
                                              .toString()
                                              .toLowerCase();
                                      return status.isNotEmpty
                                          ? status[0].toUpperCase() +
                                                status.substring(1)
                                          : "";
                                    }(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                      fontSize: 13,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
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
                        await controller.fetchWallets();
                      },
                      width: double.infinity,

                      text: localization
                          .requestMoneySuccessStepSectionRequestAgainButton,
                    ),
                    const SizedBox(height: 20),
                    CommonButton(
                      onPressed: () async {
                        Get.delete<RequestMoneyController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization
                          .requestMoneySuccessStepSectionBackHomeButton,
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

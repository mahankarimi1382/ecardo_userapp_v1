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
import 'package:qunzo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';

class ExchangeSuccessStepSection extends StatefulWidget {
  const ExchangeSuccessStepSection({super.key});

  @override
  State<ExchangeSuccessStepSection> createState() =>
      _ExchangeSuccessStepSectionState();
}

class _ExchangeSuccessStepSectionState
    extends State<ExchangeSuccessStepSection> {
  final ExchangeController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.toWallet.value!.code!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto:
          controller.successExchangeData.value!["transaction"]["is_crypto"],
    );

    return Obx(
      () => controller.isExchangeWalletLoading.value
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
                            localization.exchangeSuccessTitle,
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
                            title: localization.exchangeSuccessAmount,
                            content:
                                "${double.tryParse(controller.amountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.successExchangeData.value!["transaction"]["pay_currency"]}",
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessTransactionId,
                            content: controller
                                .successExchangeData
                                .value!["transaction"]["tnx"],
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessPayAmount,
                            content:
                                "${double.tryParse(controller.successExchangeData.value!["transaction"]["pay_amount"].toString())!.toStringAsFixed(calculateDecimals)} "
                                "${controller.successExchangeData.value!["transaction"]["pay_currency"]}",
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessConvertedAmount,
                            content:
                                "${double.tryParse(controller.successExchangeData.value!["transaction"]["amount"].toString())?.toStringAsFixed(calculateDecimals)} "
                                "(${controller.successExchangeData.value!["transaction"]["receive_currency"]})",
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessCharge,
                            content:
                                "${double.tryParse(controller.successExchangeData.value!["transaction"]["charge"].toString())?.toStringAsFixed(calculateDecimals)} ${controller.successExchangeData.value!["transaction"]["pay_currency"]}",
                            contentColor: AppColors.error,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessDate,
                            content: controller
                                .successExchangeData
                                .value!["transaction"]["created_at"],
                            contentColor: AppColors.lightTextPrimary,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.exchangeSuccessFinalAmount,
                            content:
                                "${double.tryParse(controller.successExchangeData.value!["transaction"]["final_amount"].toString())?.toStringAsFixed(calculateDecimals)} ${controller.successExchangeData.value!["transaction"]["pay_currency"]}",
                            contentColor: AppColors.lightTextPrimary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    CommonButton(
                      onPressed: () async {
                        controller.currentStep.value = 0;
                        controller.clearFields();
                      },
                      width: double.infinity,

                      text: localization.exchangeSuccessExchangeAgain,
                    ),
                    const SizedBox(height: 20),
                    CommonButton(
                      onPressed: () async {
                        Get.delete<ExchangeController>();
                        Get.toNamed(BaseRoute.navigation);
                      },
                      width: double.infinity,
                      text: localization.exchangeSuccessBackHome,
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

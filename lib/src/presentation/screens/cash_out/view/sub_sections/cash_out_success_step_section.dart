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
import 'package:qunzo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class CashOutSuccessStepSection extends StatefulWidget {
  const CashOutSuccessStepSection({super.key});

  @override
  State<CashOutSuccessStepSection> createState() =>
      _CashOutSuccessStepSectionState();
}

class _CashOutSuccessStepSectionState extends State<CashOutSuccessStepSection> {
  final CashOutController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.name!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    return Obx(
      () => controller.isCashOutLoading.value
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
                            localizations.cashOutSuccessTitle,
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
                            title: localizations.cashOutSuccessAmount,
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
                            title: localizations.cashOutSuccessTransactionId,
                            content:
                                controller.successCashOutData.value!["tnx"],
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
                              title: localizations.cashOutSuccessWalletName,
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
                              title: localizations.cashOutSuccessPaymentMethod,
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
                              title: localizations.cashOutSuccessCharge,
                              content:
                                  "${double.tryParse(controller.successCashOutData.value!["charge"].toString())!.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",

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
                            title: localizations.cashOutSuccessType,
                            content:
                                controller.successCashOutData.value!["type"],
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
                              title: localizations.cashOutSuccessFinalAmount,
                              content:
                                  "${controller.successCashOutData.value!["final_amount"].toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
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
                        await controller.fetchWallets();
                      },
                      width: double.infinity,

                      text: localizations.cashOutSuccessCashOutAgain,
                    ),
                    const SizedBox(height: 20),
                    CommonButton(
                      onPressed: () async {
                        Get.delete<CashOutController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localizations.cashOutSuccessBackHome,
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

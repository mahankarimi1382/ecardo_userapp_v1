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
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class TransferSuccessStepSection extends StatefulWidget {
  const TransferSuccessStepSection({super.key});

  @override
  State<TransferSuccessStepSection> createState() =>
      _TransferSuccessStepSectionState();
}

class _TransferSuccessStepSectionState
    extends State<TransferSuccessStepSection> {
  final TransferController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

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

    final finalAmount = controller
        .successTransferData
        .value?["sender_transaction"]?["final_amount"];
    final amount = double.tryParse(finalAmount.toString()) ?? 0.0;

    return Obx(
      () => controller.isTransferAmountLoading.value
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
                            localization.transferSuccessStepSectionTitle,
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
                            title:
                                localization.transferSuccessStepSectionAmount,
                            content:
                                "${double.tryParse(controller.amountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.wallet.value?.code ?? ''}",
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
                                .transferSuccessStepSectionTransactionId,
                            content: controller
                                .successTransferData
                                .value!["sender_transaction"]["tnx"],
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
                                  .transferSuccessStepSectionWalletName,
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
                                  .transferSuccessStepSectionPaymentMethod,
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
                                  .transferSuccessStepSectionDateTime,
                              content:
                                  "${controller.successTransferData.value!["sender_transaction"]["created_at"]}",

                              contentColor: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          _buildSuccessDynamicContent(
                            title: localization.transferSuccessStepSectionName,
                            content:
                                "${controller.successTransferData.value!["sender_transaction"]["description"]}",
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
                              title:
                                  localization.transferSuccessStepSectionCharge,
                              content:
                                  "${double.tryParse(controller.successTransferData.value!["sender_transaction"]["charge"].toString())!.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
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
                            title: localization
                                .transferSuccessStepSectionTotalAmount,
                            content:
                                "${amount.toStringAsFixed(calculateDecimals)} ${controller.wallet.value?.code ?? ''}",
                            contentColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    CommonButton(
                      onPressed: () async {
                        controller.currentStep.value = 0;
                        controller.clearFields();
                        controller.fetchTransferWallets();
                      },
                      width: double.infinity,

                      text: localization
                          .transferSuccessStepSectionTransferAgainButton,
                    ),
                    const SizedBox(height: 20),
                    CommonButton(
                      onPressed: () async {
                        Get.find<HomeController>().selectedIndex.value = 0;
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text:
                          localization.transferSuccessStepSectionBackHomeButton,
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

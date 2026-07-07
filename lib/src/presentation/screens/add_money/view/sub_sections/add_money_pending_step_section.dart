import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class AddMoneyPendingStepSection extends StatefulWidget {
  const AddMoneyPendingStepSection({super.key});

  @override
  State<AddMoneyPendingStepSection> createState() =>
      _AddMoneyPendingStepSectionState();
}

class _AddMoneyPendingStepSectionState
    extends State<AddMoneyPendingStepSection> {
  final AddMoneyController controller = Get.find();
  double totalAmount = 0.0;
  bool isCalculated = false;

  double parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void totalCalculate(Map<String, dynamic> transaction) {
    double amount = parseToDouble(transaction["amount"]);
    double charge = parseToDouble(transaction["charge"]);
    totalAmount = amount + charge;
    isCalculated = true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Obx(() {
      final data = controller.pendingPaymentData.value;

      if (data == null || data["transaction"] == null) {
        return const CommonLoading();
      }

      final transaction = data["transaction"];
      final payCurrency = transaction["pay_currency"];

      if (!isCalculated) {
        totalCalculate(transaction);
      }

      return SingleChildScrollView(
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
                    Image.asset(PngAssets.commonPendingIcon, width: 80),
                    SizedBox(height: 16),
                    Text(
                      textAlign: TextAlign.center,
                      localization.addMoneyPendingTitle,
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
                      title: localization.addMoneyPendingAmount,
                      content:
                          "${double.tryParse(controller.amountController.text)?.toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingTransactionId,
                      content: transaction["tnx"],
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingWalletName,
                      content: controller.wallet.value!.name!,
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingPaymentMethod,
                      content: payCurrency,
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingCharge,
                      content:
                          "${parseToDouble(transaction["charge"]).toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
                      contentColor: AppColors.error,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingType,
                      content: transaction["type"],
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.addMoneyPendingFinalAmount,
                      content:
                          "${totalAmount.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
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
                  controller.isLoading.value = true;
                  await controller.fetchWallets();
                  controller.isLoading.value = false;
                },
                width: double.infinity,

                text: localization.addMoneyPendingDepositAgain,
              ),
              const SizedBox(height: 20),
              CommonButton(
                onPressed: () async {
                  Get.delete<AddMoneyController>();
                  Get.toNamed(BaseRoute.navigation);
                  await Get.find<HomeController>().loadData();
                },
                width: double.infinity,
                text: localization.addMoneyPendingBackHome,
                backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                borderColor: AppColors.lightPrimary.withValues(alpha: 0.60),
                borderWidth: 2,
                textColor: AppColors.lightTextPrimary,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
    });
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

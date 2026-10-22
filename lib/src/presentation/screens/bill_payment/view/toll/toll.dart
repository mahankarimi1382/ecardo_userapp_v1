import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/controller/toll_controller.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/sub_sections/bill_payment_result_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/toll/sub_sections/toll_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/toll/sub_sections/toll_review_step_section.dart';

class Toll extends StatefulWidget {
  const Toll({super.key});

  @override
  State<Toll> createState() => _TollState();
}

class _TollState extends State<Toll> {
  final TollController controller = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // QA follow-up (wave Task-10): was a no-op `==` comparison — the step reset
    // was silently defeated on screen re-entry. Assignment restored.
    controller.currentStep.value = 0;
    await controller.fetchBillCountries();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(
                () => Visibility(
                  visible:
                      controller.currentStep.value == 0 ||
                      controller.currentStep.value == 1 ||
                      // PAYMENT-FIX (P-2): keep the app bar on the result step.
                      controller.currentStep.value == 2,
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      Semantics(
                        header: true,
                        child: CommonAppBar(
                          title: AppLocalizations.of(context)!.tollTitle,
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.currentStep.value == 0
                    ? const TollAmountStepSection()
                    : controller.currentStep.value == 1
                    ? const TollReviewStepSection()
                    : // PAYMENT-FIX (P-2): backend-driven pending/success step.
                    controller.currentStep.value == 2
                    ? _buildResultStep(context)
                    : const SizedBox(),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible:
                  controller.isPayBillServiceLoading.value ||
                  controller.isSubmitLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  // PAYMENT-FIX (P-2): backend-driven pending/success result step. The
  // backend message/status are pass-throughs (see
  // BillPaymentResultStepSection); amounts come from the confirmed review
  // values with site-currency decimals from SettingsService.
  Widget _buildResultStep(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final settings = Get.find<SettingsService>();
    final String currency =
        settings.getSetting("site_currency")?.toString() ?? "";
    final String serviceCurrency =
        controller.serviceData.value?.currency ?? '';
    final int siteDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: currency,
      siteCurrencyDecimals:
          settings.getSetting("site_currency_decimals")?.toString(),
      isCrypto: false,
    );
    final int serviceDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: serviceCurrency,
      siteCurrencyCode: currency,
      siteCurrencyDecimals:
          settings.getSetting("site_currency_decimals")?.toString(),
      isCrypto: false,
    );

    final parsedAmount = double.tryParse(controller.amountText.value);
    final String formattedAmount = parsedAmount != null
        ? parsedAmount.toStringAsFixed(serviceDecimals)
        : (controller.amountText.value.isEmpty ? '0' : controller.amountText.value);

    return BillPaymentResultStepSection(
      result: controller.lastBillPaymentResult.value,
      amountLabel: localization.billPaymentDetailsAmount,
      amountValue: serviceCurrency.isNotEmpty
          ? "$formattedAmount $serviceCurrency"
          : formattedAmount,
      chargeLabel: localization.billPaymentDetailsCharge,
      chargeValue: controller.chargeText.value,
      payableLabel: localization.tollReviewPayableAmountLabel,
      payableValue:
          "${controller.payableAmount.value.toStringAsFixed(siteDecimals)} $currency",
      statusLabel: localization.billPaymentDetailsStatus,
      historyButtonLabel: localization.billPaymentHistoryTitle,
      closeButtonLabel: localization.commonClose,
      onClose: controller.resetFields,
    );
  }
}

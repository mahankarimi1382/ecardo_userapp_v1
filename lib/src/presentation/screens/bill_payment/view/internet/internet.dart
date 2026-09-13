import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/sub_sections/bill_payment_result_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/controller/internet_controller.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/internet/sub_sections/internet_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/internet/sub_sections/internet_review_step_section.dart';

class Internet extends StatefulWidget {
  const Internet({super.key});

  @override
  State<Internet> createState() => _InternetState();
}

class _InternetState extends State<Internet> {
  final InternetController controller = Get.find();

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
    return Scaffold(
      appBar: CommonDefaultAppBar(),
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
                      CommonAppBar(
                        title: AppLocalizations.of(context)!.internetTitle,
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.currentStep.value == 0
                    ? InternetAmountStepSection()
                    : controller.currentStep.value == 1
                    ? InternetReviewStepSection()
                    : // PAYMENT-FIX (P-2): backend-driven pending/success step.
                    controller.currentStep.value == 2
                    ? _buildResultStep(context)
                    : SizedBox(),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible:
                  controller.isPayBillServiceLoading.value ||
                  controller.isSubmitLoading.value,
              child: CommonLoading(),
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
    final int decimals =
        int.tryParse(
          settings.getSetting("site_currency_decimals")?.toString() ?? "2",
        ) ??
        2;
    final String currency =
        settings.getSetting("site_currency")?.toString() ?? "";

    return BillPaymentResultStepSection(
      result: controller.lastBillPaymentResult.value,
      amountLabel: localization.billPaymentDetailsAmount,
      amountValue:
          "${controller.amountText.value.isEmpty ? '0' : controller.amountText.value} ${controller.serviceData.value?.currency ?? ''}",
      chargeLabel: localization.billPaymentDetailsCharge,
      chargeValue: controller.chargeText.value,
      payableLabel: localization.internetReviewPayableAmountLabel,
      payableValue:
          "${controller.payableAmount.value.toStringAsFixed(decimals)} $currency",
      statusLabel: localization.billPaymentDetailsStatus,
      historyButtonLabel: localization.billPaymentHistoryTitle,
      closeButtonLabel: localization.commonClose,
      onClose: controller.resetFields,
    );
  }
}

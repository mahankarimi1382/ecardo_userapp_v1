import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/controller/internet_controller.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/bill_review_receipt_card.dart';

class InternetReviewStepSection extends StatelessWidget {
  const InternetReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final InternetController controller = Get.find<InternetController>();
    final settings = Get.find<SettingsService>();

    final int decimals = int.tryParse(
          settings.getSetting("site_currency_decimals")?.toString() ?? "2",
        ) ??
        2;
    final String currency = settings.getSetting("site_currency")?.toString() ?? "تومان";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Obx(() {
        final payableText =
            "${controller.payableAmount.value.toStringAsFixed(decimals)} $currency";

        final recipient = controller.targetAccountNumber.value.isNotEmpty
            ? controller.targetAccountNumber.value
            : (controller.dynamicFieldControllers.values.firstOrNull?.text ?? 'حساب کاربری اینترنت');

        final baseAmountText =
            "${controller.amountText.value.isEmpty ? "0" : controller.amountText.value} ${controller.serviceData.value?.currency ?? currency}";

        return BillReviewReceiptCard(
          serviceTitle: localization?.internetReviewTitle ?? 'اینترنت و بسته‌های دیتا',
          operatorId: controller.selectedOperatorId.value,
          operatorName: controller.selectedOperatorName.value,
          recipientValue: recipient,
          recipientLabel: 'شناسه کاربری / تلفن اشتراک',
          baseAmount: baseAmountText,
          chargeAmount: controller.chargeText.value.isEmpty ? '0 $currency' : controller.chargeText.value,
          conversionRate: controller.rateText.value.isEmpty ? null : controller.rateText.value,
          payableAmount: payableText,
          isLoading: controller.isSubmitLoading.value,
          confirmButtonText: localization?.internetReviewConfirmButton ?? 'تأیید و تمدید اشتراک',
          backButtonText: localization?.internetReviewBackButton ?? 'بازگشت',
          onBack: () => controller.currentStep.value = 0,
          onConfirm: () => controller.submitPayBill(),
        );
      }),
    );
  }
}

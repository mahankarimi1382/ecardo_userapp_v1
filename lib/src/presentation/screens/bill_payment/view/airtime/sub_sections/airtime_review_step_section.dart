import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/controller/airtime_controller.dart';

class AirtimeReviewStepSection extends StatelessWidget {
  const AirtimeReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final AirtimeController controller = Get.find<AirtimeController>();

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization!.airtimeReviewTitle,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      title: localization.airtimeReviewAmountLabel,
                      content:
                          "${controller.amountText.value.isEmpty ? "0" : controller.amountText.value} ${controller.serviceData.value!.currency}",
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
                    () => _buildReviewDynamicContent(
                      context,
                      title: localization.airtimeReviewChargeLabel,
                      content: controller.chargeText.value,
                      contentColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    height: 0,
                    color: AppColors.black.withValues(alpha: 0.10),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      title: localization.airtimeReviewConversionRateLabel,
                      content: controller.rateText.value,
                      contentColor: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    height: 0,
                    color: AppColors.black.withValues(alpha: 0.10),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final settings = Get.find<SettingsService>();

                    final int decimals =
                        int.tryParse(
                          settings
                                  .getSetting("site_currency_decimals")
                                  ?.toString() ??
                              "2",
                        ) ??
                        2;

                    final String currency =
                        settings.getSetting("site_currency")?.toString() ?? "";

                    final String payableText =
                        "${controller.payableAmount.value.toStringAsFixed(decimals)} $currency";

                    return _buildReviewDynamicContent(
                      context,
                      title: localization.airtimeReviewPayableAmountLabel,
                      content: payableText,
                      contentColor: AppColors.lightTextPrimary,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: CommonIconButton(
                    backgroundColor: AppColors.lightPrimary.withValues(
                      alpha: 0.04,
                    ),
                    borderWidth: 2,
                    borderColor: AppColors.lightPrimary.withValues(alpha: 0.50),
                    width: double.infinity,
                    height: 52,
                    text: localization.airtimeReviewBackButton,
                    icon: PngAssets.reviewArrowBackCommonIcon,
                    iconWidth: 18,
                    iconHeight: 18,
                    iconAndTextSpace: 8,
                    iconColor: AppColors.lightTextPrimary,
                    textColor: AppColors.lightTextPrimary,
                    onPressed: () => controller.currentStep.value = 0,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CommonIconButton(
                    onPressed: () => controller.submitPayBill(),
                    width: double.infinity,
                    height: 52,
                    text: localization.airtimeReviewConfirmButton,
                    icon: PngAssets.reviewArrowRightCommonIcon,
                    iconWidth: 18,
                    iconHeight: 18,
                    iconAndTextSpace: 8,
                    isIconRight: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class AddMoneyReviewStepSection extends StatelessWidget {
  const AddMoneyReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final AddMoneyController controller = Get.find<AddMoneyController>();

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.addMoneyReviewTitle,
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
                      title: localization.addMoneyReviewAmount,
                      content:
                          "${controller.baseAmount.value.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
                      contentColor: AppColors.success,
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
                      title: localization.addMoneyReviewWalletName,
                      content: controller.wallet.value!.name!,
                      contentColor: AppColors.black,
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
                      title: localization.addMoneyReviewPaymentMethod,
                      content: controller.gatewayMethod.value!.formattedName!,
                      contentColor: AppColors.black,
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
                      title: localization.addMoneyReviewCharge,
                      content:
                          "${controller.calculatedCharge.value.toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
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
                      title: localization.addMoneyReviewTotal,
                      content:
                          "${controller.totalAmount.value.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
                      contentColor: AppColors.black,
                    ),
                  ),

                  if (controller.dynamicFieldControllers.isNotEmpty)
                    const SizedBox(height: 20),
                  if (controller.dynamicFieldControllers.isNotEmpty)
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                  ..._buildDynamicFieldsReview(context, controller),
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
                    text: localization.addMoneyReviewBack,
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
                    onPressed: () async {
                      if (controller.userModel.value.data!.passcode == "0") {
                        _continueAddMoneyFlow(controller);
                        return;
                      }

                      final bool isPasscodeEnabled =
                          Get.find<SettingsService>().getSetting(
                            "deposit_passcode_status",
                          ) ==
                          "1";

                      if (isPasscodeEnabled) {
                        final bool? isVerified = await Get.bottomSheet<bool>(
                          VerifyPasscodeBottomSheet(),
                        );
                        if (isVerified != true) return;
                        _continueAddMoneyFlow(controller);
                      } else {
                        _continueAddMoneyFlow(controller);
                      }
                    },
                    width: double.infinity,
                    height: 52,
                    text: localization.addMoneyReviewConfirm,
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

  void _continueAddMoneyFlow(AddMoneyController controller) {
    if (controller.currentStep.value == 1) {
      if (controller.gatewayMethod.value!.type == "auto") {
        controller.submitAddMoneyAuto();
      } else {
        controller.submitAddMoneyManual();
      }
    } else {
      controller.nextStepWithValidation();
    }
  }

  // Dynamic fields review section
  List<Widget> _buildDynamicFieldsReview(
    BuildContext context,
    AddMoneyController controller,
  ) {
    final localization = AppLocalizations.of(context)!;
    List<Widget> widgets = [];
    final fields = controller.dynamicFieldControllers.entries.toList();

    for (int i = 0; i < fields.length; i++) {
      final entry = fields[i];
      final fieldName = entry.key;
      final fieldData = entry.value;
      final textController = fieldData['controller'] as TextEditingController;
      final type = fieldData['type'] as String;

      widgets.add(const SizedBox(height: 20));

      if (type == 'file') {
        final file = controller.selectedImages[fieldName];
        final fileName =
            file?.path.split('/').last ??
            localization.addMoneyReviewNoFileUploaded;

        widgets.add(
          _buildReviewDynamicContent(
            context,
            title: fieldName,
            content: fileName,
            contentColor: AppColors.black,
          ),
        );
      } else {
        widgets.add(
          _buildReviewDynamicContent(
            context,
            title: fieldName,
            content: textController.text,
            contentColor: AppColors.black,
          ),
        );
      }

      if (i < fields.length - 1) {
        widgets.add(const SizedBox(height: 20));
        widgets.add(
          Divider(height: 0, color: AppColors.black.withValues(alpha: 0.10)),
        );
      }
    }

    return widgets;
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

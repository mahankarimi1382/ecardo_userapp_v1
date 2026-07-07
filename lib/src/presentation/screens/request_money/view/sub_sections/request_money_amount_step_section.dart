import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/qr_scanner_screen.dart';

class RequestMoneyAmountStepSection extends StatefulWidget {
  const RequestMoneyAmountStepSection({super.key});

  @override
  State<RequestMoneyAmountStepSection> createState() =>
      _RequestMoneyAmountStepSectionState();
}

class _RequestMoneyAmountStepSectionState
    extends State<RequestMoneyAmountStepSection> {
  final RequestMoneyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        bottom: 24,
        top: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionRecipientId,
            isLabelRequired: true,
            dynamicField: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => CommonTextInputField(
                      focusNode: controller.recipientUidFocusNode,
                      isFocused: controller.isRecipientUidFocused.value,
                      backgroundColor: AppColors.transparent,
                      hintText: "",
                      controller: controller.recipientUidController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    final scannedCode = await Get.to(
                      () => const QrScannerScreen(),
                    );

                    if (scannedCode != null) {
                      if (scannedCode.startsWith("UID:")) {
                        final midValue = scannedCode
                            .replaceAll("UID:", "")
                            .trim();

                        final isNumeric = RegExp(r'^\d+$').hasMatch(midValue);

                        if (isNumeric) {
                          controller.recipientUidController.text = midValue;
                        } else {
                          ToastHelper().showErrorToast(
                            localization
                                .requestMoneyAmountStepSectionInvalidQrCodeDigits,
                          );
                        }
                      } else {
                        ToastHelper().showErrorToast(
                          localization
                              .requestMoneyAmountStepSectionInvalidQrCodePrefix,
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      PngAssets.commonScannerIcon,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionRequestAmount,
            isLabelRequired: true,
            dynamicField: Obx(
              () => CommonTextInputField(
                focusNode: controller.requestAmountFocusNode,
                isFocused: controller.isRequestAmountFocused.value,
                backgroundColor: AppColors.transparent,
                hintText: "",
                controller: controller.requestAmountController,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.requestMoneyWalletsList.isNotEmpty,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Text(
                  "${localization.requestMoneyAmountStepSectionMin} ${controller.wallet.value!.requestMoneyLimit!.min} ${controller.wallet.value!.code} ${localization.requestMoneyAmountStepSectionMax} ${controller.wallet.value!.requestMoneyLimit!.max} ${controller.wallet.value!.code}",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionNote,
            dynamicField: Obx(
              () => CommonTextInputField(
                isFocused: controller.isNoteFocused.value,
                focusNode: controller.noteFocusNode,
                backgroundColor: AppColors.transparent,
                hintText: "",
                controller: controller.noteController,
                keyboardType: TextInputType.text,
                maxLine: 5,
              ),
            ),
          ),
          SizedBox(height: 40),
          CommonButton(
            borderRadius: 16,
            width: double.infinity,

            text: localization.requestMoneyAmountStepSectionRequestMoneyButton,
            onPressed: () {
              controller.nextStepWithValidation();
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

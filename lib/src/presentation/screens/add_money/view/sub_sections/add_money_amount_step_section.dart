import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';

class AddMoneyAmountStepSection extends StatefulWidget {
  const AddMoneyAmountStepSection({super.key});

  @override
  State<AddMoneyAmountStepSection> createState() =>
      _AddMoneyAmountStepSectionState();
}

class _AddMoneyAmountStepSectionState extends State<AddMoneyAmountStepSection> {
  final AddMoneyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.page,
          end: AppSpacing.page,
          top: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: AppSpacing.lg,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.addMoneyGateway,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.gatewayFocusNode,
                    isFocused: controller.isGatewayFocused.value,
                    suffixIcon: Image.asset(
                      PngAssets.arrowDownCommonIcon,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextTertiary,
                    ),
                    borderRadius: AppSpacing.radiusLg,
                    backgroundColor: AppColors.transparent,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownBottomSheet(
                          isShowTitle: true,
                          title: localization.addMoneyGateway,
                          notFoundText: localization.addMoneyGatewayNotFound,
                          onValueSelected: (value) async {
                            int index = controller.gatewayMethodsList
                                .indexWhere(
                                  (item) => item.formattedName == value,
                                );

                            if (index != -1) {
                              final selectedGateway =
                                  controller.gatewayMethodsList[index];
                              controller.gatewayMethod.value = selectedGateway;
                              controller.gatewayController.text =
                                  selectedGateway.formattedName ?? "";
                              controller.dynamicFieldControllers.clear();
                              if (selectedGateway.fieldOptions != null) {
                                for (var field
                                    in selectedGateway.fieldOptions!) {
                                  controller.dynamicFieldControllers[field
                                          .name ??
                                      ''] = {
                                    'controller': TextEditingController(),
                                    'validation':
                                        field.validation ?? 'nullable',
                                    'type': field.type ?? 'text',
                                  };
                                }
                              }
                            }
                          },
                          selectedValue: controller.gatewayMethodsList
                              .map((item) => item.formattedName.toString())
                              .toList(),
                          dropdownItems: controller.gatewayMethodsList
                              .map((item) => item.formattedName.toString())
                              .toList(),
                          isUnselectedValue: true,
                          onValueUnSelected: () {
                            controller.gatewayMethod.value =
                                GatewayMethodsData();
                            controller.gatewayController.clear();
                            controller.dynamicFieldControllers.clear();
                            controller.selectedImages.clear();
                          },
                          selectedItem: controller.gatewayController.text,
                          textController: controller.gatewayController,
                          currentlySelectedValue:
                              controller.gatewayController.text,
                          bottomSheetHeight: 400,
                        ),
                      );
                    },
                    hintText: localization.addMoneySelectGateway,
                    controller: controller.gatewayController,
                    suffixIconColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                    readOnly: true,
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible:
                      controller.gatewayMethod.value?.formattedName != null &&
                      controller.gatewayMethod.value!.formattedName!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      "${localization.addMoneyCharge} ${double.tryParse(controller.gatewayMethod.value!.charge ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyType != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.chargeType == "percentage" ? "%" : controller.wallet.value?.code ?? ''}",
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Amount Hero Card with Currency Badge and Quick Amount Chips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                      : AppColors.lightSecondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonRequiredLabelAndDynamicField(
                      labelText: localization.addMoneyAmount,
                      isLabelRequired: true,
                      dynamicField: Obx(
                        () => CommonTextInputField(
                          focusNode: controller.amountFocusNode,
                          isFocused: controller.isAmountFocused.value,
                          isSuffixIconCompact: false,
                          suffixIcon: Container(
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkPrimary.withValues(alpha: 0.15)
                                  : AppColors.lightPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              controller.wallet.value?.code ?? "",
                              style: TextStyle(
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                          borderRadius: AppSpacing.radiusLg,
                          backgroundColor: AppColors.transparent,
                          hintText: "0.00",
                          controller: controller.amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            AmountInputFormatter(maxDecimals: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Quick-amount chips
                    Obx(() {
                      final wallet = controller.wallet.value;
                      final balance = double.tryParse(wallet?.balance ?? '0') ?? 1000.0;
                      return QuickAmountSelector(
                        textController: controller.amountController,
                        availableBalance: balance > 0 ? balance : 1000.0,
                        isCrypto: wallet?.isCrypto ?? false,
                        currencyCode: wallet?.code,
                        height: 32.0,
                        chipSpacing: AppSpacing.sm,
                      );
                    }),
                  ],
                ),
              ),

              Obx(
                () => Visibility(
                  visible:
                      controller.gatewayMethod.value?.formattedName != null &&
                      controller.gatewayMethod.value!.formattedName!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: AppSpacing.xs,
                      start: AppSpacing.xs,
                    ),
                    child: Text(
                      "${localization.addMoneyMin} ${double.tryParse(controller.gatewayMethod.value!.minimumDeposit ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.currency} | ${localization.addMoneyMax} ${double.tryParse(controller.gatewayMethod.value!.maximumDeposit ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.currency}",
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              Obx(() {
                final gateway = controller.gatewayMethod.value;
                final hasInstructions =
                    gateway?.instructions?.isNotEmpty == true;

                if (!hasInstructions) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightPrimary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: HtmlWidget(
                        gateway!.instructions!,
                        textStyle: TextStyle(
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Obx(() {
                if (controller.dynamicFieldControllers.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    ...controller.dynamicFieldControllers.entries.map((entry) {
                      final fieldName = entry.key;
                      final fieldData = entry.value;

                      final dynamicCtrl =
                          fieldData['controller'] as TextEditingController;
                      final validation = fieldData['validation'] as String;
                      final type = fieldData['type'] as String;
                      final isRequired = validation == 'required';
                      final isTextArea = type == 'textarea';
                      final isFile = type == 'file';

                      return Column(
                        children: [
                          CommonRequiredLabelAndDynamicField(
                            labelText: fieldName,
                            isLabelRequired: isRequired,
                            dynamicField: isFile
                                ? _buildUploadSection(
                                    title: fieldName,
                                    fieldName: fieldName,
                                    isDark: isDark,
                                  )
                                : CommonTextInputField(
                                    borderRadius: AppSpacing.radiusLg,
                                    backgroundColor: AppColors.transparent,
                                    hintText: isTextArea
                                        ? localization.addMoneyWriteHere
                                        : '',
                                    controller: dynamicCtrl,
                                    maxLine: isTextArea ? 5 : 1,
                                    keyboardType: isTextArea
                                        ? TextInputType.multiline
                                        : TextInputType.text,
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      );
                    }),
                  ],
                );
              }),
              SizedBox(
                height: controller.dynamicFieldControllers.isEmpty
                    ? AppSpacing.xxl
                    : AppSpacing.lg,
              ),
              CommonButton(
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                text: localization.addMoneyAddMoneyButton,
                onPressed: () {
                  controller.nextStepWithValidation();
                },
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String fieldName,
    required bool isDark,
  }) {
    return Obx(() {
      final selectedImage = controller.selectedImages[fieldName];

      return GestureDetector(
        onTap: () {
          controller.pickImage(fieldName, image_picker.ImageSource.gallery);
        },
        child: SizedBox(
          width: double.infinity,
          height: selectedImage != null ? 120 : null,
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.file(selectedImage, fit: BoxFit.cover),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        PngAssets.commonUploadIcon,
                        width: AppSpacing.iconMd,
                        fit: BoxFit.contain,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}

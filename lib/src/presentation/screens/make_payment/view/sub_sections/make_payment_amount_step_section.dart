import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/model/beneficiary_model.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';
import 'package:qunzo_user/src/presentation/widgets/qr_scanner_screen.dart';

class MakePaymentAmountStepSection extends StatefulWidget {
  const MakePaymentAmountStepSection({super.key});

  @override
  State<MakePaymentAmountStepSection> createState() =>
      _MakePaymentAmountStepSectionState();
}

class _MakePaymentAmountStepSectionState
    extends State<MakePaymentAmountStepSection> {
  final MakePaymentController controller = Get.find();
  final CreateBeneficiaryController createBeneficiaryController = Get.put(
    CreateBeneficiaryController(),
  );
  final localization = AppLocalizations.of(Get.context!)!;

  @override
  void initState() {
    super.initState();

    ever(createBeneficiaryController.shouldReopenBottomSheet, (shouldReopen) {
      if (shouldReopen == true) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          await controller.fetchBeneficiary();
          Get.bottomSheet(_buildBeneficiary());
          createBeneficiaryController.shouldReopenBottomSheet.value = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.makePaymentAmountStepSectionMerchantId,
          isLabelRequired: true,
          dynamicField: Row(
            children: [
              Expanded(
                child: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.merchantFocusNode,
                    isFocused: controller.isMerchantFocused.value,
                    backgroundColor: AppColors.transparent,
                    hintText: "",
                    controller: controller.merchantMidController,
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
                    if (scannedCode.startsWith("MID:")) {
                      final midValue = scannedCode
                          .replaceAll("MID:", "")
                          .trim();

                      final isNumeric = RegExp(r'^\d+$').hasMatch(midValue);
                      if (isNumeric) {
                        controller.merchantMidController.text = midValue;
                      } else {
                        ToastHelper().showErrorToast(
                          localization
                              .makePaymentAmountStepSectionInvalidQrCodeDigits,
                        );
                      }
                    } else {
                      ToastHelper().showErrorToast(
                        localization
                            .makePaymentAmountStepSectionInvalidQrCodePrefix,
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
          labelText: localization.makePaymentAmountStepSectionAmount,
          isLabelRequired: true,
          dynamicField: Obx(
            () => CommonTextInputField(
              focusNode: controller.amountFocusNode,
              isFocused: controller.isAmountFocused.value,
              isSuffixIconCompact: false,
              suffixIcon: Center(
                child: Text(
                  controller.wallet.value?.code ?? '',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.40),
                  ),
                ),
              ),
              borderRadius: 16,
              backgroundColor: AppColors.transparent,
              hintText: "",
              controller: controller.amountController,
              keyboardType: TextInputType.number,
            ),
          ),
        ),

        Obx(
          () => Visibility(
            visible: controller.paymentWalletsList.isNotEmpty,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: Text(
                "${localization.makePaymentAmountStepSectionMinLimit} ${controller.wallet.value?.paymentLimit?.min ?? 0} "
                "${controller.wallet.value?.code ?? ''} ${localization.makePaymentAmountStepSectionMaxLimit} "
                "${controller.wallet.value?.paymentLimit?.max ?? 0} "
                "${controller.wallet.value?.code ?? ''}",
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

        const SizedBox(height: 40),

        CommonButton(
          borderRadius: 16,
          width: double.infinity,
          text: localization.makePaymentAmountStepSectionMakePaymentButton,
          onPressed: () {
            controller.nextStepWithValidation();
          },
        ),
        const SizedBox(height: 20),
        CommonButton(
          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.06),
          borderWidth: 2,
          borderColor: AppColors.lightPrimary.withValues(alpha: 0.16),
          textColor: AppColors.lightTextPrimary,
          borderRadius: 16,
          width: double.infinity,
          text: localization.makePaymentAmountStepSectionSavedMerchantsButton,
          onPressed: () async {
            await controller.fetchBeneficiary();
            Get.bottomSheet(_buildBeneficiary());
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBeneficiary() {
    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.makePaymentAmountStepSectionMerchantsTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      BaseRoute.createBeneficiary,
                      arguments: {"account_user": "Merchant"},
                    );
                  },
                  child: Text(
                    localization.makePaymentAmountStepSectionAddMerchant,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => Expanded(
                child:
                    controller
                        .beneficiaryModel
                        .value
                        .data!
                        .beneficiaries!
                        .isEmpty
                    ? NoDataFound()
                    : controller.isBeneficiaryLoading.value
                    ? CommonLoading()
                    : ListView.separated(
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemCount: controller
                            .beneficiaryModel
                            .value
                            .data!
                            .beneficiaries!
                            .length,
                        itemBuilder: (context, index) {
                          final Beneficiaries item = controller
                              .beneficiaryModel
                              .value
                              .data!
                              .beneficiaries![index];
                          return GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.merchantMidController.text =
                                  item.accountNumber ?? "";
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.lightTextTertiary.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.network(
                                    item.receiver?.avatar ?? "",
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        PngAssets.profileImage,
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nickname ?? "",
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${localization.makePaymentAmountStepSectionMidLabel} ${item.accountNumber}",
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontSize: 13,
                                            color: AppColors.lightTextTertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          Get.toNamed(
                                            BaseRoute.updateBeneficiary,
                                            arguments: {
                                              "beneficiary_id": item.id
                                                  .toString(),
                                              "account_user": "Merchant",
                                              "beneficiary_data": item,
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () async {
                                          Get.bottomSheet(
                                            deleteBeneficiaryBottomSheet(
                                              beneficiaryId: item.id.toString(),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget deleteBeneficiaryBottomSheet({required String beneficiaryId}) {
    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            SizedBox(height: 40),
            Image.asset(PngAssets.walletDeleteCommonIconTwo, width: 70),
            SizedBox(height: 16),
            Text(
              localization.makePaymentAmountStepSectionDeleteConfirmationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: AppColors.lightTextPrimary,
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 5),
            Text(
              textAlign: TextAlign.center,
              localization
                  .makePaymentAmountStepSectionDeleteConfirmationMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 40),

            CommonButton(
              backgroundColor: AppColors.error,
              width: 120,

              text: localization.makePaymentAmountStepSectionDeleteButton,
              onPressed: () async {
                Get.back();
                controller.merchantMidController.clear();
                createBeneficiaryController.onBeneficiaryCreated = () {
                  controller.fetchBeneficiary();
                };
                await createBeneficiaryController.deleteBeneficiary(
                  beneficiaryId: beneficiaryId,
                );
              },
            ),
            SizedBox(height: 20),
            CommonButton(
              width: 120,

              text: localization.makePaymentAmountStepSectionCancelButton,
              backgroundColor: AppColors.transparent,
              textColor: AppColors.lightTextTertiary,
              onPressed: () => Get.back(),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

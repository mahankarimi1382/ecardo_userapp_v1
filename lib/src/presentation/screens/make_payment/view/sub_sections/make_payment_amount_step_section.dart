import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/qr_scanner_screen.dart';

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

  @override
  void initState() {
    super.initState();

    ever(createBeneficiaryController.shouldReopenBottomSheet, (shouldReopen) {
      if (shouldReopen == true) {
        Future.delayed(AppDurations.normal, () async {
          await controller.fetchBeneficiary();
          if (mounted) {
            Get.bottomSheet(
              _buildBeneficiary(
                Theme.of(context).brightness == Brightness.dark,
              ),
            );
          }
          createBeneficiaryController.shouldReopenBottomSheet.value = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
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
                    borderRadius: AppSpacing.radiusLg,
                    backgroundColor: AppColors.transparent,
                    hintText: "",
                    controller: controller.merchantMidController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                onTap: () async {
                  HapticFeedback.lightImpact();
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusLg,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.darkShadow
                            : AppColors.lightShadow,
                        blurRadius: AppSpacing.sm,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    PngAssets.commonScannerIcon,
                    color: isDark ? AppColors.deepBlack : AppColors.white,
                  ),
                ),
              ),
            ],
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
                labelText: localization.makePaymentAmountStepSectionAmount,
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
                        controller.wallet.value?.code ?? '',
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
              Obx(() {
                final wallet = controller.wallet.value;
                final balance = double.tryParse(wallet?.balance ?? '0') ?? 0.0;
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
            visible: controller.paymentWalletsList.isNotEmpty &&
                controller.wallet.value?.paymentLimit != null,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: AppSpacing.xs,
                start: AppSpacing.xs,
              ),
              child: Text(
                "${localization.makePaymentAmountStepSectionMinLimit} ${controller.wallet.value?.paymentLimit?.min ?? 0} "
                "${controller.wallet.value?.code ?? ''} | ${localization.makePaymentAmountStepSectionMaxLimit} "
                "${controller.wallet.value?.paymentLimit?.max ?? 0} "
                "${controller.wallet.value?.code ?? ''}",
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

        const SizedBox(height: AppSpacing.xxxl),

        CommonButton(
          borderRadius: AppSpacing.radiusLg,
          width: double.infinity,
          text: localization.makePaymentAmountStepSectionMakePaymentButton,
          onPressed: () {
            HapticFeedback.lightImpact();
            controller.nextStepWithValidation();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        CommonButton(
          backgroundColor: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightPrimary.withValues(alpha: 0.06),
          borderWidth: 1.5,
          borderColor: isDark
              ? AppColors.darkBorder
              : AppColors.lightPrimary.withValues(alpha: 0.16),
          textColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          borderRadius: AppSpacing.radiusLg,
          width: double.infinity,
          text: localization.makePaymentAmountStepSectionSavedMerchantsButton,
          onPressed: () async {
            HapticFeedback.lightImpact();
            await controller.fetchBeneficiary();
            if (context.mounted) {
              Get.bottomSheet(_buildBeneficiary(isDark));
            }
          },
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  Widget _buildBeneficiary(bool isDark) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
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
            blurRadius: AppSpacing.xxl,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.page,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                    : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.makePaymentAmountStepSectionMerchantsTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.back();
                    Get.toNamed(
                      BaseRoute.createBeneficiary,
                      arguments: {"account_user": "Merchant"},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      localization.makePaymentAmountStepSectionAddMerchant,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                if (controller.isBeneficiaryLoading.value) {
                  return const CommonLoading();
                }

                final beneficiaries =
                    controller.beneficiaryModel.value.data?.beneficiaries ?? [];

                if (beneficiaries.isEmpty) {
                  return Center(
                    child: EcardoEmptyState(
                      title:
                          localization.makePaymentAmountStepSectionMerchantsTitle,
                      description: localization.noDataFound,
                      iconData: Icons.storefront_rounded,
                      primaryActionLabel:
                          localization.makePaymentAmountStepSectionAddMerchant,
                      onPrimaryAction: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                        Get.toNamed(
                          BaseRoute.createBeneficiary,
                          arguments: {"account_user": "Merchant"},
                        );
                      },
                    ),
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemCount: beneficiaries.length,
                  itemBuilder: (context, index) {
                    final Beneficiaries item = beneficiaries[index];
                    final displayName =
                        item.nickname ?? item.receiver?.name ?? "Merchant";

                    return InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                        controller.merchantMidController.text =
                            item.accountNumber ?? "";
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            MonogramAvatar(
                              name: displayName,
                              imageUrl: item.receiver?.avatar,
                              size: 46,
                              isVerified: true,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.accountNumber ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextTertiary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.softGray,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

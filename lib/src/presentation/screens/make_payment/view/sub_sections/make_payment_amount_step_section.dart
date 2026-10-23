import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_amount_input_card.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_recipient_card.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final siteCurrency =
        Get.find<SettingsService>().getSetting("site_currency") ?? 'USD';
    final siteDecimals =
        Get.find<SettingsService>().getSetting("site_currency_decimals") ?? '2';

    return Obx(() {
      final currentWallet = controller.wallet.value;
      final decimals = DynamicDecimalsHelper().getDynamicDecimals(
        currencyCode: currentWallet?.code ?? 'USD',
        siteCurrencyCode: siteCurrency,
        siteCurrencyDecimals: siteDecimals,
        isCrypto: currentWallet?.isCrypto ?? false,
      );

      final enteredMid = controller.merchantMidController.text.trim();
      final beneficiaries =
          controller.beneficiaryModel.value.data?.beneficiaries ??
          <Beneficiaries>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // 1. Merchant MID Input with Clear & QR Scanner
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
                      backgroundColor: isDark
                          ? colorScheme.surfaceContainerHigh.withValues(
                              alpha: 0.4,
                            )
                          : colorScheme.surface,
                      hintText: "Enter Merchant MID",
                      controller: controller.merchantMidController,
                      keyboardType: TextInputType.number,
                      suffixIcon:
                          controller.merchantMidController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              onPressed: () {
                                controller.merchantMidController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // QR Scanner Button
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final scannedCode = await Get.to(
                      () => const QrScannerScreen(),
                    );

                    if (scannedCode != null) {
                      final clean = scannedCode.trim();
                      final midMatch = RegExp(
                        r'^(?:MID\s*:\s*)?(\d+)$',
                        caseSensitive: false,
                      ).firstMatch(clean);

                      if (midMatch != null) {
                        controller.merchantMidController.text = midMatch.group(
                          1,
                        )!;
                        setState(() {});
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
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      PngAssets.commonScannerIcon,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Merchants Carousel (if saved merchants exist)
          if (beneficiaries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            BeneficiariesQuickPickRow(
              beneficiaries: beneficiaries,
              selectedUid: enteredMid,
              onSelect: (b) {
                controller.merchantMidController.text = b.accountNumber ?? '';
                setState(() {});
              },
              onAddNew: () async {
                await controller.fetchBeneficiary();
                if (mounted) {
                  Get.bottomSheet(_buildBeneficiary(isDark));
                }
              },
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // 2. Standardized FinTech Hero Amount Input Card (Zero-decimal Toman strictly enforced)
          TransferAmountInputCard(
            controller: controller.amountController,
            focusNode: controller.amountFocusNode,
            wallet: null,
            customCurrencyCode: currentWallet?.code,
            customCurrencySymbol: currentWallet?.symbol,
            customBalanceText: currentWallet?.formattedBalance,
            customTitle: localization.makePaymentAmountStepSectionAmount,
            charge: controller.charge.value,
            totalAmount: controller.totalAmount.value,
            chargeLoadFailed: controller.chargeLoadFailed.value,
            decimals: decimals,
            showFeePill: true,
            onPercentageSelected: (fraction) {
              controller.setPercentage(fraction);
              setState(() {});
            },
            onClear: () {
              controller.amountController.clear();
              controller.calculateLiveCharge();
              setState(() {});
            },
          ),

          // Limits text
          if (controller.paymentWalletsList.isNotEmpty &&
              currentWallet?.paymentLimit != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.xs,
              ),
              child: Text(
                "${localization.makePaymentAmountStepSectionMinLimit} ${double.tryParse(currentWallet?.paymentLimit?.min ?? '0')?.toStringAsFixed(decimals) ?? '0'} "
                "${currentWallet?.code ?? ''} | ${localization.makePaymentAmountStepSectionMaxLimit} "
                "${double.tryParse(currentWallet?.paymentLimit?.max ?? '0')?.toStringAsFixed(decimals) ?? '0'} "
                "${currentWallet?.code ?? ''}",
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
          ],

          const SizedBox(height: AppSpacing.xxl),

          // 3. Action Buttons with Debounce and Explicit Loading States
          CommonButton(
            borderRadius: AppSpacing.radiusLg,
            width: double.infinity,
            height: 52,
            isLoading: controller.isPaymentSettingsLoading.value,
            text: localization.makePaymentAmountStepSectionMakePaymentButton,
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.nextStepWithValidation();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CommonButton(
            isLoading: controller.isBeneficiaryLoading.value,
            backgroundColor: isDark
                ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                : colorScheme.primary.withValues(alpha: 0.06),
            borderWidth: 1.5,
            borderColor: isDark
                ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                : colorScheme.primary.withValues(alpha: 0.16),
            textColor: colorScheme.onSurface,
            borderRadius: AppSpacing.radiusLg,
            width: double.infinity,
            height: 50,
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
    });
  }

  Widget _buildBeneficiary(bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow).withValues(
              alpha: isDark ? 0.4 : 0.08,
            ),
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
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
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
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
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
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
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
                      title: localization
                          .makePaymentAmountStepSectionMerchantsTitle,
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
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemCount: beneficiaries.length,
                  itemBuilder: (context, index) {
                    final Beneficiaries item = beneficiaries[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.back();
                        controller.merchantMidController.text =
                            item.accountNumber ?? "";
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceContainerLowest
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: isDark ? 0.3 : 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            RecipientMonogramAvatar(
                              name: item.nickname ?? item.receiver?.name,
                              identifier: item.accountNumber,
                              avatarUrl: item.receiver?.avatar,
                              size: 44,
                              isVerified: item.receiver != null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nickname ?? item.receiver?.name ?? "",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${localization.makePaymentAmountStepSectionMidLabel} ${item.accountNumber}",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: 0,
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.35,
                              ),
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

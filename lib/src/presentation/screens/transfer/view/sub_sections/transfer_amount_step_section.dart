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
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_amount_input_card.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_recipient_card.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';
import 'package:ecardo_user/src/presentation/widgets/qr_scanner_screen.dart';

class TransferAmountStepSection extends StatefulWidget {
  const TransferAmountStepSection({super.key});

  @override
  State<TransferAmountStepSection> createState() =>
      _TransferAmountStepSectionState();
}

class _TransferAmountStepSectionState extends State<TransferAmountStepSection> {
  final String uidAccount = Get.arguments?['uid_account'] ?? '';
  final TransferController controller = Get.find();
  final CreateBeneficiaryController createBeneficiaryController = Get.put(
    CreateBeneficiaryController(),
  );

  @override
  void initState() {
    super.initState();
    if (uidAccount.isNotEmpty && controller.recipientUidController.text.isEmpty) {
      controller.recipientUidController.text = uidAccount;
    }

    ever(createBeneficiaryController.shouldReopenBottomSheet, (shouldReopen) {
      if (shouldReopen == true) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          await controller.fetchBeneficiary();
          if (mounted) {
            Get.bottomSheet(_buildBeneficiary());
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

      final enteredUid = controller.recipientUidController.text.trim();
      final matchedBeneficiary = controller.findBeneficiaryByAccount(enteredUid);
      final hasSelectedRecipient = enteredUid.isNotEmpty;

      final beneficiaries =
          controller.beneficiaryModel.value.data?.beneficiaries ?? <Beneficiaries>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Recipient Selection
            if (hasSelectedRecipient)
              TransferRecipientCard(
                beneficiary: matchedBeneficiary,
                fallbackUid: enteredUid,
                onClear: () {
                  controller.recipientUidController.clear();
                  setState(() {});
                },
              )
            else ...[
              CommonRequiredLabelAndDynamicField(
                labelText: localization.transferAmountStepSectionRecipientUid,
                isLabelRequired: true,
                dynamicField: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => CommonTextInputField(
                          focusNode: controller.recipientUidFocusNode,
                          isFocused: controller.isRecipientUidFocused.value,
                          backgroundColor: isDark
                              ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
                              : colorScheme.surface,
                          hintText: "Enter Recipient UID",
                          controller: controller.recipientUidController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // QR Scanner button
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final scannedCode = await Get.to(
                          () => const QrScannerScreen(),
                        );

                        if (scannedCode != null) {
                          if (scannedCode.startsWith("UID:")) {
                            final midValue = scannedCode
                                .replaceAll("UID:", "")
                                .trim();

                            final isNumeric = RegExp(
                              r'^\d+$',
                            ).hasMatch(midValue);

                            if (isNumeric) {
                              controller.recipientUidController.text = midValue;
                              setState(() {});
                            } else {
                              ToastHelper().showErrorToast(
                                localization
                                    .transferAmountStepSectionInvalidQrCodeDigits,
                              );
                            }
                          } else {
                            ToastHelper().showErrorToast(
                              localization
                                  .transferAmountStepSectionInvalidQrCodePrefix,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
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
                          PngAssets.qrCodeScannerIcon,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Beneficiaries Carousel
              if (beneficiaries.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                BeneficiariesQuickPickRow(
                  beneficiaries: beneficiaries,
                  selectedUid: enteredUid,
                  onSelect: (b) {
                    controller.recipientUidController.text = b.accountNumber ?? '';
                    setState(() {});
                  },
                  onAddNew: () async {
                    await controller.fetchBeneficiary();
                    if (mounted) {
                      Get.bottomSheet(_buildBeneficiary());
                    }
                  },
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.lg),

            // 2. Big Hero Amount Input Card with Percentage Chips & Fee Pill
            TransferAmountInputCard(
              controller: controller.amountController,
              focusNode: controller.amountFocusNode,
              wallet: currentWallet,
              charge: controller.charge.value,
              totalAmount: controller.totalAmount.value,
              chargeLoadFailed: controller.chargeLoadFailed.value,
              decimals: decimals,
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

            const SizedBox(height: AppSpacing.xxl),

            // 3. Action Buttons
            CommonButton(
              borderRadius: AppSpacing.radiusLg,
              width: double.infinity,
              height: 52,
              text: localization.transferAmountStepSectionTransferMoneyButton,
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.nextStepWithValidation();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CommonButton(
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                  : colorScheme.primary.withValues(alpha: 0.06),
              borderWidth: 1.5,
              borderColor: isDark
                  ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                  : colorScheme.primary.withValues(alpha: 0.18),
              textColor: colorScheme.onSurface,
              borderRadius: AppSpacing.radiusLg,
              width: double.infinity,
              height: 50,
              text: localization.transferAmountStepSectionSavedBeneficiaryButton,
              onPressed: () async {
                HapticFeedback.lightImpact();
                await controller.fetchBeneficiary();
                if (mounted) {
                  Get.bottomSheet(_buildBeneficiary());
                }
              },
            ),

            const SizedBox(height: AppSpacing.xxl),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        );
    });
  }

  Widget _buildBeneficiary() {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow)
                .withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 40,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.transferAmountStepSectionBeneficiariesTitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      BaseRoute.createBeneficiary,
                      arguments: {"account_user": "Beneficiary"},
                    );
                  },
                  child: Text(
                    localization.transferAmountStepSectionAddBeneficiary,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: 0,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Obx(
              () => Expanded(
                child: (controller.beneficiaryModel.value.data?.beneficiaries?.isEmpty ?? true)
                    ? const NoDataFound()
                    : controller.isBeneficiaryLoading.value
                        ? const CommonLoading()
                        : ListView.separated(
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemCount: controller
                                    .beneficiaryModel
                                    .value
                                    .data
                                    ?.beneficiaries
                                    ?.length ??
                                0,
                            itemBuilder: (context, index) {
                              final Beneficiaries item = controller
                                  .beneficiaryModel
                                  .value
                                  .data!
                                  .beneficiaries![index];
                              final displayName = item.nickname ?? item.receiver?.name ?? 'User';

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Get.back();
                                  controller.recipientUidController.text =
                                      item.accountNumber ?? "";
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colorScheme.surfaceContainerLowest
                                        : colorScheme.surfaceContainerLow,
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.radiusLg),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: isDark ? 0.3 : 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      RecipientMonogramAvatar(
                                        name: displayName,
                                        identifier: item.accountNumber,
                                        avatarUrl: item.receiver?.avatar,
                                        size: 44,
                                        isVerified: item.receiver != null,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${localization.transferAmountStepSectionUidLabel} ${item.accountNumber}",
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                letterSpacing: 0,
                                                fontSize: 12,
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
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
                                                  "beneficiary_id":
                                                      item.id.toString(),
                                                  "account_user": "Beneficiary",
                                                  "beneficiary_data": item,
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          InkWell(
                                            onTap: () async {
                                              Get.bottomSheet(
                                                deleteBeneficiaryBottomSheet(
                                                  beneficiaryId:
                                                      item.id.toString(),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppColors.error,
                                              ),
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
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow)
                .withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 40,
            offset: Offset.zero,
          ),
        ],
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: AppSpacing.xxl),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization.transferAmountStepSectionDeleteConfirmationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                localization.transferAmountStepSectionDeleteConfirmationMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: isDark
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerLow,
                      textColor: colorScheme.onSurface,
                      text: localization.transferAmountStepSectionCancelButton,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: AppColors.error,
                      textColor: Colors.white,
                      text: localization.transferAmountStepSectionDeleteButton,
                      onPressed: () async {
                        Get.back();
                        controller.recipientUidController.clear();
                        createBeneficiaryController.onBeneficiaryCreated = () {
                          controller.fetchBeneficiary();
                        };
                        await createBeneficiaryController.deleteBeneficiary(
                          beneficiaryId: beneficiaryId,
                        );
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

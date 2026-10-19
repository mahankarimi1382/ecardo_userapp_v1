import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

/// Neo-Fintech Review & Confirm Step for Add Money (Deposit).
///
/// Features:
/// - Prominent summary card with live fee breakdown, gateway info, and net deposit amount.
/// - Step-up Biometric authentication + Transaction Passcode gate.
/// - Tactile [EcardoSwipeButton] with drag physics to prevent accidental charges.
/// - Adaptive light/dark styling with [EcardoGlassCard].
class AddMoneyReviewStepSection extends StatefulWidget {
  const AddMoneyReviewStepSection({super.key});

  @override
  State<AddMoneyReviewStepSection> createState() =>
      _AddMoneyReviewStepSectionState();
}

class _AddMoneyReviewStepSectionState extends State<AddMoneyReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  Future<void> _handleConfirmAddMoney(BuildContext context) async {
    HapticFeedback.lightImpact();
    final AddMoneyController controller = Get.find<AddMoneyController>();

    final bioReason = l10nPick(
      context,
      en: 'Authenticate to confirm wallet deposit',
      fa: 'جهت تأیید شارژ کیف پول احراز هویت کنید',
      ar: 'تحقق من الهوية لتأكيد إيداع المحفظة',
      tr: 'Cüzdan yüklemesini onaylamak için doğrulama yapın',
      ru: 'Подтвердите личность для пополнения кошелька',
    );

    // Step-up Security 1: Try Biometric if enabled
    final biometricService = BiometricAuthService();
    try {
      final isBioEnabled = await biometricService.isEnabled();
      if (isBioEnabled) {
        final bioOk = await biometricService.authenticate(reason: bioReason);
        if (bioOk) {
          _executeDeposit(controller);
          return;
        }
      }
    } catch (_) {
      // Fallback to passcode prompt
    }

    // Step-up Security 2: Transaction Passcode verification
    final bool isPasscodeEnabled =
        Get.find<SettingsService>().getSetting("deposit_passcode_status") == "1";

    String? storedPasscode = controller.userModel.value.data?.passcode;
    bool? hasPasscodeFlag = controller.userModel.value.data?.hasPasscode;
    if (storedPasscode == null || storedPasscode.isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        storedPasscode = Get.find<HomeController>().userModel.value.data?.passcode;
        hasPasscodeFlag ??= Get.find<HomeController>().userModel.value.data?.hasPasscode;
      }
    }
    final hasPasscode = PasscodeHelper.userHasPasscode(storedPasscode, hasPasscodeFlag);

    if (isPasscodeEnabled && hasPasscode) {
      final dynamic verified = await Get.bottomSheet<dynamic>(
        const VerifyPasscodeBottomSheet(),
      );
      if (verified == null ||
          !PasscodeHelper.isValidFormat(verified.toString())) {
        _swipeKey.currentState?.reset();
        return;
      }
      _executeDeposit(controller);
    } else {
      _executeDeposit(controller);
    }
  }

  void _executeDeposit(AddMoneyController controller) {
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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final AddMoneyController controller = Get.find<AddMoneyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              localization.addMoneyReviewTitle,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10nPick(
                context,
                en: 'Please verify the deposit details before completing the request.',
                fa: 'لطفاً جزئیات واریز را قبل از اتصال به درگاه بررسی فرمایید.',
                ar: 'يرجى مراجعة تفاصيل الإيداع قبل المتابعة.',
                tr: 'Lütfen devam etmeden önce yükleme ayrıntılarını doğrulayın.',
                ru: 'Пожалуйста, проверьте данные перед подтверждением.',
              ),
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Glassmorphic review card with fee breakdown
            EcardoGlassCard(
              variant: EcardoGlassVariant.standard,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewAmount,
                      content:
                          "${controller.baseAmount.value.toStringAsFixed(controller.gatewayMethod.value?.currencyDecimals ?? 2)} ${controller.gatewayMethod.value?.currency ?? ''}",
                      contentColor: AppColors.success,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewWalletName,
                      content: controller.wallet.value?.name ?? 'Wallet',
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewPaymentMethod,
                      content: controller.gatewayMethod.value?.formattedName ?? '',
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewCharge,
                      content:
                          "${controller.calculatedCharge.value.toStringAsFixed(controller.gatewayMethod.value?.currencyType != "crypto" ? 2 : controller.gatewayMethod.value?.currencyDecimals ?? 2)} ${controller.gatewayMethod.value?.currency ?? ''}",
                      contentColor: AppColors.warning,
                      isBadge: true,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewTotal,
                      content:
                          "${controller.totalAmount.value.toStringAsFixed(controller.gatewayMethod.value?.currencyDecimals ?? 2)} ${controller.gatewayMethod.value?.currency ?? ''}",
                      contentColor: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.brandViolet,
                      isTotal: true,
                    ),
                  ),
                  if (controller.dynamicFieldControllers.isNotEmpty) ...[
                    _buildDivider(isDark),
                    ..._buildDynamicFieldsReview(context, controller, isDark),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Neo-Fintech Swipe to Confirm Button
            Obx(
              () => EcardoSwipeButton(
                key: _swipeKey,
                text: l10nPick(
                  context,
                  en: 'Swipe to Confirm Deposit',
                  fa: 'برای تایید واریز بکشید',
                  ar: 'اسحب لتأكيد الإيداع',
                  tr: 'Yüklemeyi Onaylamak İçin Kaydırın',
                  ru: 'Свайп для подтверждения',
                ),
                loadingText: l10nPick(
                  context,
                  en: 'Processing Deposit...',
                  fa: 'در حال اتصال به درگاه...',
                  ar: 'جارٍ معالجة الإيداع...',
                  tr: 'İşleniyor...',
                  ru: 'Обработка...',
                ),
                isLoading: controller.isPaymentLoading.value,
                onSwipeComplete: () => _handleConfirmAddMoney(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Secondary Back Button
            CommonButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.currentStep.value = 0;
              },
              borderRadius: AppSpacing.radiusLg,
              width: double.infinity,
              height: 48,
              text: localization.addMoneyReviewBack,
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.lightSecondaryContainer.withValues(alpha: 0.6),
              borderColor: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
              borderWidth: 1.0,
              textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }

  List<Widget> _buildDynamicFieldsReview(
    BuildContext context,
    AddMoneyController controller,
    bool isDark,
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

      if (type == 'file') {
        final file = controller.selectedImages[fieldName];
        final fileName =
            file?.path.split('/').last ??
            localization.addMoneyReviewNoFileUploaded;

        widgets.add(
          _buildReviewDynamicContent(
            context,
            isDark: isDark,
            title: fieldName,
            content: fileName,
            contentColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        );
      } else {
        widgets.add(
          _buildReviewDynamicContent(
            context,
            isDark: isDark,
            title: fieldName,
            content: textController.text,
            contentColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        );
      }

      if (i < fields.length - 1) {
        widgets.add(_buildDivider(isDark));
      }
    }

    return widgets;
  }

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String content,
    required Color contentColor,
    bool isTotal = false,
    bool isBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: isBadge
                ? Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: contentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Text(
                        content,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: contentColor,
                        ),
                      ),
                    ),
                  )
                : Text(
                    content,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                      fontSize: isTotal ? 17 : 15,
                      color: contentColor,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}

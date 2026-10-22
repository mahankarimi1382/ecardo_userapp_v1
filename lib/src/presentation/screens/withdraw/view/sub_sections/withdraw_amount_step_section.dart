import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/add_account_dashed_button.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_breakdown_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_limit_progress_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_step_indicator.dart';

class WithdrawAmountStepSection extends StatefulWidget {
  const WithdrawAmountStepSection({super.key});

  @override
  State<WithdrawAmountStepSection> createState() =>
      _WithdrawAmountStepSectionState();
}

class _WithdrawAmountStepSectionState extends State<WithdrawAmountStepSection> {
  final WithdrawController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    controller.amountController.removeListener(_onAmountChanged);
    super.dispose();
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  void _showAccountSelectorBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.8)
                      : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Select Payout Destination',
                    fa: 'انتخاب حساب مقصد برداشت',
                    ar: 'اختر وجهة السحب',
                    tr: 'Çekim Hesabı Seçin',
                    ru: 'Выберите счет для вывода',
                  ),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      "${controller.withdrawAccountList.length} ${l10nPick(context, en: 'Saved', fa: 'ذخیره‌شده', ar: 'محفوظ', tr: 'Kayıtlı', ru: 'Сохранено')}",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Dashed Add New Account CTA
            AddNewAccountDashedButton(
              onTap: () {
                Get.back();
                controller.selectedScreen.value = 2;
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // Accounts List
            Expanded(
              child: Obx(() {
                if (controller.withdrawAccountList.isEmpty) {
                  return Center(
                    child: EcardoEmptyState(
                      title: l10nPick(
                        context,
                        en: 'No Accounts Available',
                        fa: 'حسابی برای انتخاب یافت نشد',
                        ar: 'لا توجد حسابات متاحة',
                        tr: 'Hesap bulunamadı',
                        ru: 'Нет доступных счетов',
                      ),
                      description: l10nPick(
                        context,
                        en: 'Add a new bank account or Sheba to continue.',
                        fa: 'برای ادامه، ابتدا یک شماره شبا یا کارت جدید ثبت کنید.',
                        ar: 'أضف حساباً مصرفياً للمتابعة.',
                        tr: 'Devam etmek için yeni bir hesap ekleyin.',
                        ru: 'Добавьте счет или карту для продолжения.',
                      ),
                      iconData: Icons.account_balance_outlined,
                      primaryActionLabel: l10nPick(
                        context,
                        en: 'Add Account',
                        fa: 'افزودن حساب جدید',
                        ar: 'إضافة حساب',
                        tr: 'Hesap Ekle',
                        ru: 'Добавить счет',
                      ),
                      onPrimaryAction: () {
                        Get.back();
                        controller.selectedScreen.value = 2;
                      },
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.withdrawAccountList.length,
                  itemBuilder: (context, index) {
                    final item = controller.withdrawAccountList[index];
                    final isSelected =
                        controller.withdrawAccount.value?.id == item.id;

                    return WithdrawDestinationCard(
                      account: item,
                      mode: WithdrawCardMode.selectable,
                      isSelected: isSelected,
                      onTap: () {
                        controller.withdrawAccount.value = item;
                        controller.withdrawAccountController.text =
                            item.methodName ?? "";
                        controller.reviewCalculate();
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
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
      child: Obx(
        () => controller.isLoading.value
            ? const CommonLoading()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Indicator (Amount -> Review -> Success)
                    const WithdrawStepIndicator(currentStep: 0),
                    const SizedBox(height: AppSpacing.md),

                    // Section Title: Payout Destination
                    Text(
                      l10nPick(
                        context,
                        en: 'Payout Destination',
                        fa: 'مقصد واریز وجه',
                        ar: 'وجهة استلام السحب',
                        tr: 'Çekim Hedefi',
                        ru: 'Куда перевести',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Destination Card Selector
                    Obx(() {
                      final selectedAccount = controller.withdrawAccount.value;
                      final hasAccount =
                          selectedAccount != null &&
                          controller.withdrawAccountController.text.isNotEmpty;

                      if (hasAccount) {
                        return WithdrawDestinationCard(
                          account: selectedAccount,
                          mode: WithdrawCardMode.selectedBanner,
                          onChange: () =>
                              _showAccountSelectorBottomSheet(context),
                        );
                      }

                      // Empty selector trigger card
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showAccountSelectorBottomSheet(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.lightSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withValues(
                                    alpha: isDark ? 0.20 : 0.12,
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: accentColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10nPick(
                                        context,
                                        en: 'Select Bank Account or Sheba',
                                        fa: 'انتخاب شماره شبا یا کارت بانکی',
                                        ar: 'اختر حساب مصرفي أو آيبان',
                                        tr: 'Banka Hesabı veya IBAN Seçin',
                                        ru: 'Выберите счет или карту',
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      l10nPick(
                                        context,
                                        en: 'Tap to choose payout destination',
                                        fa: 'برای انتخاب یا افزودن مقصد ضربه بزنید',
                                        ar: 'اضغط لاختيار وجهة السحب',
                                        tr: 'Çekim yapılacak hesabı seçmek için dokunun',
                                        ru: 'Нажмите для выбора счета',
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: accentColor,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.lg),

                    // Amount Entry Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            en: 'Withdrawal Amount',
                            fa: 'مبلغ برداشت',
                            ar: 'مبلغ السحب',
                            tr: 'Çekim Tutarı',
                            ru: 'Сумма вывода',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        // Available Balance hint
                        Obx(() {
                          final cur =
                              controller.withdrawAccount.value?.currency ??
                              "USD";
                          final balance = controller.availableBalance;
                          return Text(
                            "${l10nPick(context, en: 'Balance:', fa: 'موجودی:', ar: 'الرصيد:', tr: 'Bakiye:', ru: 'Баланс:')} ${balance.toStringAsFixed(2)} $cur",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Prominent Amount Input Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant.withValues(
                                alpha: 0.5,
                              )
                            : AppColors.lightSecondaryContainer.withValues(
                                alpha: 0.35,
                              ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(
                          color: controller.isAmountFocused.value
                              ? accentColor
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          width: controller.isAmountFocused.value ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonTextInputField(
                            focusNode: controller.amountFocusNode,
                            isFocused: controller.isAmountFocused.value,
                            isSuffixIconCompact: false,
                            suffixIcon:
                                (controller
                                        .withdrawAccount
                                        .value
                                        ?.currency
                                        ?.isNotEmpty ??
                                    false)
                                ? Container(
                                    margin: const EdgeInsetsDirectional.only(
                                      end: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(
                                        alpha: isDark ? 0.20 : 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      controller
                                              .withdrawAccount
                                              .value!
                                              .currency ??
                                          "",
                                      style: TextStyle(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: accentColor,
                                      ),
                                    ),
                                  )
                                : null,
                            borderRadius: AppSpacing.radiusLg,
                            backgroundColor: AppColors.transparent,
                            hintText: "0.00",
                            controller: controller.amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              AmountInputFormatter(maxDecimals: 8),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Quick percentage / amount chips (25%, 50%, 75%, Max / تمام موجودی)
                          _buildQuickPercentageRow(
                            context,
                            isDark,
                            accentColor,
                          ),
                        ],
                      ),
                    ),

                    // Min & Max dynamic limits indicator
                    Obx(() {
                      final withdrawAccount = controller.withdrawAccount.value;
                      final hasAccount =
                          withdrawAccount != null &&
                          controller.withdrawAccountController.text.isNotEmpty;

                      if (!hasAccount) return const SizedBox.shrink();

                      final calculateDecimals = DynamicDecimalsHelper()
                          .getDynamicDecimals(
                            currencyCode: withdrawAccount.currency ?? "",
                            siteCurrencyCode:
                                Get.find<SettingsService>().getSetting(
                                  "site_currency",
                                ) ??
                                "",
                            siteCurrencyDecimals:
                                Get.find<SettingsService>().getSetting(
                                  "site_currency_decimals",
                                ) ??
                                "2",
                            isCrypto: withdrawAccount.method?.isCrypto ?? false,
                          );

                      final min =
                          double.tryParse(
                            withdrawAccount.method?.minWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      final max =
                          double.tryParse(
                            withdrawAccount.method?.maxWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: AppSpacing.xs,
                          start: AppSpacing.xs,
                        ),
                        child: Text(
                          "${localizations.withdrawAmountStepSectionMin} $min ${withdrawAccount.currency ?? ""} | ${localizations.withdrawAmountStepSectionMax} $max ${withdrawAccount.currency ?? ""}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.md),

                    // Dynamic Withdrawal Limit Progress Indicator (used vs available daily limit)
                    Obx(() {
                      final enteredAmount =
                          double.tryParse(
                            controller.amountController.text.trim(),
                          ) ??
                          0.0;
                      final currency =
                          controller.withdrawAccount.value?.currency ?? 'USD';
                      final dailyLimit = controller.dailyLimitMax;
                      final usedLimit = controller.dailyLimitUsed;

                      return WithdrawLimitProgressCard(
                        dailyLimit: dailyLimit,
                        usedLimit: usedLimit,
                        enteredAmount: enteredAmount,
                        currency: currency,
                        decimals: 2,
                      );
                    }),

                    const SizedBox(height: AppSpacing.sm),

                    // Live Fee & Payout Breakdown Card
                    Obx(() {
                      final requested =
                          double.tryParse(
                            controller.amountController.text.trim(),
                          ) ??
                          0.0;
                      final currency =
                          controller.withdrawAccount.value?.currency ?? 'USD';
                      final fee = controller.calculatedCharge.value;
                      final net = requested; // net received by user
                      final settlement =
                          controller.withdrawAccount.value?.method?.time;

                      return WithdrawBreakdownCard(
                        requestedAmount: requested,
                        feeAmount: fee,
                        netPayout: net,
                        currency: currency,
                        settlementTime: settlement,
                        hasFeeError: controller.chargeLoadFailed.value,
                        isFeeLoading: controller.isChargeConverterLoading.value,
                      );
                    }),

                    const SizedBox(height: AppSpacing.xl),

                    // Next / Review Button
                    CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      width: double.infinity,
                      text: l10nPick(
                        context,
                        en: 'Continue to Review',
                        fa: 'ادامه و بررسی جزئیات برداشت',
                        ar: 'متابعة إلى مراجعة السحب',
                        tr: 'İncelemeye Devam Et',
                        ru: 'Продолжить к проверке',
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
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

  /// Builds quick percentage chips (25%, 50%, 75%, Max / تمام موجودی)
  Widget _buildQuickPercentageRow(
    BuildContext context,
    bool isDark,
    Color accentColor,
  ) {
    final chips = [
      {'label': '25%', 'value': 0.25},
      {'label': '50%', 'value': 0.50},
      {'label': '75%', 'value': 0.75},
      {
        'label': l10nPick(
          context,
          en: 'Max',
          fa: 'تمام موجودی',
          ar: 'الكل',
          tr: 'Tümü',
          ru: 'Макс',
        ),
        'value': 1.0,
      },
    ];

    return Row(
      children: chips.map((c) {
        final label = c['label'] as String;
        final fraction = c['value'] as double;
        final isMax = fraction == 1.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.setAmountPercentage(fraction);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isMax
                        ? accentColor.withValues(alpha: isDark ? 0.22 : 0.12)
                        : (isDark ? AppColors.darkCard : AppColors.white),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: isMax
                          ? accentColor.withValues(alpha: 0.5)
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isMax ? 11.5 : 12,
                        fontWeight: isMax ? FontWeight.w800 : FontWeight.w700,
                        color: isMax
                            ? accentColor
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

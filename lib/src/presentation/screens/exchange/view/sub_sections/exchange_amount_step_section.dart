import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/recent_pairs_store.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_swap_card.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';

/// Step 0 — Amount entry.
///
/// Features:
///   - Hero swap card with animated 180° rotation on tap and haptic feedback
///   - Real-time live rate badge
///   - Recent pairs chip row
///   - Quick percentage chips (25%, 50%, 75%, Max) with haptics
///   - Fee & limits summary breakdown
///   - Recoverable error card with retry button
///   - Theme-adaptive design tokens and RTL support
class ExchangeAmountStepSection extends StatefulWidget {
  const ExchangeAmountStepSection({super.key});

  @override
  State<ExchangeAmountStepSection> createState() =>
      _ExchangeAmountStepSectionState();
}

class _ExchangeAmountStepSectionState extends State<ExchangeAmountStepSection> {
  final ExchangeController controller = Get.find();

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
    controller.onAmountChanged(controller.amountController.text);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Obx(() {
      if (controller.walletLoadError.value ||
          (!controller.isLoading.value &&
              controller.fromExchangeWalletsList.isEmpty)) {
        return _WalletLoadErrorCard(onRetry: () => controller.loadData());
      }
      return _normalContent(loc);
    });
  }

  Widget _normalContent(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Hero From ⇄ To Swap Card
          Obx(() {
            return ExchangeSwapCard(
              fromWallet: controller.fromWallet.value,
              toWallet: controller.toWallet.value,
              fromWalletsList: controller.fromExchangeWalletsList,
              toWalletsList: controller.toExchangeWalletsList,
              onFromWalletSelected: (Wallets w) {
                controller.fromWallet.value = w;
                controller.calculateExchange();
              },
              onToWalletSelected: (Wallets w) {
                controller.toWallet.value = w;
                controller.calculateExchange();
              },
              onSwapPressed: controller.swapWallets,
              amountController: controller.amountController,
              amountFocusNode: controller.amountFocusNode,
              isAmountFocused: controller.isAmountFocused.value,
              calculatedToAmount: controller.liveToAmount.value,
              isCalculating: controller.isCalculateExchangeRateLoading.value,
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          // Live rate badge strip
          Obx(() {
            final rateService = controller.rateService;
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: LiveRateBadge(
                fromCode: controller.fromWallet.value?.code ?? '',
                toCode: controller.toWallet.value?.code ?? '',
                rate: controller.currentRate.value,
                direction: controller.rateDirection.value,
                isStale: rateService.isStale.value,
                isDisconnected: rateService.isDisconnected.value,
                lastUpdatedAt: rateService.lastUpdatedAt.value,
                onManualRefresh: () => rateService.forceRefresh(),
                changePercent: controller.liveChangePercent.value,
                fromNameEn: controller.liveFromNameEn.value,
                toNameEn: controller.liveToNameEn.value,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          // Recent pairs — horizontal scrollable chip row. Hidden if empty.
          Obx(() {
            final recentPairs = controller.recentPairs;
            if (recentPairs.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: Text(
                      loc.exchangeRecentPairs,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: ExchangeDesignTokens.textTertiary(context),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentPairs.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, index) {
                        final pair = recentPairs[index];
                        return _RecentPairChip(
                          pair: pair,
                          onTap: () => controller.selectRecentPair(pair),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          // Quick percent chips (25%, 50%, 75%, Max) with haptics
          Obx(() {
            final from = controller.fromWallet.value;
            if (from == null) return const SizedBox.shrink();
            final balance = double.tryParse(from.balance ?? '0') ?? 0.0;
            final fee = controller.charge.value;
            final maxSpendable = (balance - fee > 0) ? (balance - fee) : 0.0;
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 18,
                vertical: AppSpacing.sm,
              ),
              child: QuickAmountSelector(
                textController: controller.amountController,
                availableBalance: balance,
                maxSpendableAmount: maxSpendable,
                isCrypto: from.isCrypto == true,
                currencyCode: from.code,
                maxLabel: loc.exchangeQuickMax,
                labelBuilder: (percent) {
                  if ((percent - 0.25).abs() < 1e-4) {
                    return loc.exchangeQuickPercent25;
                  }
                  if ((percent - 0.50).abs() < 1e-4) {
                    return loc.exchangeQuickPercent50;
                  }
                  if ((percent - 0.75).abs() < 1e-4) {
                    return loc.exchangeQuickPercent75;
                  }
                  if ((percent - 1.0).abs() < 1e-4) return loc.exchangeQuickMax;
                  return '${(percent * 100).round()}%';
                },
                onAmountChanged: (amount) {
                  HapticFeedback.selectionClick();
                  controller.onAmountChanged(controller.amountController.text);
                },
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          // Fee summary + min/max limits
          Obx(() {
            final fromWallet = controller.fromWallet.value;
            if (fromWallet == null) return const SizedBox.shrink();
            return _FeeAndLimitsSummary(
              controller: controller,
              fromWallet: fromWallet,
            );
          }),
          const SizedBox(height: AppSpacing.xxl),
          // Continue button (disabled state when amount is invalid)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: Obx(() {
              final isValid = controller.isAmountValid;
              final isDark = ExchangeDesignTokens.isDark(context);
              final activeBtnBg =
                  isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary;
              final activeBtnText =
                  isDark ? AppColors.deepBlack : AppColors.white;

              return CommonButton(
                borderRadius: AppSpacing.radius,
                width: double.infinity,
                text: loc.exchangeContinue,
                backgroundColor: isValid
                    ? activeBtnBg
                    : activeBtnBg.withValues(alpha: 0.30),
                textColor: isValid
                    ? activeBtnText
                    : activeBtnText.withValues(alpha: 0.60),
                onPressed: isValid
                    ? () {
                        HapticFeedback.lightImpact();
                        controller.nextStepWithValidation();
                      }
                    : () {
                        HapticFeedback.lightImpact();
                        controller.isContinueInvalid.value = true;
                        controller.nextStepWithValidation();
                      },
              );
            }),
          ),
          // Inline error hint shown only after a failed attempt
          Obx(() {
            if (!controller.isContinueInvalid.value) {
              return const SizedBox.shrink();
            }
            if (controller.isAmountValid) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                top: AppSpacing.sm,
                start: 18,
                end: 18,
              ),
              child: Text(
                _validationHint(controller, loc),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  String _validationHint(ExchangeController c, AppLocalizations loc) {
    final amount = double.tryParse(c.amountController.text) ?? 0.0;
    if (amount <= 0) return loc.exchangeValidationEnterAmount;
    final min =
        double.tryParse(c.fromWallet.value?.exchangeLimit?.min ?? '0') ?? 0.0;
    final max =
        double.tryParse(c.fromWallet.value?.exchangeLimit?.max ?? '0') ??
            double.infinity;
    if (amount < min) {
      return loc.exchangeValidationAmountMinimum(
        min.toStringAsFixed(
          c.fromWallet.value?.isCrypto == true ? 8 : 2,
        ),
        c.fromWallet.value?.code ?? '',
      );
    }
    if (amount > max) {
      return loc.exchangeValidationAmountMaximum(
        max.toStringAsFixed(
          c.fromWallet.value?.isCrypto == true ? 8 : 2,
        ),
        c.fromWallet.value?.code ?? '',
      );
    }
    return '';
  }
}

class _RecentPairChip extends StatelessWidget {
  const _RecentPairChip({required this.pair, required this.onTap});

  final RecentPair pair;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${pair.fromCode}-${pair.toCode}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: ExchangeDesignTokens.cardSurface(context),
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: ExchangeDesignTokens.cardBorder(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 13,
                color: ExchangeDesignTokens.textPrimary(context),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ExchangeDesignTokens.textPrimary(context),
                  letterSpacing: 0.3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeAndLimitsSummary extends StatelessWidget {
  const _FeeAndLimitsSummary({
    required this.controller,
    required this.fromWallet,
  });

  final ExchangeController controller;
  final Wallets fromWallet;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = Get.find<SettingsService>();

    final decimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: fromWallet.code ?? '',
      siteCurrencyCode: settings.getSetting("site_currency") ?? "",
      siteCurrencyDecimals:
          settings.getSetting("site_currency_decimals") ?? "2",
      isCrypto: fromWallet.isCrypto ?? false,
    );

    final minStr =
        (double.tryParse(fromWallet.exchangeLimit?.min ?? '0') ?? 0.0)
            .toStringAsFixed(decimals);
    final maxStr =
        (double.tryParse(fromWallet.exchangeLimit?.max ?? '0') ?? 0.0)
            .toStringAsFixed(decimals);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        decoration: BoxDecoration(
          color: ExchangeDesignTokens.cardSurface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: ExchangeDesignTokens.cardBorder(context),
          ),
          boxShadow: ExchangeDesignTokens.cardShadow(context),
        ),
        child: Column(
          children: [
            // Fee row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.exchangeReviewCharge,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ExchangeDesignTokens.textTertiary(context),
                    letterSpacing: 0,
                  ),
                ),
                MoneyDisplayText(
                  amount: controller.charge.value,
                  decimals: decimals,
                  currencyCode: fromWallet.code,
                  integerStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ExchangeDesignTokens.textPrimary(context),
                  ),
                  decimalStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: ExchangeDesignTokens.textTertiary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Divider(
              height: 0,
              color: ExchangeDesignTokens.divider(context),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.exchangeReviewTotalAmount,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ExchangeDesignTokens.textPrimary(context),
                    letterSpacing: 0,
                  ),
                ),
                MoneyDisplayText(
                  amount: controller.totalAmount.value,
                  decimals: decimals,
                  currencyCode: fromWallet.code,
                  integerColor: AppColors.success,
                  decimalColor: AppColors.success.withValues(alpha: 0.55),
                  integerStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.success,
                  ),
                  decimalStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.success.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Min / max row
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: ExchangeDesignTokens.textTertiary(context),
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Expanded(
                  child: Text(
                    '${loc.exchangeMinHint} $minStr ${fromWallet.code ?? ''}  •  ${loc.exchangeMaxHint} $maxStr ${fromWallet.code ?? ''}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ExchangeDesignTokens.textTertiary(context),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Error Card shown when wallet list could not be retrieved.
/// Allows recovery with Retry CTA.
class _WalletLoadErrorCard extends StatelessWidget {
  const _WalletLoadErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    String pick({
      required String en,
      required String fa,
      String? ar,
      String? zh,
    }) =>
        l10nPick(context, en: en, fa: fa, ar: ar, zh: zh);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              pick(
                en: 'Could not load your wallets',
                fa: 'بارگذاری کیف‌ها ناموفق بود',
                ar: 'فشل تحميل المحافظ',
                zh: '钱包加载失败',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ExchangeDesignTokens.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CommonButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              width: 180,
              text: pick(
                en: 'Try again',
                fa: 'تلاش مجدد',
                ar: 'إعادة المحاولة',
                zh: '重试',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

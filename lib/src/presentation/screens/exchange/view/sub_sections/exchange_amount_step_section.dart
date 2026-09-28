import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/recent_pairs_store.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_swap_card.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';

/// Step 0 — Amount entry. Renders the unified swap card with the amount
/// input baked into the FROM side, the live rate badge below it, the fee
/// summary row, min/max hint, and the Continue button (disabled when the
/// amount is invalid — no toast on first tap).
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

    // WAVE-REVIEW: اگر لیست کیف‌ها شکست خورد/خالی ماند، به‌جای کارت مردهٔ
    // «Wallets Not Found» بدون دکمه، کارت خطا + Retry نشان بده.
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // WAVE-REVIEW: قبلاً `Obx(() => ExchangeSwapCard(...))` arrow-form
          // بود — بیلدرش Rx مستقیم می‌خواند و ثبت می‌شد، ولی در v1.0.103
          // improper use از این Obx هم آمد؛ فرم بلاک با خواندن صریح امن‌تر.
          Obx(() {
            debugPrint('EX-DIAG: obx#1 enter');
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
          const SizedBox(height: 16),
          // Live rate badge
          Obx(() {
            debugPrint('EX-DIAG: obx#2 enter');
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
          const SizedBox(height: 16),
          // Recent pairs — horizontal scrollable chip row. Hidden if empty.
          // WAVE-REVIEW: خواندن .value صریح — isEmpty روی RxList در GetX 4.7
          // از طریق proxy ثبت نمی‌شود و Obx «improper use» پرتاب می‌کرد
          // (یکی از دو کارت خطای صفحهٔ اکسچنج).
          Obx(() {
            debugPrint('EX-DIAG: obx#3 enter');
            final recentPairs = controller.recentPairs.value;
            if (recentPairs.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: Text(
                      loc.exchangeRecentPairs,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentPairs.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          // UI-QC 1.0.47: hide inert Rate Alert until backend API exists.
          // Widget retained at exchange/widgets/rate_alert_placeholder.dart.
          const SizedBox.shrink(),
          const SizedBox(height: 16),
          // Quick percent chips
          Obx(() {
            debugPrint('EX-DIAG: obx#4 enter');
            if (controller.fromWallet.value == null) return const SizedBox();
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _QuickChip(
                    label: loc.exchangeQuickPercent25,
                    onTap: () => controller.setAmountPercent(0.25),
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    label: loc.exchangeQuickPercent50,
                    onTap: () => controller.setAmountPercent(0.50),
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    label: loc.exchangeQuickPercent75,
                    onTap: () => controller.setAmountPercent(0.75),
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    label: loc.exchangeQuickMax,
                    onTap: () => controller.setAmountPercent(1.0),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          // Fee summary + min/max
          // WAVE-REVIEW: قبلاً `Obx(() => _FeeAndLimitsSummary(...))` بود —
          // بیلدر هیچ Rx مستقیمی نمی‌خواند (خواندن‌ها در build فرزندِ بعدی
          // بودند، خارج از scope) → GetX «improper use» پرتاب می‌کرد و
          // خلاصهٔ کارمزد/حدود هیچ‌وقت رندر نمی‌شد (کارت خطا به‌جای اعداد).
          // حالا خواندن‌ها مستقیم داخل scope همین Obx است.
          Obx(() {
            debugPrint('EX-DIAG: obx#5 enter');
            final fromWallet = controller.fromWallet.value;
            if (fromWallet == null) return const SizedBox();
            return _FeeAndLimitsSummary(
              controller: controller,
              fromWallet: fromWallet,
            );
          }),
          const SizedBox(height: 24),
          // Continue button (disabled state when amount invalid)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: Obx(() {
              final isValid = controller.isAmountValid;
              return CommonButton(
                borderRadius: 16,
                width: double.infinity,
                text: loc.exchangeContinue,
                backgroundColor: isValid
                    ? AppColors.lightPrimary
                    : AppColors.lightPrimary.withValues(alpha: 0.30),
                textColor: isValid
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.70),
                onPressed: isValid
                    ? () => controller.nextStepWithValidation()
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
            debugPrint('EX-DIAG: obx#6 enter');
            if (!controller.isContinueInvalid.value) return const SizedBox();
            if (controller.isAmountValid) return const SizedBox();
            return Padding(
              padding:
                  const EdgeInsetsDirectional.only(top: 8, start: 18, end: 18),
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
          const SizedBox(height: 40),
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

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.lightPrimary.withValues(alpha: 0.15),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.lightPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightPrimary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 12,
                color: AppColors.lightPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightPrimary,
                  letterSpacing: 0.3,
                  fontFeatures: [FontFeature.tabularFigures()],
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
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
          ),
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
                    color: AppColors.lightTextTertiary,
                    letterSpacing: 0,
                  ),
                ),
                MoneyDisplayText(
                  amount: controller.charge.value,
                  decimals: decimals,
                  currencyCode: fromWallet.code,
                  integerStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.lightTextPrimary,
                  ),
                  decimalStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 0,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 10),
            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.exchangeReviewTotalAmount,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: 0,
                  ),
                ),
                MoneyDisplayText(
                  amount: controller.totalAmount.value,
                  decimals: decimals,
                  currencyCode: fromWallet.code,
                  integerColor: AppColors.success,
                  decimalColor:
                      AppColors.success.withValues(alpha: 0.55),
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
            const SizedBox(height: 12),
            // Min / max — neutral grey, not red
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.lightTextTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${loc.exchangeMinHint} $minStr ${fromWallet.code ?? ''}  •  ${loc.exchangeMaxHint} $maxStr ${fromWallet.code ?? ''}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextTertiary,
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

/// WAVE-REVIEW: کارت خطا + Retry — وقتی کیف‌ها لود نشدند، به‌جای فرم مردهٔ
/// «Wallets Not Found» بدون دکمه، این کارت نمایش داده می‌شود.
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              pick(
                en: 'Could not load your wallets',
                fa: 'بارگذاری کیف‌ها ناموفق بود',
                ar: 'فشل تحميل المحافظ',
                zh: '钱包加载失败',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            CommonButton(
              onPressed: onRetry,
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

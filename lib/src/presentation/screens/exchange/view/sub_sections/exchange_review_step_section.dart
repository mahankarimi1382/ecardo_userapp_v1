import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/currency_sparkline_chart.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/rate_lock_countdown_timer.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

/// Step 1 — Review.
///
/// Features:
///   - Locked-at-confirmation live rate strip with countdown timer & 24h trend sparkline
///   - Rate-drift alert banner (animated appearance when rate drifts or 60s expires)
///   - Glassmorphic review summary card with clear fee and exchange rate breakdown
///   - EcardoSwipeButton for secure confirmation with passcode verification
///   - Full Dark Mode and RTL support with [ExchangeDesignTokens] and [AppSpacing]
class ExchangeReviewStepSection extends StatefulWidget {
  const ExchangeReviewStepSection({super.key});

  @override
  State<ExchangeReviewStepSection> createState() =>
      _ExchangeReviewStepSectionState();
}

class _ExchangeReviewStepSectionState extends State<ExchangeReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final ExchangeController controller = Get.find();
    final settings = Get.find<SettingsService>();

    final fromWallet = controller.fromWallet.value;
    final toWallet = controller.toWallet.value;

    final fromCode = fromWallet?.code ?? 'USD';
    final toCode = toWallet?.code ?? 'IRT';

    final fromDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: fromCode,
      siteCurrencyCode: settings.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals: settings.getSetting("site_currency_decimals") ?? '2',
      isCrypto: fromWallet?.isCrypto ?? false,
    );

    final toDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: toCode,
      siteCurrencyCode: settings.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals: settings.getSetting("site_currency_decimals") ?? '2',
      isCrypto: toWallet?.isCrypto ?? false,
    );

    return Obx(() {
      if (controller.isExchangeConfigLoading.value) {
        return const CommonLoading();
      }

      final isStale = controller.isReviewRateStale.value;
      final isDark = ExchangeDesignTokens.isDark(context);

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                loc.exchangeReviewTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: ExchangeDesignTokens.textPrimary(context),
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Live locked-rate card with countdown timer & 24h trend sparkline
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md + 2),
                decoration: BoxDecoration(
                  color: ExchangeDesignTokens.cardSurface(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: Border.all(
                    color: ExchangeDesignTokens.cardBorder(context),
                  ),
                  boxShadow: ExchangeDesignTokens.cardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.mainSoftBlue.withValues(alpha: 0.16)
                                : AppColors.lightPrimaryContainer
                                    .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.lightPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.exchangeReviewRateLockedAt,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ExchangeDesignTokens.textTertiary(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '1 ${controller.fromWallet.value!.code} = ${controller.exchangeReviewRate.value.toStringAsFixed(toDecimals)} ${controller.toWallet.value!.code}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: ExchangeDesignTokens.textPrimary(
                                    context,
                                  ),
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        RateLockCountdownTimer(
                          key: ValueKey(
                            'rate_lock_${controller.exchangeReviewRate.value}_$isStale',
                          ),
                          duration: const Duration(seconds: 60),
                          size: 36,
                          isExpired: isStale,
                          onExpired: () {
                            controller.isReviewRateStale.value = true;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 24h currency rate trend sparkline chart
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightBackground.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '24h Trend',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      ExchangeDesignTokens.textTertiary(context),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (controller.liveChangePercent.value != null)
                                Text(
                                  '${controller.liveChangePercent.value! >= 0 ? '+' : ''}${controller.liveChangePercent.value!.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: controller.liveChangePercent.value! >=
                                            0
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),
                          CurrencySparklineChart(
                            changePercent: controller.liveChangePercent.value,
                            baseRate: controller.exchangeReviewRate.value > 0
                                ? controller.exchangeReviewRate.value
                                : controller.currentRate.value,
                            height: 38,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Rate-drift alert banner (animated)
              AnimatedSwitcher(
                duration: AppSpacing.normal,
                child: isStale
                    ? _RateDriftBanner(
                        key: const ValueKey('stale_drift_banner'),
                        message: loc.exchangeReviewRateStaleBanner,
                        isLoading: controller.isExchangeConfigLoading.value,
                        onAcknowledge: () async {
                          if (controller.isExchangeConfigLoading.value) return;
                          HapticFeedback.mediumImpact();
                          await controller.acknowledgeRateChange();
                        },
                      )
                    : const SizedBox(
                        key: ValueKey('no_drift'),
                        height: 0,
                      ),
              ),
              if (isStale) const SizedBox(height: AppSpacing.lg),

              // Glassmorphic review summary card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: ExchangeDesignTokens.cardSurface(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                    color: ExchangeDesignTokens.cardBorder(context),
                  ),
                  boxShadow: ExchangeDesignTokens.cardShadow(context),
                ),
                child: Column(
                  children: [
                    _ReviewRow(
                      title: loc.exchangeReviewAmount,
                      amount: double.tryParse(
                            controller.amountController.text,
                          ) ??
                          0.0,
                      decimals: fromDecimals,
                      currencyCode: fromCode,
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewFromWallet,
                      text: fromWallet?.name ?? fromCode,
                      trailing: _WalletMiniBadge(
                        isCrypto: fromWallet?.isCrypto == true,
                      ),
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewCharge,
                      amount: controller.charge.value,
                      decimals: fromDecimals,
                      currencyCode: fromCode,
                      amountColor: AppColors.warning,
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewTotalAmount,
                      amount: controller.totalAmount.value,
                      decimals: fromDecimals,
                      currencyCode: fromCode,
                      amountColor: ExchangeDesignTokens.textPrimary(context),
                      emphasize: true,
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewToWallet,
                      text: toWallet?.name ?? toCode,
                      trailing: _WalletMiniBadge(
                        isCrypto: toWallet?.isCrypto == true,
                      ),
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewExchangeRate,
                      text:
                          '1 $fromCode = ${controller.exchangeReviewRate.value.toStringAsFixed(toDecimals)} $toCode',
                    ),
                    _divider(context),
                    _ReviewRow(
                      title: loc.exchangeReviewExchangeAmount,
                      amount: controller.exchangeAmount.value,
                      decimals: toDecimals,
                      currencyCode: toCode,
                      amountColor: AppColors.success,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Swipe-to-swap confirmation
              Obx(
                () => EcardoSwipeButton(
                  key: _swipeKey,
                  text: loc.exchangeReviewConfirm,
                  loadingText: 'Processing...',
                  successText: 'Confirmed',
                  isLoading: controller.isExchangeWalletLoading.value,
                  enabled: !isStale,
                  onSwipeComplete: () async {
                    HapticFeedback.mediumImpact();

                    final savedPasscode =
                        controller.userModel.value.data?.passcode;
                    final bool hasPasscode =
                        savedPasscode != null &&
                            savedPasscode.isNotEmpty &&
                            savedPasscode != "0";

                    if (!hasPasscode) {
                      controller.exchangeWallet();
                      return;
                    }

                    final bool isPasscodeEnabled =
                        settings.getSetting(
                              "exchange_passcode_status",
                            ) ==
                            "1";

                    if (isPasscodeEnabled) {
                      final String? verifiedPasscode =
                          await Get.bottomSheet<String>(
                        const VerifyPasscodeBottomSheet(),
                      );
                      if (verifiedPasscode == null ||
                          verifiedPasscode.isEmpty) {
                        _swipeKey.currentState?.reset();
                        return;
                      }
                      controller.exchangeWallet(
                        passcode: verifiedPasscode,
                      );
                    } else {
                      controller.exchangeWallet();
                    }
                  },
                  margin: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Back button
              CommonIconButton(
                backgroundColor: isDark
                    ? AppColors.darkCard
                    : AppColors.lightPrimary.withValues(alpha: 0.04),
                borderWidth: 1.5,
                borderColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightPrimary.withValues(alpha: 0.40),
                width: double.infinity,
                height: 52,
                text: loc.exchangeReviewBack,
                icon: PngAssets.reviewArrowBackCommonIcon,
                iconWidth: 18,
                iconHeight: 18,
                iconAndTextSpace: AppSpacing.sm,
                iconColor: ExchangeDesignTokens.textPrimary(context),
                textColor: ExchangeDesignTokens.textPrimary(context),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.backToAmountStep();
                },
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      );
    });
  }

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Divider(
          height: 0,
          color: ExchangeDesignTokens.divider(context),
        ),
      );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.title,
    this.text,
    this.amount,
    this.decimals,
    this.currencyCode,
    this.amountColor,
    this.emphasize = false,
    this.trailing,
  });

  final String title;
  final String? text;
  final double? amount;
  final int? decimals;
  final String? currencyCode;
  final Color? amountColor;
  final bool emphasize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: ExchangeDesignTokens.textTertiary(context),
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: AppSpacing.sm),
          ],
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 16 : 14,
                color: ExchangeDesignTokens.textPrimary(context),
                letterSpacing: 0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else if (amount != null && decimals != null)
            MoneyDisplayText(
              amount: amount!,
              decimals: decimals!,
              currencyCode: currencyCode,
              integerColor:
                  amountColor ?? ExchangeDesignTokens.textPrimary(context),
              decimalColor: (amountColor ??
                      ExchangeDesignTokens.textPrimary(context))
                  .withValues(alpha: 0.55),
              integerStyle: TextStyle(
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 18 : 15,
                color: amountColor ?? ExchangeDesignTokens.textPrimary(context),
              ),
              decimalStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: emphasize ? 14 : 12,
                color: (amountColor ??
                        ExchangeDesignTokens.textPrimary(context))
                    .withValues(alpha: 0.55),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletMiniBadge extends StatelessWidget {
  const _WalletMiniBadge({required this.isCrypto});

  final bool isCrypto;

  @override
  Widget build(BuildContext context) {
    if (!isCrypto) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSecondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: const Text(
        'CRYPTO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.lightSecondary,
        ),
      ),
    );
  }
}

/// Rate-drift alert banner shown when the market price has drifted or the 60s
/// rate lock has elapsed.
class _RateDriftBanner extends StatelessWidget {
  const _RateDriftBanner({
    super.key,
    required this.message,
    required this.onAcknowledge,
    this.isLoading = false,
  });

  final String message;
  final VoidCallback onAcknowledge;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Acknowledge rate change and re-lock',
            child: GestureDetector(
              onTap: isLoading ? null : onAcknowledge,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 32,
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/currency_sparkline_chart.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/rate_lock_countdown_timer.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

/// Step 1 — Review. Shows the locked-at-confirmation rate, a soft banner
/// if the rate has drifted or 60s have passed (with the confirm button
/// disabled until the user re-acknowledges), and the standard list of
/// charge / total / recipient.
class ExchangeReviewStepSection extends StatelessWidget {
  const ExchangeReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final ExchangeController controller = Get.find();
    final settings = Get.find<SettingsService>();

    final fromDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.fromWallet.value!.code!,
      siteCurrencyCode: settings.getSetting("site_currency")!,
      siteCurrencyDecimals: settings.getSetting("site_currency_decimals")!,
      isCrypto: controller.fromWallet.value!.isCrypto!,
    );

    final toDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.toWallet.value!.code!,
      siteCurrencyCode: settings.getSetting("site_currency")!,
      siteCurrencyDecimals: settings.getSetting("site_currency_decimals")!,
      isCrypto: controller.toWallet.value!.isCrypto!,
    );

    return Obx(() {
      if (controller.isExchangeConfigLoading.value) {
        return CommonLoading();
      }

      final isStale = controller.isReviewRateStale.value;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                loc.exchangeReviewTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              // Locked-rate section card with countdown timer & 24h trend sparkline
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightShadow.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimaryContainer
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.exchangeReviewRateLockedAt,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightTextTertiary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '1 ${controller.fromWallet.value!.code} = ${controller.exchangeReviewRate.value.toStringAsFixed(toDecimals)} ${controller.toWallet.value!.code}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        RateLockCountdownTimer(
                          key: ValueKey(
                            'rate_lock_${controller.exchangeReviewRate.value}_$isStale',
                          ),
                          duration: const Duration(seconds: 60),
                          size: 34,
                          isExpired: isStale,
                          onExpired: () {
                            controller.isReviewRateStale.value = true;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 24h currency rate trend sparkline chart
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '24h Trend',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (controller.liveChangePercent.value != null)
                                Text(
                                  '${controller.liveChangePercent.value! >= 0 ? '+' : ''}${controller.liveChangePercent.value!.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: controller.liveChangePercent.value! >= 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
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
              const SizedBox(height: 16),

              // Stale banner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isStale
                    ? _StaleRateBanner(
                        key: const ValueKey('stale_banner'),
                        message: loc.exchangeReviewRateStaleBanner,
                        onAcknowledge: controller.acknowledgeRateChange,
                      )
                    : const SizedBox(
                        key: ValueKey('no_stale'),
                        height: 0,
                      ),
              ),
              if (isStale) const SizedBox(height: 16),

              // Summary card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    _ReviewRow(
                      title: loc.exchangeReviewAmount,
                      amount: double.tryParse(
                        controller.amountController.text,
                      ) ?? 0.0,
                      decimals: fromDecimals,
                      currencyCode: controller.fromWallet.value!.code!,
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewFromWallet,
                      text: controller.fromWallet.value!.name!,
                      trailing: _WalletMiniBadge(
                        isCrypto: controller.fromWallet.value!.isCrypto == true,
                      ),
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewCharge,
                      amount: controller.charge.value,
                      decimals: fromDecimals,
                      currencyCode: controller.fromWallet.value!.code!,
                      amountColor: AppColors.warning,
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewTotalAmount,
                      amount: controller.totalAmount.value,
                      decimals: fromDecimals,
                      currencyCode: controller.fromWallet.value!.code!,
                      amountColor: AppColors.lightTextPrimary,
                      emphasize: true,
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewToWallet,
                      text: controller.toWallet.value!.name!,
                      trailing: _WalletMiniBadge(
                        isCrypto: controller.toWallet.value!.isCrypto == true,
                      ),
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewExchangeRate,
                      text:
                          '1 ${controller.fromWallet.value!.code} = ${controller.exchangeReviewRate.value.toStringAsFixed(toDecimals)} ${controller.toWallet.value!.code}',
                    ),
                    _divider(),
                    _ReviewRow(
                      title: loc.exchangeReviewExchangeAmount,
                      amount: controller.exchangeAmount.value,
                      decimals: toDecimals,
                      currencyCode: controller.toWallet.value!.code!,
                      amountColor: AppColors.success,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CommonIconButton(
                      backgroundColor:
                          AppColors.lightPrimary.withValues(alpha: 0.04),
                      borderWidth: 2,
                      borderColor:
                          AppColors.lightPrimary.withValues(alpha: 0.50),
                      width: double.infinity,
                      height: 52,
                      text: loc.exchangeReviewBack,
                      icon: PngAssets.reviewArrowBackCommonIcon,
                      iconWidth: 18,
                      iconHeight: 18,
                      iconAndTextSpace: 8,
                      iconColor: AppColors.lightTextPrimary,
                      textColor: AppColors.lightTextPrimary,
                      onPressed: controller.backToAmountStep,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => CommonIconButton(
                        // v1.0.24: bind to the submit state — a second tap
                        // while the request is in flight must not fire.
                        isLoading: controller.isExchangeWalletLoading.value,
                        onPressed: isStale
                            ? null
                            : () async {
                                HapticFeedback.mediumImpact();

                                // EX-04: backend semantics — a user has a
                                // transaction passcode only when
                                // users.passcode is non-null/non-empty and
                                // not "0"; null/''/"0" users never see the
                                // modal and never send the field.
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
                                    return;
                                  }
                                  controller.exchangeWallet(
                                    passcode: verifiedPasscode,
                                  );
                                } else {
                                  controller.exchangeWallet();
                                }
                              },
                        width: double.infinity,
                        height: 52,
                        text: loc.exchangeReviewConfirm,
                        icon: PngAssets.reviewArrowRightCommonIcon,
                        iconWidth: 18,
                        iconHeight: 18,
                        iconAndTextSpace: 8,
                        isIconRight: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
    });
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
          height: 0,
          color: AppColors.black.withValues(alpha: 0.06),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 16 : 14,
                color: AppColors.lightTextPrimary,
                letterSpacing: 0,
              ),
            )
          else if (amount != null && decimals != null)
            MoneyDisplayText(
              amount: amount!,
              decimals: decimals!,
              currencyCode: currencyCode,
              integerColor: amountColor ?? AppColors.lightTextPrimary,
              decimalColor: (amountColor ?? AppColors.lightTextPrimary)
                  .withValues(alpha: 0.55),
              integerStyle: TextStyle(
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 18 : 15,
                color: amountColor ?? AppColors.lightTextPrimary,
              ),
              decimalStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: emphasize ? 14 : 12,
                color: (amountColor ?? AppColors.lightTextPrimary)
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
    if (!isCrypto) return const SizedBox();
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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

class _StaleRateBanner extends StatelessWidget {
  const _StaleRateBanner({
    super.key,
    required this.message,
    required this.onAcknowledge,
  });

  final String message;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAcknowledge,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

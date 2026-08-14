import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/wallet_selector_sheet.dart';

/// Unified from/to card with a circular Swap button overlapping the seam.
///
/// Layout (top → bottom):
///   ┌─────────────────────────────────────┐
///   │  FROM  [icon] USDT ▾     [balance]  │  ← gradient + glass overlay
///   │  [Amount input — large, hero]       │
///   ├────[⇅]──────────────────────────────┤
///   │  TO    [icon] BTC  ▾                 │  ← light surface
///   │  You will receive ≈ 0.02340000 BTC  │
///   └─────────────────────────────────────┘
///
/// The swap button is centred on the seam. Tapping it:
///   1. fires [HapticFeedback.selectionClick]
///   2. triggers a 180° rotation animation on the icon
///   3. calls [onSwapPressed] which the controller uses to swap from/to
///
/// The amount input on the FROM side is wired directly to the controller's
/// [TextEditingController] and [FocusNode] passed in — this widget owns no
/// state of its own for the amount.
class ExchangeSwapCard extends StatefulWidget {
  const ExchangeSwapCard({
    super.key,
    required this.fromWallet,
    required this.toWallet,
    required this.fromWalletsList,
    required this.toWalletsList,
    required this.onFromWalletSelected,
    required this.onToWalletSelected,
    required this.onSwapPressed,
    required this.amountController,
    required this.amountFocusNode,
    required this.isAmountFocused,
    required this.calculatedToAmount,
    required this.isCalculating,
    this.fromBalanceLabel,
    this.receiveLabel,
    this.amountHintText,
  });

  final Wallets? fromWallet;
  final Wallets? toWallet;
  final List<Wallets> fromWalletsList;
  final List<Wallets> toWalletsList;

  final void Function(Wallets selected) onFromWalletSelected;
  final void Function(Wallets selected) onToWalletSelected;
  final VoidCallback onSwapPressed;

  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final bool isAmountFocused;

  /// Live calculated destination amount (already debounced upstream).
  final double calculatedToAmount;

  /// True while a conversion API call is in-flight.
  final bool isCalculating;

  /// Optional override labels.
  final String? fromBalanceLabel;
  final String? receiveLabel;
  final String? amountHintText;

  @override
  State<ExchangeSwapCard> createState() => _ExchangeSwapCardState();
}

class _ExchangeSwapCardState extends State<ExchangeSwapCard>
    with TickerProviderStateMixin {
  late final AnimationController _swapRotationController;

  @override
  void initState() {
    super.initState();
    _swapRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _swapRotationController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    HapticFeedback.selectionClick();
    // Restart from current angle so rapid taps override gracefully without
    // queueing (per spec: animations must be interruptible).
    _swapRotationController.forward(from: 0.0);
    widget.onSwapPressed();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _FromCard(
                wallet: widget.fromWallet,
                balanceLabel:
                    widget.fromBalanceLabel ?? loc.exchangeWalletBalance,
                amountHintText: widget.amountHintText ?? '',
                amountController: widget.amountController,
                amountFocusNode: widget.amountFocusNode,
                isAmountFocused: widget.isAmountFocused,
                onTapWallet: () => _openWalletSelector(
                  context: context,
                  isFrom: true,
                ),
              ),
              const SizedBox(height: 2),
              _ToCard(
                wallet: widget.toWallet,
                receiveLabel: widget.receiveLabel ?? loc.exchangeAmountReceive,
                calculatedAmount: widget.calculatedToAmount,
                isCalculating: widget.isCalculating,
                onTapWallet: () => _openWalletSelector(
                  context: context,
                  isFrom: false,
                ),
              ),
            ],
          ),
          // Swap button centred on the seam.
          Positioned(
            top: _kFromCardHeight / 2 - _kSwapButtonSize / 2,
            // Right edge of viewport in LTR, left edge in RTL — but the
            // design intent is "centred horizontally", so we use center.
            left: 0,
            right: 0,
            child: Center(
              child: _SwapButton(
                rotation: _swapRotationController,
                onTap: _handleSwap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openWalletSelector({
    required BuildContext context,
    required bool isFrom,
  }) {
    final loc = AppLocalizations.of(context)!;
    Get.bottomSheet(
      WalletSelectorSheet(
        wallets:
            isFrom ? widget.fromWalletsList : widget.toWalletsList,
        currentlySelectedWalletId:
            (isFrom ? widget.fromWallet : widget.toWallet)?.id,
        notFoundText: loc.exchangeWalletsNotFound,
        onItemSelected: isFrom
            ? widget.onFromWalletSelected
            : widget.onToWalletSelected,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }
}

const double _kFromCardHeight = 220;
const double _kSwapButtonSize = 48;

class _FromCard extends StatelessWidget {
  const _FromCard({
    required this.wallet,
    required this.balanceLabel,
    required this.amountHintText,
    required this.amountController,
    required this.amountFocusNode,
    required this.isAmountFocused,
    required this.onTapWallet,
  });

  final Wallets? wallet;
  final String balanceLabel;
  final String amountHintText;
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final bool isAmountFocused;
  final VoidCallback onTapWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            AppColors.lightPrimary,
            AppColors.lightPrimaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft radial highlight in the top-left — adds depth without
          // an image asset.
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet row
              GestureDetector(
                onTap: onTapWallet,
                child: Row(
                  children: [
                    _WalletIcon(wallet: wallet, onLight: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                wallet?.name ?? '—',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: AppColors.white,
                                  letterSpacing: 0,
                                ),
                              ),
                              if (wallet?.isCrypto == true) ...[
                                const SizedBox(width: 8),
                                _LightCryptoBadge(),
                              ],
                            ],
                          ),
                          Text(
                            '$balanceLabel · ${(wallet?.formattedBalance ?? '0.00')} ${wallet?.code ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white.withValues(alpha: 0.85),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      PngAssets.commonArrowDownIcon,
                      width: 14,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Amount input — large, hero, monospace tabular figures.
              _HeroAmountField(
                controller: amountController,
                focusNode: amountFocusNode,
                isFocused: isAmountFocused,
                currencyCode: wallet?.code ?? '',
                hintText: amountHintText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToCard extends StatelessWidget {
  const _ToCard({
    required this.wallet,
    required this.receiveLabel,
    required this.calculatedAmount,
    required this.isCalculating,
    required this.onTapWallet,
  });

  final Wallets? wallet;
  final String receiveLabel;
  final double calculatedAmount;
  final bool isCalculating;
  final VoidCallback onTapWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(24),
          bottomEnd: Radius.circular(24),
        ),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapWallet,
            child: Row(
              children: [
                _WalletIcon(wallet: wallet, onLight: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            wallet?.name ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.lightTextPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          if (wallet?.isCrypto == true) ...[
                            const SizedBox(width: 8),
                            _DarkCryptoBadge(),
                          ],
                        ],
                      ),
                      Text(
                        receiveLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightTextTertiary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  PngAssets.commonArrowDownIcon,
                  width: 14,
                  color: AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '≈  ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextTertiary,
                ),
              ),
              Expanded(
                child: isCalculating
                    ? _CalculatingPlaceholder()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: MoneyDisplayText(
                          // Key on the rounded amount so AnimatedSwitcher
                          // actually rebuilds when only the value changes
                          // by a meaningful amount.
                          key: ValueKey(
                            calculatedAmount.toStringAsFixed(
                              (wallet?.isCrypto ?? false) ? 8 : 2,
                            ),
                          ),
                          amount: calculatedAmount,
                          decimals: (wallet?.isCrypto ?? false) ? 8 : 2,
                          currencyCode: wallet?.code,
                          integerColor: AppColors.success,
                          decimalColor: AppColors.success.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculatingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.lightPrimary.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'calculating'.tr,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.lightTextTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WalletIcon extends StatelessWidget {
  const _WalletIcon({required this.wallet, required this.onLight});

  final Wallets? wallet;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    if (wallet == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: 18,
          color: AppColors.lightTextTertiary,
        ),
      );
    }

    if (wallet!.isDefault == true) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onLight ? AppColors.white : AppColors.lightBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.lightPrimary.withValues(alpha: 0.20),
          ),
        ),
        child: Center(
          child: Text(
            wallet!.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.lightPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          shape: BoxShape.circle,
        ),
        child: wallet!.icon != null && wallet!.icon!.isNotEmpty
            ? Image.network(
                wallet!.icon!,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    PngAssets.commonErrorIcon,
                    color: AppColors.error.withValues(alpha: 0.7),
                  );
                },
              )
            : Center(
                child: Text(
                  (wallet!.code ?? '?').characters.first.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.rotation, required this.onTap});

  final Animation<double> rotation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kSwapButtonSize,
        height: _kSwapButtonSize,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.lightPrimary.withValues(alpha: 0.18),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightPrimary.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: rotation,
          builder: (context, child) {
            return Transform.rotate(
              angle: rotation.value * 3.14159265, // π radians = 180°
              child: child,
            );
          },
          child: const Icon(
            Icons.swap_vert_rounded,
            size: 24,
            color: AppColors.lightPrimary,
          ),
        ),
      ),
    );
  }
}

class _LightCryptoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'CRYPTO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DarkCryptoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

class _HeroAmountField extends StatelessWidget {
  const _HeroAmountField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.currencyCode,
    required this.hintText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String currencyCode;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // Subtle glassmorphism layer only on this hero field, per spec.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white.withValues(
                alpha: isFocused ? 0.45 : 0.18,
              ),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: AppColors.white,
                    letterSpacing: 0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hintText.isEmpty ? '0' : hintText,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: AppColors.white.withValues(alpha: 0.35),
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyCode,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

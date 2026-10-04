import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/wallet_selector_sheet.dart';

/// Unified From ⇄ To card with a hero Swap button overlapping the seam.
///
/// Features:
///   - 180° animated rotation + haptic feedback on swap
///   - Frosted glassmorphism on the Hero Amount field
///   - Full Dark Mode and RTL directional layout
///   - M3 design token adoption from [AppSpacing] and [ExchangeDesignTokens]
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
  late final AnimationController _swapScaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _swapRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _swapScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _swapScaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _swapRotationController.dispose();
    _swapScaleController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    HapticFeedback.mediumImpact();

    // Micro-interaction: scale down and pop back
    _swapScaleController.forward().then((_) {
      if (mounted) _swapScaleController.reverse();
    });

    // Smooth 180° rotation
    _swapRotationController.forward(from: 0.0);
    widget.onSwapPressed();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          // Swap button sits in the seam between the two cards
          Transform.translate(
            offset: const Offset(0, -_kSwapButtonSize / 2),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _SwapButton(
                  rotation: _swapRotationController,
                  onTap: _handleSwap,
                ),
              ),
            ),
          ),
          // Pull the to-card up by half the swap button's height to seal the seam
          Transform.translate(
            offset: const Offset(0, -_kSwapButtonSize / 2),
            child: _ToCard(
              wallet: widget.toWallet,
              receiveLabel:
                  widget.receiveLabel ?? loc.exchangeAmountReceive,
              calculatedAmount: widget.calculatedToAmount,
              isCalculating: widget.isCalculating,
              onTapWallet: () => _openWalletSelector(
                context: context,
                isFrom: false,
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
        wallets: isFrom ? widget.fromWalletsList : widget.toWalletsList,
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

const double _kSwapButtonSize = 48.0;

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
    final isDark = ExchangeDesignTokens.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        gradient: ExchangeDesignTokens.gradientFor(
          Theme.of(context).brightness,
        ),
        boxShadow: ExchangeDesignTokens.heroCardShadow(context),
      ),
      child: Stack(
        children: [
          // Soft radial highlight in the leading-top corner
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: -40,
            start: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ExchangeDesignTokens.softHighlightFor(
                  Theme.of(context).brightness,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet selector button with minimum 44px touch target
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  onTap: onTapWallet,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        _WalletIcon(wallet: wallet, onLight: true),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      wallet?.name ?? '—',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: AppColors.white,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  if (wallet?.isCrypto == true) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    const _LightCryptoBadge(),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$balanceLabel · ${(wallet?.formattedBalance ?? '0.00')} ${wallet?.code ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white.withValues(
                                    alpha: isDark ? 0.75 : 0.88,
                                  ),
                                  letterSpacing: 0,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            PngAssets.commonArrowDownIcon,
                            width: 14,
                            color: AppColors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Hero Amount input field with glassmorphic overlay
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
    return EcardoGlassCard(
      variant: EcardoGlassVariant.frosted,
      blur: 16.0,
      borderRadius: 0,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.xxl + 4,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      shadows: ExchangeDesignTokens.cardShadow(context),
      backgroundColor: ExchangeDesignTokens.cardSurface(context),
      interactive: false,
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: onTapWallet,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    _WalletIcon(wallet: wallet, onLight: false),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  wallet?.name ?? '—',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: ExchangeDesignTokens.textPrimary(
                                      context,
                                    ),
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              if (wallet?.isCrypto == true) ...[
                                const SizedBox(width: AppSpacing.sm),
                                const _DarkCryptoBadge(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            receiveLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: ExchangeDesignTokens.textTertiary(context),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: ExchangeDesignTokens.textPrimary(context)
                            .withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        PngAssets.commonArrowDownIcon,
                        width: 14,
                        color: ExchangeDesignTokens.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '≈  ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ExchangeDesignTokens.textTertiary(context),
                ),
              ),
              Expanded(
                child: isCalculating
                    ? _CalculatingPlaceholder()
                    : AnimatedSwitcher(
                        duration: AppSpacing.normal,
                        child: MoneyDisplayText(
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
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ExchangeDesignTokens.textPrimary(context)
                .withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          loc.exchangeCalculating,
          style: TextStyle(
            fontSize: 13,
            color: ExchangeDesignTokens.textTertiary(context),
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
    final isDark = ExchangeDesignTokens.isDark(context);

    if (wallet == null) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onLight
              ? Colors.white.withValues(alpha: 0.15)
              : ExchangeDesignTokens.textPrimary(context).withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: 18,
          color: onLight
              ? Colors.white.withValues(alpha: 0.7)
              : ExchangeDesignTokens.textTertiary(context),
        ),
      );
    }

    if (wallet!.isDefault == true) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onLight
              ? Colors.white
              : (isDark ? AppColors.darkCard : AppColors.lightBackground),
          shape: BoxShape.circle,
          border: Border.all(
            color: onLight
                ? Colors.white.withValues(alpha: 0.40)
                : ExchangeDesignTokens.cardBorder(context),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            wallet!.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onLight
                  ? AppColors.lightPrimary
                  : ExchangeDesignTokens.textPrimary(context),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onLight
              ? Colors.white.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground),
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
                  ((wallet!.code?.isNotEmpty ?? false)
                          ? wallet!.code!.characters.first
                          : '?')
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: onLight
                        ? Colors.white
                        : ExchangeDesignTokens.textTertiary(context),
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
    final isDark = ExchangeDesignTokens.isDark(context);

    return Semantics(
      button: true,
      label: 'Swap wallets',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: _kSwapButtonSize,
          height: _kSwapButtonSize,
          decoration: BoxDecoration(
            color: ExchangeDesignTokens.swapButtonBg(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: ExchangeDesignTokens.swapButtonBorder(context),
              width: 2.0,
            ),
            boxShadow: ExchangeDesignTokens.swapButtonShadow(context),
          ),
          child: AnimatedBuilder(
            animation: rotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotation.value * 3.14159265, // 180° = π rad
                child: child,
              );
            },
            child: Icon(
              Icons.swap_vert_rounded,
              size: 24,
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LightCryptoBadge extends StatelessWidget {
  const _LightCryptoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
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
  const _DarkCryptoBadge();

  @override
  Widget build(BuildContext context) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: AppSpacing.fast,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isFocused
                ? ExchangeDesignTokens.glassOverlayFocused(context)
                : ExchangeDesignTokens.glassOverlay(context),
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: ExchangeDesignTokens.glassBorder(
                context,
                isFocused: isFocused,
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
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  currencyCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

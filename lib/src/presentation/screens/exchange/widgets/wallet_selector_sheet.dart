import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Bottom sheet for selecting a source or target wallet in the exchange module.
///
/// Features:
///   - Clear separation between Fiat and Crypto assets
///   - Adaptive Dark Mode and RTL support
///   - Touch target >= 44x44
///   - Haptic feedback on selection
class WalletSelectorSheet extends StatefulWidget {
  const WalletSelectorSheet({
    super.key,
    required this.wallets,
    this.currentlySelectedWalletId,
    required this.onItemSelected,
    required this.notFoundText,
    this.fiatHeader,
    this.cryptoHeader,
  });

  /// The full list of wallets available for this slot (from / to).
  final List<Wallets> wallets;

  /// ID of the currently selected wallet, used to highlight.
  final int? currentlySelectedWalletId;

  final void Function(Wallets selected) onItemSelected;

  /// Empty-state message.
  final String notFoundText;

  /// Optional override for the fiat section header label.
  final String? fiatHeader;

  /// Optional override for the crypto section header label.
  final String? cryptoHeader;

  @override
  State<WalletSelectorSheet> createState() => _WalletSelectorSheetState();
}

class _WalletSelectorSheetState extends State<WalletSelectorSheet> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = ExchangeDesignTokens.isDark(context);

    final fiat = widget.wallets.where((w) => w.isCrypto != true).toList();
    final crypto = widget.wallets.where((w) => w.isCrypto == true).toList();

    return AnimatedContainer(
      duration: AppSpacing.normal,
      curve: Curves.easeOutQuart,
      height: MediaQuery.of(context).size.height * 0.75,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: ExchangeDesignTokens.cardSurface(context),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppColors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: ExchangeDesignTokens.textPrimary(context)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.commonDropdownWalletTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: ExchangeDesignTokens.textPrimary(context),
                    letterSpacing: 0,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Close wallet selector',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => Get.back(),
                    child: Tooltip(
                      message: l10nPick(context, en: 'Close', fa: 'بستن'),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Image.asset(
                            PngAssets.closeCommonIcon,
                            width: 24,
                            color: ExchangeDesignTokens.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            margin: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
            ),
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ExchangeDesignTokens.divider(context),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          if (widget.wallets.isEmpty)
            _EmptyState(notFoundText: widget.notFoundText)
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.lg,
                  end: AppSpacing.lg,
                  top: AppSpacing.xl,
                  bottom: AppSpacing.xxl,
                ),
                children: [
                  if (fiat.isNotEmpty) ...[
                    _SectionHeader(
                      label: widget.fiatHeader ?? loc.exchangeWalletSectionFiat,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...fiat.map(
                      (w) => _WalletRow(
                        wallet: w,
                        isSelected: widget.currentlySelectedWalletId == w.id,
                        onSelected: _handleSelect,
                      ),
                    ),
                    if (crypto.isNotEmpty) const SizedBox(height: AppSpacing.xl),
                  ],
                  if (crypto.isNotEmpty) ...[
                    _SectionHeader(
                      label: widget.cryptoHeader ??
                          loc.exchangeWalletSectionCrypto,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...crypto.map(
                      (w) => _WalletRow(
                        wallet: w,
                        isSelected: widget.currentlySelectedWalletId == w.id,
                        onSelected: _handleSelect,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleSelect(Wallets w) {
    HapticFeedback.selectionClick();
    widget.onItemSelected(w);
    Get.back();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: ExchangeDesignTokens.textTertiary(context),
        ),
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.wallet,
    required this.isSelected,
    required this.onSelected,
  });

  final Wallets wallet;
  final bool isSelected;
  final void Function(Wallets) onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = ExchangeDesignTokens.isDark(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm + 2),
      child: AnimatedContainer(
        duration: AppSpacing.fast,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.mainSoftBlue.withValues(alpha: 0.16)
                  : AppColors.lightPrimary.withValues(alpha: 0.08))
              : (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.50)
                      : AppColors.lightPrimary.withValues(alpha: 0.30),
                  width: 1.5,
                )
              : Border.all(
                  color: ExchangeDesignTokens.cardBorder(context),
                  width: 1.0,
                ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            onTap: () => onSelected(wallet),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md + 2,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  _WalletAvatar(wallet: wallet),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                wallet.name ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.mainSoftBlue
                                          : AppColors.lightPrimary)
                                      : ExchangeDesignTokens.textPrimary(
                                          context,
                                        ),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            if (wallet.isCrypto == true) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const _CryptoBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${wallet.formattedBalance ?? '0.00'} ${wallet.code ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ExchangeDesignTokens.textTertiary(context),
                            letterSpacing: 0,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: isDark ? AppColors.deepBlack : AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletAvatar extends StatelessWidget {
  const _WalletAvatar({required this.wallet});

  final Wallets wallet;

  @override
  Widget build(BuildContext context) {
    final isDark = ExchangeDesignTokens.isDark(context);

    if (wallet.isDefault == true) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark
                ? AppColors.mainSoftBlue.withValues(alpha: 0.35)
                : AppColors.lightPrimary.withValues(alpha: 0.20),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            wallet.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0,
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
          color: isDark ? AppColors.darkCard : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: wallet.icon != null && wallet.icon!.isNotEmpty
            ? Image.network(
                wallet.icon!,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    PngAssets.commonErrorIcon,
                    color: AppColors.error.withValues(alpha: 0.7),
                  );
                },
              )
            : Center(
                child: Text(
                  ((wallet.code?.isNotEmpty ?? false)
                          ? wallet.code!.characters.first
                          : '?')
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: ExchangeDesignTokens.textTertiary(context),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CryptoBadge extends StatelessWidget {
  const _CryptoBadge();

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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.notFoundText});

  final String notFoundText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 60),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44,
            color: ExchangeDesignTokens.textTertiary(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            notFoundText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ExchangeDesignTokens.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

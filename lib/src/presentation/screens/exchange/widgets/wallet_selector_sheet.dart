import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';

/// Replacement for [CommonDropdownWalletBottomSheet] inside the exchange
/// module. Splits the list into two groups — fiat and crypto — with explicit
/// section headers. Each row shows:
///   - currency icon (network logo for crypto, flag/symbol for fiat)
///   - currency name
///   - balance (formatted with locale)
///   - small badge: `کریپتو` for crypto, no badge for fiat (the icon
///     already differentiates)
///
/// The selected row gets a primary-tinted background and a tick — same
/// affordance as the legacy sheet, but with the new typographic system.
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

  /// Optional override for the fiat section header label. Defaults to
  /// localized "Fiat currencies".
  final String? fiatHeader;

  /// Optional override for the crypto section header label. Defaults to
  /// localized "Crypto assets".
  final String? cryptoHeader;

  @override
  State<WalletSelectorSheet> createState() => _WalletSelectorSheetState();
}

class _WalletSelectorSheetState extends State<WalletSelectorSheet> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final fiat = widget.wallets.where((w) => w.isCrypto != true).toList();
    final crypto = widget.wallets.where((w) => w.isCrypto == true).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: MediaQuery.of(context).size.height * 0.75,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.commonDropdownWalletTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: 0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 28,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightTextPrimary.withValues(alpha: 0.10),
                  AppColors.white,
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
                  start: 18,
                  end: 18,
                  top: 20,
                  bottom: 24,
                ),
                children: [
                  if (fiat.isNotEmpty) ...[
                    _SectionHeader(
                      label: widget.fiatHeader ??
                          loc.exchangeWalletSectionFiat,
                    ),
                    const SizedBox(height: 10),
                    ...fiat.map(
                      (w) => _WalletRow(
                        wallet: w,
                        isSelected: widget.currentlySelectedWalletId == w.id,
                        onSelected: _handleSelect,
                      ),
                    ),
                    if (crypto.isNotEmpty) const SizedBox(height: 24),
                  ],
                  if (crypto.isNotEmpty) ...[
                    _SectionHeader(
                      label: widget.cryptoHeader ??
                          loc.exchangeWalletSectionCrypto,
                    ),
                    const SizedBox(height: 10),
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
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.lightTextTertiary,
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
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPrimary.withValues(alpha: 0.08)
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.lightPrimary.withValues(alpha: 0.30),
                  width: 1.5,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            onTap: () => onSelected(wallet),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _WalletAvatar(wallet: wallet),
                  const SizedBox(width: 12),
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
                                      ? AppColors.lightPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            if (wallet.isCrypto == true) ...[
                              const SizedBox(width: 8),
                              _CryptoBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wallet.formattedBalance ?? '0.00'} ${wallet.code ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextTertiary,
                            letterSpacing: 0,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Image.asset(
                      PngAssets.commonDropdownTickIcon,
                      width: 20,
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
    if (wallet.isDefault == true) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.lightPrimary.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            wallet.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.lightPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
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
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _CryptoBadge extends StatelessWidget {
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
      child: Text(
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
            size: 40,
            color: AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            notFoundText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

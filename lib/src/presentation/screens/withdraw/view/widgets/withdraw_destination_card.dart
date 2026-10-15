import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

enum WithdrawCardMode {
  management,
  selectable,
  selectedBanner,
  review,
}

/// A luxury neo-fintech card for saved bank accounts, Sheba, IBAN, and payout destinations.
class WithdrawDestinationCard extends StatelessWidget {
  final Accounts account;
  final WithdrawCardMode mode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChange;

  const WithdrawDestinationCard({
    super.key,
    required this.account,
    this.mode = WithdrawCardMode.selectable,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onChange,
  });

  static String maskAccountNumber(dynamic account) {
    if (account == null) return '';

    String rawValue = '';
    if (account is String) {
      rawValue = account.trim();
    } else if (account is Accounts) {
      if (account.method?.fields != null) {
        for (final f in account.method!.fields!) {
          final name = (f.name ?? '').toLowerCase();
          if ((name.contains('account') ||
                  name.contains('iban') ||
                  name.contains('sheba') ||
                  name.contains('shaba') ||
                  name.contains('card') ||
                  name.contains('number') ||
                  name.contains('wallet') ||
                  name.contains('address')) &&
              f.value != null &&
              f.value!.trim().isNotEmpty) {
            rawValue = f.value!.trim();
            break;
          }
        }
        if (rawValue.isEmpty) {
          for (final f in account.method!.fields!) {
            if (f.value != null &&
                f.value!.trim().isNotEmpty &&
                f.type != 'file') {
              rawValue = f.value!.trim();
              break;
            }
          }
        }
      }

      if (rawValue.isEmpty) {
        if (account.walletName != null && account.walletName!.isNotEmpty) {
          return account.walletName!;
        }
        return '•••• •••• •••• 4242';
      }
    } else {
      rawValue = account.toString().trim();
    }

    // Sheba formatting (e.g. IR820170000000123456789012)
    final upper = rawValue.toUpperCase();
    if (upper.startsWith('IR') && upper.length >= 10) {
      final prefix = upper.substring(0, 4);
      final suffix = upper.substring(upper.length - 4);
      return '$prefix •••• •••• •••• $suffix';
    }

    // 16-digit card number
    final digitsOnly = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 16) {
      return '•••• •••• •••• ${digitsOnly.substring(12)}';
    }

    // Crypto address
    if (rawValue.length > 20) {
      return '${rawValue.substring(0, 6)}••••${rawValue.substring(rawValue.length - 4)}';
    }

    // General account masking
    if (rawValue.length > 6) {
      final prefix = rawValue.substring(0, 2);
      final suffix = rawValue.substring(rawValue.length - 3);
      return '$prefix•• •••• $suffix';
    }

    return rawValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final methodName = account.methodName ?? account.method?.name ?? 'Bank Account';
    final currency = account.currency ?? 'USD';
    final maskedAccount = maskAccountNumber(account);
    final settlementTime = account.method?.time ??
        l10nPick(
          context,
          en: 'Instant',
          fa: 'آنی',
          ar: 'فوري',
          tr: 'Anında',
          ru: 'Мгновенно',
        );

    final isHighlight = isSelected || mode == WithdrawCardMode.selectedBanner;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? (isHighlight
                ? AppColors.darkSurfaceVariant
                : AppColors.darkCard)
            : (isHighlight
                ? AppColors.white
                : AppColors.lightCard),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isHighlight
              ? accentColor.withValues(alpha: isDark ? 0.75 : 0.60)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isHighlight ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlight
                ? accentColor.withValues(alpha: isDark ? 0.22 : 0.10)
                : (isDark ? Colors.black.withValues(alpha: 0.20) : AppColors.lightShadow),
            blurRadius: isHighlight ? 14 : 6,
            spreadRadius: isHighlight ? 0 : -2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: mode == WithdrawCardMode.selectedBanner
                  ? AppSpacing.md
                  : AppSpacing.lg,
            ),
            child: Row(
              children: [
                // Bank Logo / Monogram Avatar Container
                _buildLogoAvatar(isDark, methodName),
                const SizedBox(width: AppSpacing.md),

                // Method & Account details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              methodName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          // Currency Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.20 : 0.10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXs),
                            ),
                            child: Text(
                              currency,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Masked Account / IBAN
                      Text(
                        maskedAccount,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Settlement speed tag & wallet
                      Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            settlementTime,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                          if (account.walletName != null &&
                              account.walletName!.isNotEmpty) ...[
                            Text(
                              '  •  ${account.walletName!}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Trailing section depending on mode
                _buildTrailingSection(context, isDark, accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAvatar(bool isDark, String name) {
    final iconUrl = account.method?.icon;
    final hasValidIcon = iconUrl != null &&
        iconUrl.isNotEmpty &&
        (iconUrl.startsWith('http') || iconUrl.startsWith('https'));

    if (hasValidIcon) {
      return Container(
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: CachedNetworkImage(
            imageUrl: iconUrl,
            fit: BoxFit.contain,
            placeholder: (context, _) => MonogramAvatar(
              name: name,
              size: 36,
              isVerified: true,
            ),
            errorWidget: (context, _, error) => MonogramAvatar(
              name: name,
              size: 36,
              isVerified: true,
            ),
          ),
        ),
      );
    }

    return MonogramAvatar(
      name: name,
      size: 46,
      isVerified: true,
    );
  }

  Widget _buildTrailingSection(
    BuildContext context,
    bool isDark,
    Color accentColor,
  ) {
    switch (mode) {
      case WithdrawCardMode.management:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onEdit!();
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                  ),
                  child: Image.asset(
                    PngAssets.editCommonIcon,
                    color: accentColor,
                  ),
                ),
              ),
            if (onDelete != null) ...[
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDelete!();
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    color: AppColors.error.withValues(alpha: 0.12),
                  ),
                  child: Image.asset(
                    PngAssets.invoiceDeleteIcon,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        );

      case WithdrawCardMode.selectable:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? accentColor : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 2,
            ),
          ),
          child: isSelected
              ? const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                )
              : null,
        );

      case WithdrawCardMode.selectedBanner:
        return InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          onTap: () {
            HapticFeedback.lightImpact();
            if (onChange != null) {
              onChange!();
            } else if (onTap != null) {
              onTap!();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Change',
                    fa: 'تغییر',
                    ar: 'تغيير',
                    tr: 'Değiştir',
                    ru: 'Изменить',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
        );

      case WithdrawCardMode.review:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                l10nPick(
                  context,
                  en: 'Verified',
                  fa: 'تأییدشده',
                  ar: 'تم التحقق',
                  tr: 'Doğrulandı',
                  ru: 'Подтверждено',
                ),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
    }
  }
}

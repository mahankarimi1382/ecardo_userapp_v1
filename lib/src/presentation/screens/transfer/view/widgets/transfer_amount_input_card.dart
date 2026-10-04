import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';

/// Big, beautiful FinTech hero amount input card with currency prefix/suffix,
/// clear button, available balance chip, quick percentage chips, and live fee estimation.
class TransferAmountInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Wallets? wallet;
  final double charge;
  final double totalAmount;
  final bool chargeLoadFailed;
  final int decimals;
  final ValueChanged<double> onPercentageSelected;
  final VoidCallback onClear;

  const TransferAmountInputCard({
    super.key,
    required this.controller,
    required this.focusNode,
    this.wallet,
    this.charge = 0.0,
    this.totalAmount = 0.0,
    this.chargeLoadFailed = false,
    this.decimals = 2,
    required this.onPercentageSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final currencyCode = wallet?.code ?? '';
    final currencySymbol = wallet?.symbol ?? '';
    final balanceText = wallet?.formattedBalance ?? '0.00';
    final hasAmount = controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.35)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: focusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
          width: focusNode.hasFocus ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow)
                .withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Available Balance Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Amount',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPercentageSelected(1.0); // Use 100% max
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 13,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Bal: $balanceText $currencyCode',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Big Hero Amount Input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (currencySymbol.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                  child: Text(
                    currencySymbol,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [AmountInputFormatter(maxDecimals: 8)],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface.withValues(alpha: 0.25),
                        letterSpacing: -0.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              if (hasAmount)
                IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onClear();
                  },
                )
              else if (currencyCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      currencyCode,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick Percentage Chips
          _QuickPercentageRow(
            onSelect: onPercentageSelected,
          ),
          const SizedBox(height: AppSpacing.md),

          // Live Fee Estimation Pill
          _LiveFeeEstimationPill(
            charge: charge,
            totalAmount: totalAmount,
            currencyCode: currencyCode,
            decimals: decimals,
            chargeLoadFailed: chargeLoadFailed,
            wallet: wallet,
          ),
        ],
      ),
    );
  }
}

class _QuickPercentageRow extends StatelessWidget {
  final ValueChanged<double> onSelect;

  const _QuickPercentageRow({
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final chips = [
      {'label': '25%', 'value': 0.25},
      {'label': '50%', 'value': 0.50},
      {'label': '75%', 'value': 0.75},
      {'label': 'Max', 'value': 1.0},
    ];

    return Row(
      children: chips.map((c) {
        final label = c['label'] as String;
        final value = c['value'] as double;
        final isMax = label == 'Max';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isMax
                        ? colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark
                            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
                            : colorScheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isMax
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: isMax ? FontWeight.w800 : FontWeight.w600,
                        color: isMax ? colorScheme.primary : colorScheme.onSurface,
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

class _LiveFeeEstimationPill extends StatelessWidget {
  final double charge;
  final double totalAmount;
  final String currencyCode;
  final int decimals;
  final bool chargeLoadFailed;
  final Wallets? wallet;

  const _LiveFeeEstimationPill({
    required this.charge,
    required this.totalAmount,
    required this.currencyCode,
    required this.decimals,
    required this.chargeLoadFailed,
    this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isFree = charge <= 0.0 && !chargeLoadFailed;
    final feeText = chargeLoadFailed
        ? '—'
        : isFree
            ? 'Free'
            : '${charge.toStringAsFixed(decimals)} $currencyCode';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 15,
                    color: isFree ? AppColors.success : colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Transfer Fee',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFree
                      ? AppColors.successContainer
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  feeText,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isFree ? AppColors.success : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (wallet?.transferLimit != null) ...[
            const SizedBox(height: 6),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Limits',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${wallet!.transferLimit!.min ?? '0'} – ${wallet!.transferLimit!.max ?? '∞'} $currencyCode',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

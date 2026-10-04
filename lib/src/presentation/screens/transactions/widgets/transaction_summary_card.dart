import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_glass_card.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';

/// Neo-fintech Glassmorphic Activity Flow Summary Banner.
///
/// Computes and displays total inflow (credit) and outflow (debit)
/// for the current transactions list with directional trend metrics.
class TransactionSummaryCard extends StatelessWidget {
  final List<Transactions> transactions;

  const TransactionSummaryCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate metrics
    int totalCount = transactions.length;
    int inflowCount = 0;
    int outflowCount = 0;
    double totalInflow = 0.0;
    double totalOutflow = 0.0;

    String currencySymbol = '';
    for (final tx in transactions) {
      if (currencySymbol.isEmpty && tx.trxCurrencySymbol != null) {
        currencySymbol = tx.trxCurrencySymbol!;
      }
      final amount = tx.numericAmount;
      if (tx.isPlus == true) {
        inflowCount++;
        totalInflow += amount;
      } else {
        outflowCount++;
        totalOutflow += amount;
      }
    }
    if (currencySymbol.isEmpty) currencySymbol = '\$';

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
      child: EcardoGlassCard(
        variant: EcardoGlassVariant.accent,
        borderRadius: AppSpacing.radiusLg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Count Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mainSoftBlue.withValues(alpha: 0.22)
                            : AppColors.mutedBlue.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        size: AppSpacing.iconXs,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.deepBlack,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10nPick(
                        context,
                        en: 'Activity Summary',
                        fa: 'گردش مالی',
                        ar: 'ملخص النشاط',
                      ),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$totalCount ${l10nPick(context, en: 'items', fa: 'تراکنش', ar: 'عنصر')}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Inflow & Outflow Metrics Row
            Row(
              children: [
                // Inflow Column
                Expanded(
                  child: _MetricTile(
                    label: l10nPick(
                      context,
                      en: 'Total Inflow',
                      fa: 'مجموع دریافتی',
                      ar: 'إجمالي الوارد',
                    ),
                    amount: '+$currencySymbol${_formatCompact(totalInflow)}',
                    countLabel: '$inflowCount ${l10nPick(context, en: 'in', fa: 'ورودی', ar: 'وارد')}',
                    color: AppColors.success,
                    icon: Icons.arrow_downward_rounded,
                    isDark: isDark,
                  ),
                ),
                Container(
                  height: 48,
                  width: 1,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider.withValues(alpha: 0.6),
                ),
                // Outflow Column
                Expanded(
                  child: _MetricTile(
                    label: l10nPick(
                      context,
                      en: 'Total Outflow',
                      fa: 'مجموع پرداختی',
                      ar: 'إجمالي الصادر',
                    ),
                    amount: '-$currencySymbol${_formatCompact(totalOutflow)}',
                    countLabel: '$outflowCount ${l10nPick(context, en: 'out', fa: 'خروجی', ar: 'صادر')}',
                    color: AppColors.error,
                    icon: Icons.arrow_upward_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String amount;
  final String countLabel;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _MetricTile({
    required this.label,
    required this.amount,
    required this.countLabel,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 11, color: color),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          countLabel,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

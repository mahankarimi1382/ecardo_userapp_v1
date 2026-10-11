import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Dynamic FinTech withdrawal limit progress indicator showing used vs available
/// daily limit with real-time transaction consumption preview.
class WithdrawLimitProgressCard extends StatelessWidget {
  final double dailyLimit;
  final double usedLimit;
  final double enteredAmount;
  final String currency;
  final int decimals;

  const WithdrawLimitProgressCard({
    super.key,
    required this.dailyLimit,
    required this.usedLimit,
    required this.enteredAmount,
    required this.currency,
    this.decimals = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final effectiveDailyLimit = dailyLimit > 0 ? dailyLimit : 1000.0;
    final remainingLimit = (effectiveDailyLimit - usedLimit).clamp(0.0, effectiveDailyLimit);
    final isOverLimit = enteredAmount > remainingLimit && remainingLimit > 0;

    // Ratios for the progress bar
    final usedRatio = (usedLimit / effectiveDailyLimit).clamp(0.0, 1.0);
    final enteredRatio = (enteredAmount / effectiveDailyLimit).clamp(0.0, (1.0 - usedRatio));
    final totalProjectedRatio = (usedRatio + (enteredAmount / effectiveDailyLimit)).clamp(0.0, 1.0);

    final title = l10nPick(
      context,
      en: 'Daily Withdrawal Limit',
      fa: 'سقف برداشت روزانه',
      ar: 'حد السحب اليومي',
      tr: 'Günlük Çekim Limiti',
      ru: 'Дневной лимит вывода',
    );

    final remainingText = l10nPick(
      context,
      en: '${remainingLimit.toStringAsFixed(decimals)} $currency remaining of ${effectiveDailyLimit.toStringAsFixed(decimals)} $currency',
      fa: '${remainingLimit.toStringAsFixed(decimals)} $currency باقی‌مانده از ${effectiveDailyLimit.toStringAsFixed(decimals)} $currency',
      ar: '${remainingLimit.toStringAsFixed(decimals)} $currency متبقي من ${effectiveDailyLimit.toStringAsFixed(decimals)} $currency',
      tr: '${effectiveDailyLimit.toStringAsFixed(decimals)} $currency toplamdan ${remainingLimit.toStringAsFixed(decimals)} $currency kaldı',
      ru: 'Осталось ${remainingLimit.toStringAsFixed(decimals)} $currency из ${effectiveDailyLimit.toStringAsFixed(decimals)} $currency',
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.45)
            : AppColors.lightSurfaceVariant.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isOverLimit
              ? AppColors.error.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isOverLimit ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isOverLimit ? AppColors.error : accentColor)
                      .withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  isOverLimit
                      ? Icons.warning_amber_rounded
                      : Icons.shield_outlined,
                  size: 16,
                  color: isOverLimit ? AppColors.error : accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              // Daily Limit Total Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  "${effectiveDailyLimit.toStringAsFixed(decimals)} $currency",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Multi-layer Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: SizedBox(
              height: 7,
              child: Stack(
                children: [
                  // Background Track
                  Container(
                    width: double.infinity,
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.5)
                        : AppColors.lightBorder.withValues(alpha: 0.6),
                  ),

                  // Consumed / Used portion
                  if (usedRatio > 0)
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: usedRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.softGray,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),

                  // Projected current transaction portion
                  if (enteredRatio > 0 && !isOverLimit)
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: totalProjectedRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.success, AppColors.darkPrimary]
                                : [AppColors.success, AppColors.lightPrimary],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),

                  // Over-limit indicator in red
                  if (isOverLimit)
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: 1.0,
                      child: Container(
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Footnote & Remaining status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  remainingText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isOverLimit
                        ? AppColors.error
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOverLimit)
                Text(
                  l10nPick(
                    context,
                    en: 'Exceeds limit',
                    fa: 'فراتر از سقف',
                    ar: 'تجاوز الحد',
                    tr: 'Limit aşıldı',
                    ru: 'Превышен лимит',
                  ),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

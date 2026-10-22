import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Clean transparent glassmorphic fee & payout breakdown card showing
/// Requested Amount, Provider Fee, Net Payout, and Estimated Settlement Time.
class WithdrawBreakdownCard extends StatelessWidget {
  final double requestedAmount;
  final double feeAmount;
  final double netPayout;
  final String currency;
  final int decimals;
  final String? settlementTime;
  final bool isFeeLoading;
  final bool hasFeeError;

  const WithdrawBreakdownCard({
    super.key,
    required this.requestedAmount,
    required this.feeAmount,
    required this.netPayout,
    required this.currency,
    this.decimals = 2,
    this.settlementTime,
    this.isFeeLoading = false,
    this.hasFeeError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final isFreeFee = feeAmount <= 0.0 && !hasFeeError;
    final formattedRequested =
        "${requestedAmount.toStringAsFixed(decimals)} $currency";
    final formattedFee = hasFeeError
        ? '—'
        : (isFreeFee
              ? l10nPick(
                  context,
                  en: 'Free (0.00 $currency)',
                  fa: 'رایگان (۰.۰۰ $currency)',
                  ar: 'مجاني (0.00 $currency)',
                  tr: 'Ücretsiz (0.00 $currency)',
                  ru: 'Бесплатно (0.00 $currency)',
                )
              : "${feeAmount.toStringAsFixed(decimals)} $currency");
    final formattedNet = "${netPayout.toStringAsFixed(decimals)} $currency";
    final isInternationalCurrency =
        currency.toUpperCase() == 'USD' ||
        currency.toUpperCase() == 'EUR' ||
        currency.toUpperCase() == 'USDT';
    final resolvedSettlementTime =
        settlementTime ??
        (isInternationalCurrency
            ? l10nPick(
                context,
                en: '1-3 Business Days (Wire / SWIFT)',
                fa: '۱ تا ۳ روز کاری (انتقال بین‌المللی)',
                ar: '1-3 أيام عمل (حوالة مصرفية)',
                tr: '1-3 İş Günü (Uluslararası Transfer)',
                ru: '1-3 рабочих дня (Международный перевод)',
              )
            : l10nPick(
                context,
                en: 'Instant ⚡ (Next Banking Cycle)',
                fa: 'تسویه آنی ⚡ / سیکل بعدی بانکی',
                ar: 'تسوية فورية ⚡ / الدورة المصرفية التالية',
                tr: 'Anında ⚡ / Sonraki bankacılık döngüsü',
                ru: 'Мгновенно ⚡ / след. банковский цикл',
              ));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: EcardoGlassCard(
        variant: EcardoGlassVariant.frosted,
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10nPick(
                    context,
                    en: 'Payout & Fee Breakdown',
                    fa: 'جزئیات تسویه و کارمزد',
                    ar: 'تفاصيل السحب والرسوم',
                    tr: 'Çekim ve Ücret Detayları',
                    ru: 'Детали вывода и комиссии',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            _buildDivider(isDark),

            // 1. Requested Amount
            _buildRow(
              label: l10nPick(
                context,
                en: 'Requested Amount',
                fa: 'مبلغ درخواستی',
                ar: 'المبلغ المطلوب',
                tr: 'Talep Edilen Tutar',
                ru: 'Запрошенная сумма',
              ),
              value: formattedRequested,
              valueColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              isDark: isDark,
            ),

            _buildDivider(isDark),

            // 2. Provider Fee
            _buildRow(
              label: l10nPick(
                context,
                en: 'Transfer Fee',
                fa: 'کارمزد انتقال',
                ar: 'رسوم التحويل',
                tr: 'Transfer Ücreti',
                ru: 'Комиссия за перевод',
              ),
              value: formattedFee,
              valueColor: isFreeFee ? AppColors.success : AppColors.warning,
              isTag: isFreeFee,
              isDark: isDark,
            ),

            _buildDivider(isDark),

            // 3. Estimated Settlement Time
            _buildRow(
              label: l10nPick(
                context,
                en: 'Estimated Settlement',
                fa: 'زمان تخمینی تسویه',
                ar: 'وقت التسوية المتوقع',
                tr: 'Tahmini Takas Süresi',
                ru: 'Расчетное время зачисления',
              ),
              value: resolvedSettlementTime,
              valueColor: AppColors.success,
              isDark: isDark,
            ),

            _buildDivider(isDark),

            // 4. Net Payout (مبلغ خالص دریافتی)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Net Payout to Bank',
                          fa: 'مبلغ خالص واریزی به حساب',
                          ar: 'صافي المبلغ المحول للبنك',
                          tr: 'Bankaya Net Aktarım',
                          ru: 'Чистая сумма к зачислению',
                        ),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10nPick(
                          context,
                          en: 'Credited directly to destination',
                          fa: 'مبلغ دقیق واریزی به شبا مقصد',
                          ar: 'يصل مباشرة إلى الحساب',
                          tr: 'Hedef hesaba tam yatırılacak',
                          ru: 'Поступит на указанный счет',
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedNet,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandViolet,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
    bool isTag = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (isTag)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(
        height: 1,
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.6)
            : AppColors.lightBorder.withValues(alpha: 0.8),
      ),
    );
  }
}

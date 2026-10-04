import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

/// Rich Transaction Card component for eCardo.
///
/// Features:
/// - Category icon badge with dynamic colored container.
/// - Counterparty/type monogram avatar fallback.
/// - Signed colored amounts (+ credit green, - debit red) with tabular numbers.
/// - Adaptive status pill badges (Success, Pending, Failed).
/// - Micro-haptic tactile tap feedback.
/// - Full dark mode and RTL directionality support.
class TransactionCard extends StatelessWidget {
  final Transactions transaction;
  final VoidCallback? onTap;
  final bool showDivider;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlus = transaction.isPlus == true;
    final amountColor = isPlus ? AppColors.success : AppColors.error;

    return Semantics(
      button: true,
      label: '${transaction.type ?? 'Transaction'} ${isPlus ? '+' : '-'}${transaction.amount ?? ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Category Icon / Avatar Badge
                    _buildAvatar(context, isDark, isPlus),
                    const SizedBox(width: AppSpacing.md),

                    // 2. Transaction Details (Title, Date, Method)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolveTitle(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  JalaliDateHelper.format(transaction.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (transaction.method != null &&
                                  transaction.method!.trim().isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    '•',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    transaction.method!.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // 3. Amount & Status Pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAmountText(isPlus, amountColor),
                        const SizedBox(height: AppSpacing.xs),
                        _buildStatusPill(context, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 68.0,
                end: AppSpacing.lg,
              ),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark, bool isPlus) {
    final catColor = TransactionDynamicColor.getTransactionColor(transaction.type);
    final iconPath = TransactionDynamicIcon.getTransactionIcon(transaction.type);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: catColor.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            child: Image.asset(
              iconPath,
              excludeFromSemantics: true,
            ),
          ),
        ),
        // Mini direction indicator badge
        PositionedDirectional(
          bottom: -2,
          end: -2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlus ? AppColors.success : AppColors.error,
              border: Border.all(
                color: isDark ? AppColors.darkCard : AppColors.white,
                width: 1.8,
              ),
            ),
            child: Icon(
              isPlus ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 11,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _resolveTitle(BuildContext context) {
    final desc = transaction.description?.trim();
    if (desc != null && desc.isNotEmpty && desc != transaction.type) {
      return desc;
    }
    return transaction.type ?? l10nPick(context, en: 'Transaction', fa: 'تراکنش', ar: 'معاملة');
  }

  Widget _buildAmountText(bool isPlus, Color amountColor) {
    final prefix = isPlus ? '+' : '-';
    final isCrypto = transaction.isCrypto == true;

    final String formattedText;
    if (isCrypto) {
      formattedText = '$prefix${transaction.amount ?? '0'} ${transaction.trxCurrencyCode ?? ''}';
    } else {
      final symbol = transaction.trxCurrencySymbol ?? '';
      formattedText = '$prefix$symbol${transaction.amount ?? '0'}';
    }

    return Text(
      formattedText,
      textAlign: TextAlign.end,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w800,
        color: amountColor,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, bool isDark) {
    final normalized = transaction.normalizedStatus;

    Color pillBg;
    Color pillFg;
    IconData pillIcon;
    String pillText;

    if (transaction.isSuccess) {
      pillBg = isDark
          ? AppColors.success.withValues(alpha: 0.18)
          : AppColors.successContainer;
      pillFg = AppColors.success;
      pillIcon = Icons.check_circle_rounded;
      pillText = l10nPick(context, en: 'Success', fa: 'موفق', ar: 'ناجح');
    } else if (transaction.isPending) {
      pillBg = isDark
          ? AppColors.warning.withValues(alpha: 0.18)
          : AppColors.warningContainer;
      pillFg = AppColors.warning;
      pillIcon = Icons.access_time_filled_rounded;
      pillText = l10nPick(context, en: 'Pending', fa: 'در انتظار', ar: 'قيد الانتظار');
    } else if (transaction.isFailed) {
      pillBg = isDark
          ? AppColors.error.withValues(alpha: 0.18)
          : AppColors.errorContainer;
      pillFg = AppColors.error;
      pillIcon = Icons.cancel_rounded;
      pillText = l10nPick(context, en: 'Failed', fa: 'ناموفق', ar: 'فشل');
    } else {
      // Fallback
      pillBg = isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant;
      pillFg = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      pillIcon = Icons.info_rounded;
      pillText = normalized.isNotEmpty ? normalized : l10nPick(context, en: 'Completed', fa: 'انجام شد', ar: 'مكتمل');
    }

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pillIcon, size: 10, color: pillFg),
          const SizedBox(width: 3),
          Text(
            pillText,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: pillFg,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Dedicated empty state for dashboard cards and lists.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final double iconSize;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.iconSize = 48,
  });

  factory EmptyView.wallets({VoidCallback? onCta}) => EmptyView(
        icon: Icons.account_balance_wallet_outlined,
        title: 'هنوز کیف پولی ندارید',
        subtitle: 'اولین کیف پول را بسازید تا بتوانید واریز و انتقال انجام دهید.',
        ctaLabel: onCta != null ? 'ایجاد کیف پول' : null,
        onCta: onCta,
      );

  factory EmptyView.transactions({VoidCallback? onCta}) => EmptyView(
        icon: Icons.receipt_long_outlined,
        title: 'تراکنشی ثبت نشده',
        subtitle: 'بعد از اولین انتقال یا واریز، تاریخچه اینجا نمایش داده می‌شود.',
        ctaLabel: onCta != null ? 'مشاهده خدمات' : null,
        onCta: onCta,
      );

  factory EmptyView.notifications({VoidCallback? onCta}) => EmptyView(
        icon: Icons.notifications_none_rounded,
        title: 'اعلانی نیست',
        subtitle: 'هشدارهای مالی و سیستمی اینجا جمع می‌شوند.',
        ctaLabel: onCta != null ? 'بروزرسانی' : null,
        onCta: onCta,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pad = MediaQuery.sizeOf(context).width < 370 ? 16.0 : 24.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppColors.lightPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? Colors.white70
                    : AppColors.lightTextPrimary.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(ctaLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

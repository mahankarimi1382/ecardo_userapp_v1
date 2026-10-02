import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Dedicated empty state for dashboard cards and lists with multi-lingual support.
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
        title: l10nPickAuto(
          en: 'No Wallets Yet',
          fa: 'هنوز کیف پولی ندارید',
          ar: 'لا توجد محافظ بعد',
          zh: '暂无钱包',
        ),
        subtitle: l10nPickAuto(
          en: 'Create your first wallet to start depositing and transferring funds.',
          fa: 'اولین کیف پول را بسازید تا بتوانید واریز و انتقال انجام دهید.',
          ar: 'أنشئ محفظتك الأولى لبدء الإيداع وتحويل الأموال.',
          zh: '创建您的第一个钱包以开始存款和转账。',
        ),
        ctaLabel: onCta != null
            ? l10nPickAuto(
                en: 'Create Wallet',
                fa: 'ایجاد کیف پول',
                ar: 'إنشاء محفظة',
                zh: '创建钱包',
              )
            : null,
        onCta: onCta,
      );

  factory EmptyView.transactions({VoidCallback? onCta}) => EmptyView(
        icon: Icons.receipt_long_outlined,
        title: l10nPickAuto(
          en: 'No Transactions Yet',
          fa: 'تراکنشی ثبت نشده',
          ar: 'لا توجد معاملات بعد',
          zh: '暂无交易记录',
        ),
        subtitle: l10nPickAuto(
          en: 'Your transaction history will appear here once you send or receive money.',
          fa: 'بعد از اولین انتقال یا واریز، تاریخچه اینجا نمایش داده می‌شود.',
          ar: 'ستظهر سجل معاملاتك هنا بمجرد إرسال أو استلام الأموال.',
          zh: '一旦您转账或收款，交易记录将显示在此处。',
        ),
        ctaLabel: onCta != null
            ? l10nPickAuto(
                en: 'Explore Services',
                fa: 'مشاهده خدمات',
                ar: 'استكشاف الخدمات',
                zh: '探索服务',
              )
            : null,
        onCta: onCta,
      );

  factory EmptyView.notifications({VoidCallback? onCta}) => EmptyView(
        icon: Icons.notifications_none_rounded,
        title: l10nPickAuto(
          en: 'No Notifications',
          fa: 'اعلانی نیست',
          ar: 'لا توجد إشعارات',
          zh: '暂无通知',
        ),
        subtitle: l10nPickAuto(
          en: 'Financial and system notifications will be collected here.',
          fa: 'هشدارهای مالی و سیستمی اینجا جمع می‌شوند.',
          ar: 'سيتم جمع الإشعارات المالية والنظام هنا.',
          zh: '财务和系统通知将汇集在此处。',
        ),
        ctaLabel: onCta != null
            ? l10nPickAuto(
                en: 'Refresh',
                fa: 'بروزرسانی',
                ar: 'تحديث',
                zh: '刷新',
              )
            : null,
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

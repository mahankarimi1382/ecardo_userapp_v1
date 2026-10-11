import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Card freeze control (Block 4).
///
/// [CardFreezeOverlay] is retained because freezing actually calls the card
/// status endpoint — the toggle is backed by a real request.
///
/// In addition, [VirtualCardSecurityControls] provides the comprehensive
/// fintech quick action security grid (Apple Card / Revolut / Monzo pattern):
/// - ❄️ Freeze / Unfreeze card with instant tactile frost/glass feedback.
/// - 💳 Online Payments (E-commerce) allow/disallow toggle.
/// - 📊 Spending Limits modal with daily/monthly presets and sliders.
/// - 📜 Card Statement / Transactions instant navigation.
/// - ➕ Direct Top-up link.

// ============================================================================
// 1. CARD FREEZE OVERLAY & TOGGLE (Backward Compatible Block 4)
// ============================================================================

/// Visual frozen card state widget / card freeze toggle.
/// When frozen: displays frosted glass blur effect, frosted blue border,
/// lock/snowflake badge, and "Card is currently frozen - all transactions blocked" banner.
/// Includes quick toggle switch to freeze / unfreeze card with haptic feedback.
class CardFreezeOverlay extends StatelessWidget {
  final Widget child;
  final bool isFrozen;
  final ValueChanged<bool>? onFreezeToggled;
  final ValueChanged<bool>? onToggleFreeze;
  final bool showToggle;
  final BorderRadius? borderRadius;

  const CardFreezeOverlay({
    super.key,
    required this.child,
    required this.isFrozen,
    this.onFreezeToggled,
    this.onToggleFreeze,
    this.showToggle = true,
    this.borderRadius,
  });

  void _handleToggle(bool value) {
    HapticFeedback.mediumImpact();
    onFreezeToggled?.call(value);
    onToggleFreeze?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(18.r);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card Container with Frosted Glass Overlay when frozen
        Stack(
          children: [
            child,

            // Frosted Glass Blur Effect & Frozen Badge Overlay
            if (isFrozen)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: const Color(0x384A90E2),
                        border: Border.all(
                          color: AppColors.mainSoftBlue,
                          width: 2.2.w,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x40ABC3EA),
                            Color(0x28849ACD),
                            Color(0x45ABC3EA),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Lock & Snowflake Frost Badge
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlack.withValues(
                                    alpha: 0.82,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColors.mainSoftBlue.withValues(
                                      alpha: 0.8,
                                    ),
                                    width: 1.2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.mainSoftBlue.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.ac_unit_rounded,
                                      color: AppColors.mainSoftBlue,
                                      size: 15.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 13.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Flexible(
                                      child: Text(
                                        'Card is Frozen',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // Frozen Banner
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepBlack.withValues(
                                  alpha: 0.88,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.mainSoftBlue.withValues(
                                    alpha: 0.65,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: AppColors.mainSoftBlue,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Card is currently frozen - all transactions blocked',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Quick Toggle Switch below card
        if (showToggle) ...[
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isFrozen
                    ? AppColors.mainSoftBlue
                    : AppColors.lightWarmGray.withValues(alpha: 0.45),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFrozen
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.12)
                      : AppColors.mutedBlue.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: isFrozen
                        ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
                        : AppColors.lightBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFrozen ? Icons.ac_unit_rounded : Icons.lock_open_rounded,
                    color: isFrozen ? AppColors.deepBlack : AppColors.softGray,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrozen ? 'Unfreeze Card' : 'Freeze Virtual Card',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isFrozen
                              ? AppColors.deepBlack
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isFrozen
                            ? 'Toggle off to unfreeze and resume transactions'
                            : 'Temporarily lock your card against any charges',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Switch.adaptive(
                  value: isFrozen,
                  activeTrackColor: AppColors.mutedBlue,
                  onChanged: _handleToggle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 2. SECURITY CONTROL QUICK ACTION GRID (Apple Card / Revolut Standards)
// ============================================================================

/// Modern fintech quick action security controls grid for virtual cards.
class VirtualCardSecurityControls extends StatelessWidget {
  final bool isFrozen;
  final ValueChanged<bool>? onToggleFreeze;
  final bool isOnlinePaymentsEnabled;
  final ValueChanged<bool>? onToggleOnlinePayments;
  final double dailySpendLimit;
  final double monthlySpendLimit;
  final String currency;
  final void Function(double daily, double monthly)? onUpdateSpendingLimits;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onTopUp;
  final bool canViewTransactions;
  final bool canTopUp;

  const VirtualCardSecurityControls({
    super.key,
    required this.isFrozen,
    this.onToggleFreeze,
    this.isOnlinePaymentsEnabled = true,
    this.onToggleOnlinePayments,
    this.dailySpendLimit = 1000.0,
    this.monthlySpendLimit = 5000.0,
    this.currency = 'USD',
    this.onUpdateSpendingLimits,
    this.onViewTransactions,
    this.onTopUp,
    this.canViewTransactions = true,
    this.canTopUp = true,
  });

  void _showSpendingLimitsModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _SpendingLimitsBottomSheet(
          initialDaily: dailySpendLimit,
          initialMonthly: monthlySpendLimit,
          currency: currency,
          onSave: (daily, monthly) {
            onUpdateSpendingLimits?.call(daily, monthly);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.mutedBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Shield Badge
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.20)
                      : AppColors.brandVioletContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security_rounded,
                  size: 17.sp,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Card Security & Controls',
                        fa: 'امنیت و کنترل‌های کارت',
                        ar: 'أمان البطاقة وعناصر التحكم',
                        tr: 'Kart Güvenliği ve Kontrolleri',
                        ru: 'Безопасность и управление картой',
                        zh: '卡安全与控制',
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(
                        context,
                        en: 'Instant lock, spending caps & transaction rules',
                        fa: 'مسدودسازی آنی، سقف برداشت و قوانین تراکنش',
                        ar: 'قفل فوري، حدود الإنفاق وقواعد المعاملات',
                        tr: 'Anında kilitleme, harcama limitleri ve kurallar',
                        ru: 'Мгновенная блокировка, лимиты и правила операций',
                        zh: '实时锁定、支出上限和交易规则',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // 1. FREEZE / UNFREEZE TILE
          _SecurityActionTile(
            isDark: isDark,
            icon: Icons.ac_unit_rounded,
            iconColor: isFrozen ? Colors.white : const Color(0xFF29B6F6),
            iconBgColor: isFrozen
                ? AppColors.mainSoftBlue
                : const Color(0xFFE1F5FE),
            title: isFrozen
                ? l10nPick(
                    context,
                    en: 'Card is Frozen',
                    fa: 'کارت مسدود است',
                    ar: 'البطاقة مجمدة',
                    tr: 'Kart Donduruldu',
                    ru: 'Карта заморожена',
                    zh: '卡已被冻结',
                  )
                : l10nPick(
                    context,
                    en: 'Freeze Card',
                    fa: 'مسدودسازی موقت کارت',
                    ar: 'تجميد البطاقة',
                    tr: 'Kartı Dondur',
                    ru: 'Заморозить карту',
                    zh: '冻结卡片',
                  ),
            subtitle: isFrozen
                ? l10nPick(
                    context,
                    en: 'All charges and withdrawals blocked',
                    fa: 'همه تراکنش‌ها و برداشت‌ها مسدود است',
                    ar: 'جميع الرسوم والسحوبات محظورة',
                    tr: 'Tüm harcama ve çekimler engellendi',
                    ru: 'Все операции и списания заблокированы',
                    zh: '所有扣款和取款均已阻止',
                  )
                : l10nPick(
                    context,
                    en: 'Instantly pause all transactions',
                    fa: 'توقف آنی کلیه تراکنش‌ها با یک لمس',
                    ar: 'إيقاف فوري لجميع المعاملات',
                    tr: 'Tüm işlemleri anında durdurun',
                    ru: 'Мгновенно приостановить операции',
                    zh: '即时暂停所有交易',
                  ),
            trailing: Switch.adaptive(
              value: isFrozen,
              activeTrackColor: AppColors.mainSoftBlue,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                onToggleFreeze?.call(val);
              },
            ),
          ),

          SizedBox(height: 12.h),

          // 2. ONLINE PAYMENTS (E-COMMERCE) TILE
          _SecurityActionTile(
            isDark: isDark,
            icon: Icons.shopping_bag_outlined,
            iconColor: isOnlinePaymentsEnabled
                ? const Color(0xFF00BFA6)
                : AppColors.softGray,
            iconBgColor: isOnlinePaymentsEnabled
                ? const Color(0xFFE0F8F5)
                : (isDark ? const Color(0xFF333333) : const Color(0xFFF0F0F0)),
            title: l10nPick(
              context,
              en: 'Online Payments',
              fa: 'پرداخت‌های اینترنتی',
              ar: 'المدفوعات عبر الإنترنت',
              tr: 'Çevrimiçi Ödemeler',
              ru: 'Онлайн-платежи',
              zh: '在线支付',
            ),
            subtitle: isOnlinePaymentsEnabled
                ? l10nPick(
                    context,
                    en: 'E-commerce and in-app transactions active',
                    fa: 'خرید اینترنتی و پرداخت درون‌برنامه‌ای فعال است',
                    ar: 'التجارة الإلكترونية والدفع مفعل',
                    tr: 'E-ticaret ve uygulama içi işlemler aktif',
                    ru: 'Покупки в интернете и приложениях активны',
                    zh: '电子商务和应用内交易已激活',
                  )
                : l10nPick(
                    context,
                    en: 'Online purchases blocked for security',
                    fa: 'خریدهای اینترنتی جهت امنیت مسدود شده‌اند',
                    ar: 'تم حظر المشتريات عبر الإنترنت للأمان',
                    tr: 'Güvenlik için çevrimiçi alışveriş engellendi',
                    ru: 'Онлайн-покупки заблокированы для безопасности',
                    zh: '为安全起见，在线购物已阻止',
                  ),
            trailing: Switch.adaptive(
              value: isOnlinePaymentsEnabled,
              activeTrackColor: AppColors.mutedBlue,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                onToggleOnlinePayments?.call(val);
              },
            ),
          ),

          SizedBox(height: 12.h),

          // 3. SPENDING LIMITS TILE
          _SecurityActionTile(
            isDark: isDark,
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFFFFA000),
            iconBgColor: const Color(0xFFFFF8E1),
            title: l10nPick(
              context,
              en: 'Spending Limits',
              fa: 'سقف تراکنش و مخارج',
              ar: 'حدود الإنفاق',
              tr: 'Harcama Limitleri',
              ru: 'Лимиты расходов',
              zh: '支出限额',
            ),
            subtitle:
                '${_formatAmount(dailySpendLimit)} $currency ${l10nPick(
              context,
              en: 'daily limit configured',
              fa: 'سقف روزانه تنظیم‌شده',
              ar: 'الحد اليومي المحدد',
              tr: 'günlük limit ayarlandı',
              ru: 'дневной лимит настроен',
              zh: '已配置的每日限额',
            )}',
            onTap: () => _showSpendingLimitsModal(context),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10nPick(
                      context,
                      en: 'Adjust',
                      fa: 'تنظیم',
                      ar: 'تعديل',
                      tr: 'Ayarla',
                      ru: 'Изменить',
                      zh: '调整',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.sp,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 4. CARD STATEMENT & TRANSACTIONS
          if (canViewTransactions) ...[
            _SecurityActionTile(
              isDark: isDark,
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFF5C6BC0),
              iconBgColor: const Color(0xFFE8EAF6),
              title: l10nPick(
                context,
                en: 'Card Transactions',
                fa: 'گردش حساب و تراکنش‌های کارت',
                ar: 'معاملات البطاقة وكشف الحساب',
                tr: 'Kart İşlemleri',
                ru: 'Операции и выписка по карте',
                zh: '卡交易明细',
              ),
              subtitle: l10nPick(
                context,
                en: 'Full statement, authorizations & receipts',
                fa: 'گزارش کامل واریزها، برداشت‌ها و رسیدها',
                ar: 'كشف حساب كامل، تصاريح وإيصالات',
                tr: 'Tam ekstre, onaylar ve makbuzlar',
                ru: 'Полная выписка, списания и чеки',
                zh: '完整账单、授权和收据',
              ),
              onTap: onViewTransactions,
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // 5. TOP-UP CARD TILE
          if (canTopUp) ...[
            _SecurityActionTile(
              isDark: isDark,
              icon: Icons.add_card_rounded,
              iconColor: AppColors.success,
              iconBgColor: AppColors.successContainer,
              title: l10nPick(
                context,
                en: 'Top-up Card Balance',
                fa: 'شارژ موجودی کارت',
                ar: 'شحن رصيد البطاقة',
                tr: 'Kart Bakiyesini Yükle',
                ru: 'Пополнить баланс карты',
                zh: '充值卡余额',
              ),
              subtitle: l10nPick(
                context,
                en: 'Add funds instantly from your wallet or gateway',
                fa: 'افزایش آنی موجودی از کیف پول یا درگاه بانکی',
                ar: 'أضف أموالاً فوراً من محفظتك أو البوابة',
                tr: 'Cüzdanınızdan veya ağ geçidinden anında para yükleyin',
                ru: 'Мгновенное пополнение с кошелька или шлюза',
                zh: '立即从钱包或网关充值',
              ),
              onTap: onTopUp,
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14AE6F), Color(0xFF0D8F5A)],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  l10nPick(
                    context,
                    en: '+ Add Funds',
                    fa: '+ شارژ',
                    ar: '+ إضافة',
                    tr: '+ Para Yükle',
                    ru: '+ Пополнить',
                    zh: '+ 充值',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    return NumberFormat('#,###').format(amount);
  }
}

// ============================================================================
// ACTION TILE COMPONENT
// ============================================================================

class _SecurityActionTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SecurityActionTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F1F1D)
                : AppColors.lightBackground.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C2C2A)
                  : AppColors.lightOutlineVariant,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SPENDING LIMITS MODAL (Revolut/Monzo Style)
// ============================================================================

class _SpendingLimitsBottomSheet extends StatefulWidget {
  final double initialDaily;
  final double initialMonthly;
  final String currency;
  final void Function(double daily, double monthly) onSave;

  const _SpendingLimitsBottomSheet({
    required this.initialDaily,
    required this.initialMonthly,
    required this.currency,
    required this.onSave,
  });

  @override
  State<_SpendingLimitsBottomSheet> createState() =>
      _SpendingLimitsBottomSheetState();
}

class _SpendingLimitsBottomSheetState extends State<_SpendingLimitsBottomSheet> {
  late double _daily;
  late double _monthly;

  final List<double> _dailyPresets = [250, 500, 1000, 2500, 5000];
  final List<double> _monthlyPresets = [2000, 5000, 10000, 25000];

  @override
  void initState() {
    super.initState();
    _daily = widget.initialDaily;
    _monthly = widget.initialMonthly;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        14.h,
        20.w,
        30.h + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title Row
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.speed_rounded,
                  size: 20.sp,
                  color: const Color(0xFFFFA000),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Card Spending Limits',
                        fa: 'سقف تراکنش و مخارج کارت',
                        ar: 'حدود الإنفاق للبطاقة',
                        tr: 'Kart Harcama Limitleri',
                        ru: 'Лимиты расходов по карте',
                        zh: '卡支出限额',
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      l10nPick(
                        context,
                        en: 'Set daily and monthly transaction caps',
                        fa: 'سقف مجاز پرداخت روزانه و ماهانه را تعیین کنید',
                        ar: 'حدد سقف المعاملات اليومية والشهرية',
                        tr: 'Günlük ve aylık işlem sınırlarını belirleyin',
                        ru: 'Установите лимиты операций на день и месяц',
                        zh: '设置每日和每月交易限额',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Daily Limit Section
          _buildSliderSection(
            isDark: isDark,
            title: l10nPick(
              context,
              en: 'Daily Spend Limit',
              fa: 'سقف تراکنش روزانه',
              ar: 'الحد اليومي للإنفاق',
              tr: 'Günlük Harcama Limiti',
              ru: 'Дневной лимит расходов',
              zh: '每日支出限额',
            ),
            currentValue: _daily,
            min: 100,
            max: 10000,
            presets: _dailyPresets,
            onChanged: (val) => setState(() => _daily = val),
          ),

          SizedBox(height: 20.h),

          // Monthly Limit Section
          _buildSliderSection(
            isDark: isDark,
            title: l10nPick(
              context,
              en: 'Monthly Spend Limit',
              fa: 'سقف تراکنش ماهانه',
              ar: 'الحد الشهري للإنفاق',
              tr: 'Aylık Harcama Limiti',
              ru: 'Месячный лимит расходов',
              zh: '每月支出限额',
            ),
            currentValue: _monthly,
            min: 500,
            max: 50000,
            presets: _monthlyPresets,
            onChanged: (val) => setState(() => _monthly = val),
          ),

          SizedBox(height: 26.h),

          // Save Button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onSave(_daily, _monthly);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandViolet,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 4,
            ),
            child: Text(
              l10nPick(
                context,
                en: 'Save Spending Limits',
                fa: 'ذخیره سقف تراکنش‌ها',
                ar: 'حفظ حدود الإنفاق',
                tr: 'Harcama Limitlerini Kaydet',
                ru: 'Сохранить лимиты',
                zh: '保存支出限额',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required bool isDark,
    required String title,
    required double currentValue,
    required double min,
    required double max,
    required List<double> presets,
    required ValueChanged<double> onChanged,
  }) {
    final formattedValue =
        '${NumberFormat('#,###').format(currentValue.round())} ${widget.currency}';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222220) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF333330) : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.2)
                      : AppColors.brandVioletContainer,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  formattedValue,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.brandViolet,
              inactiveTrackColor: isDark
                  ? const Color(0xFF3A3A38)
                  : const Color(0xFFD1D5DB),
              thumbColor: AppColors.brandViolet,
              overlayColor: AppColors.brandViolet.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: currentValue.clamp(min, max),
              min: min,
              max: max,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: presets.map((preset) {
              final isSelected = (currentValue.round() == preset.round());
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(preset);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brandViolet
                        : (isDark ? const Color(0xFF2E2E2C) : Colors.white),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandViolet
                          : (isDark
                              ? const Color(0xFF444442)
                              : const Color(0xFFD1D5DB)),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    NumberFormat('#,###').format(preset),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

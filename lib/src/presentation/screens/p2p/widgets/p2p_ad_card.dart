import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart'
    as marketplace;
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_buy_sell_ad_screen.dart';

/// Micro-scale tap interaction wrapper providing high-tactility micro-feedback.
class MicroScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const MicroScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.94,
  });

  @override
  State<MicroScaleTap> createState() => _MicroScaleTapState();
}

class _MicroScaleTapState extends State<MicroScaleTap> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              HapticFeedback.mediumImpact();
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled
          ? () {
              if (_isPressed) setState(() => _isPressed = false);
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// World-Class P2P Advertisement Card (Binance P2P / OKX / Bybit standard)
/// Features:
/// - Trader Header: Avatar with initials, online pulse indicator, verified pro-merchant gold badge,
///   trade count and completion rate percentage ("99.4% (320 trades)").
/// - Price & Limit Typography: Big crisp price in fiat/IRT, available crypto quantity, and order limit range (Min - Max).
/// - Payment Method Badges: Colorful tag chips (Bank Transfer, Sheba, Card to Card, eCardo Internal, Cash).
/// - Distinctive "Buy USDT" / "Sell USDT" CTA button with micro-scale tap interaction and haptics.
/// - Full Dark mode & RTL support using AppColors, AppSpacing, and l10nPick.
class P2pAdCard extends StatelessWidget {
  final marketplace.Ad item;

  const P2pAdCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final traderName = (item.advertiser?.fullName?.trim().isNotEmpty ?? false)
        ? item.advertiser!.fullName!
        : (item.advertiser?.username ?? '--');
    final avatarText = (item.advertiser?.avatarText?.trim().isNotEmpty ?? false)
        ? item.advertiser!.avatarText!
        : (traderName.isNotEmpty ? traderName[0].toUpperCase() : 'T');

    final completionRate = (item.completionRate ?? 0).toDouble();
    final completedOrders = item.completedOrders ?? 0;
    final isVerifiedTrader = item.advertiser?.isVerifiedTrader == true;

    final isOwnAd = item.isOwnAd == true;
    final isAdTypeBuy = (item.adType ?? '').toLowerCase() == 'buy';
    final assetCode = item.assetCurrency?.code ?? 'USDT';

    // Button action text: When ad is "buy", user sells to advertiser. When "sell", user buys from advertiser.
    final actionButtonText = isOwnAd
        ? l10nPick(context, en: 'Your Ad', fa: 'آگهی شما')
        : isAdTypeBuy
            ? l10nPick(context, en: 'Sell $assetCode', fa: 'فروش $assetCode')
            : l10nPick(context, en: 'Buy $assetCode', fa: 'خرید $assetCode');

    final emeraldGreen = AppColors.success;
    final rubyRed = AppColors.error;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final paymentMethodsList = item.paymentMethods ?? <marketplace.PaymentMethodElement>[];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Trader Header: Avatar, Pro-Merchant Gold Badge, Completion %, Orders Volume
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Online Pulse Indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [AppColors.darkPrimaryContainer, AppColors.brandVioletDeep]
                            : const [AppColors.darkGray, AppColors.deepBlack],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.brandVioletDeep : AppColors.black)
                              .withValues(alpha: 0.20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        avatarText,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: emeraldGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: emeraldGreen.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.sm.w),

              // Trader Name, Verified Pro-Merchant Badge & Completion Row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.advertiser?.username ?? traderName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5.sp,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        if (isVerifiedTrader) ...[
                          SizedBox(width: 6.w),
                          _buildProMerchantBadge(context, isDark),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Trade count & completion rate percentage (e.g. "99.4% (320 trades)")
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                          decoration: BoxDecoration(
                            color: emeraldGreen.withValues(alpha: isDark ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                            border: Border.all(
                              color: emeraldGreen.withValues(alpha: isDark ? 0.35 : 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 11.5.r,
                                color: emeraldGreen,
                              ),
                              SizedBox(width: 3.5.w),
                              Text(
                                '${completionRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: emeraldGreen,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '($completedOrders ${l10nPick(context, en: 'trades', fa: 'معامله')})',
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: emeraldGreen.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Response Time Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 13.r,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      item.responseTime ?? '≤15m',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: AppSpacing.md.h),

          // 2. Price, Limits Typography & Payment Badges + Distinctive CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left Column: Big Crisp Price, Available Crypto, Order Limit Range (Min - Max)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price typography: Big Crisp Price
                    Text(
                      item.price ?? '--',
                      style: TextStyle(
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w900,
                        fontSize: 20.sp,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Available Crypto Quantity
                    _buildCryptoMetricRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: localization.p2pAvailable,
                      value: item.totalAmount ?? '--',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    SizedBox(height: 4.h),

                    // Order Limit Range (Min - Max)
                    _buildCryptoMetricRow(
                      icon: Icons.tune_rounded,
                      label: localization.p2pLimit,
                      value: item.orderLimit ?? '--',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppSpacing.sm.w),

              // Right Column: Payment Method Tag Chips & Distinctive CTA Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Payment Method Badges: Colorful tag chips with distinctive colors
                  _buildPaymentMethodBadges(paymentMethodsList, isDark),
                  SizedBox(height: 10.h),

                  // Distinctive "Buy USDT" / "Sell USDT" CTA with micro-scale tap interaction
                  MicroScaleTap(
                    onTap: isOwnAd
                        ? null
                        : () {
                            final adId = item.id;
                            if (adId == null) return;
                            Get.to(
                              () => P2pBuySellAdScreen(
                                adId: adId,
                                isSellMode: isAdTypeBuy,
                              ),
                            );
                          },
                    child: Container(
                      height: 40.h,
                      constraints: BoxConstraints(minWidth: 105.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isOwnAd
                            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightOutlineVariant)
                            : isAdTypeBuy
                                ? rubyRed
                                : emeraldGreen,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        boxShadow: isOwnAd
                            ? null
                            : [
                                BoxShadow(
                                  color: (isAdTypeBuy ? rubyRed : emeraldGreen)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          actionButtonText,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isOwnAd
                                ? (isDark ? AppColors.darkTextSecondary : AppColors.softGray)
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pro-Merchant Gold Badge (Verified with Gold Shield / Star)
  Widget _buildProMerchantBadge(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.5.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.warning, AppColors.warmBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 11.5.r,
            color: AppColors.deepBlack,
          ),
          SizedBox(width: 3.w),
          Text(
            'PRO',
            style: TextStyle(
              letterSpacing: 0.4,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.deepBlack,
            ),
          ),
        ],
      ),
    );
  }

  /// Crypto Metric Row (Limits & Available)
  Widget _buildCryptoMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12.5.r,
          color: textSecondary.withValues(alpha: 0.7),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Colorful Payment Method Tag Chips (Bank Transfer, Sheba, Card to Card, eCardo Internal, Cash)
  Widget _buildPaymentMethodBadges(
    List<marketplace.PaymentMethodElement> methods,
    bool isDark,
  ) {
    if (methods.isEmpty) {
      return _buildPaymentChip(
        name: '--',
        badgeTheme: _getPaymentMethodTheme('--', isDark),
        isDark: isDark,
      );
    }

    // Display up to 2 payment methods to keep layout clean, plus a "+N" overflow chip if more
    final displayMethods = methods.take(2).toList();
    final remainingCount = methods.length - displayMethods.length;

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.w,
      runSpacing: 4.h,
      children: [
        for (final m in displayMethods)
          _buildPaymentChip(
            name: m.paymentMethod?.name ?? '--',
            badgeTheme: _getPaymentMethodTheme(m.paymentMethod?.name ?? '', isDark),
            isDark: isDark,
          ),
        if (remainingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
            ),
            child: Text(
              '+$remainingCount',
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentChip({
    required String name,
    required _PaymentBadgeTheme badgeTheme,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: badgeTheme.bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
        border: Border.all(color: badgeTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.5.w,
            height: 9.h,
            decoration: BoxDecoration(
              color: badgeTheme.accent,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 10.5.sp,
              color: badgeTheme.text,
            ),
          ),
        ],
      ),
    );
  }

  /// Distinctive Colors for Payment Methods:
  /// - Bank Transfer (انتقال بانکی): Royal Blue (#2563EB)
  /// - Sheba / Paya (شبا / پایا): Teal (#0D9488)
  /// - Card to Card (کارت به کارت): Purple / Indigo (#7C3AED)
  /// - eCardo Internal (داخلی / اکاردو): Brand Violet (#7445FF)
  /// - Cash / Dollar (نقدی / دلار نقد): Amber / Orange (#EA580C)
  /// - Other: Slate Gray (#475569)
  _PaymentBadgeTheme _getPaymentMethodTheme(String rawName, bool isDark) {
    final lower = rawName.toLowerCase();

    // 1. eCardo Internal / Wallet
    if (lower.contains('ecardo') ||
        lower.contains('اکاردو') ||
        lower.contains('internal') ||
        lower.contains('کیف پول') ||
        lower.contains('wallet')) {
      return _PaymentBadgeTheme(
        bg: isDark ? AppColors.darkPrimaryContainer : AppColors.brandVioletContainer,
        text: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
        border: isDark ? AppColors.darkPrimary : AppColors.lightBorder,
        accent: AppColors.brandViolet,
      );
    }

    // 2. Sheba / Paya
    if (lower.contains('sheba') ||
        lower.contains('شبا') ||
        lower.contains('paya') ||
        lower.contains('پایا') ||
        lower.contains('satna') ||
        lower.contains('ساتنا') ||
        lower.contains('iban')) {
      return _PaymentBadgeTheme(
        bg: isDark ? AppColors.darkSecondaryContainer : AppColors.lightSecondaryContainer,
        text: isDark ? AppColors.lightSecondary : AppColors.mutedBlue,
        border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        accent: AppColors.mutedBlue,
      );
    }

    // 3. Card to Card
    if (lower.contains('card') ||
        lower.contains('کارت') ||
        lower.contains('c2c') ||
        lower.contains('debit')) {
      return _PaymentBadgeTheme(
        bg: isDark ? AppColors.darkPrimaryContainer : AppColors.lightSurfaceVariant,
        text: isDark ? AppColors.mainSoftBlue : AppColors.brandVioletDeep,
        border: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        accent: AppColors.brandVioletDeep,
      );
    }

    // 4. Bank Transfer
    if (lower.contains('bank') ||
        lower.contains('بانک') ||
        lower.contains('transfer') ||
        lower.contains('انتقال') ||
        lower.contains('wire')) {
      return _PaymentBadgeTheme(
        bg: isDark ? AppColors.darkSurfaceVariant : AppColors.infoContainer,
        text: isDark ? AppColors.mainSoftBlue : AppColors.info,
        border: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        accent: AppColors.info,
      );
    }

    // 5. Cash Dollar / Cash
    if (lower.contains('cash') ||
        lower.contains('نقد') ||
        lower.contains('dollar') ||
        lower.contains('دلار')) {
      return _PaymentBadgeTheme(
        bg: isDark ? AppColors.darkSurfaceVariant : AppColors.warningContainer,
        text: isDark ? AppColors.warning : AppColors.warning,
        border: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        accent: AppColors.warning,
      );
    }

    // 6. Generic / Default
    return _PaymentBadgeTheme(
      bg: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      text: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      accent: AppColors.softGray,
    );
  }
}

class _PaymentBadgeTheme {
  final Color bg;
  final Color text;
  final Color border;
  final Color accent;

  const _PaymentBadgeTheme({
    required this.bg,
    required this.text,
    required this.border,
    required this.accent,
  });
}

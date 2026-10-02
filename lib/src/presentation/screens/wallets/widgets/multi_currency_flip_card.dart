import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Card theme presets for each world currency.
class CurrencyCardTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final String currencyName;
  final String flagEmoji;

  const CurrencyCardTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.currencyName,
    required this.flagEmoji,
  });

  static CurrencyCardTheme forCode(String code, {bool isCrypto = false, bool isDefault = false}) {
    final normalized = code.toUpperCase().trim();

    if (isCrypto || normalized == 'USDT' || normalized == 'BTC' || normalized == 'ETH') {
      return const CurrencyCardTheme(
        gradientColors: [Color(0xFF0D322B), Color(0xFF164E43), Color(0xFF092520)],
        accentColor: Color(0xFF26A69A),
        currencyName: 'Tether USD',
        flagEmoji: '₮',
      );
    }

    switch (normalized) {
      case 'USD':
        return const CurrencyCardTheme(
          gradientColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          accentColor: Color(0xFF4CA1AF),
          currencyName: 'US Dollar',
          flagEmoji: '🇺🇸',
        );
      case 'EUR':
        return const CurrencyCardTheme(
          gradientColors: [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF000000)],
          accentColor: Color(0xFFFFD700),
          currencyName: 'Euro',
          flagEmoji: '🇪🇺',
        );
      case 'TRY':
        return const CurrencyCardTheme(
          gradientColors: [Color(0xFF3F0B13), Color(0xFF6A1B29), Color(0xFF2B070D)],
          accentColor: Color(0xFFE53935),
          currencyName: 'Turkish Lira',
          flagEmoji: '🇹🇷',
        );
      case 'AED':
        return const CurrencyCardTheme(
          gradientColors: [Color(0xFF282116), Color(0xFF4A3E2A), Color(0xFF1B160E)],
          accentColor: Color(0xFFD4AF37),
          currencyName: 'UAE Dirham',
          flagEmoji: '🇦🇪',
        );
      case 'IRR':
      case 'TOMAN':
      default:
        if (isDefault) {
          return const CurrencyCardTheme(
            gradientColors: [AppColors.deepBlack, AppColors.darkGray, Color(0xFF1A1A18)],
            accentColor: Color(0xFFE0E0E0),
            currencyName: 'Iranian Rial',
            flagEmoji: '🇮🇷',
          );
        }
        return const CurrencyCardTheme(
          gradientColors: [Color(0xFF1A2A44), Color(0xFF2C3E50), Color(0xFF141E30)],
          accentColor: AppColors.mainSoftBlue,
          currencyName: 'eCardo Wallet',
          flagEmoji: '💳',
        );
    }
  }
}

/// Interactive 3D flip card widget for multi-currency wallets.
class MultiCurrencyFlipCard extends StatefulWidget {
  final Wallets wallet;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const MultiCurrencyFlipCard({
    super.key,
    required this.wallet,
    this.width = 320,
    this.height = 196,
    this.onTap,
  });

  @override
  State<MultiCurrencyFlipCard> createState() => _MultiCurrencyFlipCardState();
}

class _MultiCurrencyFlipCardState extends State<MultiCurrencyFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    // The face swap is derived from the angle inside the AnimatedBuilder
    // instead of a setState listener. A listener here fired a second rebuild
    // on every frame of the flip, on top of the AnimatedBuilder's own.
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  /// `Icons.send_rounded` points along the reading direction in LTR but
  /// against it in RTL, and Material does not auto-mirror it. Directional
  /// glyphs only — passing an already-symmetric icon through this is a no-op
  /// in LTR but would wrongly flip it in RTL, so it is opt-in per call site.
  Widget _mirrorInRtl(IconData icon) => Transform.flip(
        flipX: Directionality.of(context) == TextDirection.rtl,
        child: Icon(icon, color: Colors.white, size: 13),
      );

  @override
  Widget build(BuildContext context) {
    final currencyCode = widget.wallet.code ?? 'USD';
    final isDefault = widget.wallet.isDefault == true;
    final isCrypto = widget.wallet.isCrypto == true;
    final theme = CurrencyCardTheme.forCode(
      currencyCode,
      isCrypto: isCrypto,
      isDefault: isDefault,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: angle >= (pi / 2)
              ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildBack(theme),
                )
              : _buildFront(theme),
        );
      },
    );
  }

  Widget _buildFront(CurrencyCardTheme theme) {
    final symbol = widget.wallet.symbol ?? '';
    final code = widget.wallet.code ?? '';
    final balance = widget.wallet.formattedBalance ?? '0';
    final accountNo = widget.wallet.accountNo ?? '•••• •••• •••• ••••';

    return GestureDetector(
      onTap: widget.onTap ?? () {
        Get.toNamed(
          BaseRoute.walletsDetails,
          arguments: {"wallet_id": widget.wallet.id},
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.gradientColors.first.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background artistic watermark curves. Directional so the
            // oversized currency code leans into the trailing edge instead
            // of colliding with the balance in RTL.
            PositionedDirectional(
              end: -30,
              bottom: -40,
              child: Opacity(
                opacity: 0.06,
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 130,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -4,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Brand & Currency Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'eCardo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(theme.flagEmoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Flip trigger button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _flipCard,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flip_camera_android_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Center row: EMV Chip & Balance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chip icon
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFFF3E5AB),
                          width: 0.7,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26, width: 0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Available Balance',
                              fa: 'موجودی در دسترس',
                              ar: 'الرصيد المتاح',
                              zh: '可用余额',
                              tr: 'Kullanılabilir Bakiye',
                              ru: 'Доступный баланс',
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            alignment: AlignmentDirectional.centerStart.resolve(
                              Directionality.of(context),
                            ),
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                Text(
                                  balance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  symbol.isNotEmpty ? symbol : code,
                                  style: TextStyle(
                                    color: theme.accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom row: Masked Account Number & Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      accountNo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.wallet.isDefault == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.accentColor.withValues(alpha: 0.4), width: 0.6),
                        ),
                        child: Text(
                          l10nPick(
                            context,
                            en: 'DEFAULT',
                            fa: 'پیش‌فرض',
                            ar: 'افتراضي',
                            zh: '默认',
                          ),
                          tr: 'Varsayılan',
                          ru: 'По умолчанию',
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(CurrencyCardTheme theme) {
    final accountNo = widget.wallet.accountNo ?? '0000 0000 0000 0000';
    final code = widget.wallet.code ?? '';

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors.reversed.toList(),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.gradientColors.first.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          // Magnetic Stripe
          Container(
            height: 32,
            color: Colors.black87,
          ),
          const SizedBox(height: 12),
          // Signature and Account Details
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                    alignment: AlignmentDirectional.centerStart.resolve(
                      Directionality.of(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      accountNo,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Copy Account Number button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  // Mirrors automatically under RTL: the icon points away
                  // from the account number it copies.
                  icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: accountNo));
                    ToastHelper().showSuccessToast(
                      l10nPick(
                        context,
                        en: 'Account number copied',
                        fa: 'شماره حساب کپی شد',
                        ar: 'تم نسخ رقم الحساب',
                        zh: '已复制账号',
                        tr: 'Hesap numarası kopyalandı',
                        ru: 'Номер счёта скопирован',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                // Flip back icon button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.flip_to_front_rounded, color: Colors.white, size: 18),
                  onPressed: _flipCard,
                  tooltip: l10nPick(
                    context,
                    en: 'Show card front',
                    fa: 'نمایش روی کارت',
                    ar: 'إظهار وجه البطاقة',
                    zh: '显示卡正面',
                    tr: 'Kartın ön yüzünü göster',
                    ru: 'Показать лицевую сторону',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Quick Action Shortcut Buttons
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    label: l10nPick(
                      context,
                      en: 'Deposit',
                      fa: 'واریز',
                      ar: 'إيداع',
                      zh: '充值',
                      tr: 'Yatır',
                      ru: 'Пополнить',
                    ),
                    icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 13),
                    onTap: () {
                      Get.toNamed(BaseRoute.addMoney, arguments: {'wallet_id': widget.wallet.id});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionBtn(
                    label: l10nPick(
                      context,
                      en: 'Exchange',
                      fa: 'تبدیل',
                      ar: 'تبادل',
                      zh: '兑换',
                      tr: 'Takas',
                      ru: 'Обмен',
                    ),
                    icon: Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 13),
                    onTap: () {
                      Get.toNamed(BaseRoute.exchange, arguments: {'from_wallet': widget.wallet.id});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionBtn(
                    label: l10nPick(
                      context,
                      en: 'Transfer',
                      fa: 'انتقال',
                      ar: 'تحويل',
                      zh: '转账',
                      tr: 'Transfer',
                      ru: 'Перевод',
                    ),
                    icon: _mirrorInRtl(Icons.send_rounded),
                    onTap: () {
                      Get.toNamed(BaseRoute.transfer, arguments: {'wallet_id': widget.wallet.id});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/delete_wallet_bottom_sheet.dart';

/// Hero visual theme preset for cryptocurrency and fiat wallet cards.
/// Distinguishes sleek holographic dark mesh crypto cards from elegant
/// matte metallic fiat cards (Apple Card & Revolut inspired).
class HeroWalletCardTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final Color secondaryColor;
  final String currencyName;
  final String flagOrSymbol;
  final String cardEdition;
  final bool isCrypto;
  final String rateTicker;
  final String trendChange;
  final bool isTrendPositive;
  final List<Color>? meshGlowColors;

  const HeroWalletCardTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.secondaryColor,
    required this.currencyName,
    required this.flagOrSymbol,
    required this.cardEdition,
    required this.isCrypto,
    required this.rateTicker,
    required this.trendChange,
    required this.isTrendPositive,
    this.meshGlowColors,
  });

  static HeroWalletCardTheme forWallet(Wallets wallet) {
    final code = (wallet.code ?? 'USD').toUpperCase().trim();
    final isCrypto = wallet.isCrypto == true ||
        const {'BTC', 'ETH', 'USDT', 'USDC', 'BNB', 'SOL', 'TRX', 'XRP', 'LTC'}.contains(code);

    if (isCrypto) {
      if (code == 'BTC') {
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 BTC ≈ \$${wallet.conversionRate}'
            : '1 BTC ≈ \$68,450.00';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF1F1202),
            Color(0xFF3B2306),
            Color(0xFF140A01),
          ],
          accentColor: const Color(0xFFFFB020),
          secondaryColor: const Color(0xFFFFE082),
          currencyName: wallet.name ?? 'Bitcoin',
          flagOrSymbol: '₿',
          cardEdition: 'OBSIDIAN GOLD',
          isCrypto: true,
          rateTicker: rate,
          trendChange: '▲ 2.4%',
          isTrendPositive: true,
          meshGlowColors: const [Color(0x35FFB020), Color(0x20FF8F00)],
        );
      } else if (code == 'ETH') {
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 ETH ≈ \$${wallet.conversionRate}'
            : '1 ETH ≈ \$3,520.00';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF140D2B),
            Color(0xFF281850),
            Color(0xFF0C071C),
          ],
          accentColor: const Color(0xFFB57EDC),
          secondaryColor: const Color(0xFFE1BEE7),
          currencyName: wallet.name ?? 'Ethereum',
          flagOrSymbol: 'Ξ',
          cardEdition: 'CYBER VIOLET',
          isCrypto: true,
          rateTicker: rate,
          trendChange: '▲ 1.8%',
          isTrendPositive: true,
          meshGlowColors: const [Color(0x358A2BE2), Color(0x20B57EDC)],
        );
      } else {
        // USDT / Default Crypto
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 $code ≈ \$${wallet.conversionRate}'
            : '1 USDT = 1.00 USD';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF04241F),
            Color(0xFF0A3C33),
            Color(0xFF061E1A),
          ],
          accentColor: const Color(0xFF00F5D4),
          secondaryColor: const Color(0xFF80FFE8),
          currencyName: wallet.name ?? (code == 'USDT' ? 'Tether USD' : code),
          flagOrSymbol: code == 'USDT' ? '₮' : '⚡',
          cardEdition: 'HOLOGRAPHIC MESH',
          isCrypto: true,
          rateTicker: rate,
          trendChange: '● Stable',
          isTrendPositive: true,
          meshGlowColors: const [Color(0x3500F5D4), Color(0x2000B4D8)],
        );
      }
    }

    // Fiat Currencies
    switch (code) {
      case 'USD':
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF132226),
            Color(0xFF1F373C),
            Color(0xFF0E1A1C),
          ],
          accentColor: const Color(0xFF56CFB2),
          secondaryColor: const Color(0xFFA7E9D7),
          currencyName: wallet.name ?? 'US Dollar',
          flagOrSymbol: '🇺🇸',
          cardEdition: 'TITANIUM SLATE',
          isCrypto: false,
          rateTicker: '1 USD = 1.00 USD',
          trendChange: '● Base',
          isTrendPositive: true,
        );
      case 'EUR':
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 EUR ≈ \$${wallet.conversionRate}'
            : '1 EUR ≈ \$1.08 USD';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF0E1A2E),
            Color(0xFF172D4D),
            Color(0xFF091220),
          ],
          accentColor: const Color(0xFFFFD166),
          secondaryColor: const Color(0xFFFFE299),
          currencyName: wallet.name ?? 'Euro',
          flagOrSymbol: '🇪🇺',
          cardEdition: 'MIDNIGHT SAPPHIRE',
          isCrypto: false,
          rateTicker: rate,
          trendChange: '▲ 0.3%',
          isTrendPositive: true,
        );
      case 'AED':
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 AED ≈ \$${wallet.conversionRate}'
            : '1 AED ≈ \$0.272 USD';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF271E10),
            Color(0xFF43331C),
            Color(0xFF191309),
          ],
          accentColor: const Color(0xFFE5B869),
          secondaryColor: const Color(0xFFF3D59B),
          currencyName: wallet.name ?? 'UAE Dirham',
          flagOrSymbol: '🇦🇪',
          cardEdition: 'DESERT GOLD',
          isCrypto: false,
          rateTicker: rate,
          trendChange: '▲ 0.1%',
          isTrendPositive: true,
        );
      case 'IRR':
      case 'TOMAN':
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 USD ≈ ${wallet.conversionRate}'
            : '1 USD ≈ 65,000 Toman';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF1A1A1E),
            Color(0xFF2C2C35),
            Color(0xFF121215),
          ],
          accentColor: const Color(0xFFE0C38C),
          secondaryColor: const Color(0xFFF0DEC0),
          currencyName: wallet.name ?? 'Iranian Rial',
          flagOrSymbol: '🇮🇷',
          cardEdition: 'PERSIAN ONYX',
          isCrypto: false,
          rateTicker: rate,
          trendChange: '● Official',
          isTrendPositive: true,
        );
      case 'TRY':
        final rate = wallet.conversionRate != null && wallet.conversionRate!.isNotEmpty
            ? '1 TRY ≈ \$${wallet.conversionRate}'
            : '1 TRY ≈ \$0.029 USD';
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF2E0C12),
            Color(0xFF4B1620),
            Color(0xFF1E070B),
          ],
          accentColor: const Color(0xFFFF6B6B),
          secondaryColor: const Color(0xFFFFB3B3),
          currencyName: wallet.name ?? 'Turkish Lira',
          flagOrSymbol: '🇹🇷',
          cardEdition: 'CRIMSON METALLIC',
          isCrypto: false,
          rateTicker: rate,
          trendChange: '▼ 0.4%',
          isTrendPositive: false,
        );
      default:
        return HeroWalletCardTheme(
          gradientColors: const [
            Color(0xFF18181B),
            Color(0xFF28282D),
            Color(0xFF111113),
          ],
          accentColor: AppColors.mainSoftBlue,
          secondaryColor: const Color(0xFFD0E1FD),
          currencyName: wallet.name ?? 'eCardo Wallet',
          flagOrSymbol: '💳',
          cardEdition: 'CARBON MATTE',
          isCrypto: false,
          rateTicker: 'Multi-Currency',
          trendChange: '● Active',
          isTrendPositive: true,
        );
    }
  }
}

/// Custom painter for holographic iridescence and subtle metallic grain.
class _HolographicSheenPainter extends CustomPainter {
  final bool isCrypto;
  const _HolographicSheenPainter({this.isCrypto = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -1.0),
        end: const Alignment(1.0, 1.0),
        colors: isCrypto
            ? [
                Colors.white.withValues(alpha: 0.0),
                const Color(0xFF00F5D4).withValues(alpha: 0.07),
                const Color(0xFFB57EDC).withValues(alpha: 0.05),
                const Color(0xFFFFB020).withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.0),
              ]
            : [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.0),
              ],
        stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Frosted mesh ambient glow orbs for cryptocurrency cards.
class _FrostedMeshPainter extends CustomPainter {
  final Color primaryGlow;
  final Color secondaryGlow;

  const _FrostedMeshPainter({
    required this.primaryGlow,
    required this.secondaryGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGlow,
          primaryGlow.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.15),
        radius: size.width * 0.45,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15),
      size.width * 0.45,
      p1,
    );

    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryGlow,
          secondaryGlow.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.85),
        radius: size.width * 0.4,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.85),
      size.width * 0.4,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// EMV Microchip custom painter for physical contact pads.
class _EmvChipPainter extends CustomPainter {
  const _EmvChipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0x55000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(outerRRect, stroke);

    final midX = size.width * 0.44;
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), stroke);
    canvas.drawLine(
      Offset(0, size.height * 0.36),
      Offset(midX, size.height * 0.36),
      stroke,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.68),
      Offset(midX, size.height * 0.68),
      stroke,
    );
    canvas.drawLine(
      Offset(midX, size.height * 0.50),
      Offset(size.width, size.height * 0.50),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Realistic Golden EMV Microchip widget with subtle bevel.
class _EmvChipWidget extends StatelessWidget {
  const _EmvChipWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF7D),
            Color(0xFFC79E3B),
            Color(0xFFECCB68),
            Color(0xFF9E7720),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFF2AC),
          width: 0.6,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2.5),
        child: CustomPaint(
          painter: _EmvChipPainter(),
        ),
      ),
    );
  }
}

/// Cryptographic glowing badge for crypto cards.
class _CryptoBadgeWidget extends StatelessWidget {
  final HeroWalletCardTheme theme;
  const _CryptoBadgeWidget({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.accentColor.withValues(alpha: 0.16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          theme.flagOrSymbol,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: theme.accentColor,
          ),
        ),
      ),
    );
  }
}

/// Hero Wallet Card (Revolut / Apple Card inspired)
/// Features:
/// - Distinctive visual styling (dark mesh holographic crypto vs matte metallic fiat)
/// - High-end typography (big balance, currency code badge, live ticker)
/// - Mini quick-action bar: [Top-up (+)] [Transfer (→)] [Exchange (⇄)] with micro-haptic feedback
/// - Interactive 3D card flip animation
/// - RTL-aware layout
class HeroWalletCard extends StatefulWidget {
  final Wallets wallet;
  final VoidCallback? onTap;

  const HeroWalletCard({
    super.key,
    required this.wallet,
    this.onTap,
  });

  @override
  State<HeroWalletCard> createState() => _HeroWalletCardState();
}

class _HeroWalletCardState extends State<HeroWalletCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _copyAccountNo(String accountNo) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = HeroWalletCardTheme.forWallet(widget.wallet);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final shineOpacity =
            (sin(_flipAnimation.value * pi) * 0.22).clamp(0.0, 0.22);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: Stack(
            children: [
              angle >= (pi / 2)
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildBack(theme),
                    )
                  : _buildFront(theme),
              if (shineOpacity > 0.01)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment(
                            -1.0 + (_flipAnimation.value * 2.0),
                            -1.0,
                          ),
                          end: Alignment(
                            1.0 + (_flipAnimation.value * 2.0),
                            1.0,
                          ),
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: shineOpacity),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFront(HeroWalletCardTheme theme) {
    final code = widget.wallet.code ?? 'USD';
    final isDefault = widget.wallet.isDefault == true;
    final isCrypto = theme.isCrypto;

    // The card surface is an opaque, per-currency gradient — a physical-card look
    // that EcardoGlassCard's frosted background cannot reproduce. The card is
    // therefore wrapped in the component for its gradient border, drop shadows,
    // rounded clipping and press-scale tap feedback, while the currency gradient
    // stays on the child. Background and glow are transparent so the component's
    // own surface does not tint the currency gradient; per the design-system
    // guide the backdrop blur is inert behind an opaque child.
    return EcardoGlassCard(
      width: double.infinity,
      borderRadius: AppSpacing.radiusXl,
      borderWidth: 1.0,
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      backgroundColor: Colors.transparent,
      glowColor: Colors.transparent,
      padding: EdgeInsets.zero,
      shadows: [
        BoxShadow(
          color: theme.accentColor.withValues(alpha: 0.30),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: widget.onTap ??
          () {
            Get.toNamed(
              BaseRoute.walletsDetails,
              arguments: {"wallet_id": widget.wallet.id},
            );
          },
      child: Container(
        constraints: const BoxConstraints(minHeight: 215),
        padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // Ambient Mesh Glow / Holographic Texture
            if (isCrypto && theme.meshGlowColors != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _FrostedMeshPainter(
                    primaryGlow: theme.meshGlowColors![0],
                    secondaryGlow: theme.meshGlowColors![1],
                  ),
                ),
              ),

            // Diagonal Holographic Sheen
            Positioned.fill(
              child: CustomPaint(
                painter: _HolographicSheenPainter(isCrypto: isCrypto),
              ),
            ),

            // Watermark Currency Code in background
            PositionedDirectional(
              end: -20,
              bottom: -24,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.05,
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -4,
                    ),
                  ),
                ),
              ),
            ),

            // Main Card Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Brand & Currency Badge & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'eCardo',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                theme.cardEdition,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Currency Code & Flag/Symbol Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                theme.flagOrSymbol,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isDefault) const SizedBox(width: 5),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.accentColor.withValues(alpha: 0.6),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              l10nPick(
                                context,
                                en: 'DEFAULT',
                                fa: 'اصلی',
                                ar: 'افتراضي',
                                tr: 'Varsayılan',
                                ru: 'Основной',
                                zh: '默认',
                              ),
                              style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        const SizedBox(width: 5),
                        // Flip Button
                        Material(
                          color: Colors.transparent,
                          child: Tooltip(
                            message: l10nPick(
                              context,
                              en: 'Flip card',
                              fa: 'چرخاندن کارت',
                              ar: 'قلب البطاقة',
                              zh: '翻转卡片',
                              tr: 'Kartı çevir',
                              ru: 'Перевернуть карту',
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _flipCard,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flip_camera_android_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Middle Row: Chip/Badge & Big Balance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isCrypto)
                      _CryptoBadgeWidget(theme: theme)
                    else
                      const _EmvChipWidget(),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.contactless_rounded,
                      color: Colors.white.withValues(alpha: 0.65),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBalanceRow(context, widget.wallet, theme),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Live Rate Ticker on Card
                _buildLiveRateTicker(theme),
                const SizedBox(height: 14),

                // Mini Quick-Action Bar on Card
                _buildQuickActionBar(context, widget.wallet, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(
    BuildContext context,
    Wallets wallet,
    HeroWalletCardTheme theme,
  ) {
    final WalletsController controller = Get.find<WalletsController>();

    return Obx(() {
      final isPrivacy = controller.isPrivacyMode.value;
      final symbol = wallet.symbol ?? '';
      final code = wallet.code ?? '';
      final balanceText = wallet.formattedBalance ?? wallet.balance ?? '0';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(
              context,
              en: 'Available Balance',
              fa: 'موجودی در دسترس',
              ar: 'الرصيد المتاح',
              tr: 'Kullanılabilir Bakiye',
              ru: 'Доступный баланс',
              zh: '可用余额',
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart.resolve(
              Directionality.of(context),
            ),
            child: isPrivacy
                ? const Text(
                    '••••••••',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5,
                    ),
                  )
                : Row(
                    textDirection: TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        balanceText,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        symbol.isNotEmpty ? symbol : code,
                        textDirection: TextDirection.ltr,
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
      );
    });
  }

  Widget _buildLiveRateTicker(HeroWalletCardTheme theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.isTrendPositive
                  ? const Color(0xFF00E676)
                  : const Color(0xFFFF5252),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (theme.isTrendPositive
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF5252))
                      .withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              theme.rateTicker,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
            decoration: BoxDecoration(
              color: (theme.isTrendPositive
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF5252))
                  .withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              theme.trendChange,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: theme.isTrendPositive
                    ? const Color(0xFF69F0AE)
                    : const Color(0xFFFF8A80),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar(
    BuildContext context,
    Wallets wallet,
    HeroWalletCardTheme theme,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        // Top-up (+)
        Expanded(
          child: _buildActionPill(
            label: l10nPick(
              context,
              en: 'Top-up',
              fa: 'واریز',
              ar: 'إيداع',
              tr: 'Yatır',
              ru: 'Пополнить',
              zh: '充值',
            ),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 13,
              color: Colors.white,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              if (Get.find<SettingsService>().getSetting("user_deposit") ==
                  "1") {
                Get.toNamed(
                  BaseRoute.addMoney,
                  arguments: {"wallet_id": wallet.id.toString()},
                );
              } else {
                ToastHelper().showErrorToast(
                  l10nPick(
                    context,
                    en: 'Deposit is currently disabled',
                    fa: 'واریز در حال حاضر غیرفعال است',
                    ar: 'الإيداع معطل حالياً',
                    tr: 'Yatırma şu anda devre dışı',
                    ru: 'Пополнение временно отключено',
                    zh: '充值当前已禁用',
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // Transfer (→)
        Expanded(
          child: _buildActionPill(
            label: l10nPick(
              context,
              en: 'Transfer',
              fa: 'انتقال',
              ar: 'تحويل',
              tr: 'Transfer',
              ru: 'Перевод',
              zh: '转账',
            ),
            icon: Transform.flip(
              flipX: isRtl,
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(
                BaseRoute.transfer,
                arguments: {"wallet_id": wallet.id},
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Exchange (⇄)
        Expanded(
          child: _buildActionPill(
            label: l10nPick(
              context,
              en: 'Exchange',
              fa: 'تبدیل',
              ar: 'تبادل',
              tr: 'Takas',
              ru: 'Обмен',
              zh: '兑换',
            ),
            icon: const Icon(
              Icons.swap_horiz_rounded,
              size: 13,
              color: Colors.white,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(
                BaseRoute.exchange,
                arguments: {"from_wallet": wallet.id},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(HeroWalletCardTheme theme) {
    final accountNo = widget.wallet.accountNo ?? '0000 0000 0000 0000';
    final isDefault = widget.wallet.isDefault == true;

    // Mirrors the front face's container so the card reads the same on both sides
    // of the flip. No `onTap` here: the back has its own buttons, and making the
    // whole surface tappable would swallow taps meant for them.
    return EcardoGlassCard(
      width: double.infinity,
      borderRadius: AppSpacing.radiusXl,
      borderWidth: 1.0,
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      backgroundColor: Colors.transparent,
      glowColor: Colors.transparent,
      padding: EdgeInsets.zero,
      shadows: [
        BoxShadow(
          color: theme.accentColor.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 215),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors.reversed.toList(),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          // Magnetic Stripe
          Container(
            height: 32,
            color: Colors.black.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 14),

          // Account Number & Copy & Flip Back
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: AlignmentDirectional.centerStart.resolve(
                      Directionality.of(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      accountNo,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Copy Account Number
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 38,
                  ),
                  tooltip: l10nPick(
                    context,
                    en: 'Copy account number',
                    fa: 'کپی شماره حساب',
                    ar: 'نسخ رقم الحساب',
                    zh: '复制账号',
                    tr: 'Hesap numarasını kopyala',
                    ru: 'Скопировать номер счёта',
                  ),
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  onPressed: () => _copyAccountNo(accountNo),
                ),
                // Flip back icon button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 38,
                  ),
                  icon: const Icon(
                    Icons.flip_to_front_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _flipCard,
                  tooltip: l10nPick(
                    context,
                    en: 'Show front',
                    fa: 'نمایش روی کارت',
                    ar: 'إظهار وجه البطاقة',
                    zh: '显示正面',
                    tr: 'Ön yüzü göster',
                    ru: 'Показать лицевую сторону',
                  ),
                ),
                if (!isDefault)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFF8A80),
                      size: 19,
                    ),
                    onPressed: () {
                      Get.bottomSheet(
                        DeleteWalletBottomSheet(
                          walletId: widget.wallet.id.toString(),
                        ),
                      );
                    },
                    tooltip: l10nPick(
                      context,
                      en: 'Delete wallet',
                      fa: 'حذف کیف پول',
                      ar: 'حذف المحفظة',
                      tr: 'Cüzdanı sil',
                      ru: 'Удалить кошелёк',
                      zh: '删除钱包',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Details row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  theme.currencyName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: #${widget.wallet.id ?? 0}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Quick Action Bar on Back
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 14),
            child: _buildQuickActionBar(context, widget.wallet, theme),
          ),
          ],
        ),
      ),
    );
  }
}

/// Wallets Card Section: renders the list of modernized hero wallet cards
/// with support for filtering [All] [Fiat] [Crypto] and dynamic animations.
class WalletsCardSection extends StatelessWidget {
  const WalletsCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletsController controller = Get.find<WalletsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final wallets = controller.filteredWallets;

      if (wallets.isEmpty) {
        return _buildFilteredEmptyState(context, controller, isDark);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          24,
        ),
        itemCount: wallets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return HeroWalletCard(
            wallet: wallet,
            onTap: () {
              Get.toNamed(
                BaseRoute.walletsDetails,
                arguments: {"wallet_id": wallet.id},
              );
            },
          );
        },
      );
    });
  }

  Widget _buildFilteredEmptyState(
    BuildContext context,
    WalletsController controller,
    bool isDark,
  ) {
    final filter = controller.activeFilter.value;
    String filterName;
    if (filter == WalletFilterType.crypto) {
      filterName = l10nPick(
        context,
        en: 'Crypto',
        fa: 'کریپتو',
        ar: 'العملات المشفرة',
        tr: 'Kripto',
        ru: 'Крипто',
        zh: '加密',
      );
    } else {
      filterName = l10nPick(
        context,
        en: 'Fiat',
        fa: 'فیات',
        ar: 'العملات الورقية',
        tr: 'İtibari',
        ru: 'Фиат',
        zh: '法币',
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: 24,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x33D5CBC8) : const Color(0x1F000000),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter == WalletFilterType.crypto
                ? Icons.currency_bitcoin_rounded
                : Icons.account_balance_outlined,
            size: 42,
            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
          ),
          const SizedBox(height: 12),
          Text(
            l10nPick(
              context,
              en: 'No $filterName Wallets Found',
              fa: 'کیف پول $filterName یافت نشد',
              ar: 'لم يتم العثور على محافظ $filterName',
              tr: '$filterName Cüzdanı Bulunamadı',
              ru: 'Кошельки $filterName не найдены',
              zh: '未找到$filterName钱包',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10nPick(
              context,
              en: 'Create a new $filterName wallet to start managing your assets.',
              fa: 'برای شروع مدیریت دارایی‌های خود، یک کیف پول $filterName ایجاد کنید.',
              ar: 'أنشئ محفظة $filterName جديدة لبدء إدارة أصولك.',
              tr: 'Varlıklarınızı yönetmeye başlamak için yeni bir $filterName cüzdanı oluşturun.',
              ru: 'Создайте кошелёк $filterName для управления активами.',
              zh: '创建新的$filterName钱包以开始管理您的资产。',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Get.toNamed(BaseRoute.createNewWallet),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(
              l10nPick(
                context,
                en: 'Add $filterName Wallet',
                fa: 'افزودن کیف پول $filterName',
                ar: 'إضافة محفظة $filterName',
                tr: '$filterName Cüzdan Ekle',
                ru: 'Добавить кошелёк $filterName',
                zh: '添加$filterName钱包',
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: isDark ? AppColors.deepBlack : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

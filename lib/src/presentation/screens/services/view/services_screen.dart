import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/bindings/app_bindings.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/service_tiles.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/esim_intro_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/insurance/insurance_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/catalog_service_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/cip_lounge_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/extra_service_registry.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/quick_service_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/sim/sim_topup_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/taxi/taxi_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/trains/train_screens.dart';
import 'package:ecardo_user/src/tour/screens/tour_list_screen.dart';
import 'package:ecardo_user/src/visa/screens/visa_catalog_screen.dart';

/// Categories supported by the Services Hub
enum ServiceCategory {
  all,
  financial,
  travel,
  business,
  transactions,
}

/// Metadata model encapsulating service categorization, visual design, and search synonyms
class _HubItem {
  final ServiceCategory category;
  final ServiceTile tile;
  final List<String> searchKeywords;
  final bool isQuickAccess;
  final Color? accentColor;
  final List<Color>? gradientColors;
  final String Function(BuildContext)? badgeText;
  final Color? badgeColor;

  const _HubItem({
    required this.category,
    required this.tile,
    this.searchKeywords = const [],
    this.isQuickAccess = false,
    this.accentColor,
    this.gradientColors,
    this.badgeText,
    this.badgeColor,
  });
}

/// Smooth staggered entrance transition (Slide-up + Fade-in)
class _SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SlideFadeTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final val = animation.value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - val) * 22.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Interactive quick-action card for the Quick Access Hero banner
class _QuickAccessTile extends StatefulWidget {
  final _HubItem item;
  final ResolvedTile resolved;
  final bool isDark;

  const _QuickAccessTile({
    required this.item,
    required this.resolved,
    required this.isDark,
  });

  @override
  State<_QuickAccessTile> createState() => _QuickAccessTileState();
}

class _QuickAccessTileState extends State<_QuickAccessTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tile = widget.resolved.tile;
    final disabled = widget.resolved.state != TileState.available;
    final accentColor = widget.item.accentColor ?? AppColors.brandViolet;
    final gradientColors = widget.item.gradientColors ?? [
      accentColor,
      accentColor.withValues(alpha: 0.8),
    ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTileTap(context, widget.resolved);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: disabled ? 0.55 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF261D45).withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : accentColor.withValues(alpha: 0.16),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isDark ? Colors.black : accentColor)
                      .withValues(alpha: widget.isDark ? 0.25 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      padding: tile.icon != null
                          ? const EdgeInsets.all(7.5)
                          : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: tile.iconData != null
                          ? Icon(
                              tile.iconData,
                              color: Colors.white,
                              size: 19,
                            )
                          : Image.asset(
                              tile.icon!,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                    ),
                    if (widget.resolved.state == TileState.kycLocked ||
                        widget.resolved.state == TileState.notBuilt)
                      PositionedDirectional(
                        top: -3,
                        end: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? AppColors.darkGray
                                : AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isDark
                                  ? AppColors.warmWhite.withValues(alpha: 0.15)
                                  : AppColors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 9,
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: widget.isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive card item for service grid sections
class _InteractiveServiceCard extends StatefulWidget {
  final _HubItem item;
  final ResolvedTile resolved;
  final bool isDark;

  const _InteractiveServiceCard({
    required this.item,
    required this.resolved,
    required this.isDark,
  });

  @override
  State<_InteractiveServiceCard> createState() =>
      _InteractiveServiceCardState();
}

class _InteractiveServiceCardState extends State<_InteractiveServiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tile = widget.resolved.tile;
    final disabled = widget.resolved.state != TileState.available;
    final accentColor = widget.item.accentColor ?? AppColors.brandViolet;
    final badgeText = widget.item.badgeText?.call(context);
    final badgeColor = widget.item.badgeColor ?? accentColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        onTileTap(context, widget.resolved);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: disabled ? 0.55 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Icon container with vibrant gradient/solid background and rounded corners (14-16r)
                  Container(
                    width: 46,
                    height: 46,
                    padding: tile.icon != null
                        ? const EdgeInsets.all(9)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.item.gradientColors != null
                            ? [
                                widget.item.gradientColors![0].withValues(
                                  alpha: widget.isDark ? 0.30 : 0.16,
                                ),
                                widget.item.gradientColors![1].withValues(
                                  alpha: widget.isDark ? 0.15 : 0.08,
                                ),
                              ]
                            : [
                                accentColor.withValues(
                                  alpha: widget.isDark ? 0.28 : 0.14,
                                ),
                                accentColor.withValues(
                                  alpha: widget.isDark ? 0.12 : 0.06,
                                ),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: widget.isDark ? 0.35 : 0.20,
                        ),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(
                            alpha: widget.isDark ? 0.18 : 0.08,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: tile.iconData != null
                        ? Icon(
                            tile.iconData,
                            color: widget.isDark
                                ? AppColors.darkPrimary
                                : accentColor,
                            size: 23,
                          )
                        : Image.asset(
                            tile.icon!,
                            width: 24,
                            height: 24,
                            color: disabled
                                ? (widget.isDark
                                    ? AppColors.white.withValues(alpha: 0.30)
                                    : AppColors.black.withValues(alpha: 0.30))
                                : (widget.isDark ? AppColors.white : null),
                          ),
                  ),

                  // Subtle status badge if applicable (e.g. "Instant / آنی", "New / جدید")
                  if (badgeText != null &&
                      widget.resolved.state == TileState.available)
                    PositionedDirectional(
                      top: -4,
                      end: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withValues(alpha: 0.45),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                  // Lock badge for KYC-gated or unbuilt modules
                  if (widget.resolved.state == TileState.kycLocked ||
                      widget.resolved.state == TileState.notBuilt)
                    PositionedDirectional(
                      top: -4,
                      end: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppColors.darkGray
                              : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark
                                ? AppColors.warmWhite.withValues(alpha: 0.15)
                                : AppColors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 9,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: (widget.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)
                        .withValues(
                      alpha: disabled ? 0.40 : (widget.isDark ? 0.92 : 0.88),
                    ),
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
}

/// PREMIER BLUBANK SERVICES HUB
///
/// Features:
/// 1. Instant fuzzy & keyword search with Iranian/regional synonym resolution.
/// 2. Segmented category filter chips (All, Financial, Travel, Business, Transactions).
/// 3. BluBank-style Quick Access hero banner for high-frequency actions.
/// 4. Modern card styling with soft border glow and micro-interaction scale feedback.
/// 5. Full integration of Recent Transactions history.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  final HomeController _homeController = Get.find<HomeController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final AnimationController _entranceController;
  late final Animation<double> _searchAnim;
  late final Animation<double> _chipsAnim;
  late final Animation<double> _heroAnim;
  late final Animation<double> _contentAnim;

  ServiceCategory _selectedCategory = ServiceCategory.all;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _searchAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _chipsAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.10, 0.55, curve: Curves.easeOutCubic),
    );
    _heroAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.70, curve: Curves.easeOutCubic),
    );
    _contentAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (_searchQuery != text) {
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 150), () {
          if (mounted && _searchQuery != text) {
            setState(() {
              _searchQuery = text;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _ensureTravelController() {
    if (!Get.isRegistered<TravelController>()) {
      TravelBinding().dependencies();
    }
  }

  /// Normalizes Persian / Arabic letters for seamless search matching
  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ة', 'ه')
        .replaceAll('‌', ' ') // Zero-width non-joiner
        .trim();
  }

  List<_HubItem> _buildHubItems(BuildContext context, Addons? addons) {
    final localization = AppLocalizations.of(context)!;
    const travelOn = true;

    return [
      // ══════════════════════════════════════════════════════════
      // 1. FINANCIAL & PAYMENT SERVICES
      // ══════════════════════════════════════════════════════════
      _HubItem(
        category: ServiceCategory.financial,
        isQuickAccess: true,
        accentColor: const Color(0xFF7445FF),
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Instant',
          fa: 'آنی',
          ar: 'فوري',
          zh: '极速',
          ru: 'Мгновенно',
          tr: 'Anında',
        ),
        badgeColor: const Color(0xFF10B981),
        searchKeywords: const [
          'رمز',
          'پویا',
          'رمز پویا',
          'یکبار مصرف',
          'otp',
          'pin',
          'dynamic password',
          'كلمة مرور',
        ],
        tile: ServiceTile(
          title: localization.otherServicesDynamicPassword,
          iconData: Icons.pin_rounded,
          route: BaseRoute.dynamicPassword,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        isQuickAccess: true,
        accentColor: const Color(0xFF10B981),
        gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Fast',
          fa: 'سریع',
          ar: 'سريع',
          zh: '秒达',
          ru: 'Быстро',
          tr: 'Hızlı',
        ),
        badgeColor: const Color(0xFF059669),
        searchKeywords: const [
          'انتقال',
          'کارت به کارت',
          'حواله',
          'ساتنا',
          'پایا',
          'transfer',
          'send money',
          'تحويل',
        ],
        tile: ServiceTile(
          title: localization.otherServicesTransfer,
          icon: PngAssets.transferService,
          route: BaseRoute.transfer,
          feature: 'transfer',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        isQuickAccess: true,
        accentColor: const Color(0xFF00BFA6),
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
        searchKeywords: const [
          'واریز',
          'شارژ کیف پول',
          'افزایش موجودی',
          'add money',
          'deposit',
          'top up',
          'إيداع',
        ],
        tile: ServiceTile(
          title: localization.otherServicesAddMoney,
          icon: PngAssets.addMoneyService,
          route: BaseRoute.addMoney,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFEF4444),
        gradientColors: const [Color(0xFFF87171), Color(0xFFDC2626)],
        searchKeywords: const [
          'برداشت',
          'تسویه',
          'برداشت وجه',
          'withdraw',
          'cashout',
          'سحب',
        ],
        tile: ServiceTile(
          title: localization.otherServicesWithdraw,
          icon: PngAssets.withdrawService,
          route: BaseRoute.withdraw,
          feature: 'withdraw',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        isQuickAccess: true,
        accentColor: const Color(0xFF0284C7),
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0369A1)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Live',
          fa: 'لحظه‌ای',
          ar: 'مباشر',
          zh: '实时',
          ru: 'Курс',
          tr: 'Canlı',
        ),
        badgeColor: const Color(0xFF0284C7),
        searchKeywords: const [
          'صرافی',
          'تبدیل ارز',
          'دلار',
          'یورو',
          'exchange',
          'currency',
          'convert',
          'صرافة',
        ],
        tile: ServiceTile(
          title: localization.otherServicesExchange,
          icon: PngAssets.exchangeService,
          route: BaseRoute.exchange,
          feature: 'exchange',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF6366F1),
        gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
        searchKeywords: const [
          'کیف پول',
          'موجودی',
          'حساب',
          'wallets',
          'wallet',
          'محفظة',
        ],
        tile: ServiceTile(
          title: localization.otherServicesWallets,
          icon: PngAssets.walletsService,
          route: BaseRoute.wallets,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF8B5CF6),
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        searchKeywords: const [
          'تراکنش',
          'تاریخچه',
          'صورتحساب',
          'گردش حساب',
          'transactions',
          'history',
          'معاملات',
        ],
        tile: ServiceTile(
          title: localization.otherServicesTransactions,
          icon: PngAssets.transactionService,
          route: BaseRoute.transactions,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF3B82F6),
        gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
        searchKeywords: const [
          'کیو آر',
          'بارکد',
          'اسکن',
          'پرداخت بارکد',
          'qr',
          'qr code',
          'scan',
          'رمز',
        ],
        tile: ServiceTile(
          title: localization.otherServicesQrCode,
          icon: PngAssets.qrCodeService,
          route: BaseRoute.qrCode,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFEC4899),
        gradientColors: const [Color(0xFFF472B6), Color(0xFFDB2777)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Instant',
          fa: 'آنی',
          ar: 'فوري',
          zh: '即时',
          ru: 'Мгновенно',
          tr: 'Anında',
        ),
        badgeColor: const Color(0xFFEC4899),
        searchKeywords: const [
          'کارت',
          'کارت مجازی',
          'پی کاردو',
          'مسترکارت',
          'ویزا کارت',
          'card',
          'virtual card',
          'بطاقة',
        ],
        tile: ServiceTile(
          title: localization.otherServicesVirtualCard,
          icon: PngAssets.virtualCardService,
          route: BaseRoute.virtualCard,
          feature: 'paycardo',
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFF59E0B),
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFD97706)],
        searchKeywords: const [
          'قبض',
          'پرداخت قبض',
          'آب',
          'برق',
          'گاز',
          'تلفن',
          'bill',
          'utility',
          'فاتورة',
        ],
        tile: ServiceTile(
          title: localization.otherServicesBillPayment,
          icon: PngAssets.billPaymentService,
          route: BaseRoute.billPayment,
          feature: 'pay-bill',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF14B8A6),
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0F766E)],
        searchKeywords: const [
          'درخواست پول',
          'مطالبه',
          'دنگ',
          'request money',
          'طلب مال',
        ],
        tile: ServiceTile(
          title: localization.otherServicesRequestMoney,
          icon: PngAssets.requestMoneyService,
          route: BaseRoute.requestMoney,
          feature: 'request-money',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF0EA5E9),
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        searchKeywords: const [
          'لینک پرداخت',
          'درگاه',
          'فروشگاهی',
          'payment links',
          'link',
          'رابط',
        ],
        tile: ServiceTile(
          title: localization.otherServicesPaymentLinks,
          icon: PngAssets.paymentLinksService,
          route: BaseRoute.paymentLinks,
          feature: 'payment-links',
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF4F46E5),
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
        searchKeywords: const [
          'پرداخت',
          'خرید',
          'پرداخت مستقیم',
          'make payment',
          'pay',
          'دفع',
        ],
        tile: ServiceTile(
          title: localization.otherServicesMakePayment,
          icon: PngAssets.makePaymentService,
          route: BaseRoute.makePayment,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFE11D48),
        gradientColors: const [Color(0xFFFB7185), Color(0xFFBE123C)],
        searchKeywords: const [
          'نقد کردن',
          'دریافت وجه',
          'cash out',
          'نقد',
        ],
        tile: ServiceTile(
          title: localization.otherServicesCashOut,
          icon: PngAssets.cashOutService,
          route: BaseRoute.cashOut,
          feature: 'cashout',
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFD946EF),
        gradientColors: const [Color(0xFFE879F9), Color(0xFFC026D3)],
        searchKeywords: const [
          'هدیه',
          'کد هدیه',
          'عیدی',
          'gift',
          'gift code',
          'هدية',
        ],
        tile: ServiceTile(
          title: localization.otherServicesGift,
          icon: PngAssets.giftService,
          route: BaseRoute.giftCode,
          feature: 'gift_send',
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFFA855F7),
        gradientColors: const [Color(0xFFC084FC), Color(0xFF9333EA)],
        searchKeywords: const [
          'کارت هدیه',
          'گیفت کارت',
          'gift cards',
          'voucher',
          'بطاقة هدية',
        ],
        tile: ServiceTile(
          title: localization.otherServicesGiftCards,
          icon: PngAssets.giftCardsService,
          route: BaseRoute.giftCard,
          feature: 'gift_redeem',
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.financial,
        accentColor: const Color(0xFF059669),
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Bonus',
          fa: 'پاداش',
          ar: 'مكافأة',
          zh: '奖励',
          ru: 'Бонус',
          tr: 'Ödül',
        ),
        badgeColor: const Color(0xFF10B981),
        searchKeywords: const [
          'دعوت',
          'معرف',
          'پاداش',
          'کد معرف',
          'invite',
          'referral',
          'دعوة',
        ],
        tile: ServiceTile(
          title: localization.otherServicesInvite,
          icon: PngAssets.inviteService,
          route: BaseRoute.referral,
        ),
      ),

      // ══════════════════════════════════════════════════════════
      // 2. TRAVEL & TOURISM SERVICES
      // ══════════════════════════════════════════════════════════
      _HubItem(
        category: ServiceCategory.travel,
        isQuickAccess: true,
        accentColor: const Color(0xFF0284C7),
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        searchKeywords: const [
          'پرواز',
          'هواپیما',
          'بلیط هواپیما',
          'flight',
          'ticket',
          'airline',
          'طيران',
        ],
        tile: ServiceTile(
          title: localization.travelFlights,
          iconData: Icons.flight_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const FlightSearchScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFF97316),
        gradientColors: const [Color(0xFFFB923C), Color(0xFFEA580C)],
        searchKeywords: const [
          'هتل',
          'اقامتگاه',
          'رزرو هتل',
          'hotel',
          'booking',
          'stay',
          'فندق',
        ],
        tile: ServiceTile(
          title: localization.travelHotels,
          iconData: Icons.hotel_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const HotelSearchScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        isQuickAccess: true,
        accentColor: const Color(0xFF10B981),
        gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Global',
          fa: 'جهانی',
          ar: 'عالمي',
          zh: '全球',
          ru: 'Глобал',
          tr: 'Küresel',
        ),
        badgeColor: const Color(0xFF06B6D4),
        searchKeywords: const [
          'ای سیم',
          'سیم کارت الکترونیکی',
          'اینترنت رومینگ',
          'esim',
          'roaming',
        ],
        tile: ServiceTile(
          title: localization.travelEsim,
          iconData: Icons.sim_card_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const EsimIntroScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFEAB308),
        gradientColors: const [Color(0xFFFACC15), Color(0xFFCA8A04)],
        searchKeywords: const [
          'تاکسی',
          'اسنپ',
          'دربستی',
          'ماشین',
          'taxi',
          'ride',
          'تاكسي',
        ],
        tile: ServiceTile(
          title: localization.travelServiceTaxi,
          iconData: Icons.local_taxi_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const TaxiSearchScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF8B5CF6),
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        searchKeywords: const [
          'قطار',
          'بلیط قطار',
          'راه آهن',
          'train',
          'railway',
          'قطار',
        ],
        tile: ServiceTile(
          title: localization.travelServiceTrain,
          iconData: Icons.train_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const TrainSearchScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF3B82F6),
        gradientColors: const [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
        searchKeywords: const [
          'اجاره خودرو',
          'کرایه ماشین',
          'رنت',
          'car rental',
          'rent car',
          'تأجير سيارات',
        ],
        tile: ServiceTile(
          title: localization.travelServiceCarRental,
          iconData: Icons.directions_car_rounded,
          route: BaseRoute.rentalHome,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF14B8A6),
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0F766E)],
        searchKeywords: const [
          'ویزا',
          'روادید',
          'مهاجرت',
          'سفارت',
          'visa',
          'تأشيرة',
        ],
        tile: ServiceTile(
          title: localization.travelServiceVisa,
          iconData: Icons.approval_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const VisaCatalogScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF06B6D4),
        gradientColors: const [Color(0xFF22D3EE), Color(0xFF0891B2)],
        searchKeywords: const [
          'تور',
          'تور گردشگری',
          'سفر گروهی',
          'tour',
          'travel',
          'جولة',
        ],
        tile: ServiceTile(
          title: localization.travelServiceTour,
          iconData: Icons.tour_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const TourListScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF0EA5E9),
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        searchKeywords: const [
          'کشتی',
          'قایق',
          'دریایی',
          'کروز',
          'boat',
          'ship',
          'cruise',
          'قارب',
        ],
        tile: ServiceTile(
          title: localization.travelServiceBoat,
          iconData: Icons.directions_boat_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const BoatCatalogScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF7445FF),
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        badgeText: (c) => l10nPick(
          c,
          en: 'VIP',
          fa: 'تشریفات',
          ar: 'VIP',
          zh: '贵宾',
          ru: 'VIP',
          tr: 'VIP',
        ),
        badgeColor: const Color(0xFF7445FF),
        searchKeywords: const [
          'سی آی پی',
          'تشریفات فرودگاه',
          'لانژ',
          'cip',
          'lounge',
          'airport vip',
        ],
        tile: ServiceTile(
          title: l10nPick(
            context,
            en: 'CIP Lounge',
            fa: 'تشریفات فرودگاهی CIP',
            ar: 'صالة تشريفات المطار',
            zh: '机场贵宾厅',
          ),
          iconData: Icons.airline_seat_recline_extra_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const CipLoungeReservationScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFEC4899),
        gradientColors: const [Color(0xFFF472B6), Color(0xFFDB2777)],
        searchKeywords: const [
          'مکان دیدنی',
          'گردشگری محلی',
          'جاذبه',
          'local',
          'attractions',
          'معالم',
        ],
        tile: ServiceTile(
          title: localization.travelServiceLocal,
          iconData: Icons.place_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const LocalCatalogScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFF43F5E),
        gradientColors: const [Color(0xFFFB7185), Color(0xFFE11D48)],
        searchKeywords: const [
          'غذا',
          'دلیوری',
          'سفارش آنلاین',
          'food',
          'delivery',
          'dining',
          'طعام',
        ],
        tile: ServiceTile(
          title: localization.travelServiceFood,
          iconData: Icons.delivery_dining_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const DiningCatalogScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF10B981),
        gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
        searchKeywords: const [
          'سوپرمارکت',
          'خرید آنلاین',
          'supermarket',
          'grocery',
          'سوبرماركت',
        ],
        tile: ServiceTile(
          title: localization.travelServiceSupermarket,
          iconData: Icons.storefront_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () =>
              CatalogServiceScreen(config: extraServiceConfig('supermarket')),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFF97316),
        gradientColors: const [Color(0xFFFB923C), Color(0xFFEA580C)],
        searchKeywords: const [
          'رستوران',
          'کافه',
          'میز',
          'restaurant',
          'cafe',
          'مطعم',
        ],
        tile: ServiceTile(
          title: localization.travelServiceRestaurant,
          iconData: Icons.restaurant_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const DiningCatalogScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF6366F1),
        gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
        searchKeywords: const [
          'فروشگاه',
          'خرید کالا',
          'store',
          'shop',
          'متجر',
        ],
        tile: ServiceTile(
          title: localization.travelServiceStore,
          iconData: Icons.shopping_bag_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () =>
              CatalogServiceScreen(config: extraServiceConfig('store')),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF8B5CF6),
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        searchKeywords: const [
          'مترجم',
          'ترجمه',
          'همزمان',
          'translator',
          'translate',
          'مترجم',
        ],
        tile: ServiceTile(
          title: localization.travelServiceTranslator,
          iconData: Icons.translate_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () =>
              CatalogServiceScreen(config: extraServiceConfig('translator')),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFFEF4444),
        gradientColors: const [Color(0xFFF87171), Color(0xFFDC2626)],
        searchKeywords: const [
          'اورژانس',
          'امداد',
          'پشتیبانی فوری',
          'emergency',
          'help',
          'طوارئ',
        ],
        tile: ServiceTile(
          title: localization.travelServiceEmergency,
          iconData: Icons.support_agent_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const EmergencyServiceScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF1677FF),
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        badgeText: (c) => l10nPick(
          c,
          en: 'CNY',
          fa: 'یوان',
          ar: 'يوان',
          zh: '支付宝',
          ru: 'CNY',
          tr: 'CNY',
        ),
        badgeColor: const Color(0xFF1677FF),
        searchKeywords: const [
          'علی پی',
          'چین',
          'یوان',
          'alipay',
          'china',
        ],
        tile: ServiceTile(
          title: localization.travelServiceAliPay,
          iconData: Icons.account_balance_wallet_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => WalletServiceScreen(
            serviceKey: 'aliPay',
            brandStart: const Color(0xFF1677FF),
            brandEnd: const Color(0xFF0E42A8),
            description: (localization) => localization.travelAliPayDescription,
          ),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF2BB673),
        gradientColors: const [Color(0xFF34D399), Color(0xFF15803D)],
        badgeText: (c) => l10nPick(
          c,
          en: 'RUB',
          fa: 'روبل',
          ar: 'روبل',
          zh: '卢布',
          ru: 'RUB',
          tr: 'RUB',
        ),
        badgeColor: const Color(0xFF2BB673),
        searchKeywords: const [
          'میر پی',
          'روسیه',
          'روبل',
          'mirpay',
          'mir',
          'russia',
        ],
        tile: ServiceTile(
          title: localization.travelServiceMirPay,
          iconData: Icons.credit_card_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => WalletServiceScreen(
            serviceKey: 'mirPay',
            brandStart: const Color(0xFF2BB673),
            brandEnd: const Color(0xFF157A4A),
            description: (localization) => localization.travelMirPayDescription,
          ),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF059669),
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)],
        searchKeywords: const [
          'شارژ',
          'شارژ سیم کارت',
          'بسته اینترنت',
          'ایرانسل',
          'همراه اول',
          'رایتل',
          'top up',
          'recharge',
          'sim',
          'شحن',
        ],
        tile: ServiceTile(
          title: localization.travelServiceSimTopUp,
          iconData: Icons.phone_android_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const SimTopUpScreen(),
        ),
      ),
      _HubItem(
        category: ServiceCategory.travel,
        accentColor: const Color(0xFF0284C7),
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0369A1)],
        searchKeywords: const [
          'بیمه',
          'بیمه مسافرتی',
          'سامان',
          'پاسارگاد',
          'insurance',
          'travel insurance',
          'تأمين',
        ],
        tile: ServiceTile(
          title: localization.travelServiceInsurance,
          iconData: Icons.health_and_safety_rounded,
          route: '',
          available: travelOn,
          beforeNavigate: _ensureTravelController,
          pageBuilder: () => const TravelInsuranceScreen(),
        ),
      ),

      // ══════════════════════════════════════════════════════════
      // 3. BUSINESS & INVESTMENT SERVICES
      // ══════════════════════════════════════════════════════════
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF4F46E5),
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
        searchKeywords: const [
          'حواله',
          'حواله ارزی',
          'سوئیفت',
          'شرکتی',
          'remittance',
          'wire transfer',
          'حوالة',
        ],
        tile: ServiceTile(
          title: localization.drawerRemittance,
          icon: PngAssets.billPaymentService,
          route: BaseRoute.remittance,
          feature: 'remittance',
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF10B981),
        gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
        searchKeywords: const [
          'انتقال تجاری',
          'حواله بیزنس',
          'business transfer',
        ],
        tile: ServiceTile(
          title: localization.businessServiceMoneyTransfer,
          icon: PngAssets.transferService,
          route: BaseRoute.transfer,
          feature: 'transfer',
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF8B5CF6),
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        badgeText: (c) => l10nPick(
          c,
          en: 'P2P',
          fa: 'مستقیم',
          ar: 'مباشر',
          zh: 'C2C',
          ru: 'P2P',
          tr: 'P2P',
        ),
        badgeColor: const Color(0xFF8B5CF6),
        searchKeywords: const [
          'پی تو پی',
          'ترید',
          'معاملات مستقیم',
          'خرید ارز',
          'p2p',
          'trading',
        ],
        tile: ServiceTile(
          title: localization.drawerP2pTrading,
          icon: PngAssets.p2pTradingService,
          route: BaseRoute.p2pTrading,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFFD97706),
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFB45309)],
        badgeText: (c) => l10nPick(
          c,
          en: 'Escrow',
          fa: 'ضمانت',
          ar: 'أمانة',
          zh: '担保',
          ru: 'Эскроу',
          tr: 'Emanet',
        ),
        badgeColor: const Color(0xFFD97706),
        searchKeywords: const [
          'اسکرو',
          'معامله امن',
          'حساب امانی',
          'ضمانت معامله',
          'escrow',
          'safe trade',
        ],
        tile: ServiceTile(
          title: localization.businessServiceP2pEscrow,
          iconData: Icons.gavel_rounded,
          route: BaseRoute.escrowHome,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF059669),
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)],
        searchKeywords: const [
          'ضمانت',
          'گارانتی',
          'ضمانت بانکی',
          'guarantee',
          'warranty',
        ],
        tile: ServiceTile(
          title: localization.businessServiceGuarantee,
          iconData: Icons.verified_user_rounded,
          route: BaseRoute.guaranteeHome,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF2563EB),
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        searchKeywords: const [
          'وام',
          'تسهیلات',
          'قرض الحسنه',
          'اعتبار',
          'loan',
          'bank loan',
          'credit',
          'قرض',
        ],
        tile: ServiceTile(
          title: localization.businessServiceBankLoan,
          iconData: Icons.account_balance_rounded,
          route: BaseRoute.loanHome,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF16A34A),
        gradientColors: const [Color(0xFF22C55E), Color(0xFF15803D)],
        searchKeywords: const [
          'بورس',
          'سهام',
          'اوراق بهادار',
          'stocks',
          'equity',
          'market',
          'أسهم',
        ],
        tile: ServiceTile(
          title: localization.businessServiceStocks,
          iconData: Icons.trending_up_rounded,
          route: BaseRoute.stockHome,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFF7C3AED),
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        searchKeywords: const [
          'سرمایه گذاری',
          'پروژه تجاری',
          'جذب سرمایه',
          'equity',
          'investment',
          'استثمار',
        ],
        tile: ServiceTile(
          title: l10nPick(
            context,
            en: 'Equity Projects',
            fa: 'سرمایه‌گذاری تجاری',
            ar: 'المشاريع الاستثمارية',
            zh: '股权投资项目',
            ru: 'Инвест-проекты',
            tr: 'Yatırım Projeleri',
          ),
          iconData: Icons.corporate_fare_rounded,
          route: BaseRoute.commercialProjects,
          available: true,
        ),
      ),
      _HubItem(
        category: ServiceCategory.business,
        accentColor: const Color(0xFFEA580C),
        gradientColors: const [Color(0xFFF97316), Color(0xFFC2410C)],
        searchKeywords: const [
          'لایسنس',
          'مجوز نرم افزار',
          'کد فعالسازی',
          'license',
          'software license',
          'ترخيص',
        ],
        tile: ServiceTile(
          title: l10nPick(
            context,
            en: 'License Store',
            fa: 'فروشگاه لایسنس',
            ar: 'متجر التراخيص',
            zh: '许可证商店',
            tr: 'Lisans Mağazası',
            ru: 'Магазин лицензий',
          ),
          iconData: Icons.vpn_key_rounded,
          route: BaseRoute.licenseStore,
          available: true,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurfaceVariant,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightOutlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              l10nPick(
                context,
                en: 'Services Hub',
                fa: 'مرکز خدمات',
                ar: 'مركز الخدمات',
                zh: '服务中心',
                ru: 'Центр сервисов',
                tr: 'Hizmet Merkezi',
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10nPick(
                context,
                en: 'Fintech & Travel Suite',
                fa: 'دسترسی سریع و یکپارچه',
                ar: 'وصول سريع وموحد',
                zh: '一站式极速访问',
                ru: 'Единый доступ',
                tr: 'Hızlı ve Entegre Erişim',
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final addons = _homeController.userModel.value.data?.addons;
        final KycBadge? badge = currentKycBadge();
        final allHubItems = _buildHubItems(context, addons);

        // Filter by category or search
        final normalizedQuery = _normalizeString(_searchQuery);
        final isSearching = normalizedQuery.isNotEmpty;

        final filteredItems = allHubItems.where((item) {
          if (isSearching) {
            final titleNorm = _normalizeString(item.tile.title);
            if (titleNorm.contains(normalizedQuery)) return true;
            for (final kw in item.searchKeywords) {
              if (_normalizeString(kw).contains(normalizedQuery)) return true;
            }
            return false;
          }

          if (_selectedCategory == ServiceCategory.all) return true;
          return item.category == _selectedCategory;
        }).toList();

        final quickAccessItems =
            allHubItems.where((i) => i.isQuickAccess).toList();

        return RefreshIndicator(
          color: theme.colorScheme.primary,
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          onRefresh: () => _homeController.loadData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Search Bar with slide-up & fade-in entrance
              SliverToBoxAdapter(
                child: _SlideFadeTransition(
                  animation: _searchAnim,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: _buildSearchBar(context, isDark),
                  ),
                ),
              ),

              // 2. Category Filter Chips (Hidden when actively searching)
              if (!isSearching)
                SliverToBoxAdapter(
                  child: _SlideFadeTransition(
                    animation: _chipsAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildCategoryChips(context, isDark, allHubItems),
                    ),
                  ),
                ),

              // 3. Quick Access Hero Banner (Shown in "All" view with empty search)
              if (!isSearching && _selectedCategory == ServiceCategory.all) ...[
                SliverToBoxAdapter(
                  child: _SlideFadeTransition(
                    animation: _heroAnim,
                    child: _buildQuickAccessHero(
                      context: context,
                      items: quickAccessItems,
                      badge: badge,
                      isDark: isDark,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
              ],

              // 4. Main Services Content / Search Results
              if (isSearching)
                _buildSearchResultsSliver(
                  context,
                  filteredItems,
                  badge,
                  isDark,
                )
              else if (_selectedCategory == ServiceCategory.transactions)
                SliverToBoxAdapter(
                  child: _SlideFadeTransition(
                    animation: _contentAnim,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: RecentTransactionsSection(),
                    ),
                  ),
                )
              else if (_selectedCategory == ServiceCategory.all) ...[
                // Categorized sections layout
                _buildCategorizedSectionSliver(
                  context: context,
                  title: l10nPick(
                    context,
                    en: 'Financial & Payments',
                    fa: 'مالی و پرداخت',
                    ar: 'المالية والمدفوعات',
                    zh: '金融与支付',
                    ru: 'Финансы и платежи',
                    tr: 'Finans ve Ödemeler',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'Wallets, Transfers, Cards & Utilities',
                    fa: 'کیف پول، انتقال، کارت و پرداخت قبوض',
                    ar: 'المحافظ، التحويلات، البطاقات والفواتير',
                    zh: '钱包、转账、卡券与生活缴费',
                    ru: 'Кошельки, переводы, карты и счета',
                    tr: 'Cüzdanlar, Transferler, Kartlar ve Faturalar',
                  ),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.brandViolet,
                  items: allHubItems
                      .where((i) => i.category == ServiceCategory.financial)
                      .toList(),
                  badge: badge,
                  isDark: isDark,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),
                _buildCategorizedSectionSliver(
                  context: context,
                  title: l10nPick(
                    context,
                    en: 'Travel & Tourism',
                    fa: 'سفر و گردشگری',
                    ar: 'السفر والسياحة',
                    zh: '旅行与旅游',
                    ru: 'Путешествия и туризм',
                    tr: 'Seyahat ve Turizm',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'Flights, Hotels, eSIM, Rides & CIP',
                    fa: 'پرواز، هتل، ای‌سیم، تاکسی و تشریفات CIP',
                    ar: 'الطيران، الفنادق، الشرائح الإلكترونية والتاكسي',
                    zh: '机票、酒店、eSIM、出行与贵宾厅',
                    ru: 'Авиабилеты, отели, eSIM, такси и CIP',
                    tr: 'Uçuşlar, Oteller, eSIM, Taksi ve CIP',
                  ),
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: const Color(0xFF0284C7),
                  items: allHubItems
                      .where((i) => i.category == ServiceCategory.travel)
                      .toList(),
                  badge: badge,
                  isDark: isDark,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),
                _buildCategorizedSectionSliver(
                  context: context,
                  title: l10nPick(
                    context,
                    en: 'Business & Commercial',
                    fa: 'کسب‌وکار و سرمایه‌گذاری',
                    ar: 'الأعمال والاستثمار',
                    zh: '商务与投资',
                    ru: 'Бизнес и инвестиции',
                    tr: 'İş ve Yatırım',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'P2P Trading, Escrow, Loans & Licenses',
                    fa: 'معاملات مستقیم، حساب امانی، وام و مجوزها',
                    ar: 'تداول P2P، حساب الضمان، القروض والتراخيص',
                    zh: 'C2C交易、担保交易、贷款与许可证',
                    ru: 'P2P торговля, эскроу, кредиты и лицензии',
                    tr: 'P2P İşlemler, Emanet, Kredi ve Lisanslar',
                  ),
                  icon: Icons.store_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  items: allHubItems
                      .where((i) => i.category == ServiceCategory.business)
                      .toList(),
                  badge: badge,
                  isDark: isDark,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),
                // Recent transactions at bottom of "All"
                SliverToBoxAdapter(
                  child: _SlideFadeTransition(
                    animation: _contentAnim,
                    child: const RecentTransactionsSection(),
                  ),
                ),
              ] else ...[
                // Single category selected
                _buildSingleCategorySliver(
                  context,
                  filteredItems,
                  badge,
                  isDark,
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH BAR COMPONENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightOutlineVariant.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10nPick(
            context,
            en: 'Search services (transfer, flight, hotel, loan...)',
            fa: 'جستجوی خدمات (انتقال، شارژ، هتل، وام، ویزا...)',
            ar: 'البحث عن الخدمات (تحويل، طيران، فندق، قرض...)',
            zh: '搜索服务（转账、机票、酒店、贷款...）',
            ru: 'Поиск услуг (перевод, авиабилеты, отель, кредит...)',
            tr: 'Hizmet ara (transfer, uçuş, otel, kredi...)',
          ),
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.brandViolet,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORY FILTER CHIPS
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryChips(
    BuildContext context,
    bool isDark,
    List<_HubItem> allItems,
  ) {
    final chips = [
      (
        category: ServiceCategory.all,
        label: l10nPick(
          context,
          en: 'All',
          fa: 'همه',
          ar: 'الكل',
          zh: '全部',
          ru: 'Все',
          tr: 'Tümü',
        ),
        count: allItems.length,
        icon: Icons.apps_rounded,
      ),
      (
        category: ServiceCategory.financial,
        label: l10nPick(
          context,
          en: 'Financial',
          fa: 'مالی و پرداخت',
          ar: 'مالية',
          zh: '金融',
          ru: 'Финансы',
          tr: 'Finans',
        ),
        count: allItems
            .where((i) => i.category == ServiceCategory.financial)
            .length,
        icon: Icons.payments_rounded,
      ),
      (
        category: ServiceCategory.travel,
        label: l10nPick(
          context,
          en: 'Travel',
          fa: 'سفر و گردشگری',
          ar: 'سفر',
          zh: '旅行',
          ru: 'Путешествия',
          tr: 'Seyahat',
        ),
        count:
            allItems.where((i) => i.category == ServiceCategory.travel).length,
        icon: Icons.flight_rounded,
      ),
      (
        category: ServiceCategory.business,
        label: l10nPick(
          context,
          en: 'Business',
          fa: 'کسب‌وکار',
          ar: 'أعمال',
          zh: '商务',
          ru: 'Бизнес',
          tr: 'İş',
        ),
        count: allItems
            .where((i) => i.category == ServiceCategory.business)
            .length,
        icon: Icons.business_center_rounded,
      ),
      (
        category: ServiceCategory.transactions,
        label: l10nPick(
          context,
          en: 'Transactions',
          fa: 'تراکنش‌ها',
          ar: 'معاملات',
          zh: '明细',
          ru: 'История',
          tr: 'İşlemler',
        ),
        count: 0,
        icon: Icons.receipt_long_rounded,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = _selectedCategory == chip.category;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategory = chip.category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF382A6E),
                                const Color(0xFF271C54),
                              ]
                            : [
                                AppColors.brandViolet,
                                const Color(0xFF5E2BFF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? AppColors.darkSurface : AppColors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF9065FF)
                          : AppColors.brandViolet)
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightOutlineVariant),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark
                                  ? const Color(0xFF7445FF)
                                  : AppColors.brandViolet)
                              .withValues(alpha: isDark ? 0.35 : 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.15 : 0.02,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    size: 16,
                    color: isSelected
                        ? (isDark ? const Color(0xFFD8C7FF) : Colors.white)
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chip.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? const Color(0xFFF1EBFF) : Colors.white)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                  if (chip.count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                                .withValues(alpha: isDark ? 0.20 : 0.25)
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.brandVioletContainer),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chip.count}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.brandViolet),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // QUICK ACCESS HERO BANNER (PREMIER BLUBANK FINTECH CARD)
  // ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccessHero({
    required BuildContext context,
    required List<_HubItem> items,
    required KycBadge? badge,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF221743),
                  const Color(0xFF191333),
                  const Color(0xFF130F26),
                ]
              : [
                  const Color(0xFFF9F7FF),
                  const Color(0xFFF1ECFF),
                  const Color(0xFFE8E2FF),
                ],
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF9065FF).withValues(alpha: 0.28)
              : AppColors.brandViolet.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF7445FF) : AppColors.brandViolet)
                .withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient blurred glow circles in background
            PositionedDirectional(
              top: -30,
              end: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7445FF)
                          .withValues(alpha: isDark ? 0.35 : 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: -35,
              start: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00BFA6)
                          .withValues(alpha: isDark ? 0.25 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7445FF),
                              Color(0xFF9065FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7445FF)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(
                                context,
                                en: 'Quick Access',
                                fa: 'دسترسی سریع و پرتکرار',
                                ar: 'الوصول السريع',
                                zh: '快捷通道',
                                ru: 'Быстрый доступ',
                                tr: 'Hızlı Erişim',
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              l10nPick(
                                context,
                                en: 'Top financial & travel actions',
                                fa: 'عملیات برگزیده مالی و مسافرتی',
                                ar: 'أبرز الخدمات المالية والسياحية',
                                zh: '精选金融与商旅服务',
                                ru: 'Топ финансовые и туристические сервисы',
                                tr: 'Öne Çıkan Finans ve Seyahat İşlemleri',
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? const Color(0xFF7445FF)
                                  : AppColors.brandViolet)
                              .withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isDark
                                    ? const Color(0xFF9065FF)
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 11,
                              color: isDark
                                  ? const Color(0xFFB79CFF)
                                  : AppColors.brandViolet,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${items.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? const Color(0xFFB79CFF)
                                    : AppColors.brandViolet,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Grid of top actions
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 86,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final resolved = resolveTile(item.tile, badge);
                          return _QuickAccessTile(
                            item: item,
                            resolved: resolved,
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIZED CARD SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategorizedSectionSliver({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<_HubItem> items,
    required KycBadge? badge,
    required bool isDark,
  }) {
    return SliverToBoxAdapter(
      child: _SlideFadeTransition(
        animation: _contentAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            iconColor.withValues(alpha: isDark ? 0.35 : 0.20),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${items.length}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.lightOutlineVariant.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: iconColor.withValues(alpha: isDark ? 0.04 : 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildGridOfItems(
                context: context,
                items: items,
                badge: badge,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SINGLE CATEGORY SLIVER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSingleCategorySliver(
    BuildContext context,
    List<_HubItem> items,
    KycBadge? badge,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: _SlideFadeTransition(
        animation: _contentAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.lightOutlineVariant.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildGridOfItems(
            context: context,
            items: items,
            badge: badge,
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH RESULTS SLIVER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSearchResultsSliver(
    BuildContext context,
    List<_HubItem> items,
    KycBadge? badge,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkPrimaryContainer
                      : AppColors.brandVioletContainer,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandViolet
                          .withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 38,
                  color: AppColors.brandViolet,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10nPick(
                  context,
                  en: 'No services found',
                  fa: 'خدمتی با این مشخصات یافت نشد',
                  ar: 'لم يتم العثور على خدمات',
                  zh: '未找到相关服务',
                  ru: 'Услуги не найдены',
                  tr: 'Hizmet bulunamadı',
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10nPick(
                  context,
                  en: 'Try searching for: transfer, flight, hotel, loan, or top-up',
                  fa: 'پیشنهاد: عباراتی مانند «انتقال»، «شارژ»، «پرواز»، «وام» یا «کارت» را امتحان کنید.',
                  ar: 'جرب البحث عن: تحويل، طيران، فندق، قرض، أو شحن',
                  zh: '请尝试搜索：转账、机票、酒店、贷款或充值',
                  ru: 'Попробуйте: перевод, перелет, отель, кредит или пополнение',
                  tr: 'Şunları aramayı deneyin: transfer, uçuş, otel, kredi veya yükleme',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  l10nPick(
                    context,
                    en: 'Clear search',
                    fa: 'پاک کردن جستجو',
                    ar: 'مسح البحث',
                    zh: '清空搜索',
                    ru: 'Очистить поиск',
                    tr: 'Aramayı Temizle',
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandViolet,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Text(
              l10nPick(
                context,
                en: '${items.length} matching services found',
                fa: '${items.length} خدمت یافت شد',
                ar: 'تم العثور على ${items.length} خدمة',
                zh: '找到 ${items.length} 个相关服务',
                ru: 'Найдено ${items.length} услуг',
                tr: '${items.length} eşleşen hizmet bulundu',
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightOutlineVariant.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildGridOfItems(
              context: context,
              items: items,
              badge: badge,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GRID OF ITEMS RENDERER
  // ─────────────────────────────────────────────────────────────
  Widget _buildGridOfItems({
    required BuildContext context,
    required List<_HubItem> items,
    required KycBadge? badge,
    required bool isDark,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 6,
        mainAxisExtent: 96,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final resolved = resolveTile(item.tile, badge);
        return _InteractiveServiceCard(
          item: item,
          resolved: resolved,
          isDark: isDark,
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
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

/// Metadata model encapsulating service categorization and search synonyms
class _HubItem {
  final ServiceCategory category;
  final ServiceTile tile;
  final List<String> searchKeywords;
  final bool isQuickAccess;
  final Color? accentColor;

  const _HubItem({
    required this.category,
    required this.tile,
    this.searchKeywords = const [],
    this.isQuickAccess = false,
    this.accentColor,
  });
}

/// PREMIER BLUBANK SERVICES HUB
///
/// Features:
/// 1. Instant fuzzy & keyword search with Iranian/regional synonym resolution.
/// 2. Segmented category filter chips (All, Financial, Travel, Business, Transactions).
/// 3. BluBank-style Quick Access hero banner for high-frequency actions.
/// 4. Modern card styling matching brand violet #7445FF with dark mode support.
/// 5. Full integration of Recent Transactions history moved off the dashboard.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  ServiceCategory _selectedCategory = ServiceCategory.all;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
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
        .replaceAll('\u200c', ' ') // Zero-width non-joiner
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
        isQuickAccess: true,
        accentColor: const Color(0xFF6366F1),
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
        accentColor: const Color(0xFF10B981),
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
                en: 'BluBank Edition',
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
              // 1. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: _buildSearchBar(context, isDark),
                ),
              ),

              // 2. Category Filter Chips (Hidden when actively searching)
              if (!isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildCategoryChips(context, isDark, allHubItems),
                  ),
                ),

              // 3. Quick Access Bar (Shown only in "All" view with empty search)
              if (!isSearching && _selectedCategory == ServiceCategory.all) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: _buildQuickAccessHeader(context, isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildQuickAccessGrid(
                      context,
                      quickAccessItems,
                      badge,
                      isDark,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
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
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: RecentTransactionsSection(),
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
                const SliverToBoxAdapter(
                  child: RecentTransactionsSection(),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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

          return InkWell(
            onTap: () => setState(() => _selectedCategory = chip.category),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimaryContainer : AppColors.brandViolet)
                    : (isDark ? AppColors.darkSurface : AppColors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightOutlineVariant),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet).withValues(alpha: isDark ? 0.2 : 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    size: 16,
                    color: isSelected
                        ? (isDark ? AppColors.mainSoftBlue : Colors.white)
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
                          ? (isDark ? AppColors.mainSoftBlue : Colors.white)
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
                            ? (isDark ? AppColors.mainSoftBlue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.25))
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
                              ? (isDark ? AppColors.mainSoftBlue : Colors.white)
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
  // QUICK ACCESS BANNER (پرتکرارترین‌ها)
  // ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccessHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkPrimaryContainer
                : AppColors.brandVioletContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 18,
            color: AppColors.brandViolet,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10nPick(
            context,
            en: 'Quick Access',
            fa: 'دسترسی سریع و پرتکرار',
            ar: 'وصول سريع ومميز',
            zh: '常用快捷服务',
          ),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(
    BuildContext context,
    List<_HubItem> items,
    KycBadge? badge,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.brandViolet.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandViolet.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: items.map((item) {
                  final resolved = resolveTile(item.tile, badge);
                  return SizedBox(
                    width: 68,
                    child: _buildTileView(
                      context: context,
                      resolved: resolved,
                      accentColor: item.accentColor ?? AppColors.brandViolet,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final resolved = resolveTile(item.tile, badge);
              return Expanded(
                child: _buildTileView(
                  context: context,
                  resolved: resolved,
                  accentColor: item.accentColor ?? AppColors.brandViolet,
                  isDark: isDark,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIZED CARD SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategorizedSectionSliver({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_HubItem> items,
    required KycBadge? badge,
    required bool isDark,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 11,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 14,
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
  // SINGLE CATEGORY SLIVER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSingleCategorySliver(
    BuildContext context,
    List<_HubItem> items,
    KycBadge? badge,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 14,
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkPrimaryContainer
                      : AppColors.brandVioletContainer,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 36,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 14,
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 4,
        mainAxisExtent: 86,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final resolved = resolveTile(item.tile, badge);
        return _buildTileView(
          context: context,
          resolved: resolved,
          accentColor: item.accentColor ?? AppColors.brandViolet,
          isDark: isDark,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INDIVIDUAL TILE VIEW (PREMIER BLUBANK STYLE)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTileView({
    required BuildContext context,
    required ResolvedTile resolved,
    required Color accentColor,
    required bool isDark,
  }) {
    final tile = resolved.tile;
    final disabled = resolved.state != TileState.available;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onTileTap(context, resolved),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon squircle container with soft tinted background
                Container(
                  width: 44,
                  height: 44,
                  padding: tile.icon != null
                      ? const EdgeInsets.all(9)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      width: 1,
                    ),
                  ),
                  child: tile.iconData != null
                      ? Icon(
                          tile.iconData,
                          color: isDark ? AppColors.darkPrimary : accentColor,
                          size: 22,
                        )
                      : Image.asset(
                          tile.icon!,
                          width: 24,
                          height: 24,
                          color: disabled
                              ? (isDark
                                  ? AppColors.white.withValues(alpha: 0.30)
                                  : AppColors.black.withValues(alpha: 0.30))
                              : (isDark ? AppColors.white : null),
                        ),
                ),
                // Lock badge for KYC-gated or unbuilt modules
                if (resolved.state == TileState.kycLocked ||
                    resolved.state == TileState.notBuilt)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkGray : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.warmWhite.withValues(alpha: 0.15)
                              : AppColors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 9,
                        color: isDark
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
                  height: 1.2,
                  color: (isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF2D2D2D))
                      .withValues(
                    alpha: disabled ? 0.40 : (isDark ? 0.90 : 0.85),
                  ),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

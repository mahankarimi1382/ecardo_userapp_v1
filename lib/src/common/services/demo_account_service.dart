import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Comprehensive Demo & Test Account Service
/// Provides instant zero-network bypass, rich mock entities, KYC switcher,
/// and smart endpoint fallback simulation for all app modules.
class DemoAccountService extends GetxService {
  static DemoAccountService get to => Get.find<DemoAccountService>();

  static const String _prefDemoActiveKey = 'ecardo_demo_mode_active';
  static const String _demoBearerToken = 'demo_user_auth_token_ecardo_qa_2026';

  final RxBool isDemoMode = false.obs;
  // Admin-controlled kill-switch: if disabled by admin, the demo button is completely hidden from the UI!
  final RxBool isDemoAllowedByAdmin = true.obs;
  final RxInt demoKycStatus = 1.obs; // 1: Verified, 2: Pending, 3: Rejected, 0: Unverified
  final RxString demoRejectReason =
      'تصویر کارت ملی ارسالی مخدوش یا ناخوانا می‌باشد. لطفاً تصویر باکیفیت‌تری بارگذاری فرمایید.'.obs;

  late final Rx<UserModel> demoUserModel;
  late final RxList<Wallets> demoWallets;
  late final Rx<VirtualCardsData> demoVirtualCard;
  late final Rx<DashboardModel> demoDashboardModel;
  late final Rx<TransactionsModel> demoTransactionsModel;

  @override
  void onInit() {
    super.onInit();
    _initDemoEntities();
    _loadPersistedDemoState();
  }

  Future<void> _loadPersistedDemoState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final active = prefs.getBool(_prefDemoActiveKey) ?? false;
      if (active) {
        isDemoMode.value = true;
      }
    } catch (_) {}
  }

  void _initDemoEntities() {
    // 1. Demo User Profile
    demoUserModel = UserModel(
      status: 'success',
      message: 'Demo profile active',
      data: UserData(
        id: 9999,
        role: 'user',
        firstName: 'کاربر دمو',
        lastName: 'تست کیفیت',
        username: 'demo_tester',
        fullName: 'کاربر دمو و تست کیفیت (QA Demo)',
        accountNumber: 'EC-99204812',
        email: 'demo@ecardo.ir',
        phone: '+989123456789',
        emailVerifiedAt: '2026-01-01 00:00:00',
        phoneVerified: true,
        status: 1,
        kyc: demoKycStatus.value,
        kycLevel: 3,
        kycType: 'PASSPORT_AND_FACE',
        isRejected: false,
        balance: '1850.00',
        hasPasscode: true,
        passcode: '1234',
        country: 'IR',
        city: 'Tehran',
        zipCode: '1969713456',
        address: 'خیابان ولیعصر، برج تجارت الکترونیک، طبقه ۱۲',
        referralCode: 'ECAR-DEMO-VIP',
        twoFa: false,
        withdrawStatus: 1,
        otpStatus: 1,
        depositStatus: 1,
        transferStatus: 1,
        paymentStatus: 1,
        createdAt: '2026-01-01 10:00:00',
        currentStep: 'completed',
        boardingSteps: BoardingSteps(
          emailVerification: true,
          passwordSetup: true,
          personalInfo: true,
          idVerification: true,
          completed: true,
        ),
        addons: Addons(
          virtualCards: true,
          giftCards: true,
          p2pTrading: true,
          travel: true,
          travelSim: true,
          travelFlight: true,
        ),
      ),
    ).obs;

    // 2. Multi-Currency Wallets with requested live balances
    demoWallets = <Wallets>[
      Wallets(
        id: 1,
        name: 'کیف پول دلار آمریکا (USD)',
        accountNo: 'WA-USD-9901',
        balance: '1850.00',
        formattedBalance: '\$1,850.00',
        code: 'USD',
        symbol: '\$',
        isDefault: true,
        isCrypto: false,
        currencyId: 1,
        conversionRate: '1.0',
      ),
      Wallets(
        id: 2,
        name: 'کیف پول یورو اروپا (EUR)',
        accountNo: 'WA-EUR-9902',
        balance: '1200.00',
        formattedBalance: '€1,200.00',
        code: 'EUR',
        symbol: '€',
        isDefault: false,
        isCrypto: false,
        currencyId: 2,
        conversionRate: '1.08',
      ),
      Wallets(
        id: 3,
        name: 'کیف پول تتر (USDT-TRC20)',
        accountNo: 'WA-USDT-9903',
        balance: '3400.00',
        formattedBalance: '3,400.00 ₮',
        code: 'USDT',
        symbol: '₮',
        isDefault: false,
        isCrypto: true,
        currencyId: 3,
        conversionRate: '1.0',
      ),
      Wallets(
        id: 4,
        name: 'کیف پول ریال ایران (IRR)',
        accountNo: 'WA-IRR-9904',
        balance: '520000000',
        formattedBalance: '520,000,000 ریال',
        code: 'IRR',
        symbol: 'ریال',
        isDefault: false,
        isCrypto: false,
        currencyId: 4,
        conversionRate: '0.0000015',
      ),
      Wallets(
        id: 5,
        name: 'کیف پول درهم امارات (AED)',
        accountNo: 'WA-AED-9905',
        balance: '4500.00',
        formattedBalance: '4,500.00 د.إ',
        code: 'AED',
        symbol: 'د.إ',
        isDefault: false,
        isCrypto: false,
        currencyId: 5,
        conversionRate: '0.27',
      ),
    ].obs;

    // 3. Active Virtual Card
    demoVirtualCard = VirtualCardsData(
      id: 101,
      userId: 9999,
      cardHolderId: 1,
      cardId: 'epay_card_demo_101',
      currency: 'USD',
      type: 'MasterCard Platinum',
      status: 'active',
      lifecycleStatus: 'active',
      amount: '450.00',
      provider: 'MasterCard / Ecardo Pay',
      cardNumber: '5328 9200 4812 7640',
      displayNumber: '•••• 7640',
      lastFourDigits: '7640',
      cvc: '382',
      expirationMonth: 8,
      expirationYear: 2029,
      createdAt: '2026-02-10 14:00:00',
      cardHolder: CardHolder(
        firstName: 'کاربر دمو',
        lastName: 'تست کیفیت',
        email: 'demo@ecardo.ir',
      ),
    ).obs;

    // 4. Dashboard Model
    demoDashboardModel = DashboardModel(
      status: 'success',
      message: 'Dashboard data loaded',
      data: DashboardData(
        referral: Referral(
          bonus: '50.00',
          count: 5,
          referralCode: 'ECAR-DEMO-VIP',
        ),
        info: Info(
          timeWiseWish: 'روز بخیر، کاربر گرامی',
          lastLogin: 'امروز، ۱۰:۱۵',
          unreadNotificationsCount: 2,
        ),
        user: User(
          fullName: 'کاربر دمو و تست کیفیت',
          userName: 'demo_tester',
          accountNumber: 'EC-99204812',
          email: 'demo@ecardo.ir',
        ),
      ),
    ).obs;

    // 5. Recent Transactions
    demoTransactionsModel = TransactionsModel(
      status: 'success',
      message: 'Transactions loaded',
      data: TransactionsData(
        transactions: [
          Transactions(
            description: 'شارژ آنلاین کیف پول تتر',
            tnx: 'TNX-USDT-991240',
            isPlus: true,
            type: 'deposit',
            amount: '1,000.00',
            charge: '0.00',
            finalAmount: '1,000.00',
            status: 'completed',
            createdAt: '2026-10-01 11:20:00',
            trxCurrency: 'USDT',
            trxCurrencySymbol: '₮',
            trxCurrencyCode: 'USDT',
          ),
          Transactions(
            description: 'صدور کارت مجازی مسترکارت',
            tnx: 'TNX-CRD-882104',
            isPlus: false,
            type: 'virtual_card',
            amount: '50.00',
            charge: '0.00',
            finalAmount: '50.00',
            status: 'completed',
            createdAt: '2026-09-29 16:45:00',
            trxCurrency: 'USD',
            trxCurrencySymbol: '\$',
            trxCurrencyCode: 'USD',
          ),
          Transactions(
            description: 'تبدیل یورو به دلار آمریکا',
            tnx: 'TNX-EXC-774102',
            isPlus: true,
            type: 'exchange',
            amount: '250.00',
            charge: '1.20',
            finalAmount: '248.80',
            status: 'completed',
            createdAt: '2026-09-28 09:12:00',
            trxCurrency: 'USD',
            trxCurrencySymbol: '\$',
            trxCurrencyCode: 'USD',
          ),
        ],
      ),
    ).obs;
  }

  /// Activate full Demo Mode and bypass authentication
  Future<void> activateDemoMode() async {
    isDemoMode.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDemoActiveKey, true);

    // Save demo token & login state
    if (Get.isRegistered<TokenService>()) {
      await Get.find<TokenService>().saveAccessToken(_demoBearerToken);
    }
    if (Get.isRegistered<SettingsService>()) {
      final settings = Get.find<SettingsService>();
      await settings.saveLoginCurrentState('logged_in');
      await settings.saveLoggedInUserEmail('demo@ecardo.ir');
      await settings.saveEmailVerified(true);
      await settings.saveSetUpPassword(true);
    }

    // Push into HomeController
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      homeCtrl.userModel.value = demoUserModel.value;
      homeCtrl.walletsList.assignAll(demoWallets);
      homeCtrl.transactionsModel.value = demoTransactionsModel.value;
      homeCtrl.dashboardModel.value = demoDashboardModel.value;
      homeCtrl.isLoading.value = false;
      homeCtrl.loadError.value = '';
    }

    // Trigger reactive state updates
    AppEventBus.emit(ProfileUpdatedEvent());
    AppEventBus.emit(BalanceChangedEvent());
    AppEventBus.emit(KycStatusChangedEvent());

    Get.offAllNamed(BaseRoute.navigation);
  }

  /// Deactivate demo mode and clean session
  Future<void> deactivateDemoMode() async {
    isDemoMode.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefDemoActiveKey);

    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().wipeSession();
    }
    if (Get.isRegistered<TokenService>()) {
      await Get.find<TokenService>().clearToken();
    }

    Get.offAllNamed(BaseRoute.signIn);
  }

  /// Switch KYC Status instantly
  void setKycStatus(int status, {String? rejectReason}) {
    demoKycStatus.value = status;
    final data = demoUserModel.value.data;
    if (data != null) {
      data.kyc = status;
      if (status == 3) {
        data.isRejected = true;
        data.rejectionReason = rejectReason ?? demoRejectReason.value;
      } else {
        data.isRejected = false;
        data.rejectionReason = null;
      }
    }
    demoUserModel.refresh();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().userModel.value = demoUserModel.value;
      Get.find<HomeController>().userModel.refresh();
    }

    AppEventBus.emit(KycStatusChangedEvent());
    AppEventBus.emit(ProfileUpdatedEvent());
  }

  /// Reset & recharge demo wallets
  void rechargeWallets() {
    demoWallets.assignAll([
      Wallets(
        id: 1,
        name: 'کیف پول دلار آمریکا (USD)',
        accountNo: 'WA-USD-9901',
        balance: '1850.00',
        formattedBalance: '\$1,850.00',
        code: 'USD',
        symbol: '\$',
        isDefault: true,
        isCrypto: false,
        currencyId: 1,
        conversionRate: '1.0',
      ),
      Wallets(
        id: 2,
        name: 'کیف پول یورو اروپا (EUR)',
        accountNo: 'WA-EUR-9902',
        balance: '1200.00',
        formattedBalance: '€1,200.00',
        code: 'EUR',
        symbol: '€',
        isDefault: false,
        isCrypto: false,
        currencyId: 2,
        conversionRate: '1.08',
      ),
      Wallets(
        id: 3,
        name: 'کیف پول تتر (USDT-TRC20)',
        accountNo: 'WA-USDT-9903',
        balance: '3400.00',
        formattedBalance: '3,400.00 ₮',
        code: 'USDT',
        symbol: '₮',
        isDefault: false,
        isCrypto: true,
        currencyId: 3,
        conversionRate: '1.0',
      ),
      Wallets(
        id: 4,
        name: 'کیف پول ریال ایران (IRR)',
        accountNo: 'WA-IRR-9904',
        balance: '520000000',
        formattedBalance: '520,000,000 ریال',
        code: 'IRR',
        symbol: 'ریال',
        isDefault: false,
        isCrypto: false,
        currencyId: 4,
        conversionRate: '0.0000015',
      ),
      Wallets(
        id: 5,
        name: 'کیف پول درهم امارات (AED)',
        accountNo: 'WA-AED-9905',
        balance: '4500.00',
        formattedBalance: '4,500.00 د.إ',
        code: 'AED',
        symbol: 'د.إ',
        isDefault: false,
        isCrypto: false,
        currencyId: 5,
        conversionRate: '0.27',
      ),
    ]);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().walletsList.assignAll(demoWallets);
    }

    AppEventBus.emit(BalanceChangedEvent());
    AppEventBus.emit(WalletListChangedEvent());
  }

  // -------------------------------------------------------------------------
  // Smart Mock & Fallback Dispatcher for NetworkService & Repositories
  // -------------------------------------------------------------------------

  Map<String, dynamic>? handleDemoRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
  }) {
    if (!isDemoMode.value) return null;
    return _dispatchDemoResponse(endpoint, method, data);
  }

  Map<String, dynamic>? handleDemoFallback({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    int? statusCode,
  }) {
    if (!isDemoMode.value) return null;
    return _dispatchDemoResponse(endpoint, method, data);
  }

  Map<String, dynamic>? _dispatchDemoResponse(
    String endpoint,
    String method,
    Map<String, dynamic>? data,
  ) {
    final cleanEndpoint = endpoint.split('?').first;

    // User Profile
    if (cleanEndpoint == '/auth/user/get' || cleanEndpoint == '/user/profile') {
      return {
        'status': 'success',
        'message': 'Success',
        'data': {
          'id': 9999,
          'role': 'user',
          'first_name': 'کاربر دمو',
          'last_name': 'تست کیفیت',
          'username': 'demo_tester',
          'full_name': 'کاربر دمو و تست کیفیت (QA Demo)',
          'account_number': 'EC-99204812',
          'email': 'demo@ecardo.ir',
          'phone': '+989123456789',
          'email_verified_at': '2026-01-01 00:00:00',
          'phone_verified': true,
          'status': 1,
          'kyc': demoKycStatus.value,
          'kyc_level': 3,
          'kyc_type': 'PASSPORT_AND_FACE',
          'is_rejected': demoKycStatus.value == 3,
          'rejection_reason': demoKycStatus.value == 3 ? demoRejectReason.value : null,
          'balance': '1850.00',
          'has_passcode': true,
          'country': 'IR',
          'city': 'Tehran',
          'zip_code': '1969713456',
          'address': 'خیابان ولیعصر، برج تجارت الکترونیک، طبقه ۱۲',
          'referral_code': 'ECAR-DEMO-VIP',
          'created_at': '2026-01-01 10:00:00',
          'boarding_steps': {
            'email_verification': true,
            'password_setup': true,
            'personal_info': true,
            'id_verification': true,
            'completed': true,
          },
          'addons': {
            'virtual_cards': true,
            'gift_cards': true,
            'p2p_trading': true,
            'travel': true,
            'travel_sim': true,
            'travel_flight': true,
          },
        },
      };
    }

    // Wallets
    if (cleanEndpoint == '/user/wallets') {
      return {
        'status': 'success',
        'message': 'Success',
        'data': {
          'wallets': demoWallets.map((w) => {
            'id': w.id,
            'name': w.name,
            'account_no': w.accountNo,
            'balance': w.balance,
            'formatted_balance': w.formattedBalance,
            'code': w.code,
            'symbol': w.symbol,
            'is_default': w.isDefault,
            'is_crypto': w.isCrypto,
            'currency_id': w.currencyId,
            'conversion_rate': w.conversionRate,
          }).toList(),
        },
      };
    }

    // Dashboard
    if (cleanEndpoint == '/user/dashboard') {
      return {
        'status': 'success',
        'message': 'Success',
        'data': {
          'referral': {'bonus': '50.00', 'count': 5, 'referral_code': 'ECAR-DEMO-VIP'},
          'info': {
            'time_wise_wish': 'روز بخیر، کاربر گرامی',
            'last_login': 'امروز، ۱۰:۱۵',
            'unread_notifications_count': 2,
          },
          'user': {
            'full_name': 'کاربر دمو و تست کیفیت',
            'username': 'demo_tester',
            'account_number': 'EC-99204812',
            'email': 'demo@ecardo.ir',
          },
        },
      };
    }

    // Virtual Cards
    if (cleanEndpoint == '/user/cards' || cleanEndpoint == '/epay/cards') {
      return {
        'status': 'success',
        'message': 'Success',
        'data': [
          {
            'id': 101,
            'card_id': 'epay_card_demo_101',
            'currency': 'USD',
            'type': 'MasterCard Platinum',
            'status': 'active',
            'lifecycle_status': 'active',
            'amount': '450.00',
            'provider': 'MasterCard / Ecardo Pay',
            'card_number': '5328 9200 4812 7640',
            'display_number': '•••• 7640',
            'last_four_digits': '7640',
            'cvc': '382',
            'expiration_month': 8,
            'expiration_year': 2029,
            'card_holder': {
              'first_name': 'کاربر دمو',
              'last_name': 'تست کیفیت',
              'email': 'demo@ecardo.ir',
            },
          }
        ],
      };
    }

    // Virtual Card Transactions
    if (cleanEndpoint == '/user/cards/transactions') {
      return {
        'status': 'success',
        'message': 'Success',
        'data': [
          {
            'id': 1,
            'title': 'Amazon AWS Cloud Subscription',
            'amount': '42.50',
            'currency': 'USD',
            'type': 'debit',
            'created_at': '2026-09-28 12:10:00',
            'status': 'completed',
          },
          {
            'id': 2,
            'title': 'Card Balance Top-Up',
            'amount': '200.00',
            'currency': 'USD',
            'type': 'credit',
            'created_at': '2026-09-20 18:30:00',
            'status': 'completed',
          },
        ],
      };
    }

    // ------------------------- LOAN SERVICE -------------------------
    if (cleanEndpoint == '/loan/products') {
      return {
        'status': 'success',
        'data': {
          'products': [
            {
              'id': 1,
              'title': 'تسهیلات خرید تجهیزات دیجیتال / Digital Tech Credit',
              'currency': 'USD',
              'min_amount': 500.0,
              'max_amount': 10000.0,
              'apr': 12.5,
              'tenure_months': [6, 12, 18, 24],
              'collateral_type': 'CASH',
              'collateral_ratio': 20.0,
            },
            {
              'id': 2,
              'title': 'وام کارآفرینی و تجارت بین‌الملل / SME Business Credit',
              'currency': 'EUR',
              'min_amount': 2000.0,
              'max_amount': 50000.0,
              'apr': 9.8,
              'tenure_months': [12, 24, 36],
              'collateral_type': 'MIXED',
              'collateral_ratio': 15.0,
            },
          ],
        },
      };
    }

    if (cleanEndpoint == '/loan/my') {
      return {
        'status': 'success',
        'data': {
          'cases': [_buildDemoLoanCase()],
        },
      };
    }

    if (cleanEndpoint.startsWith('/loan/cases/')) {
      if (method == 'GET') {
        return {
          'status': 'success',
          'data': {'case': _buildDemoLoanCase()},
        };
      }
      return {'status': 'success', 'message': 'Operation completed in demo mode'};
    }

    if (cleanEndpoint == '/loan/apply') {
      return {
        'status': 'success',
        'data': {
          'case_id': 1001,
          'approved_amount': 5000.0,
          'status': 'AWAITING_COLLATERAL',
          'monthly_installment': 458.33,
        },
      };
    }

    // ----------------------- GUARANTEE SERVICE -----------------------
    if (cleanEndpoint == '/guarantee/instruments') {
      return {
        'status': 'success',
        'data': {
          'instruments': [
            {
              'id': 1,
              'code': 'PERFORMANCE_BG',
              'title': 'ضمانت‌نامه حسن انجام تعهدات (Performance Guarantee)',
              'currency': 'EUR',
              'min_amount': 5000.0,
              'max_amount': 200000.0,
              'issuing_banks': ['بنک آف جورجیا (BOG)', 'امارات ان‌بی‌دی (ENBD)', 'استاندارد چارترد'],
            },
            {
              'id': 2,
              'code': 'ADVANCE_PAYMENT_BG',
              'title': 'ضمانت‌نامه پیش‌پرداخت (Advance Payment Guarantee)',
              'currency': 'USD',
              'min_amount': 10000.0,
              'max_amount': 500000.0,
              'issuing_banks': ['بانک زراعت ترکیه', 'حبیب بانک'],
            },
          ],
        },
      };
    }

    if (cleanEndpoint == '/guarantee/my') {
      return {
        'status': 'success',
        'data': {
          'cases': [_buildDemoGuaranteeCase()],
        },
      };
    }

    if (cleanEndpoint.startsWith('/guarantee/cases')) {
      if (method == 'GET') {
        return {
          'status': 'success',
          'data': {'case': _buildDemoGuaranteeCase()},
        };
      }
      return {'status': 'success', 'message': 'Guarantee processed in demo mode'};
    }

    // ----------------------- LICENSE SERVICE -----------------------
    if (cleanEndpoint == '/user/licenses/catalog') {
      return {
        'status': 'success',
        'data': {
          'products': [
            {
              'id': 1,
              'title': 'JetBrains All Products Pack',
              'slug': 'jetbrains-all-products',
              'category': 'developer',
              'description': 'دسترسی کامل ۱ ساله به کلیه IDEهای جت‌برینز (IntelliJ, WebStorm, PyCharm)',
              'price': 189.0,
              'tiers': [
                {'id': 1, 'name': '1 Year Personal License', 'price': 189.0},
                {'id': 2, 'name': '2 Year Personal License', 'price': 349.0},
              ],
            },
            {
              'id': 2,
              'title': 'TradingView Premium Pro+',
              'slug': 'tradingview-premium',
              'category': 'financial',
              'description': 'اکانت پریمیوم تریدینگ‌ویو بدون تبلیغات با دسترسی به داده‌های لحظه‌ای بازارهای جهانی',
              'price': 120.0,
              'tiers': [
                {'id': 3, 'name': '12 Months Pro+', 'price': 120.0},
              ],
            },
          ],
        },
      };
    }

    if (cleanEndpoint.startsWith('/user/licenses/catalog/')) {
      return {
        'status': 'success',
        'data': {
          'id': 1,
          'title': 'JetBrains All Products Pack',
          'slug': 'jetbrains-all-products',
          'price': 189.0,
          'tiers': [
            {'id': 1, 'name': '1 Year Personal License', 'price': 189.0},
          ],
        },
      };
    }

    if (cleanEndpoint == '/user/licenses/my-licenses') {
      return {
        'status': 'success',
        'data': {
          'orders': [
            {
              'id': 3001,
              'order_number': 'LIC-2026-JB-9912',
              'product_title': 'JetBrains All Products Pack (1 Year Subscription)',
              'status': 'DELIVERED',
              'license_key': 'ECAR-JB2026-X992-KL49-DEMO-LICENSE-KEY',
              'quantity': 1,
              'total_amount': 189.0,
              'created_at': '2026-09-28 14:30:00',
            }
          ],
        },
      };
    }

    if (cleanEndpoint == '/user/licenses/orders' || cleanEndpoint.contains('/user/licenses/orders/')) {
      return {
        'status': 'success',
        'data': {
          'id': 3001,
          'order_number': 'LIC-2026-JB-9912',
          'status': 'PAID',
          'license_key': 'ECAR-JB2026-X992-KL49-DEMO-LICENSE-KEY',
        },
      };
    }

    // ----------------------- VISA SERVICE -----------------------
    if (cleanEndpoint == '/visa/catalog') {
      return {
        'status': 'success',
        'data': [
          {
            'id': 1,
            'country_name': 'آلمان (Germany)',
            'country_code': 'DE',
            'title': 'ویزای شنگن تجاری و توریستی (Type C)',
            'price': 120.0,
            'processing_days': 15,
            'validity_days': 90,
            'requirements': ['گذرنامه با ۶ ماه اعتبار', 'تمکن مالی معتبر', 'رزرو پرواز و هتل'],
          },
          {
            'id': 2,
            'country_name': 'امارات متحده عربی (UAE)',
            'country_code': 'AE',
            'title': 'ویزای الکترونیکی ۳۰ روزه توریستی',
            'price': 95.0,
            'processing_days': 3,
            'validity_days': 30,
            'requirements': ['تصویر پاسپورت', 'عکس پرسنلی'],
          },
        ],
      };
    }

    if (cleanEndpoint == '/user/visa/requests') {
      if (method == 'GET') {
        return {
          'status': 'success',
          'data': [
            {
              'id': 4001,
              'case_no': 'VSA-2026-DE-88341',
              'country_name': 'آلمان (Germany)',
              'country_code': 'DE',
              'title': 'ویزای توریستی شنگن (Schengen Tourist Visa)',
              'status': 'UNDER_REVIEW',
              'amount': 120.0,
              'created_at': '2026-09-25 10:00:00',
            }
          ],
        };
      }
      return {
        'status': 'success',
        'data': {
          'id': 4002,
          'case_no': 'VSA-2026-NEW-9912',
          'status': 'SUBMITTED',
        },
      };
    }

    // ----------------------- TOURS SERVICE -----------------------
    if (cleanEndpoint == '/user/tours') {
      return {
        'status': 'success',
        'data': {
          'tours': [
            {
              'id': 1,
              'title': 'تور لوکس پاریس و رم (۷ روزه رویایی)',
              'country_code': 'FR',
              'city': 'Paris & Rome',
              'category': 'cultural',
              'duration_days': 7,
              'starting_price': 1450.0,
              'rating': 4.9,
              'highlights': ['برج ایفل', 'موزه لوور', 'کولوسئوم رم', 'اقامت در هتل‌های ۵ ستاره'],
            },
            {
              'id': 2,
              'title': 'تور سافاری و استراحت ساحلی بالی',
              'country_code': 'ID',
              'city': 'Bali',
              'category': 'beach',
              'duration_days': 8,
              'starting_price': 890.0,
              'rating': 4.8,
              'highlights': ['سواحل نوسا دوآ', 'معابد تاریخی', 'جنگل میمون‌ها'],
            },
          ],
        },
      };
    }

    if (cleanEndpoint == '/user/tours/match') {
      return {
        'status': 'success',
        'data': {
          'tours': [
            {
              'id': 1,
              'title': 'تور لوکس پاریس و رم (۷ روزه رویایی)',
              'city': 'Paris & Rome',
              'starting_price': 1450.0,
            }
          ],
        },
      };
    }

    // ----------------------- CAR RENTAL -----------------------
    if (cleanEndpoint == '/rental/cars') {
      return {
        'status': 'success',
        'data': {
          'data': [
            {
              'id': 1,
              'title': 'Toyota Camry Hybrid 2024',
              'category': 'ECONOMY',
              'transmission': 'AUTOMATIC',
              'daily_price': 65.0,
              'deposit_amount': 300.0,
              'is_fleet': true,
              'insurance_tiers': [
                {'tier': 'BASIC', 'extra_cost': 0},
                {'tier': 'FULL_COVERAGE', 'extra_cost': 15.0},
              ],
            },
            {
              'id': 2,
              'title': 'BMW 5 Series Executive',
              'category': 'LUXURY',
              'transmission': 'AUTOMATIC',
              'daily_price': 160.0,
              'deposit_amount': 800.0,
              'is_fleet': true,
              'insurance_tiers': [
                {'tier': 'BASIC', 'extra_cost': 0},
                {'tier': 'VIP_ZERO_DEDUCTIBLE', 'extra_cost': 35.0},
              ],
            },
          ],
        },
      };
    }

    if (cleanEndpoint == '/rental/my') {
      return {
        'status': 'success',
        'data': {
          'bookings': [
            {
              'id': 5001,
              'booking_no': 'RNT-2026-TC-8812',
              'status': 'CONFIRMED',
              'rental_total': 195.0,
              'extras_total': 0.0,
              'pickup_at': '2026-10-05T10:00:00Z',
              'return_at': '2026-10-08T10:00:00Z',
              'car': {
                'id': 1,
                'title': 'Toyota Camry Hybrid 2024',
                'category': 'ECONOMY',
                'daily_price': 65.0,
                'deposit_amount': 300.0,
              },
            }
          ],
        },
      };
    }

    // Default catch-all for successful demo actions
    if (method == 'POST' || method == 'PUT') {
      return {
        'status': 'success',
        'message': 'Operation completed successfully (Demo Mode)',
        'data': {'id': DateTime.now().millisecondsSinceEpoch, 'status': 'completed'},
      };
    }

    return null;
  }

  static Map<String, dynamic> _buildDemoLoanCase() {
    return {
      'id': 1001,
      'case_number': 'LN-2026-QA-8821',
      'product_title': 'تسهیلات خرید تجهیزات دیجیتال / Digital Equipment Credit',
      'currency': 'USD',
      'approved_amount': 5000.0,
      'tenure_months': 12,
      'monthly_installment': 458.33,
      'status': 'ACTIVE',
      'status_fa': 'فعال (در حال بازپرداخت)',
      'disbursed_at': '2026-08-01 10:00:00',
      'installments': List.generate(12, (index) {
        final num = index + 1;
        final status = num <= 2 ? 'PAID' : (num == 3 ? 'DUE' : 'UNPAID');
        return {
          'installment_number': num,
          'due_date': '2026-${(index + 8).toString().padLeft(2, '0')}-05',
          'amount': 458.33,
          'status': status,
        };
      }),
      'events': [
        {'title': 'درخواست ثبت شد', 'timestamp': '2026-07-28 14:00'},
        {'title': 'وثیقه تأمین و قفل شد', 'timestamp': '2026-07-29 11:30'},
        {'title': 'امضای دیجیتال تکمیل شد', 'timestamp': '2026-07-30 09:15'},
        {'title': 'مبلغ وام به کیف پول واریز گردید', 'timestamp': '2026-08-01 10:00'},
      ],
    };
  }

  static Map<String, dynamic> _buildDemoGuaranteeCase() {
    return {
      'id': 2001,
      'case_number': 'BG-2026-INT-4412',
      'instrument_title': 'ضمانت‌نامه حسن انجام تعهدات (Performance Guarantee)',
      'currency': 'EUR',
      'amount': 25000.0,
      'beneficiary_name': 'شرکت بازرگانی بین‌المللی پارس / Pars Global Trading Co.',
      'validity_months': 12,
      'status': 'ISSUED',
      'status_fa': 'صادر شده و معتبر',
      'issuing_bank': 'بنک آف جورجیا (Bank of Georgia)',
      'collateral_amount': 3750.0,
      'issued_at': '2026-09-01',
      'expires_at': '2027-09-01',
    };
  }

  // -------------------------------------------------------------------------
  // Tester Control Panel Bottom Sheet UI
  // -------------------------------------------------------------------------

  void showTesterControlBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.h, 20.w, 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.biotech_rounded,
                          color: AppColors.lightPrimary,
                          size: 24,
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
                                en: 'Tester & Demo Control Panel',
                                fa: 'کنترل‌پنل تست و ارزیابی زنده (Demo Mode)',
                                ar: 'لوحة تحكم الحساب التجريبي',
                                zh: '演示与测试控制台',
                              ),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              l10nPick(
                                context,
                                en: 'Switch KYC levels, top-up wallets, and inspect mock flows.',
                                fa: 'تغییر آنی وضعیت احراز هویت، شارژ کیف پول‌ها و راستی‌آزمایی مدارک.',
                                ar: 'التحكم بمستوى KYC وشحن المحافظ وتجربة الخدمات.',
                                zh: '切换KYC状态、重置钱包余额、全面实测各项功能。',
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // KYC Quick Switcher
                  Text(
                    l10nPick(
                      context,
                      en: 'Instant KYC Level & Status',
                      fa: 'تغییر فوری وضعیت احراز هویت (KYC)',
                      ar: 'حالة التحقق من الهوية (KYC)',
                      zh: '一键切换KYC认证状态',
                    ),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10.h),
                  Obx(() {
                    return Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _KycOptionChip(
                          title: l10nPick(context, en: 'Approved (Level 3)', fa: 'تأییدشده (سطح ۳)', ar: 'مقبول (مستوى ٣)', zh: '认证通过（3级）'),
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                          selected: demoKycStatus.value == 1,
                          onTap: () => setKycStatus(1),
                        ),
                        _KycOptionChip(
                          title: l10nPick(context, en: 'Under Review', fa: 'در حال بررسی', ar: 'قيد المراجعة', zh: '审核中'),
                          icon: Icons.hourglass_top_rounded,
                          color: Colors.orange,
                          selected: demoKycStatus.value == 2,
                          onTap: () => setKycStatus(2),
                        ),
                        _KycOptionChip(
                          title: l10nPick(context, en: 'Rejected (With Reason)', fa: 'رد شده با دلیل', ar: 'مرفوض مع السبب', zh: '已拒绝'),
                          icon: Icons.cancel_rounded,
                          color: Colors.red,
                          selected: demoKycStatus.value == 3,
                          onTap: () => setKycStatus(3),
                        ),
                        _KycOptionChip(
                          title: l10nPick(context, en: 'Unverified (Level 0)', fa: 'احرازنشده (سطح ۰)', ar: 'غير موثق', zh: '未认证'),
                          icon: Icons.person_off_rounded,
                          color: Colors.grey,
                          selected: demoKycStatus.value == 0,
                          onTap: () => setKycStatus(0),
                        ),
                      ],
                    );
                  }),
                  const Divider(height: 24),

                  // Recharge Wallets
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
                    ),
                    title: Text(
                      l10nPick(
                        context,
                        en: 'Recharge Multi-Currency Wallets',
                        fa: 'شارژ مجدد کیف پول‌های چندارزی',
                        ar: 'إعادة شحن المحافظ',
                        zh: '重置多币种钱包资金',
                      ),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      l10nPick(
                        context,
                        en: 'Reset to \$1,850 USD, €1,200 EUR, 3,400 USDT, 520M IRR, 4,500 AED.',
                        fa: 'شارژ به ۱,۸۵۰ دلار، ۱,۲۰۰ یورو، ۳,۴۰۰ تتر، ۵۲۰ میلیون ریال، ۴,۵۰۰ درهم.',
                        ar: 'إعادة الأرصدة إلى القيم الافتراضية التجريبية.',
                        zh: '恢复为 1850 美元、1200 欧元、3400 USDT 等。',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        rechargeWallets();
                        Get.snackbar(
                          l10nPick(context, en: 'Wallets Recharged', fa: 'کیف‌پول‌ها شارژ شدند', ar: 'تم شحن المحافظ', zh: '钱包已充值'),
                          l10nPick(context, en: 'Balances reset to demo baseline.', fa: 'موجودی تمام ارزها با موفقیت به‌روزرسانی شد.', ar: 'تم تحديث الأرصدة.', zh: '余额已成功更新。'),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        l10nPick(context, en: 'Recharge', fa: 'شارژ', ar: 'شحن', zh: '充值'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const Divider(height: 24),

                  // Exit Demo Mode
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
                    ),
                    title: Text(
                      l10nPick(
                        context,
                        en: 'Exit Demo Mode',
                        fa: 'خروج از حالت دمو و بازگشت به لاگین',
                        ar: 'الخروج من الوضع التجريبي',
                        zh: '退出演示模式',
                      ),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.red),
                    ),
                    subtitle: Text(
                      l10nPick(
                        context,
                        en: 'Clear demo session and return to standard sign-in.',
                        fa: 'پاکسازی داده‌های شبیه‌سازی و بازگشت به صفحه ورود عادی.',
                        ar: 'العودة لتسجيل الدخول القياسي.',
                        zh: '清除演示会话并返回常规登录界面。',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      deactivateDemoMode();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KycOptionChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _KycOptionChip({
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

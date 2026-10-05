import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/net_worth_banner.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallet_filter_chips.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/wallets_screen.dart';

class _TestWalletsController extends WalletsController {
  @override
  // ignore: must_call_super
  void onInit() {
    // Override to skip network calls during widget testing
  }
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

Wallets _createWallet({
  int id = 1,
  String name = 'USD Wallet',
  String code = 'USD',
  String symbol = r'$',
  String balance = '2500.00',
  String formattedBalance = '2,500.00',
  String accountNo = 'IR820540102680020817909002',
  bool isDefault = false,
  bool isCrypto = false,
  String? conversionRate,
}) {
  return Wallets(
    id: id,
    name: name,
    code: code,
    symbol: symbol,
    balance: balance,
    formattedBalance: formattedBalance,
    accountNo: accountNo,
    isDefault: isDefault,
    isCrypto: isCrypto,
    conversionRate: conversionRate,
  );
}

Widget _buildTestApp(
  Widget child, {
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
  ThemeData? theme,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
        Locale('tr'),
        Locale('ru'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme ?? ThemeData.light(),
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestWalletsController controller;
  late _TestSettingsService settingsService;

  setUp(() {
    Get.reset();
    controller = _TestWalletsController();
    settingsService = _TestSettingsService();
    Get.put<WalletsController>(controller);
    Get.put<SettingsService>(settingsService);
  });

  tearDown(Get.reset);

  group('HeroWalletCardTheme theme resolution', () {
    test('resolves Crypto BTC card theme with obsidian gold and live rate', () {
      final btcWallet = _createWallet(
        id: 1,
        code: 'BTC',
        name: 'Bitcoin Vault',
        symbol: '₿',
        isCrypto: true,
      );
      final theme = HeroWalletCardTheme.forWallet(btcWallet);

      expect(theme.isCrypto, isTrue);
      expect(theme.cardEdition, 'OBSIDIAN GOLD');
      expect(theme.flagOrSymbol, '₿');
      expect(theme.rateTicker, contains('68,450'));
      expect(theme.trendChange, '▲ 2.4%');
      expect(theme.isTrendPositive, isTrue);
      expect(theme.meshGlowColors, isNotNull);
    });

    test('resolves Crypto ETH card theme with cyber violet styling', () {
      final ethWallet = _createWallet(
        id: 2,
        code: 'ETH',
        name: 'Ethereum Web3',
        symbol: 'Ξ',
        isCrypto: true,
      );
      final theme = HeroWalletCardTheme.forWallet(ethWallet);

      expect(theme.isCrypto, isTrue);
      expect(theme.cardEdition, 'CYBER VIOLET');
      expect(theme.flagOrSymbol, 'Ξ');
      expect(theme.rateTicker, contains('3,520'));
      expect(theme.trendChange, '▲ 1.8%');
    });

    test('resolves Crypto USDT card theme with holographic mesh styling', () {
      final usdtWallet = _createWallet(
        id: 3,
        code: 'USDT',
        name: 'Tether USD',
        symbol: '₮',
        isCrypto: true,
      );
      final theme = HeroWalletCardTheme.forWallet(usdtWallet);

      expect(theme.isCrypto, isTrue);
      expect(theme.cardEdition, 'HOLOGRAPHIC MESH');
      expect(theme.flagOrSymbol, '₮');
      expect(theme.rateTicker, '1 USDT = 1.00 USD');
      expect(theme.trendChange, '● Stable');
    });

    test('resolves Fiat USD card theme with matte titanium slate', () {
      final usdWallet = _createWallet(
        id: 4,
        code: 'USD',
        isCrypto: false,
      );
      final theme = HeroWalletCardTheme.forWallet(usdWallet);

      expect(theme.isCrypto, isFalse);
      expect(theme.cardEdition, 'TITANIUM SLATE');
      expect(theme.flagOrSymbol, '🇺🇸');
      expect(theme.rateTicker, '1 USD = 1.00 USD');
    });

    test('resolves Fiat EUR card theme with midnight sapphire', () {
      final eurWallet = _createWallet(
        id: 5,
        code: 'EUR',
        symbol: '€',
        isCrypto: false,
      );
      final theme = HeroWalletCardTheme.forWallet(eurWallet);

      expect(theme.isCrypto, isFalse);
      expect(theme.cardEdition, 'MIDNIGHT SAPPHIRE');
      expect(theme.flagOrSymbol, '🇪🇺');
      expect(theme.rateTicker, contains('1.08'));
    });

    test('resolves Fiat AED card theme with desert gold', () {
      final aedWallet = _createWallet(
        id: 6,
        code: 'AED',
        symbol: 'د.إ',
        isCrypto: false,
      );
      final theme = HeroWalletCardTheme.forWallet(aedWallet);

      expect(theme.isCrypto, isFalse);
      expect(theme.cardEdition, 'DESERT GOLD');
      expect(theme.flagOrSymbol, '🇦🇪');
      expect(theme.rateTicker, contains('0.272'));
    });

    test('resolves Fiat IRR card theme with persian onyx', () {
      final irrWallet = _createWallet(
        id: 7,
        code: 'IRR',
        symbol: '﷼',
        isCrypto: false,
      );
      final theme = HeroWalletCardTheme.forWallet(irrWallet);

      expect(theme.isCrypto, isFalse);
      expect(theme.cardEdition, 'PERSIAN ONYX');
      expect(theme.flagOrSymbol, '🇮🇷');
      expect(theme.rateTicker, contains('65,000'));
    });
  });

  group('HeroWalletCard widget rendering & interaction', () {
    testWidgets('renders crypto card with high-end typography and live rate ticker',
        (tester) async {
      final btcWallet = _createWallet(
        id: 1,
        code: 'BTC',
        name: 'Bitcoin Vault',
        symbol: '₿',
        balance: '1.25000000',
        formattedBalance: '1.25000000',
        isCrypto: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          Center(
            child: SizedBox(
              width: 380,
              child: HeroWalletCard(wallet: btcWallet),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('eCardo'), findsOneWidget);
      expect(find.text('OBSIDIAN GOLD'), findsOneWidget);
      expect(find.text('BTC'), findsWidgets);
      expect(find.text('1.25000000'), findsOneWidget);
      expect(find.text('▲ 2.4%'), findsOneWidget);
      expect(find.text('Top-up'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Exchange'), findsOneWidget);
    });

    testWidgets('renders fiat card with EMV microchip and DEFAULT badge',
        (tester) async {
      final usdWallet = _createWallet(
        id: 2,
        code: 'USD',
        balance: '5420.50',
        formattedBalance: '5,420.50',
        isDefault: true,
        isCrypto: false,
      );

      await tester.pumpWidget(
        _buildTestApp(
          Center(
            child: SizedBox(
              width: 380,
              child: HeroWalletCard(wallet: usdWallet),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TITANIUM SLATE'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('5,420.50'), findsOneWidget);
      expect(find.text('1 USD = 1.00 USD'), findsOneWidget);
    });

    testWidgets('flips card to reveal back face with account number and actions',
        (tester) async {
      final wallet = _createWallet(
        id: 3,
        code: 'USDT',
        accountNo: '0x71C...B49F',
        isCrypto: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          Center(
            child: SizedBox(
              width: 380,
              child: HeroWalletCard(wallet: wallet),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HOLOGRAPHIC MESH'), findsOneWidget);
      expect(find.text('0x71C...B49F'), findsNothing);

      // Tap flip button
      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();

      // Back face must be displayed
      expect(find.text('0x71C...B49F'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.flip_to_front_rounded), findsOneWidget);

      // Flip back to front
      await tester.tap(find.byIcon(Icons.flip_to_front_rounded));
      await tester.pumpAndSettle();

      expect(find.text('HOLOGRAPHIC MESH'), findsOneWidget);
      expect(find.text('0x71C...B49F'), findsNothing);
    });

    testWidgets('masks balance when privacy mode is activated', (tester) async {
      final wallet = _createWallet(
        id: 4,
        code: 'USD',
        balance: '3500.00',
        formattedBalance: '3,500.00',
      );

      await tester.pumpWidget(
        _buildTestApp(
          Center(
            child: SizedBox(
              width: 380,
              child: HeroWalletCard(wallet: wallet),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3,500.00'), findsOneWidget);
      expect(find.text('••••••••'), findsNothing);

      // Toggle privacy mode
      controller.togglePrivacyMode();
      await tester.pumpAndSettle();

      expect(find.text('••••••••'), findsOneWidget);
      expect(find.text('3,500.00'), findsNothing);

      // Toggle off privacy mode
      controller.togglePrivacyMode();
      await tester.pumpAndSettle();

      expect(find.text('3,500.00'), findsOneWidget);
    });

    testWidgets('mirrors transfer arrow and localizes labels in Persian RTL',
        (tester) async {
      final wallet = _createWallet(id: 5, code: 'IRR', symbol: '﷼');

      await tester.pumpWidget(
        _buildTestApp(
          Center(
            child: SizedBox(
              width: 380,
              child: HeroWalletCard(wallet: wallet),
            ),
          ),
          locale: const Locale('fa'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('موجودی در دسترس'), findsOneWidget);
      expect(find.text('واریز'), findsOneWidget);
      expect(find.text('انتقال'), findsOneWidget);
      expect(find.text('تبدیل'), findsOneWidget);

      final depositX = tester.getCenter(find.text('واریز')).dx;
      final transferX = tester.getCenter(find.text('انتقال')).dx;
      expect(depositX, greaterThan(transferX),
          reason: 'In RTL, Top-up sits to the right of Transfer');
    });
  });

  group('NetWorthBanner widget', () {
    testWidgets('calculates aggregate net worth and reacts to privacy toggle',
        (tester) async {
      controller.walletsList.value = [
        _createWallet(
          id: 1,
          code: 'USD',
          balance: '2000.00',
          symbol: r'$',
          isDefault: true,
          isCrypto: false,
        ),
        _createWallet(
          id: 2,
          code: 'USDT',
          balance: '1500.00',
          symbol: '₮',
          isCrypto: true,
          conversionRate: '1.00',
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          const SingleChildScrollView(child: NetWorthBanner()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Net Worth'), findsOneWidget);
      expect(find.text(r'$3,500.00'), findsOneWidget);

      // Tap privacy eye toggle icon
      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pumpAndSettle();

      expect(controller.isPrivacyMode.value, isTrue);
      expect(find.text('••••••••'), findsOneWidget);

      // Tap to unmask
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pumpAndSettle();

      expect(controller.isPrivacyMode.value, isFalse);
      expect(find.text(r'$3,500.00'), findsOneWidget);
    });

    testWidgets('shows wallet breakdown counts and switches filter on pill tap',
        (tester) async {
      controller.walletsList.value = [
        _createWallet(id: 1, code: 'USD', isCrypto: false),
        _createWallet(id: 2, code: 'EUR', isCrypto: false),
        _createWallet(id: 3, code: 'BTC', isCrypto: true),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          const SingleChildScrollView(child: NetWorthBanner()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Wallets'), findsOneWidget);
      expect(find.text('Fiat'), findsOneWidget);
      expect(find.text('Crypto'), findsOneWidget);

      // Tap Crypto breakdown chip
      await tester.tap(find.text('Crypto'));
      await tester.pumpAndSettle();

      expect(controller.activeFilter.value, WalletFilterType.crypto);

      // Tap Fiat breakdown chip
      await tester.tap(find.text('Fiat'));
      await tester.pumpAndSettle();

      expect(controller.activeFilter.value, WalletFilterType.fiat);
    });
  });

  group('WalletFilterChips & WalletsCardSection filtering', () {
    testWidgets('filters wallet cards between All, Fiat, and Crypto',
        (tester) async {
      controller.walletsList.value = [
        _createWallet(id: 1, code: 'USD', name: 'US Dollar', isCrypto: false),
        _createWallet(id: 2, code: 'BTC', name: 'Bitcoin', isCrypto: true),
        _createWallet(id: 3, code: 'ETH', name: 'Ethereum', isCrypto: true),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          const SingleChildScrollView(
            child: Column(
              children: [
                WalletFilterChips(),
                WalletsCardSection(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially All is selected (3 cards)
      expect(find.byType(HeroWalletCard), findsNWidgets(3));

      // Tap Fiat chip
      await tester.tap(find.text('Fiat'));
      await tester.pumpAndSettle();

      expect(controller.activeFilter.value, WalletFilterType.fiat);
      expect(find.byType(HeroWalletCard), findsOneWidget);
      expect(find.text('TITANIUM SLATE'), findsOneWidget);
      expect(find.text('OBSIDIAN GOLD'), findsNothing);

      // Tap Crypto chip
      await tester.tap(find.text('Crypto'));
      await tester.pumpAndSettle();

      expect(controller.activeFilter.value, WalletFilterType.crypto);
      expect(find.byType(HeroWalletCard), findsNWidgets(2));
      expect(find.text('OBSIDIAN GOLD'), findsOneWidget);
      expect(find.text('CYBER VIOLET'), findsOneWidget);
      expect(find.text('TITANIUM SLATE'), findsNothing);

      // Tap All chip
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(controller.activeFilter.value, WalletFilterType.all);
      expect(find.byType(HeroWalletCard), findsNWidgets(3));
      expect(find.text('TITANIUM SLATE'), findsOneWidget);
      expect(find.text('OBSIDIAN GOLD'), findsOneWidget);
      expect(find.text('CYBER VIOLET'), findsOneWidget);
    });

    testWidgets('displays contextual empty state when filtered category has 0 cards',
        (tester) async {
      // Only fiat wallets exist
      controller.walletsList.value = [
        _createWallet(id: 1, code: 'USD', isCrypto: false),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          const SingleChildScrollView(
            child: Column(
              children: [
                WalletFilterChips(),
                WalletsCardSection(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Crypto chip
      await tester.tap(find.text('Crypto'));
      await tester.pumpAndSettle();

      expect(find.byType(HeroWalletCard), findsNothing);
      expect(find.text('No Crypto Wallets Found'), findsOneWidget);
      expect(find.text('Add Crypto Wallet'), findsOneWidget);
    });
  });

  group('WalletsScreen states & layout', () {
    testWidgets('renders shimmer loader during isLoading', (tester) async {
      controller.isLoading.value = true;

      await tester.pumpWidget(
        _buildTestApp(const WalletsScreen()),
      );
      await tester.pump();

      expect(find.byType(WalletsScreen), findsOneWidget);
    });

    testWidgets('renders error state with retry button when isError is true',
        (tester) async {
      controller.isError.value = true;

      await tester.pumpWidget(
        _buildTestApp(const WalletsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('renders creative empty state when wallets list is empty',
        (tester) async {
      controller.walletsList.clear();

      await tester.pumpWidget(
        _buildTestApp(const WalletsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('renders populated WalletsScreen with banner, chips, cards and FAB',
        (tester) async {
      controller.walletsList.value = [
        _createWallet(id: 1, code: 'USD', isCrypto: false, isDefault: true),
        _createWallet(id: 2, code: 'USDT', isCrypto: true),
      ];

      await tester.pumpWidget(
        _buildTestApp(const WalletsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NetWorthBanner), findsOneWidget);
      expect(find.byType(WalletFilterChips), findsOneWidget);
      expect(find.byType(WalletsCardSection), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Wallet'), findsOneWidget);
    });

    testWidgets('renders seamlessly in Dark Mode without layout overflow',
        (tester) async {
      controller.walletsList.value = [
        _createWallet(id: 1, code: 'USD', isCrypto: false),
        _createWallet(id: 2, code: 'BTC', isCrypto: true),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          const WalletsScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalletsScreen), findsOneWidget);
      expect(find.byType(HeroWalletCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}

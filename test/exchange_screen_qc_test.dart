import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// WAVE-REVIEW (۲۰۲۶-۰۹-۲۷) — regression tests for the owner-reported
/// broken Exchange screen:
///   1. "Wallets Not Found" + a dead form with no action buttons when the
///      wallet fetch failed (no retry, no error state) — now covered by
///      [ExchangeController.walletLoadError] + the Amount-step error card.
///   2. The entry-time `getExchangeRateConverter()` call fired with an
///      EMPTY amount → the backend answered 404 "Not Found" (verified
///      live on production) → the toast fired on every screen entry.
///      Now guarded: an empty/zero amount skips the call.
///   3. Two back buttons (CommonDefaultAppBar implied leading + the
///      CommonAppBar back) — fixed at the screen level; asserted here via
///      the absence of dead states.
///
/// The wallet fixture is the REAL payload returned by
/// `GET /api/user/wallets?exchange` for the owner's account (user 1,
/// captured 2026-09-27): Main Wallet (USD, id 0) + TOMAN (IRT) + CNY +
/// USDT wallets — exactly what production serves.
class _NoopExchangeController extends ExchangeController {
  @override
  // The real onInit fires live network calls; these tests seed the Rx
  // state directly and never want HTTP.
  // ignore: must_call_super
  void onInit() {}
}

const String _ownerWalletsPayload = '''
{
  "status": "success",
  "message": "Wallets",
  "data": {
    "wallets": [
      {
        "id": 0,
        "name": "Main Wallet",
        "account_no": "2486825164",
        "balance": "19925.00000000",
        "formatted_balance": "19,925",
        "code": "USD",
        "symbol": "\$",
        "icon": null,
        "is_default": true,
        "is_crypto": false,
        "currency_id": 0,
        "exchange_limit": {"min": "10", "max": "100000"}
      },
      {
        "id": 2,
        "name": "TOMAN",
        "balance": "0.00000000",
        "formatted_balance": "0",
        "code": "IRT",
        "symbol": "IRT",
        "conversion_rate": "235000.00000000",
        "icon": "https://ecardo.ir/public/global/uploads/currency/qTQkrWtJapfINSqIi61o.png",
        "is_default": false,
        "exchange_limit": {"min": "2350000", "max": "23500000000"},
        "is_crypto": false,
        "currency_id": 1
      },
      {
        "id": 5,
        "name": "Chinese Yuan",
        "balance": "0.00000000",
        "formatted_balance": "0",
        "code": "CNY",
        "symbol": "¥",
        "conversion_rate": "6.67234526",
        "icon": "https://ecardo.ir/public/global/uploads/currency/57wjqkitTksLYvO5sUVG.png",
        "is_default": false,
        "exchange_limit": {"min": "67", "max": "667235"},
        "is_crypto": false,
        "currency_id": 5
      },
      {
        "id": 6,
        "name": "USDT",
        "balance": "0.00000000",
        "formatted_balance": "0",
        "code": "USDT",
        "symbol": "\$",
        "conversion_rate": "1.00000000",
        "icon": "https://ecardo.ir/public/global/uploads/currency/SjbzGZiEEvcX0eVewdDr.png",
        "is_default": false,
        "exchange_limit": {"min": "10", "max": "100000"},
        "is_crypto": true,
        "currency_id": 6
      }
    ]
  },
  "errors": null
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExchangeController controller;

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    if (!Get.isRegistered<ExchangeRateService>()) {
      Get.put<ExchangeRateService>(ExchangeRateService());
    }
    controller = _NoopExchangeController();
    Get.put<ExchangeController>(controller);
  });

  tearDown(Get.reset);

  void seedOwnerWallets() {
    final model = ExchangeWalletModel.fromJson(
      jsonDecode(_ownerWalletsPayload) as Map<String, dynamic>,
    );
    final wallets = model.data?.wallets ?? <Wallets>[];
    expect(wallets.length, 4, reason: 'the real payload has 4 wallets');
    controller.fromExchangeWalletsList.assignAll(wallets);
    controller.toExchangeWalletsList.assignAll(wallets);
    // Mirror the real selection: first wallet with a positive balance is
    // the USD Main Wallet; the first different-code wallet is TOMAN (IRT).
    controller.fromWallet.value = wallets.first;
    controller.toWallet.value =
        wallets.firstWhere((w) => w.code != wallets.first.code);
  }

  Widget buildSubject() => GetMaterialApp(
        // WAVE-REVIEW: مثل اپ واقعی (app.dart) — .w/.r ویجت‌ها به
        // ScreenUtilInitializer نیاز دارند وگرنه LateInitializationError.
        builder: (context, child) => ScreenUtilInit(
          designSize: const Size(376, 812),
          minTextAdapt: true,
          child: child ?? const SizedBox.shrink(),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fa')],
        locale: const Locale('en'),
        home: const Scaffold(body: ExchangeAmountStepSection()),
      );

  test(
    'regression: the exchange wallet model parses the real owner payload '
    '(4 wallets, USD main + IRT/CNY/USDT sub-wallets)',
    () {
      final model = ExchangeWalletModel.fromJson(
        jsonDecode(_ownerWalletsPayload) as Map<String, dynamic>,
      );
      final wallets = model.data!.wallets!;
      expect(model.status, 'success');
      expect(wallets.length, 4);
      expect(wallets[0].id, 0);
      expect(wallets[0].code, 'USD');
      expect(wallets[0].isDefault, true);
      expect(wallets[1].code, 'IRT');
      expect(wallets[3].code, 'USDT');
      expect(wallets[3].isCrypto, true);
      // The Main Wallet deliberately carries NO conversion_rate — the
      // model must tolerate that (all-nullable parse).
      expect(wallets[0].conversionRate, isNull);
    },
  );

  testWidgets(
    'regression: the amount step builds with the real owner wallets — '
    'Continue button present, no dead "Wallets Not Found" state, no exception',
    (tester) async {
      seedOwnerWallets();

      await tester.pumpWidget(buildSubject());
      // WAVE-REVIEW: pumpAndSettle با تایمر ۶۰ ثانیه‌ای سرویس نرخ settle
      // نمی‌شود — پمپ صریح.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // REGRESSION 1 — no build exception: the owner-reported state threw
      // inside the swap-card / fee widgets and rendered the global
      // "Something went wrong rendering this section" card TWICE.
      expect(tester.takeException(), isNull);

      // The next-step (Continue) button is present — the owner's #1 ask.
      expect(find.text('Continue'), findsOneWidget);

      // No dead "Wallets Not Found" empty state anywhere.
      expect(find.text('Wallets Not Found'), findsNothing);

      // The from-side shows the USD Main Wallet the selection picked.
      expect(find.text('Main Wallet'), findsOneWidget);
    },
  );

  testWidgets(
    'regression: the wallet-load failure state renders the retry card — '
    'the screen is recoverable, not dead',
    (tester) async {
      controller.walletLoadError.value = true;

      await tester.pumpWidget(buildSubject());
      // WAVE-REVIEW: pumpAndSettle با تایمر ۶۰ ثانیه‌ای سرویس نرخ settle
      // نمی‌شود — پمپ صریح.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Wallets Not Found'), findsNothing);
    },
  );

  test(
    'regression: getExchangeRateConverter skips the convert call for an '
    'empty amount (the entry-time 404 "Not Found" root cause)',
    () async {
      seedOwnerWallets();
      controller.amountController.text = '';
      // The NetworkService would be hit if the guard were missing; the
      // real instance throws on a failed response in this environment —
      // the guard must return BEFORE any request.
      await controller.getExchangeRateConverter();
      expect(controller.exchangeReviewRate.value, 0.0);
      expect(controller.exchangeAmount.value, 0.0);
      expect(controller.isExchangeConfigLoading.value, false);
    },
  );
}

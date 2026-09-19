import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/my_wallet_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/other_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/referral_stats_section.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// v1.0.43 (QC): reproduces the reported home-screen breakage "after the
/// wallet section" — pumps MyWalletSection + ReferralStatsSection +
/// OtherServicesSection with realistic controller data, scrolls through
/// them and hammers the Rx state the area reads, asserting nothing throws
/// (the reported symptom was a frozen grey page).
class _TestHomeController extends HomeController {
  @override
  void onInit() {} // no network in tests
}

class _TestKycController extends KycLevelController {
  @override
  void onInit() {} // no network in tests
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    Get.put<HomeController>(_TestHomeController());
    Get.put<KycLevelController>(_TestKycController());
  });

  tearDown(Get.reset);

  Widget buildSubject() {
    return GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      locale: const Locale('en'),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              MyWalletSection(),
              ReferralStatsSection(),
              OtherServicesSection(),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  void seedData(HomeController home) {
    home.dashboardModel.value = DashboardModel.fromJson({
      'status': 'success',
      'data': {
        'referral': {'bonus': '12.50000000', 'count': 3, 'referral_code': 'X'},
        'info': {'unread_notifications_count': 2, 'time_wise_wish': 'Day'},
      },
    });
    home.userModel.value = UserModel.fromJson({
      'status': 'success',
      'data': {'kyc_level': 1, 'passcode': '0', 'kyc': 1, 'addons': <String, dynamic>{}},
    });
    home.walletsList.value = [
      Wallets.fromJson({
        'id': 1,
        'name': 'USD Wallet',
        'code': 'USD',
        'symbol': '\$',
        'balance': '120.50',
        'formatted_balance': '120.50',
        'is_default': true,
        'is_crypto': false,
        'icon': 'https://example.com/x.png',
      }),
    ];
    home.transactionsModel.value = TransactionsModel.fromJson({
      'status': 'success',
      'data': {'transactions': []},
    });
  }

  testWidgets(
      'wallet → referral → services render, scroll and settle without '
      'exceptions (the reported frozen area)', (tester) async {
    final home = Get.find<HomeController>();
    seedData(home);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Scroll INTO the reported zone (referral strip + services grid).
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    // Page the services grid horizontally (onPageChanged → setState path).
    await tester.drag(
      find.byType(PageView),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    // Long soak: any rebuild storm / runaway timer surfaces here.
    await tester.pump(const Duration(seconds: 10));

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'repeated Rx refreshes (FCM badge style) do not storm the services '
      'Obx', (tester) async {
    final home = Get.find<HomeController>();
    final kyc = Get.find<KycLevelController>();
    seedData(home);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      home.userModel.refresh();
      if (kyc.badge.value != null) kyc.badge.refresh();
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
  });
}

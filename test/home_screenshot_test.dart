import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/home_screen.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

class _TestHomeController extends HomeController {
  _TestHomeController() {
    // Populate with realistic mock data for screenshot tests.
    // Values are set in the constructor so onInit (which is skipped) doesn't
    // overwrite them with network responses.
    dashboardModel.value = DashboardModel(
      data: DashboardData(
        user: User(
          userName: 'Alex Thompson',
          accountNumber: '12345678',
          email: 'alex@example.com',
          avatarPath: null,
        ),
      ),
    );

    walletsList.value = [
      Wallets(
        id: 1,
        name: 'US Dollar',
        code: 'USD',
        symbol: r'$',
        balance: '12450.50',
        formattedBalance: '12,450.50',
        isDefault: true,
        isCrypto: false,
      ),
      Wallets(
        id: 2,
        name: 'Euro',
        code: 'EUR',
        symbol: '€',
        balance: '8320.00',
        formattedBalance: '8,320.00',
        isDefault: false,
        isCrypto: false,
      ),
      Wallets(
        id: 3,
        name: 'Bitcoin',
        code: 'BTC',
        symbol: '₿',
        balance: '0.45820000',
        formattedBalance: '0.45820000',
        isDefault: false,
        isCrypto: true,
      ),
    ];
  }

  @override
  void onInit() {  // ignore: must_call_super
    // Intentionally empty — prevents all network calls in test.
    // super.onInit() is deliberately NOT called (see screenshot_harness.dart).
  }
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

void main() {
  tearDown(resetHarness);

  testWidgets('home — light', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      registrations: [
        () => registerController<HomeController>(_TestHomeController()),
        () => registerController<SettingsService>(_TestSettingsService()),
      ],
    );
    await capture(tester, 'home__light');
  });

  testWidgets('home — dark', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      dark: true,
      registrations: [
        () => registerController<HomeController>(_TestHomeController()),
        () => registerController<SettingsService>(_TestSettingsService()),
      ],
    );
    await capture(tester, 'home__dark');
  });
}
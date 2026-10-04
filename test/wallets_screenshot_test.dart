import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/wallets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'screenshot_harness.dart';

/// Subclassing the real controller and stubbing `onInit` keeps network calls out of
/// the test. The override is deliberately empty — calling `super` here would run
/// `fetchWallets()`, which is the thing these tests are avoiding.
class _TestWalletsController extends WalletsController {
  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

/// Seeds the controller with one fiat and one crypto wallet.
///
/// Without this the screen short-circuits to the empty branch and the goldens
/// would never cover `NetWorthBanner`, `WalletFilterChips` or the wallet cards —
/// i.e. exactly the code paths a screenshot suite exists to watch.
final List<Wallets> _seedWallets = [
  Wallets(
    id: 1,
    name: 'US Dollar',
    accountNo: '4111 1111 1111 1111',
    balance: '5420.50',
    formattedBalance: '5,420.50',
    code: 'USD',
    symbol: r'$',
    isDefault: true,
    isCrypto: false,
  ),
  Wallets(
    id: 2,
    name: 'Tether USD',
    accountNo: '0x71C4a2b8e9F34c7d9E5b0D7a1C49F82bB49F',
    balance: '1250.00',
    formattedBalance: '1,250.00',
    code: 'USDT',
    symbol: '₮',
    isDefault: false,
    isCrypto: true,
  ),
];

/// Registers the seeded wallet list so the screen renders its populated branch.
void _withWallets(WalletsController controller) {
  controller.isLoading.value = false;
  controller.isError.value = false;
  controller.walletsList.value = _seedWallets;
}

/// Forces the screen's empty branch.
void _withoutWallets(WalletsController controller) {
  controller.isLoading.value = false;
  controller.isError.value = false;
  controller.walletsList.clear();
}

/// Forces the screen's error branch.
void _withError(WalletsController controller) {
  controller.isLoading.value = false;
  controller.isError.value = true;
}

/// Registers under the base type (not the subclass type) so the screen's
/// `Get.find<WalletsController>()` resolves. See `registerController`.
///
/// [configure] runs against the registered controller before the screen is pumped,
/// which is how the error and empty branches of the screen get exercised.
List<void Function()> _registrations([void Function(WalletsController)? configure]) =>
    [
      () {
        final controller = _TestWalletsController();
        // Registered under the base type by hand rather than via the helper,
        // because we need the instance back to seed its state.
        Get.put<WalletsController>(controller, permanent: true);
        configure?.call(controller);
      },
      () => registerController<SettingsService>(_TestSettingsService()),
    ];

void main() {
  tearDown(resetHarness);

  testWidgets('wallets — light', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        registrations: _registrations(_withWallets));
    await capture(tester, 'wallets__light');
  });

  testWidgets('wallets — dark', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        dark: true, registrations: _registrations(_withWallets));
    await capture(tester, 'wallets__dark');
  });

  testWidgets('wallets — RTL', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        textDirection: TextDirection.rtl,
        registrations: _registrations(_withWallets));
    await capture(tester, 'wallets__rtl');
  });

  // The screen branches on `isLoading` / `isError` / empty `walletsList` before it
  // reaches the card list, so each branch needs its own seed. These cover the
  // design-system components that replaced the hand-rolled states.
  testWidgets('wallets — empty state', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        registrations: _registrations(_withoutWallets));
    await capture(tester, 'wallets__empty');

    expect(find.byType(EcardoEmptyState), findsOneWidget);
    expect(find.text('No wallets yet'), findsOneWidget);
    expect(find.text('Create Wallet'), findsOneWidget);
    expect(find.text('Add Money'), findsOneWidget);
  });

  testWidgets('wallets — empty state RTL', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        textDirection: TextDirection.rtl,
        registrations: _registrations(_withoutWallets));
    await capture(tester, 'wallets__empty_rtl');
  });

  testWidgets('wallets — error state', (tester) async {
    await pumpScreen(tester, const WalletsScreen(),
        registrations: _registrations(_withError));
    await capture(tester, 'wallets__error');

    expect(find.byType(EcardoErrorView), findsOneWidget);
    expect(find.text('Something went wrong!'), findsOneWidget);
    expect(find.text('Please check your network settings'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('wallets — error state dark', (tester) async {
    await pumpScreen(tester, const WalletsScreen(), dark: true,
        registrations: _registrations(_withError));
    await capture(tester, 'wallets__error_dark');
  });
}
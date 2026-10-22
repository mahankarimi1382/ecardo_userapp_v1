import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/epay_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_screen.dart';

import 'screenshot_harness.dart';

class _TestVirtualCardController extends VirtualCardController {
  _TestVirtualCardController() {
    isLoading.value = false;
    isError.value = false;
    virtualCardList.value = [
      VirtualCardsData(
        id: 1,
        cardId: 'vc-1001',
        cardNumber: '4532123456789012',
        displayNumber: '•••• •••• •••• 9012',
        amount: '1,250.00',
        currency: 'USD',
        expirationMonth: 12,
        expirationYear: 2028,
        cvc: '321',
        virtualStatus: 'Active',
        status: 'Active',
        lifecycleStatus: 'Active',
        provider: 'Visa',
        display: CardDisplay.fromJson({
          'title': 'eCardo Platinum Visa',
          'balance_label': 'Balance',
          'number_label': 'Card Number',
          'expiry_label': 'EXPIRY',
          'cvc_label': 'CVC',
          'currency_label': 'Currency',
          'show_pan': true,
          'show_expiry': true,
          'show_cvc': true,
          'network': 'visa',
          'primary_color': '#1A1F36',
          'secondary_color': '#38BDF8',
        }),
        capabilities: CardCapabilities.fromJson({
          'can_topup': true,
          'can_freeze': true,
          'can_view_transactions': true,
          'can_reveal_pan': true,
        }),
      ),
    ];
    showAccountNumberList.assignAll([false.obs]);
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> syncCardBackgroundImageFromSettings() async {}

  @override
  Future<void> fetchVirtualCards() async {}
}

class _TestEpayCardController extends EpayCardController {
  _TestEpayCardController() {
    isLoading.value = false;
    isActionLoading.value = false;
    epayCards.assignAll([
      {
        'id': 'epay-1',
        'card_number_masked': '5200 •••• •••• 8844',
        'currency_code': 'USD',
        'balance': 450.00,
        'status': 'ACTIVE',
      }
    ]);
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchEpayCards() async {}
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

void _ignoreOverflows() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exceptionAsString();
    if (exceptionStr.contains('A RenderFlex overflowed') ||
        exceptionStr.contains('RenderBox was not laid out') ||
        exceptionStr.contains('hasSize') ||
        exceptionStr.contains('would not hit test on the specified widget')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}

void main() {
  tearDown(resetHarness);

  group('VirtualCardScreen Screenshots', () {
    testWidgets('virtual_card — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        registrations: [
          () => registerController<VirtualCardController>(
                _TestVirtualCardController(),
              ),
          () => registerController<EpayCardController>(
                _TestEpayCardController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(VirtualCardScreen), findsOneWidget);
      await capture(tester, 'virtual_card__light');
    });

    testWidgets('virtual_card — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        dark: true,
        registrations: [
          () => registerController<VirtualCardController>(
                _TestVirtualCardController(),
              ),
          () => registerController<EpayCardController>(
                _TestEpayCardController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(VirtualCardScreen), findsOneWidget);
      await capture(tester, 'virtual_card__dark');
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/model/country_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/remittance_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/bookings/travel_orders_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

import 'screenshot_harness.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

class _TestRemittanceController extends RemittanceController {
  _TestRemittanceController() {
    isMethodsLoading.value = false;
    isCurrenciesLoading.value = false;
    isCountriesLoading.value = false;

    methods.assignAll([
      RemittanceMethod(
        id: 1,
        name: 'Alipay Direct',
        countryCode: 'CN',
        receiveCurrencyCode: 'CNY',
        receiveCurrencySymbol: '¥',
        status: 1,
      ),
      RemittanceMethod(
        id: 2,
        name: 'WeChat Pay',
        countryCode: 'CN',
        receiveCurrencyCode: 'CNY',
        receiveCurrencySymbol: '¥',
        status: 1,
      ),
      RemittanceMethod(
        id: 3,
        name: 'SWIFT Wire Transfer',
        countryCode: 'US',
        receiveCurrencyCode: 'USD',
        receiveCurrencySymbol: r'$',
        status: 1,
      ),
    ]);

    sendCurrencies.assignAll([
      CurrenciesData(id: 1, name: 'US Dollar', code: 'USD', symbol: r'$'),
      CurrenciesData(id: 2, name: 'Euro', code: 'EUR', symbol: '€'),
      CurrenciesData(id: 3, name: 'Iranian Rial', code: 'IRR', symbol: '﷼'),
    ]);

    countries.assignAll([
      CountryData(name: 'China', code: 'CN', dialCode: '+86'),
      CountryData(name: 'United States', code: 'US', dialCode: '+1'),
      CountryData(name: 'Germany', code: 'DE', dialCode: '+49'),
    ]);

    selectedSendCurrencyId.value = 1;
    selectedMethod.value = methods.first;
    amountController.text = '1000';
  }

  @override
  // ignore: must_call_super
  void onInit() {
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
  }
}

class _TestTravelController extends TravelController {
  _TestTravelController() {
    isLoading.value = false;
    isBootstrapLoading.value = false;
    orders.assignAll([
      TravelOrder(
        id: 'ord-101',
        type: TravelProductType.hotel,
        titleKey: 'Grand Hotel Tehran',
        reference: 'TRV-HTL-9401',
        total: const TravelMoney(amount: 140, currency: 'USD'),
        status: TravelOrderStatus.confirmed,
        rawStatus: 'booked',
        createdAt: DateTime(2026, 8, 15),
        details: const {'hotel_name': 'Grand Hotel Tehran', 'nights': '3'},
      ),
      TravelOrder(
        id: 'ord-102',
        type: TravelProductType.flight,
        titleKey: 'Tehran to Istanbul',
        reference: 'TRV-FLT-8821',
        total: const TravelMoney(amount: 320, currency: 'USD'),
        status: TravelOrderStatus.issued,
        rawStatus: 'voucher_generated',
        createdAt: DateTime(2026, 8, 20),
        details: const {'flight_number': 'TK-871', 'seat': '14B'},
      ),
      TravelOrder(
        id: 'ord-103',
        type: TravelProductType.esim,
        titleKey: 'Turkey 5GB 15 Days',
        reference: 'TRV-ESM-3302',
        total: const TravelMoney(amount: 18, currency: 'USD'),
        status: TravelOrderStatus.completed,
        rawStatus: 'completed',
        createdAt: DateTime(2026, 8, 25),
        details: const {'data_limit': '5GB'},
      ),
    ]);
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }
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

  group('RemittanceScreen Visual Regression Tests', () {
    testWidgets('remittance — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const RemittanceScreen(),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<SettingsService>(_TestSettingsService()),
          () => registerController<RemittanceController>(_TestRemittanceController()),
        ],
      );
      await capture(tester, 'remittance__light');
    });

    testWidgets('remittance — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const RemittanceScreen(),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<SettingsService>(_TestSettingsService()),
          () => registerController<RemittanceController>(_TestRemittanceController()),
        ],
      );
      await capture(tester, 'remittance__dark');
    });
  });

  group('TravelOrdersScreen Visual Regression Tests', () {
    testWidgets('travel_orders — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const TravelOrdersScreen(),
        registrations: [
          () => registerController<TravelController>(_TestTravelController()),
        ],
      );
      await capture(tester, 'travel_orders__light');
    });

    testWidgets('travel_orders — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const TravelOrdersScreen(),
        dark: true,
        registrations: [
          () => registerController<TravelController>(_TestTravelController()),
        ],
      );
      await capture(tester, 'travel_orders__dark');
    });
  });
}

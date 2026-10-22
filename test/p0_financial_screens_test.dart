import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/model/cash_out_wallet_model.dart'
    as co_model;
import 'package:ecardo_user/src/presentation/screens/cash_out/view/cash_out_screen.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/model/payment_wallet_model.dart'
    as mp_model;
import 'package:ecardo_user/src/presentation/screens/make_payment/view/make_payment_screen.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/view/sub_sections/make_payment_review_step_section.dart';

import 'screenshot_harness.dart';

class _TestMakePaymentController extends MakePaymentController {
  _TestMakePaymentController() {
    isLoading.value = false;
    isPaymentSettingsLoading.value = false;
    isMakePaymentLoading.value = false;
    isBeneficiaryLoading.value = false;
    chargeLoadFailed.value = false;
    charge.value = 1.50;
    totalAmount.value = 101.50;
    currentStep.value = 1;

    amountController.text = '100.00';
    merchantMidController.text = 'MID-884210';

    final testWallet = mp_model.Wallets(
      id: 1,
      name: 'USD Wallet',
      accountNo: 'ACC-123456',
      balance: '500.00',
      formattedBalance: '500.00',
      code: 'USD',
      symbol: r'$',
      isDefault: true,
      isCrypto: false,
    );

    wallet.value = testWallet;
    paymentWalletsList.value = [testWallet];

    userModel.value = UserModel(
      data: UserData(
        passcode: '1234',
        hasPasscode: true,
      ),
    );
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchWallets() async {}

  @override
  Future<void> fetchUser() async {}
}

class _TestCashOutController extends CashOutController {
  _TestCashOutController() {
    isLoading.value = false;
    isCashOutLoading.value = false;
    isBeneficiaryLoading.value = false;
    isCashoutConfigLoading.value = false;
    chargeLoadFailed.value = false;
    charge.value = 2.00;
    totalAmount.value = 102.00;
    currentStep.value = 1;

    amountController.text = '100.00';
    agentAidController.text = 'AGT-778899';

    final testWallet = co_model.Wallets(
      id: 1,
      name: 'USD Wallet',
      accountNo: 'ACC-123456',
      balance: '1000.00',
      formattedBalance: '1,000.00',
      code: 'USD',
      symbol: r'$',
      isDefault: true,
      isCrypto: false,
    );

    wallet.value = testWallet;
    cashOutWalletsList.value = [testWallet];

    userModel.value = UserModel(
      data: UserData(
        passcode: '1234',
        hasPasscode: true,
      ),
    );
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchWallets() async {}

  @override
  Future<void> fetchUser() async {}
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) {
    switch (key) {
      case 'site_currency':
        return 'USD';
      case 'site_currency_decimals':
        return '2';
      case 'make_payment_passcode_status':
        return '1';
      case 'cashout_passcode_status':
        return '1';
      default:
        return '1';
    }
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

  group('MakePaymentScreen Review Step Screenshots', () {
    testWidgets('make_payment_review — light', (tester) async {
      _ignoreOverflows();
      Get.routing.args = {'mid_account': 'MID-884210'};
      await pumpScreen(
        tester,
        const MakePaymentScreen(),
        registrations: [
          () => registerController<MakePaymentController>(
                _TestMakePaymentController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(MakePaymentScreen), findsOneWidget);
      expect(find.byType(MakePaymentReviewStepSection), findsOneWidget);
      await capture(tester, 'make_payment_review__light');
    });

    testWidgets('make_payment_review — dark', (tester) async {
      _ignoreOverflows();
      Get.routing.args = {'mid_account': 'MID-884210'};
      await pumpScreen(
        tester,
        const MakePaymentScreen(),
        dark: true,
        registrations: [
          () => registerController<MakePaymentController>(
                _TestMakePaymentController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(MakePaymentScreen), findsOneWidget);
      expect(find.byType(MakePaymentReviewStepSection), findsOneWidget);
      await capture(tester, 'make_payment_review__dark');
    });
  });

  group('CashOutScreen Review Step Screenshots', () {
    testWidgets('cash_out_review — light', (tester) async {
      _ignoreOverflows();
      Get.routing.args = {'aid_account': 'AGT-778899'};
      await pumpScreen(
        tester,
        const CashOutScreen(),
        registrations: [
          () => registerController<CashOutController>(
                _TestCashOutController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(CashOutScreen), findsOneWidget);
      expect(find.byType(CashOutReviewStepSection), findsOneWidget);
      await capture(tester, 'cash_out_review__light');
    });

    testWidgets('cash_out_review — dark', (tester) async {
      _ignoreOverflows();
      Get.routing.args = {'aid_account': 'AGT-778899'};
      await pumpScreen(
        tester,
        const CashOutScreen(),
        dark: true,
        registrations: [
          () => registerController<CashOutController>(
                _TestCashOutController(),
              ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(CashOutScreen), findsOneWidget);
      expect(find.byType(CashOutReviewStepSection), findsOneWidget);
      await capture(tester, 'cash_out_review__dark');
    });
  });
}

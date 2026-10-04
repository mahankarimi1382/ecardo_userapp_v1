// Exchange module screenshot tests.
//
// Covers: light mode, dark mode, and swap-review state (with filled amount)
// for the three Exchange steps: Amount, Review, and Success.
//
// Run with:
//   flutter test --update-goldens test/exchange_screenshot_test.dart
//
// DO NOT run `flutter test` (without --update-goldens) until goldens exist.
//
// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart';
import 'screenshot_harness.dart';

void main() {
  tearDown(resetHarness);

  // ── Amount Step ────────────────────────────────────────────────────────────

  testWidgets('exchange — amount step — light', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeAmountStepSection()),
      registrations: [
        () => registerController<ExchangeRateService>(
              _TestExchangeRateService(),
            ),
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeController(),
            ),
      ],
    );
    await capture(tester, 'exchange__amount__light');
  });

  testWidgets('exchange — amount step — dark', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeAmountStepSection()),
      dark: true,
      registrations: [
        () => registerController<ExchangeRateService>(
              _TestExchangeRateService(),
            ),
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeController(),
            ),
      ],
    );
    await capture(tester, 'exchange__amount__dark');
  });

  // ── Review Step (swap-review state) ───────────────────────────────────────

  testWidgets('exchange — swap review — light', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeReviewStepSection()),
      registrations: [
        () => registerController<ExchangeRateService>(
              _TestExchangeRateService(),
            ),
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeControllerReview(),
            ),
      ],
    );
    await capture(tester, 'exchange__review__light');
  });

  testWidgets('exchange — swap review — dark', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeReviewStepSection()),
      dark: true,
      registrations: [
        () => registerController<ExchangeRateService>(
              _TestExchangeRateService(),
            ),
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeControllerReview(),
            ),
      ],
    );
    await capture(tester, 'exchange__review__dark');
  });

  // ── Success Step ───────────────────────────────────────────────────────────

  testWidgets('exchange — success — light', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeSuccessStepSection()),
      registrations: [
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeControllerSuccess(),
            ),
      ],
    );
    await capture(tester, 'exchange__success__light');
  });

  testWidgets('exchange — success — dark', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: ExchangeSuccessStepSection()),
      dark: true,
      registrations: [
        () => registerController<SettingsService>(
              _TestSettingsService(),
            ),
        () => registerController<ExchangeController>(
              _TestExchangeControllerSuccess(),
            ),
      ],
    );
    await capture(tester, 'exchange__success__dark');
  });
}

// ── Fake ExchangeRateService ──────────────────────────────────────────────────

/// Minimal subclass that skips the network timer entirely.
class _TestExchangeRateService extends ExchangeRateService {
  @override
  void onInit() {
    // Intentionally empty — no timer, no network call.
  }
}

// ── Fake SettingsService ──────────────────────────────────────────────────────

/// Supplies the minimum settings that Exchange screens read.
class _TestSettingsService extends SettingsService {
  @override
  void onInit() {
    // Intentionally empty — skip SharedPreferences / network init.
    appSettings.addAll({
      'site_currency': 'USD',
      'site_currency_decimals': '2',
      'exchange_passcode_status': '0',
    });
  }
}

// ── Fake ExchangeControllers ──────────────────────────────────────────────────

final _usdWallet = Wallets(
  id: 1,
  code: 'USD',
  name: 'US Dollar',
  balance: '1000.00',
  formattedBalance: '1,000.00',
  isCrypto: false,
  isDefault: true,
  symbol: r'$',
  exchangeLimit: ExchangeLimit(min: '10', max: '5000'),
);

final _usdtWallet = Wallets(
  id: 2,
  code: 'USDT',
  name: 'Tether',
  balance: '500.00',
  formattedBalance: '500.00',
  isCrypto: true,
  isDefault: false,
  symbol: '₮',
  exchangeLimit: ExchangeLimit(min: '10', max: '5000'),
);

/// Amount-step fake — wallets populated, no network calls.
class _TestExchangeController extends ExchangeController {
  @override
  void onInit() {
    // Intentionally empty — skip super.onInit to avoid network calls.
    _seedWallets();
  }

  void _seedWallets() {
    isLoading.value = false;
    walletLoadError.value = false;
    fromWallet.value = _usdWallet;
    toWallet.value = _usdtWallet;
    fromExchangeWalletsList.value = [_usdWallet];
    toExchangeWalletsList.value = [_usdtWallet];
    currentRate.value = 1.0;
    charge.value = 2.5;
    totalAmount.value = 102.5;
    liveToAmount.value = 100.0;
  }
}

/// Review-step fake — amount pre-filled, rate locked.
class _TestExchangeControllerReview extends _TestExchangeController {
  @override
  void onInit() {
    super.onInit();
    amountController.text = '100';
    currentStep.value = 1;
    exchangeReviewRate.value = 1.0;
    exchangeAmount.value = 100.0;
    isReviewRateStale.value = false;
    isExchangeConfigLoading.value = false;
    userModel.value = UserModel(data: UserData(passcode: ''));
  }
}

/// Success-step fake — transaction data populated.
class _TestExchangeControllerSuccess extends _TestExchangeController {
  @override
  void onInit() {
    super.onInit();
    currentStep.value = 2;
    amountController.text = '100';
    isExchangeWalletLoading.value = false;
    successExchangeData.value = {
      'transaction': {
        'tnx': 'EXC-2026-10-04-001',
        'pay_amount': '100.00',
        'pay_currency': 'USD',
        'amount': '100.00',
        'receive_currency': 'USDT',
        'charge': '2.50',
        'final_amount': '102.50',
        'created_at': '2026-10-04T07:58:00Z',
        'is_crypto': true,
      },
    };
  }
}

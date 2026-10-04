import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_manager.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_validation_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

class _TestExchangeController extends ExchangeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExchangeValidationService', () {
    const service = ExchangeValidationService();

    final fromWallet = Wallets(
      id: 1,
      name: 'USD Wallet',
      code: 'USD',
      balance: '500.00',
      isCrypto: false,
      exchangeLimit: ExchangeLimit(min: '10', max: '1000'),
    );

    final toWallet = Wallets(
      id: 2,
      name: 'EUR Wallet',
      code: 'EUR',
      balance: '100.00',
      isCrypto: false,
      exchangeLimit: ExchangeLimit(min: '5', max: '5000'),
    );

    test('validates selectFromWallet when fromWallet is null', () {
      final result = service.validateAmountStep(
        fromWallet: null,
        toWallet: toWallet,
        amountText: '50',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.selectFromWallet);
    });

    test('validates selectToWallet when toWallet is null', () {
      final result = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: null,
        amountText: '50',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.selectToWallet);
    });

    test('validates sameWallet when from and to currencies match', () {
      final sameWallet = Wallets(
        id: 3,
        name: 'USD Secondary',
        code: 'USD',
        balance: '200.00',
        exchangeLimit: ExchangeLimit(min: '10', max: '1000'),
      );

      final result = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: sameWallet,
        amountText: '50',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.sameWallet);
    });

    test('validates enterAmount when amount is empty or non-positive', () {
      final emptyResult = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: toWallet,
        amountText: '',
        decimals: 2,
      );
      expect(emptyResult.isValid, false);
      expect(emptyResult.errorType, ExchangeValidationErrorType.enterAmount);

      final zeroResult = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: toWallet,
        amountText: '0',
        decimals: 2,
      );
      expect(zeroResult.isValid, false);
      expect(zeroResult.errorType, ExchangeValidationErrorType.enterAmount);
    });

    test('validates amountBelowMinimum when amount is below minimum limit', () {
      final result = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: toWallet,
        amountText: '5',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.amountBelowMinimum);
      expect(result.limitValue, 10.0);
    });

    test('validates amountAboveMaximum when amount exceeds maximum limit', () {
      final result = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: toWallet,
        amountText: '1500',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.amountAboveMaximum);
      expect(result.limitValue, 1000.0);
    });

    test('validates insufficientBalance when amount exceeds available balance', () {
      final smallBalanceWallet = Wallets(
        id: 1,
        name: 'USD Wallet',
        code: 'USD',
        balance: '50.00',
        exchangeLimit: ExchangeLimit(min: '10', max: '1000'),
      );

      final result = service.validateAmountStep(
        fromWallet: smallBalanceWallet,
        toWallet: toWallet,
        amountText: '75',
        decimals: 2,
      );

      expect(result.isValid, false);
      expect(result.errorType, ExchangeValidationErrorType.insufficientBalance);
      expect(result.limitValue, 50.0);
    });

    test('validates successfully when all boundaries pass', () {
      final result = service.validateAmountStep(
        fromWallet: fromWallet,
        toWallet: toWallet,
        amountText: '100',
        decimals: 2,
      );

      expect(result.isValid, true);
      expect(result.errorType, ExchangeValidationErrorType.none);
    });

    test('isAmountValid returns correct boolean for inputs', () {
      expect(service.isAmountValid(fromWallet: null, toWallet: toWallet, amountText: '50'), false);
      expect(service.isAmountValid(fromWallet: fromWallet, toWallet: null, amountText: '50'), false);
      expect(service.isAmountValid(fromWallet: fromWallet, toWallet: toWallet, amountText: '0'), false);
      expect(service.isAmountValid(fromWallet: fromWallet, toWallet: toWallet, amountText: '5'), false);
      expect(service.isAmountValid(fromWallet: fromWallet, toWallet: toWallet, amountText: '2000'), false);
      expect(service.isAmountValid(fromWallet: fromWallet, toWallet: toWallet, amountText: '50'), true);
    });

    test('calculatePercentageCharge calculates charge and total without floating drift', () {
      final calc = service.calculatePercentageCharge(amount: 100.0, percent: 2.5);
      expect(calc.charge, 2.5);
      expect(calc.totalAmount, 102.5);
    });

    test('calculateTotalWithFixedCharge adds fixed fee accurately', () {
      final calc = service.calculateTotalWithFixedCharge(amount: 100.0, fixedCharge: 1.75);
      expect(calc.charge, 1.75);
      expect(calc.totalAmount, 101.75);
    });

    test('calculateMaxSpendable deducts fee safely', () {
      expect(service.calculateMaxSpendable(balance: 100.0, fee: 5.0), 95.0);
      expect(service.calculateMaxSpendable(balance: 5.0, fee: 10.0), 0.0);
      expect(service.calculateMaxSpendable(balance: 0.0, fee: 1.0), 0.0);
    });

    test('calculateQuickAmountString formats correctly for fiat and crypto', () {
      expect(
        service.calculateQuickAmountString(balance: 100.0, percent: 0.5, isCrypto: false),
        '50.00',
      );
      expect(
        service.calculateQuickAmountString(balance: 1.0, percent: 0.25, isCrypto: true),
        '0.25000000',
      );
    });
  });

  group('ExchangeRateManager', () {
    late ExchangeRateService mockRateService;
    late ExchangeRateManager manager;

    setUp(() {
      mockRateService = ExchangeRateService();
      manager = ExchangeRateManager(rateService: mockRateService);
    });

    tearDown(() {
      manager.dispose();
      mockRateService.onClose();
    });

    test('normalizeApiCode handles USDT and passthrough codes', () {
      expect(manager.normalizeApiCode('usdt'), 'USDT_IRT');
      expect(manager.normalizeApiCode('USDT'), 'USDT_IRT');
      expect(manager.normalizeApiCode('USD'), 'USD');
      expect(manager.normalizeApiCode('eur'), 'EUR');
      expect(manager.normalizeApiCode('IRR'), 'IRR');
    });

    test('calculateCrossRate computes correct 1 FROM = X TO rate based on IRR values', () {
      // 1 USD = 700,000 IRR, 1 EUR = 770,000 IRR -> 1 USD = (700000 / 770000) EUR ≈ 0.90909091
      final crossRate = manager.calculateCrossRate(700000, 770000);
      expect(crossRate, isNotNull);
      expect(crossRate!, closeTo(0.90909091, 0.0001));

      expect(manager.calculateCrossRate(0, 100), isNull);
      expect(manager.calculateCrossRate(100, 0), isNull);
      expect(manager.calculateCrossRate(null, 100), isNull);
    });

    test('bumpLiveRate tracks previousRate and updates rateDirection', () {
      expect(manager.previousRate.value, 0.0);
      expect(manager.currentRate.value, 0.0);
      expect(manager.rateDirection.value, RateDirection.unknown);

      // First rate update: initial
      manager.bumpLiveRate(1.20);
      expect(manager.currentRate.value, 1.20);
      expect(manager.previousRate.value, 0.0);
      expect(manager.rateDirection.value, RateDirection.unknown);

      // Second rate update: UP
      manager.bumpLiveRate(1.25);
      expect(manager.currentRate.value, 1.25);
      expect(manager.previousRate.value, 1.20);
      expect(manager.rateDirection.value, RateDirection.up);

      // Third rate update: DOWN
      manager.bumpLiveRate(1.22);
      expect(manager.currentRate.value, 1.22);
      expect(manager.previousRate.value, 1.25);
      expect(manager.rateDirection.value, RateDirection.down);

      // Negligible change should be ignored
      manager.bumpLiveRate(1.22000000000001);
      expect(manager.currentRate.value, 1.22);
    });

    test('calculateStaticRate derives rate from CurrenciesData list', () {
      final currencies = [
        CurrenciesData(code: 'USD', conversionRate: '1.0'),
        CurrenciesData(code: 'EUR', conversionRate: '0.92'),
      ];

      final targetRate = 0.0.obs;
      manager.calculateStaticRate(
        fromWallet: Wallets(code: 'USD'),
        toWallet: Wallets(code: 'EUR'),
        currenciesList: currencies,
        targetStaticRate: targetRate,
      );

      // 1 / 1.0 * 0.92 = 0.92
      expect(targetRate.value, closeTo(0.92, 0.0001));
      expect(manager.currentRate.value, closeTo(0.92, 0.0001));
    });

    test('lockRateForReview and drift detection', () {
      manager.currentRate.value = 1.0;
      manager.lockRateForReview();

      expect(manager.lockedReviewRate, 1.0);
      expect(manager.reviewEnteredAt, isNotNull);
      expect(manager.isReviewRateStale.value, false);

      // Rate within 0.01% tolerance (drift = 0.00005) -> not stale
      final notDrifted = manager.checkDriftOrExpired(
        enteredAt: DateTime.now(),
        lockedRate: 1.0,
        currentRate: 1.00005,
      );
      expect(notDrifted, false);

      // Rate drifted > 0.01% (drift = 0.001) -> stale!
      final drifted = manager.checkDriftOrExpired(
        enteredAt: DateTime.now(),
        lockedRate: 1.0,
        currentRate: 1.002,
      );
      expect(drifted, true);

      // 61 seconds elapsed -> stale!
      final expired = manager.checkDriftOrExpired(
        enteredAt: DateTime.now().subtract(const Duration(seconds: 61)),
        lockedRate: 1.0,
        currentRate: 1.0,
      );
      expect(expired, true);
    });

    test('acknowledgeRateChange updates locked rate and clears stale status', () {
      manager.isReviewRateStale.value = true;
      manager.currentRate.value = 1.05;

      manager.acknowledgeRateChange();

      expect(manager.isReviewRateStale.value, false);
      expect(manager.lockedReviewRate, 1.05);
    });

    test('clearReviewLock resets review state', () {
      manager.lockRateForReview(1.10);
      expect(manager.lockedReviewRate, 1.10);

      manager.clearReviewLock();
      expect(manager.lockedReviewRate, isNull);
      expect(manager.reviewEnteredAt, isNull);
      expect(manager.isReviewRateStale.value, false);
    });

    test('reset clears all rate fields to default', () {
      manager.bumpLiveRate(2.5);
      manager.liveChangePercent.value = 1.5;
      manager.liveFromNameEn.value = 'Dollar';
      manager.liveToNameEn.value = 'Euro';
      manager.lockRateForReview();

      manager.reset();

      expect(manager.previousRate.value, 0.0);
      expect(manager.currentRate.value, 0.0);
      expect(manager.rateDirection.value, RateDirection.unknown);
      expect(manager.liveChangePercent.value, isNull);
      expect(manager.liveFromNameEn.value, '');
      expect(manager.liveToNameEn.value, '');
      expect(manager.lockedReviewRate, isNull);
      expect(manager.isReviewRateStale.value, false);
    });
  });

  group('ExchangeController with Modular Architecture', () {
    late ExchangeController controller;

    setUp(() {
      Get.put<TokenService>(TokenService());
      Get.put<NetworkService>(NetworkService());
      Get.put<SettingsService>(SettingsService());
      if (!Get.isRegistered<ExchangeRateService>()) {
        Get.put<ExchangeRateService>(ExchangeRateService());
      }
      controller = _TestExchangeController();
      Get.put<ExchangeController>(controller);
    });

    tearDown(() {
      Get.reset();
    });

    test('exposes modular services through getters and delegators', () {
      expect(controller.rateManager, isA<ExchangeRateManager>());
      expect(controller.validationService, isA<ExchangeValidationService>());
      expect(controller.rateService, isA<ExchangeRateService>());

      expect(controller.currentRate.value, 0.0);
      expect(controller.previousRate.value, 0.0);
      expect(controller.rateDirection.value, RateDirection.unknown);
      expect(controller.isReviewRateStale.value, false);
    });

    test('isAmountValid correctly delegates to validation service', () {
      controller.fromWallet.value = Wallets(
        code: 'USD',
        exchangeLimit: ExchangeLimit(min: '10', max: '100'),
      );
      controller.toWallet.value = Wallets(code: 'EUR');

      controller.amountController.text = '5';
      expect(controller.isAmountValid, false);

      controller.amountController.text = '50';
      expect(controller.isAmountValid, true);

      controller.amountController.text = '150';
      expect(controller.isAmountValid, false);
    });

    test('clearFields clears both controller and rateManager state', () {
      controller.charge.value = 5.0;
      controller.totalAmount.value = 105.0;
      controller.currentRate.value = 1.25;

      controller.clearFields();

      expect(controller.charge.value, 0.0);
      expect(controller.totalAmount.value, 0.0);
      expect(controller.currentRate.value, 0.0);
      expect(controller.rateManager.lockedReviewRate, isNull);
    });
  });
}

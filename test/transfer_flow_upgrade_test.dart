import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/model/payment_settings_model.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/model/payment_wallet_model.dart'
    as payment_wallet;
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/model/request_money_wallet_model.dart'
    as request_wallet;
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart'
    as transfer_wallet;

class _MockNetworkService extends NetworkService {
  Map<String, dynamic>? mockResponseData;
  Status mockStatus = Status.completed;
  int getCallCount = 0;
  int postCallCount = 0;
  String? lastEndpoint;
  Map<String, dynamic>? lastPostData;
  Completer<void>? postDelayCompleter;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<ApiResponse<Map<String, dynamic>>> get({
    required String endpoint,
    bool isForeground = true,
  }) async {
    getCallCount++;
    lastEndpoint = endpoint;
    if (mockStatus == Status.completed && mockResponseData != null) {
      return ApiResponse.completed(mockResponseData!);
    } else {
      return ApiResponse.error('Network Error');
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> post({
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
    String? operationId,
    bool isForeground = true,
  }) async {
    postCallCount++;
    lastEndpoint = endpoint;
    lastPostData = data;
    if (postDelayCompleter != null) {
      await postDelayCompleter!.future;
    }
    if (mockStatus == Status.completed) {
      return ApiResponse.completed(
        mockResponseData ??
            {
              'status': 'success',
              'message': 'Operation successful',
              'data': {'id': 1},
            },
      );
    } else {
      return ApiResponse.error('Operation failed');
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> globalGet({
    required String endpoint,
    bool isForeground = true,
  }) async {
    getCallCount++;
    lastEndpoint = endpoint;
    if (mockStatus == Status.completed) {
      return ApiResponse.completed(
        mockResponseData ??
            {
              'status': 'success',
              'data': {'converted_amount': '15.00'},
            },
      );
    } else {
      return ApiResponse.error('Conversion error');
    }
  }
}

class _MockSettingsService extends SettingsService {
  @override
  String? getSetting(String key) {
    if (key == 'site_currency') return 'USD';
    if (key == 'site_currency_decimals') return '2';
    if (key == 'transfer_money_passcode_status') return '0';
    if (key == 'make_payment_passcode_status') return '0';
    if (key == 'request_money_accept_passcode_status') return '0';
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNetworkService mockNetwork;
  late TransferController transferController;
  late MakePaymentController paymentController;
  late RequestMoneyController requestMoneyController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (MethodCall methodCall) async => true,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (MethodCall methodCall) async => <String, dynamic>{
            'appName': 'ecardo',
            'packageName': 'ir.ecardo.user',
            'version': '1.0.41',
            'buildNumber': '41',
          },
        );

    mockNetwork = _MockNetworkService();
    Get.put<NetworkService>(mockNetwork);
    Get.put<SettingsService>(_MockSettingsService());

    transferController = TransferController();
    paymentController = MakePaymentController();
    requestMoneyController = RequestMoneyController();
  });

  tearDown(() {
    transferController.onClose();
    paymentController.onClose();
    requestMoneyController.onClose();
    Get.reset();
  });

  group('MOD-TX - Zero-Decimal Toman Enforcements', () {
    test('DynamicDecimalsHelper enforces 0 decimals for IRT, IRR, and TOMAN', () {
      final helper = DynamicDecimalsHelper();

      expect(
        helper.getDynamicDecimals(
          currencyCode: 'IRT',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        ),
        equals(0),
      );

      expect(
        helper.getDynamicDecimals(
          currencyCode: 'IRR',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        ),
        equals(0),
      );

      expect(
        helper.getDynamicDecimals(
          currencyCode: 'TOMAN',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        ),
        equals(0),
      );

      expect(
        helper.getDynamicDecimals(
          currencyCode: 'USD',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        ),
        equals(2),
      );

      expect(
        helper.getDynamicDecimals(
          currencyCode: 'BTC',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        equals(8),
      );
    });

    test(
      'TransferController.setPercentage sets integer string with 0 decimals for IRT',
      () {
        transferController.wallet.value = transfer_wallet.Wallets(
          name: 'Toman Wallet',
          code: 'IRT',
          symbol: 'تومان',
          balance: '2500000',
          isCrypto: false,
        );

        transferController.setPercentage(0.5);

        // 2,500,000 * 0.5 = 1,250,000 without any decimal point
        expect(transferController.amountController.text, equals('1250000'));
        expect(transferController.amountController.text.contains('.'), isFalse);
      },
    );

    test(
      'MakePaymentController.setPercentage sets integer string with 0 decimals for IRT',
      () {
        paymentController.wallet.value = payment_wallet.Wallets(
          name: 'Toman Wallet',
          code: 'IRT',
          symbol: 'تومان',
          balance: '5000000',
          isCrypto: false,
        );

        paymentController.setPercentage(0.25);

        // 5,000,000 * 0.25 = 1,250,000 integer
        expect(paymentController.amountController.text, equals('1250000'));
        expect(paymentController.amountController.text.contains('.'), isFalse);
      },
    );

    test(
      'RequestMoneyController.setPercentage sets integer string with 0 decimals for IRT',
      () {
        requestMoneyController.wallet.value = request_wallet.Wallets(
          name: 'Toman Wallet',
          code: 'IRT',
          symbol: 'تومان',
          balance: '1000000',
          isCrypto: false,
        );

        requestMoneyController.setPercentage(0.75);

        // 1,000,000 * 0.75 = 750,000 integer
        expect(requestMoneyController.requestAmountController.text, equals('750000'));
        expect(requestMoneyController.requestAmountController.text.contains('.'), isFalse);
      },
    );
  });

  group('MOD-TX - Transfer Input Validation', () {
    setUp(() {
      transferController.wallet.value = transfer_wallet.Wallets(
        name: 'USD Wallet',
        code: 'USD',
        symbol: '\$',
        balance: '500.00',
        isCrypto: false,
        transferLimit: transfer_wallet.TransferLimit(
          min: '10.00',
          max: '1000.00',
        ),
      );
      transferController.recipientUidController.text = '102345';
    });

    test('validates successfully when amount is within min and max and <= balance', () {
      transferController.amountController.text = '100.00';
      transferController.charge.value = 2.0;

      final isValid = transferController.validateAmountStep();
      expect(isValid, isTrue);
    });

    test('fails validation when recipient UID is empty', () {
      transferController.recipientUidController.clear();
      transferController.amountController.text = '100.00';

      final isValid = transferController.validateAmountStep();
      expect(isValid, isFalse);
    });

    test('fails validation when amount is below minimum limit', () {
      transferController.amountController.text = '5.00'; // min is 10.00

      final isValid = transferController.validateAmountStep();
      expect(isValid, isFalse);
    });

    test('fails validation when amount exceeds maximum limit', () {
      transferController.amountController.text = '1500.00'; // max is 1000.00

      final isValid = transferController.validateAmountStep();
      expect(isValid, isFalse);
    });

    test('fails validation when amount + charge exceeds available balance', () {
      // Balance is 500.00, amount is 499.00, fee is 5.00 -> total 504.00 > 500.00
      transferController.amountController.text = '499.00';
      transferController.charge.value = 5.0;

      final isValid = transferController.validateAmountStep();
      expect(isValid, isFalse);
    });

    test('fails validation when charge calculation failed', () {
      transferController.amountController.text = '100.00';
      transferController.chargeLoadFailed.value = true;

      final isValid = transferController.validateAmountStep();
      expect(isValid, isFalse);
    });
  });

  group('MOD-TX - Fee Breakdown Calculation', () {
    test('calculates percentage fee safely using MoneyMathHelper without float drift', () {
      transferController.transferConfigModel.value = TransferConfigModel(
        data: TransferConfigData(
          settings: Settings(
            charge: '1.5',
            chargeType: 'percentage',
          ),
        ),
      );

      transferController.amountController.text = '1000';
      transferController.calculateLiveCharge();

      // 1000 * 1.5% = 15.0
      expect(transferController.charge.value, equals(15.0));
      expect(transferController.totalAmount.value, equals(1015.0));
    });

    test('MoneyMathHelper prevents 0.1 + 0.2 floating point binary drift', () {
      final sum = MoneyMathHelper.add(0.1, 0.2);
      expect(sum, equals(0.3));

      final percentFee = MoneyMathHelper.calculatePercentCharge(100.0, 3.5);
      expect(percentFee, equals(3.5));
    });

    test('MakePaymentController calculates percentage fee with MoneyMathHelper', () {
      paymentController.paymentSettings.value = PaymentSettingsModel(
        data: PaymentSettingsData(
          userCharge: '2.0',
          userChargeType: 'percentage',
        ),
      );

      paymentController.amountController.text = '500';
      paymentController.calculateLiveCharge();

      // 500 * 2.0% = 10.0
      expect(paymentController.charge.value, equals(10.0));
      expect(paymentController.totalAmount.value, equals(510.0));
    });
  });

  group('MOD-TX - Double-Tap Debounce Invariants', () {
    test('rapid multi-tap on nextStepWithValidation does not double-advance step', () async {
      transferController.wallet.value = transfer_wallet.Wallets(
        name: 'USD Wallet',
        code: 'USD',
        balance: '500.00',
        transferLimit: transfer_wallet.TransferLimit(min: '1', max: '1000'),
      );
      transferController.recipientUidController.text = '102345';
      transferController.amountController.text = '50';
      transferController.currentStep.value = 0;

      mockNetwork.mockResponseData = {
        'status': 'success',
        'data': {
          'settings': {'charge': '0', 'charge_type': 'percentage'},
        },
      };

      // Fire 3 simultaneous rapid clicks
      final f1 = transferController.nextStepWithValidation();
      final f2 = transferController.nextStepWithValidation();
      final f3 = transferController.nextStepWithValidation();

      await Future.wait([f1, f2, f3]);

      // Current step should advance to 1 (Review step), NOT 2 or 3
      expect(transferController.currentStep.value, equals(1));
    });

    test('transferAmount guards against double submission when request is in flight', () async {
      transferController.wallet.value = transfer_wallet.Wallets(
        name: 'USD Wallet',
        code: 'USD',
        isDefault: true,
      );
      transferController.recipientUidController.text = '102345';
      transferController.amountController.text = '50';

      // Simulate network latency with a Completer
      mockNetwork.postDelayCompleter = Completer<void>();

      // First call starts network post
      final call1 = transferController.transferAmount();
      expect(transferController.isTransferAmountLoading.value, isTrue);

      // Second call while first is in flight
      final call2 = transferController.transferAmount();

      // Verify that postCallCount is only 1 (second call was rejected by debounce guard)
      expect(mockNetwork.postCallCount, equals(1));

      // Complete the in-flight network request
      mockNetwork.postDelayCompleter!.complete();
      await Future.wait([call1, call2]);

      expect(mockNetwork.postCallCount, equals(1));
      expect(transferController.isTransferAmountLoading.value, isFalse);
    });

    test('makePayment guards against duplicate submission when in flight', () async {
      paymentController.wallet.value = payment_wallet.Wallets(
        name: 'USD Wallet',
        code: 'USD',
        isDefault: true,
      );
      paymentController.merchantMidController.text = '999123';
      paymentController.amountController.text = '100';

      mockNetwork.postDelayCompleter = Completer<void>();

      final call1 = paymentController.makePayment();
      expect(paymentController.isMakePaymentLoading.value, isTrue);

      final call2 = paymentController.makePayment();
      expect(mockNetwork.postCallCount, equals(1));

      mockNetwork.postDelayCompleter!.complete();
      await Future.wait([call1, call2]);

      expect(mockNetwork.postCallCount, equals(1));
      expect(paymentController.isMakePaymentLoading.value, isFalse);
    });

    test('requestMoney guards against duplicate submission when in flight', () async {
      requestMoneyController.wallet.value = request_wallet.Wallets(
        name: 'USD Wallet',
        code: 'USD',
        isDefault: true,
      );
      requestMoneyController.recipientUidController.text = '888456';
      requestMoneyController.requestAmountController.text = '200';

      mockNetwork.postDelayCompleter = Completer<void>();

      final call1 = requestMoneyController.requestMoney();
      expect(requestMoneyController.isRequestMoneyLoading.value, isTrue);

      final call2 = requestMoneyController.requestMoney();
      expect(mockNetwork.postCallCount, equals(1));

      mockNetwork.postDelayCompleter!.complete();
      await Future.wait([call1, call2]);

      expect(mockNetwork.postCallCount, equals(1));
      expect(requestMoneyController.isRequestMoneyLoading.value, isFalse);
    });
  });

  group('MOD-TX - State Matrix Invariants', () {
    test('TransferController sets hasError and errorMessage on network failure', () async {
      mockNetwork.mockStatus = Status.error;
      mockNetwork.mockResponseData = null;

      await transferController.fetchTransferWallets();

      expect(transferController.isLoading.value, isFalse);
      expect(transferController.hasError.value, isTrue);
      expect(transferController.errorMessage.value, isNotEmpty);
    });

    test('MakePaymentController sets hasError and errorMessage on network failure', () async {
      mockNetwork.mockStatus = Status.error;
      mockNetwork.mockResponseData = null;

      await paymentController.fetchWallets();

      expect(paymentController.isLoading.value, isFalse);
      expect(paymentController.hasError.value, isTrue);
      expect(paymentController.errorMessage.value, isNotEmpty);
    });

    test('RequestMoneyController sets hasError and errorMessage on network failure', () async {
      mockNetwork.mockStatus = Status.error;
      mockNetwork.mockResponseData = null;

      await requestMoneyController.fetchWallets();

      expect(requestMoneyController.isLoading.value, isFalse);
      expect(requestMoneyController.hasError.value, isTrue);
      expect(requestMoneyController.errorMessage.value, isNotEmpty);
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/receipt/digital_receipt_ticket.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/apply_verification/controller/apply_verification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/apply_verification/view/apply_verification_screen.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/create_ad/controller/create_ad_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/create_ad/view/create_ad_screen.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_ads/view/my_ads_screen.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/controller/my_order_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/view/my_order_screen.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/add_payment_method_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/edit_payment_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/add_payment_method.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/edit_payment_account.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';

class _TestMyAdsController extends MyAdsController {
  @override
  Future<void> fetchFilterCurrencies() async {}

  @override
  Future<void> fetchMyAds({bool isRefresh = false}) async {}
}

class _TestCreateAdController extends CreateAdController {
  @override
  Future<void> fetchAdsEligibility() async {}
}

class _TestApplyVerificationController extends ApplyVerificationController {
  @override
  Future<void> fetchVerificationStatus() async {}
}

class _TestMyOrderController extends MyOrderController {
  @override
  Future<void> fetchMyOrders({bool isRefresh = false}) async {}
}

class _TestAddPaymentMethodController extends AddPaymentMethodController {
  @override
  Future<void> fetchPaymentMethods() async {}
}

class _TestPaymentAccountController extends PaymentAccountController {
  @override
  Future<void> fetchPaymentAccounts({bool isRefresh = false}) async {}
}

class _TestEditPaymentAccountController extends EditPaymentAccountController {}

Widget _wrapTestWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => GetMaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('TravelServiceRequestStatus pending state tests', () {
    test('parses pending status correctly from raw string and serializes', () {
      expect(
        travelServiceRequestStatusFromRaw('pending'),
        TravelServiceRequestStatus.pending,
      );
      expect(
        travelServiceRequestStatusFromRaw('PENDING'),
        TravelServiceRequestStatus.pending,
      );

      final req = TravelServiceRequest(
        id: 'cip_test_1',
        serviceKey: 'cip',
        title: 'Airport CIP Lounge',
        subtitle: 'Flight 101',
        amountLabel: r'$250 USD',
        reference: 'TSR-TEST123',
        createdAt: DateTime.now(),
        status: TravelServiceRequestStatus.pending,
      );

      final json = req.toJson();
      expect(json['status'], 'pending');

      final deserialized = TravelServiceRequest.fromJson(json);
      expect(deserialized.status, TravelServiceRequestStatus.pending);
    });
  });

  group('DigitalReceiptTicket Account Number Masking Tests', () {
    testWidgets(
      'masks fromAccount and toAccount on receipt and hides raw values',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const rawFromAccount = 'IR820170000000123456789012';
        const rawToAccount = '6037997123456789';

        final maskedFrom = WithdrawDestinationCard.maskAccountNumber(
          rawFromAccount,
        );
        final maskedTo = WithdrawDestinationCard.maskAccountNumber(
          rawToAccount,
        );

        expect(maskedFrom, 'IR82 •••• •••• •••• 9012');
        expect(maskedTo, '•••• •••• •••• 6789');

        await tester.pumpWidget(
          _wrapTestWidget(
            const DigitalReceiptTicket(
              title: 'Transfer Receipt',
              transactionId: 'TX-123456',
              status: ReceiptStatus.success,
              primaryAmount: 500.0,
              primaryCurrency: 'USD',
              fromAccount: rawFromAccount,
              toAccount: rawToAccount,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Masked values should be displayed in the UI
        expect(find.text(maskedFrom), findsOneWidget);
        expect(find.text(maskedTo), findsOneWidget);

        // Raw unmasked account numbers should NEVER be displayed
        expect(find.text(rawFromAccount), findsNothing);
        expect(find.text(rawToAccount), findsNothing);
      },
    );
  });

  group('NetworkErrorHelper Timeout Detection Tests', () {
    test('detects DioException timeouts', () {
      final connTimeout = DioException(
        requestOptions: RequestOptions(path: '/transfer'),
        type: DioExceptionType.connectionTimeout,
      );
      final recvTimeout = DioException(
        requestOptions: RequestOptions(path: '/exchange'),
        type: DioExceptionType.receiveTimeout,
      );
      final sendTimeout = DioException(
        requestOptions: RequestOptions(path: '/cashout'),
        type: DioExceptionType.sendTimeout,
      );
      final badCert = DioException(
        requestOptions: RequestOptions(path: '/transfer'),
        type: DioExceptionType.badCertificate,
      );

      expect(NetworkErrorHelper.isTimeout(connTimeout), isTrue);
      expect(NetworkErrorHelper.isTimeout(recvTimeout), isTrue);
      expect(NetworkErrorHelper.isTimeout(sendTimeout), isTrue);
      expect(NetworkErrorHelper.isTimeout(badCert), isFalse);
    });

    test('detects string timeout messages', () {
      expect(NetworkErrorHelper.isTimeout('connection timed out'), isTrue);
      expect(NetworkErrorHelper.isTimeout('Request timed out'), isTrue);
      expect(NetworkErrorHelper.isTimeout('connectionTimeout'), isTrue);
      expect(NetworkErrorHelper.isTimeout('receiveTimeout'), isTrue);
      expect(NetworkErrorHelper.isTimeout('Invalid password'), isFalse);
      expect(NetworkErrorHelper.isTimeout('Insufficient funds'), isFalse);
    });

    test(
      'NetworkErrorHelper.from returns timeout kind for timeout exceptions',
      () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );
        final info = NetworkErrorHelper.from(err);
        expect(info.kind, NetworkErrorKind.timeout);
      },
    );
  });

  group('P2P Controller Lifecycle Lazy-Binding Tests (ARC-02)', () {
    testWidgets('MyAdsScreen reuses pre-registered controller without leak', (
      tester,
    ) async {
      final customController = Get.put<MyAdsController>(_TestMyAdsController());
      await tester.pumpWidget(_wrapTestWidget(const MyAdsScreen()));
      await tester.pump();

      expect(Get.isRegistered<MyAdsController>(), isTrue);
      expect(identical(Get.find<MyAdsController>(), customController), isTrue);
    });

    testWidgets(
      'CreateAdScreen reuses pre-registered controller without leak',
      (tester) async {
        final customController = Get.put<CreateAdController>(
          _TestCreateAdController(),
        );
        await tester.pumpWidget(_wrapTestWidget(const CreateAdScreen()));
        await tester.pump();

        expect(Get.isRegistered<CreateAdController>(), isTrue);
        expect(
          identical(Get.find<CreateAdController>(), customController),
          isTrue,
        );
      },
    );

    testWidgets(
      'ApplyVerificationScreen reuses pre-registered controller without leak',
      (tester) async {
        final customController = Get.put<ApplyVerificationController>(
          _TestApplyVerificationController(),
        );
        await tester.pumpWidget(
          _wrapTestWidget(const ApplyVerificationScreen()),
        );
        await tester.pump();

        expect(Get.isRegistered<ApplyVerificationController>(), isTrue);
        expect(
          identical(Get.find<ApplyVerificationController>(), customController),
          isTrue,
        );
      },
    );

    testWidgets('MyOrderScreen reuses pre-registered controller without leak', (
      tester,
    ) async {
      final customController = Get.put<MyOrderController>(
        _TestMyOrderController(),
      );
      await tester.pumpWidget(_wrapTestWidget(const MyOrderScreen()));
      await tester.pump();

      expect(Get.isRegistered<MyOrderController>(), isTrue);
      expect(
        identical(Get.find<MyOrderController>(), customController),
        isTrue,
      );
    });

    testWidgets(
      'AddPaymentMethod reuses pre-registered controller without leak',
      (tester) async {
        Get.put<PaymentAccountController>(_TestPaymentAccountController());
        final customController = Get.put<AddPaymentMethodController>(
          _TestAddPaymentMethodController(),
        );
        await tester.pumpWidget(_wrapTestWidget(const AddPaymentMethod()));
        await tester.pump();

        expect(Get.isRegistered<AddPaymentMethodController>(), isTrue);
        expect(
          identical(Get.find<AddPaymentMethodController>(), customController),
          isTrue,
        );
      },
    );

    testWidgets(
      'EditPaymentAccount reuses pre-registered controller without leak',
      (tester) async {
        Get.put<PaymentAccountController>(_TestPaymentAccountController());
        final customController = Get.put<EditPaymentAccountController>(
          _TestEditPaymentAccountController(),
        );
        final account = PaymentAccount(
          id: 1,
          paymentMethod: PaymentMethod(name: 'Test'),
        );

        await tester.pumpWidget(
          _wrapTestWidget(EditPaymentAccount(account: account)),
        );
        await tester.pump();

        expect(Get.isRegistered<EditPaymentAccountController>(), isTrue);
        expect(
          identical(Get.find<EditPaymentAccountController>(), customController),
          isTrue,
        );
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart';

import 'screenshot_harness.dart';

class _FakeNetworkService extends NetworkService {
  Map<String, dynamic>? mockResponseData;
  Status mockStatus = Status.completed;
  String? lastEndpoint;
  int callCount = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<ApiResponse<Map<String, dynamic>>> get({
    required String endpoint,
    bool isForeground = true,
  }) async {
    callCount++;
    lastEndpoint = endpoint;
    if (mockStatus == Status.completed && mockResponseData != null) {
      return ApiResponse.completed(mockResponseData!);
    } else {
      return ApiResponse.error('Not found');
    }
  }
}

class _FakeSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => 'USD';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeNetworkService fakeNetworkService;
  late TransferController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    fakeNetworkService = _FakeNetworkService();
    Get.put<NetworkService>(fakeNetworkService);
    Get.put<SettingsService>(_FakeSettingsService());
    controller = TransferController();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('TransferController - Recipient Lookup Tests', () {
    test('initial lookup states are null and false', () {
      expect(controller.lookedUpRecipient.value, isNull);
      expect(controller.isLookingUpRecipient.value, isFalse);
    });

    test('lookupRecipient ignores account numbers under 3 characters', () async {
      controller.lookedUpRecipient.value = {'name': 'Previous User'};
      await controller.lookupRecipient('12');

      expect(controller.lookedUpRecipient.value, isNull);
      expect(controller.isLookingUpRecipient.value, isFalse);
      expect(fakeNetworkService.callCount, equals(0));
    });

    test('lookupRecipient fetches and populates lookedUpRecipient on success', () async {
      fakeNetworkService.mockStatus = Status.completed;
      fakeNetworkService.mockResponseData = {
        'status': 'success',
        'data': {
          'name': 'Ali Vafadar',
          'account_number': '102345',
          'avatar': 'https://example.com/avatar.png',
        },
      };

      await controller.lookupRecipient('102345');

      expect(
        fakeNetworkService.lastEndpoint,
        equals('${ApiPath.userTransferEndpoint}/lookup-recipient?account_number=102345'),
      );
      expect(controller.isLookingUpRecipient.value, isFalse);
      expect(controller.lookedUpRecipient.value, isNotNull);
      expect(controller.lookedUpRecipient.value?['name'], equals('Ali Vafadar'));
      expect(controller.lookedUpRecipient.value?['account_number'], equals('102345'));
    });

    test('lookupRecipient clears lookedUpRecipient when endpoint returns error', () async {
      fakeNetworkService.mockStatus = Status.error;
      fakeNetworkService.mockResponseData = null;

      await controller.lookupRecipient('999999');

      expect(controller.isLookingUpRecipient.value, isFalse);
      expect(controller.lookedUpRecipient.value, isNull);
    });

    test('clearFields clears lookedUpRecipient', () {
      controller.lookedUpRecipient.value = {'name': 'Some User'};
      controller.recipientUidController.text = '102345';

      controller.clearFields();

      expect(controller.lookedUpRecipient.value, isNull);
      expect(controller.recipientUidController.text, isEmpty);
    });

    test('findBeneficiaryByAccount prioritizes saved beneficiaries list', () {
      controller.beneficiaryModel.value = BeneficiaryModel(
        data: BeneficiaryData(
          beneficiaries: [
            Beneficiaries(
              accountNumber: '102345',
              nickname: 'Saved Friend',
              receiver: Receiver(name: 'Saved Friend Name'),
            ),
          ],
        ),
      );

      controller.lookedUpRecipient.value = {
        'account_number': '102345',
        'name': 'Looked Up Name',
      };

      final result = controller.findBeneficiaryByAccount('102345');
      expect(result, isNotNull);
      expect(result?.nickname, equals('Saved Friend'));
    });

    test('findBeneficiaryByAccount synthesizes beneficiary when matched with lookedUpRecipient', () {
      controller.beneficiaryModel.value = BeneficiaryModel(
        data: BeneficiaryData(beneficiaries: []),
      );

      controller.lookedUpRecipient.value = {
        'account_number': '102345',
        'name': 'Ali Vafadar',
        'avatar': 'https://example.com/ali.png',
      };

      final result = controller.findBeneficiaryByAccount('102345');
      expect(result, isNotNull);
      expect(result?.accountNumber, equals('102345'));
      expect(result?.nickname, equals('Ali Vafadar'));
      expect(result?.receiver?.name, equals('Ali Vafadar'));
      expect(result?.receiver?.avatar, equals('https://example.com/ali.png'));
    });

    test('findBeneficiaryByAccount returns null when no saved or lookedUp match', () {
      controller.beneficiaryModel.value = BeneficiaryModel(
        data: BeneficiaryData(beneficiaries: []),
      );
      controller.lookedUpRecipient.value = null;

      final result = controller.findBeneficiaryByAccount('000000');
      expect(result, isNull);
    });

    test('text change triggers debounced lookupRecipient', () async {
      fakeNetworkService.mockStatus = Status.completed;
      fakeNetworkService.mockResponseData = {
        'status': 'success',
        'data': {'name': 'Debounced User', 'account_number': '102345'},
      };

      controller.onInit();
      controller.recipientUidController.text = '102345';

      // Before debounce duration, no call made yet
      expect(fakeNetworkService.callCount, equals(0));

      // Wait for debounce timer (400ms)
      await Future.delayed(const Duration(milliseconds: 500));

      expect(fakeNetworkService.callCount, equals(1));
      expect(controller.lookedUpRecipient.value?['name'], equals('Debounced User'));
    });
  });

  group('TransferAmountStepSection - Real-Time Lookup UI Tests', () {
    testWidgets('renders verifying account indicator when isLookingUpRecipient is true', (tester) async {
      final testController = TransferController();
      testController.isLookingUpRecipient.value = true;
      testController.recipientUidController.text = '1023';

      await pumpScreen(
        tester,
        const Scaffold(body: SingleChildScrollView(child: TransferAmountStepSection())),
        locale: const Locale('fa'),
        registrations: [
          () => registerController<TransferController>(testController),
          () => registerController<SettingsService>(_FakeSettingsService()),
        ],
      );

      expect(find.text('در حال استعلام حساب...'), findsOneWidget);
    });

    testWidgets('renders confirmation chip when lookedUpRecipient is populated', (tester) async {
      final testController = TransferController();
      testController.isLookingUpRecipient.value = false;
      testController.recipientUidController.text = '102345';
      testController.lookedUpRecipient.value = {
        'name': 'علی وفادار',
        'account_number': '102345',
      };

      await pumpScreen(
        tester,
        const Scaffold(body: SingleChildScrollView(child: TransferAmountStepSection())),
        locale: const Locale('fa'),
        registrations: [
          () => registerController<TransferController>(testController),
          () => registerController<SettingsService>(_FakeSettingsService()),
        ],
      );

      expect(find.text('حساب مقصد: علی وفادار (102345)'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('renders not found hint when UID length >= 6 and no recipient found', (tester) async {
      final testController = TransferController();
      testController.isLookingUpRecipient.value = false;
      testController.recipientUidController.text = '999999';
      testController.lookedUpRecipient.value = null;

      await pumpScreen(
        tester,
        const Scaffold(body: SingleChildScrollView(child: TransferAmountStepSection())),
        locale: const Locale('fa'),
        registrations: [
          () => registerController<TransferController>(testController),
          () => registerController<SettingsService>(_FakeSettingsService()),
        ],
      );

      expect(find.text('کاربری با این شناسه یافت نشد'), findsOneWidget);
    });
  });
}

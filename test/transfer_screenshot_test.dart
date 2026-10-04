import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_success_step_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'screenshot_harness.dart';

void main() {
  tearDown(resetHarness);

  group('Transfer Flow Screenshots', () {
    testWidgets('transfer_review_step_light', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: TransferReviewStepSection()),
        registrations: [
          () => registerController<TransferController>(_TestTransferController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'transfer_review_step__light');
    });

    testWidgets('transfer_review_step_dark', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: TransferReviewStepSection()),
        dark: true,
        registrations: [
          () => registerController<TransferController>(_TestTransferController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'transfer_review_step__dark');
    });

    testWidgets('transfer_success_step_light', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: TransferSuccessStepSection()),
        registrations: [
          () => registerController<TransferController>(_TestTransferControllerSuccess()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'transfer_success_step__light');
    });

    testWidgets('transfer_success_step_dark', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: TransferSuccessStepSection()),
        dark: true,
        registrations: [
          () => registerController<TransferController>(_TestTransferControllerSuccess()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'transfer_success_step__dark');
    });
  });
}

/// Mock TransferController for review step.
class _TestTransferController extends TransferController {
  _TestTransferController() {
    isTransferConfigLoading.value = false;
    isTransferAmountLoading.value = false;
    chargeLoadFailed.value = false;
    charge.value = 2.50;
    totalAmount.value = 102.50;

    amountController.text = '100.00';
    recipientUidController.text = 'ECAR12345';

    wallet.value = Wallets(
      name: 'USD Wallet',
      code: 'USD',
      symbol: '\$',
      balance: '1250.00',
      isCrypto: false,
      conversionRate: '1.00',
    );

    transferWalletsList.value = [wallet.value!];

    beneficiaryModel.value = BeneficiaryModel(
      data: BeneficiaryData(
        beneficiaries: [
          Beneficiaries(
            accountNumber: 'ECAR12345',
            nickname: 'John Doe',
            receiver: Receiver(
              name: 'John Doe',
              email: 'john.doe@example.com',
              avatar: null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mock TransferController for success step.
class _TestTransferControllerSuccess extends TransferController {
  _TestTransferControllerSuccess() {
    isTransferAmountLoading.value = false;
    currentStep.value = 2;

    amountController.text = '100.00';
    recipientUidController.text = 'ECAR12345';

    wallet.value = Wallets(
      name: 'USD Wallet',
      code: 'USD',
      symbol: '\$',
      balance: '1250.00',
      isCrypto: false,
    );

    successTransferData.value = {
      'sender_transaction': {
        'tnx': 'TRX-ECAR-1728028614037',
        'final_amount': '100.00',
        'charge': '2.50',
        'created_at': '2026-10-04 10:56:54',
        'description': 'Transfer to John Doe',
      },
    };

    beneficiaryModel.value = BeneficiaryModel(
      data: BeneficiaryData(
        beneficiaries: [
          Beneficiaries(
            accountNumber: 'ECAR12345',
            nickname: 'John Doe',
            receiver: Receiver(
              name: 'John Doe',
              email: 'john.doe@example.com',
              avatar: null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mock SettingsService for transfer flow.
class _TestSettingsService extends GetxService implements SettingsService {
  @override
  String? getSetting(String key) {
    if (key == 'site_currency') return 'USD';
    if (key == 'site_currency_decimals') return '2';
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/beneficiary_model.dart';
import 'package:qunzo_user/src/common/model/converter_model.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/model/transfer_config_model.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';

class TransferController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isTransferConfigLoading = false.obs;
  final RxBool isTransferAmountLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<TransferConfigModel> transferConfigModel = TransferConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successTransferData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> transferWalletsList = <Wallets>[].obs;

  // Recipient UID
  final RxBool isRecipientUidFocused = false.obs;
  final FocusNode recipientUidFocusNode = FocusNode();
  final recipientUidController = TextEditingController();

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    recipientUidFocusNode.addListener(_handleRecipientUidFocusChange);
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void onClose() {
    recipientUidFocusNode.removeListener(_handleRecipientUidFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    recipientUidFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  // Recipient Uid focus change handler
  void _handleRecipientUidFocusChange() {
    isRecipientUidFocused.value = recipientUidFocusNode.hasFocus;
  }

  // Amount focus change handler
  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  // Next Step Function
  Future<void> nextStepWithValidation() async {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      await fetchTransferConfig();
    } else {
      currentStep.value = 0;
    }
  }

  // Fetch User
  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Transfer Config
  Future<void> fetchTransferConfig() async {
    isTransferConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.transferConfigEndpoint,
      );

      if (response.status == Status.completed) {
        transferConfigModel.value = TransferConfigModel.fromJson(
          response.data!,
        );
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTransferConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Charge Calculation
  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr =
        transferConfigModel.value.data!.settings!.charge ?? "0";
    final userChargeType =
        transferConfigModel.value.data!.settings!.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
      totalAmount.value = amount + calculatedCharge;
    } else {
      await getChargeConverter();
    }

    isTransferConfigLoading.value = false;
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: transferConfigModel.value.data!.settings!.charge!,
          currencyCode: wallet.value!.code!,
        ),
      );
      if (response.status == Status.completed) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        charge.value =
            double.tryParse(
              converterModel.value.data!.convertedAmount ?? "0",
            ) ??
            0.0;
        totalAmount.value =
            (double.tryParse(amountController.text)! + charge.value);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Validate Amount Step
  bool validateAmountStep() {
    if (wallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(localization.transferValidationSelectWallet);
      return false;
    }

    if (recipientUidController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.transferValidationEnterRecipientUid,
      );
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.transferValidationEnterAmount);
      return false;
    }

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: wallet.value!.code!,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: wallet.value!.isCrypto!,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(wallet.value!.transferLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(wallet.value!.transferLimit!.max!) ?? double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.transferValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.transferValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    return true;
  }

  // Transfer Amount
  Future<void> transferAmount() async {
    isTransferAmountLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'account_number': recipientUidController.text.trim(),
      'amount': amountController.text.trim(),
      'wallet_id': wallet.value!.isDefault!
          ? "default"
          : wallet.value!.id.toString(),
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.userTransferEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successTransferData.value = response.data!['data'];
        currentStep.value = 2;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ transferAmount() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isTransferAmountLoading.value = false;
    }
  }

  // Fetch Wallets
  Future<void> fetchTransferWallets() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?transfer",
      );

      if (response.status == Status.completed) {
        final transferWalletsModel = TransferWalletModel.fromJson(
          response.data!,
        );
        transferWalletsList.assignAll(transferWalletsModel.data?.wallets ?? []);

        if (transferWalletsList.isNotEmpty) {
          wallet.value = transferWalletsList.first;
        } else {
          wallet.value = null;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTransferWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Beneficiary
  Future<void> fetchBeneficiary() async {
    isBeneficiaryLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.beneficiaryEndpoint}?type=user",
      );

      if (response.status == Status.completed) {
        beneficiaryModel.value = BeneficiaryModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      isBeneficiaryLoading.value = false;
      debugPrint('❌ fetchBeneficiary() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isBeneficiaryLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    transferConfigModel.value = TransferConfigModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    recipientUidController.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';

class TransferController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isTransferConfigLoading = false.obs;
  final RxBool isTransferAmountLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool chargeLoadFailed = false.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<TransferConfigModel> transferConfigModel = TransferConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successTransferData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  AppLocalizations get localization =>
      AppLocalizations.of(Get.context!)!;

  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> transferWalletsList = <Wallets>[].obs;

  final RxBool isRecipientUidFocused = false.obs;
  final FocusNode recipientUidFocusNode = FocusNode();
  final recipientUidController = TextEditingController();

  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    recipientUidFocusNode.addListener(_handleRecipientUidFocusChange);
    amountFocusNode.addListener(_handleAmountFocusChange);
    amountController.addListener(_handleAmountTextChange);
  }

  @override
  void onClose() {
    recipientUidFocusNode.removeListener(_handleRecipientUidFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    amountController.removeListener(_handleAmountTextChange);
    recipientUidFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  void _handleRecipientUidFocusChange() {
    isRecipientUidFocused.value = recipientUidFocusNode.hasFocus;
  }

  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  void _handleAmountTextChange() {
    if (transferConfigModel.value.data?.settings != null) {
      _calculateCharge();
    }
  }

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
    } finally {
      isTransferConfigLoading.value = false;
    }
  }

  Future<void> calculateLiveCharge() async => _calculateCharge();

  void setPercentage(double fraction) {
    final currentWallet = wallet.value;
    if (currentWallet == null) return;
    final balanceStr = currentWallet.balance ?? '0';
    final balance = double.tryParse(balanceStr) ?? 0.0;
    if (balance <= 0) return;

    final siteCurrency =
        Get.find<SettingsService>().getSetting("site_currency") ?? 'USD';
    final siteDecimals =
        Get.find<SettingsService>().getSetting("site_currency_decimals") ?? '2';
    final decimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currentWallet.code ?? 'USD',
      siteCurrencyCode: siteCurrency,
      siteCurrencyDecimals: siteDecimals,
      isCrypto: currentWallet.isCrypto ?? false,
    );

    final targetAmount = balance * fraction;
    amountController.text = targetAmount.toStringAsFixed(decimals);
    calculateLiveCharge();
  }

  Beneficiaries? findBeneficiaryByAccount(String accountNumber) {
    if (accountNumber.trim().isEmpty) return null;
    final list = beneficiaryModel.value.data?.beneficiaries;
    if (list == null || list.isEmpty) return null;
    try {
      return list.firstWhere(
        (b) => (b.accountNumber?.trim() == accountNumber.trim()),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final settings = transferConfigModel.value.data?.settings;
    if (settings == null) {
      charge.value = 0.0;
      totalAmount.value = amount;
      return;
    }
    final userChargeStr = settings.charge ?? "0";
    final userChargeType = settings.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      // BUG-11 (P2): Safe monetary calculation without binary floating-point drift.
      calculatedCharge = MoneyMathHelper.calculatePercentCharge(amount, percent);
      charge.value = calculatedCharge;
      totalAmount.value = MoneyMathHelper.add(amount, calculatedCharge);
    } else {
      await getChargeConverter();
    }

    isTransferConfigLoading.value = false;
  }

  Future<void> getChargeConverter() async {
    final chargeSetting = transferConfigModel.value.data?.settings?.charge;
    final walletCode = wallet.value?.code;
    if (chargeSetting == null || walletCode == null) {
      charge.value = 0.0;
      totalAmount.value = double.tryParse(amountController.text) ?? 0.0;
      return;
    }
    chargeLoadFailed.value = false;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: chargeSetting,
          currencyCode: walletCode,
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
            ((double.tryParse(amountController.text) ?? 0.0) + charge.value);
      } else {
        chargeLoadFailed.value = true;
      }
    } catch (e, stackTrace) {
      chargeLoadFailed.value = true;
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  bool validateAmountStep() {
    if (chargeLoadFailed.value) {
      ToastHelper().showErrorToast(localization.allControllerLoadError);
      return false;
    }
    final walletData = wallet.value;
    if (walletData == null || (walletData.name ?? '').isEmpty) {
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
          ) ??
          'USD',
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
            "site_currency_decimals",
          ) ??
          '2',
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

    final double availableBalance =
        double.tryParse(wallet.value!.balance ?? '') ?? 0.0;
    if (enteredAmount > availableBalance) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationInsufficientBalance(
          availableBalance.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    return true;
  }

  /// [passcode] — verified 4-digit transaction passcode when required.
  Future<void> transferAmount({String? passcode}) async {
    if (isTransferAmountLoading.isTrue) return;
    isTransferAmountLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'account_number': recipientUidController.text.trim(),
      'amount': amountController.text.trim(),
      'wallet_id': wallet.value!.isDefault!
          ? "default"
          : wallet.value!.id.toString(),
    };
    if (passcode != null && PasscodeHelper.isValidFormat(passcode)) {
      requestBody['passcode'] = PasscodeHelper.normalize(passcode);
    }

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.userTransferEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successTransferData.value = response.data!['data'];
        currentStep.value = 2;
        AppEventBus.emit(BalanceChangedEvent(sourceModule: 'transfer'));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ transferAmount() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isTransferAmountLoading.value = false;
    }
  }

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

  void clearFields() {
    transferConfigModel.value = TransferConfigModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    recipientUidController.clear();
  }
}

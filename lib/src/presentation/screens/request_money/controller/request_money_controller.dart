import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/model/request_money_wallet_model.dart';

class RequestMoneyController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRequestMoneyLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxInt currentStep = 0.obs;
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  AppLocalizations get localization {
    final ctx = Get.context;
    if (ctx != null) {
      final loc = AppLocalizations.of(ctx);
      if (loc != null) return loc;
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> requestMoneyWalletsList = <Wallets>[].obs;

  // Recipient
  final RxBool isRecipientUidFocused = false.obs;
  final FocusNode recipientUidFocusNode = FocusNode();
  final recipientUidController = TextEditingController();

  // Request Amount
  final RxBool isRequestAmountFocused = false.obs;
  final FocusNode requestAmountFocusNode = FocusNode();
  final requestAmountController = TextEditingController();

  // Note
  final RxBool isNoteFocused = false.obs;
  final FocusNode noteFocusNode = FocusNode();
  final noteController = TextEditingController();

  // Steps
  final List<String> steps = ['Amount', 'Review', 'Success'];
  bool _isAdvancingStep = false;

  @override
  void onInit() {
    super.onInit();
    recipientUidFocusNode.addListener(_handleRecipientUidFocusChange);
    requestAmountFocusNode.addListener(_handleRequestAmountFocusChange);
    noteFocusNode.addListener(_handleNoteFocusChange);
  }

  @override
  void onClose() {
    recipientUidFocusNode.removeListener(_handleRecipientUidFocusChange);
    requestAmountFocusNode.removeListener(_handleRequestAmountFocusChange);
    noteFocusNode.removeListener(_handleNoteFocusChange);
    recipientUidFocusNode.dispose();
    requestAmountFocusNode.dispose();
    noteFocusNode.dispose();
    super.onClose();
  }

  // Recipient Uid focus change handler
  void _handleRecipientUidFocusChange() {
    isRecipientUidFocused.value = recipientUidFocusNode.hasFocus;
  }

  // Request Amount focus change handler
  void _handleRequestAmountFocusChange() {
    isRequestAmountFocused.value = requestAmountFocusNode.hasFocus;
  }

  // Note focus change handler
  void _handleNoteFocusChange() {
    isNoteFocused.value = noteFocusNode.hasFocus;
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

  // Fetch Wallets
  Future<void> fetchWallets() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?request_money",
      );

      if (response.status == Status.completed) {
        final requestMoneyWalletsModel = RequestMoneyWalletModel.fromJson(
          response.data!,
        );
        requestMoneyWalletsList.assignAll(
          requestMoneyWalletsModel.data?.wallets ?? [],
        );

        if (requestMoneyWalletsList.isNotEmpty) {
          wallet.value = requestMoneyWalletsList.first;
        } else {
          wallet.value = null;
        }
      } else {
        hasError.value = true;
        errorMessage.value =
            response.message ?? localization.allControllerLoadError;
      }
    } catch (e, stackTrace) {
      hasError.value = true;
      final info = NetworkErrorHelper.from(e);
      errorMessage.value = info.message;
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Request Money
  Future<void> requestMoney() async {
    // v1.0.24: guard against double submission while a request is in flight.
    if (isRequestMoneyLoading.isTrue) return;
    isRequestMoneyLoading.value = true;

    final currentWallet = wallet.value;
    final Map<String, dynamic> requestBody = {
      'wallet_id': currentWallet?.isDefault == true
          ? "default"
          : (currentWallet?.id?.toString() ?? "default"),
      'request_to': recipientUidController.text.trim(),
      'amount': requestAmountController.text.trim(),
      'note': noteController.text,
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.requestMoneyEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        clearFields();
        successPaymentData.value = response.data!['data'];
        currentStep.value = 2;
        AppEventBus.emit(BalanceChangedEvent(sourceModule: 'request_money'));
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ requestMoney() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isRequestMoneyLoading.value = false;
    }
  }

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
    requestAmountController.text = decimals == 0
        ? targetAmount.round().toString()
        : targetAmount.toStringAsFixed(decimals);
  }

  // Next Step Function
  Future<void> nextStepWithValidation() async {
    if (_isAdvancingStep || isRequestMoneyLoading.isTrue) return;
    _isAdvancingStep = true;
    try {
      if (currentStep.value == 0) {
        if (!validateAmountStep()) {
          return;
        }
      }

      if (currentStep.value < steps.length - 1) {
        currentStep.value++;
      } else {
        currentStep.value = 0;
      }
    } finally {
      _isAdvancingStep = false;
    }
  }

  // Validate Amount Step
  bool validateAmountStep() {
    final currentWallet = wallet.value;
    if (currentWallet == null || (currentWallet.name ?? '').isEmpty) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationSelectWallet,
      );
      return false;
    }

    if (recipientUidController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationEnterRecipientUid,
      );
      return false;
    }

    if (requestAmountController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationEnterRequestAmount,
      );
      return false;
    }

    final walletCode = currentWallet.code ?? '';
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode:
          Get.find<SettingsService>().getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          Get.find<SettingsService>().getSetting("site_currency_decimals") ??
          '2',
      isCrypto: currentWallet.isCrypto ?? false,
    );

    final double enteredAmount =
        double.tryParse(requestAmountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(currentWallet.requestMoneyLimit?.min ?? '') ?? 0.0;
    final double max =
        double.tryParse(currentWallet.requestMoneyLimit?.max ?? '') ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          walletCode,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          walletCode,
        ),
      );
      return false;
    }

    return true;
  }

  // Clear Fields
  void clearFields() {
    recipientUidController.clear();
    requestAmountController.clear();
    noteController.clear();
    hasError.value = false;
    errorMessage.value = '';
  }
}

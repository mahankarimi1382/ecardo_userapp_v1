import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/request_money_wallet_model.dart';

class RequestMoneyController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isRequestMoneyLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxInt currentStep = 0.obs;
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

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
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Request Money
  Future<void> requestMoney() async {
    isRequestMoneyLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'wallet_id': wallet.value!.isDefault!
          ? "default"
          : wallet.value!.id.toString(),
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

  // Next Step Function
  Future<void> nextStepWithValidation() async {
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
  }

  // Validate Amount Step
  bool validateAmountStep() {
    if (wallet.value!.name!.isEmpty) {
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
        double.tryParse(requestAmountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(wallet.value!.requestMoneyLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(wallet.value!.requestMoneyLimit!.max!) ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.requestMoneyValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
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
  }
}

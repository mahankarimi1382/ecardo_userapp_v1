import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/converter_model.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_config_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_wallet_model.dart';

class CreateGiftController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isGiftConfigLoading = false.obs;
  final RxBool isCreateGiftLoading = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<GiftConfigModel> giftConfigModel = GiftConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rxn<Map<String, dynamic>> successCreateGiftData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final FocusNode amountFocusNode = FocusNode();
  final amountController = TextEditingController();

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> giftWalletsList = <Wallets>[].obs;

  @override
  void onInit() {
    super.onInit();
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void onClose() {
    amountFocusNode.removeListener(_handleAmountFocusChange);
    amountFocusNode.dispose();
    super.onClose();
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
      await fetchGiftConfig();
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

  // Fetch Gift Config
  Future<void> fetchGiftConfig() async {
    isGiftConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.giftConfigEndpoint,
      );

      if (response.status == Status.completed) {
        giftConfigModel.value = GiftConfigModel.fromJson(response.data!);
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchGiftConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Charge Calculation
  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr = giftConfigModel.value.data!.settings!.charge ?? "0";
    final userChargeType =
        giftConfigModel.value.data!.settings!.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
      totalAmount.value = amount + calculatedCharge;
    } else {
      await getChargeConverter();
    }

    isGiftConfigLoading.value = false;
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: giftConfigModel.value.data!.settings!.charge!,
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
      ToastHelper().showErrorToast(
        localization.createGiftValidationSelectWallet,
      );
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.createGiftValidationEnterAmount,
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
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min = double.tryParse(wallet.value!.giftLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(wallet.value!.giftLimit!.max!) ?? double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.createGiftValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.createGiftValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    return true;
  }

  // Fetch Wallets
  Future<void> fetchWallets() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?gift",
      );

      if (response.status == Status.completed) {
        final giftWalletsModel = GiftWalletModel.fromJson(response.data!);
        giftWalletsList.assignAll(giftWalletsModel.data?.wallets ?? []);

        if (giftWalletsList.isNotEmpty) {
          wallet.value = giftWalletsList.first;
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

  // Create Gift
  Future<void> createGift() async {
    isCreateGiftLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'amount': amountController.text.trim(),
      'wallet_id': wallet.value!.isDefault!
          ? "default"
          : wallet.value!.id.toString(),
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.createGiftEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        successCreateGiftData.value = response.data!['data'];
        currentStep.value = 2;
        clearFields();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ createGift() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isCreateGiftLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    giftConfigModel.value = GiftConfigModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
  }
}

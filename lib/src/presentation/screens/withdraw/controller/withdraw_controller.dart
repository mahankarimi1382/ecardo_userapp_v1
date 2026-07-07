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
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class WithdrawController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isWithdrawLoading = false.obs;
  final RxBool isChargeConverterLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble calculatedCharge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rxn<Map<String, dynamic>> successWithdrawData =
      Rxn<Map<String, dynamic>>();
  final Rx<Accounts?> selectedAccount = Rx<Accounts?>(null);
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Withdraw Accounts
  final RxString withdrawAccountValue = "".obs;
  final RxInt selectedAccountIndex = (-1).obs;
  final RxBool isWithdrawAccountFocused = false.obs;
  final FocusNode withdrawAccountFocusNode = FocusNode();
  final withdrawAccountController = TextEditingController();
  final Rxn<Accounts> withdrawAccount = Rxn<Accounts>();
  final RxList<Accounts> withdrawAccountList = <Accounts>[].obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    withdrawAccountFocusNode.addListener(() {
      isWithdrawAccountFocused.value = withdrawAccountFocusNode.hasFocus;
    });
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    super.onInit();
  }

  // Get Unique Display Names for Withdraw Accounts
  List<String> getUniqueDisplayNames() {
    List<String> displayNames = [];

    for (var account in withdrawAccountList) {
      String methodName = account.methodName ?? "";
      displayNames.add(methodName);
    }

    return displayNames;
  }

  // Next Step Function
  void nextStepWithValidation() {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      reviewCalculate();
    } else {
      currentStep.value = 0;
    }
  }

  // Review Calculate Function
  Future<void> reviewCalculate() async {
    final baseAmount = double.tryParse(amountController.text) ?? 0.0;
    final double charge =
        double.tryParse(withdrawAccount.value!.method!.charge!) ?? 0.0;

    if (withdrawAccount.value!.method!.chargeType == 'percentage') {
      calculatedCharge.value = (baseAmount * charge / 100);
      totalAmount.value = baseAmount + calculatedCharge.value;
    } else {
      await getChargeConverter();
    }
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    isChargeConverterLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: withdrawAccount.value!.method!.charge!,
          currencyCode: withdrawAccount.value!.currency!,
        ),
      );
      if (response.status == Status.completed) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        calculatedCharge.value =
            double.tryParse(
              converterModel.value.data!.convertedAmount ?? "0",
            ) ??
            0.0;
        totalAmount.value =
            (double.tryParse(amountController.text)! + calculatedCharge.value);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isChargeConverterLoading.value = false;
    }
  }

  // Validate Amount Step
  bool validateAmountStep() {
    // Validate Withdraw Account
    if (withdrawAccountController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationSelectWithdrawAccount,
      );
      return false;
    }

    // Validate Amount
    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.withdrawValidationEnterAmount);
      return false;
    }

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: withdrawAccount.value!.currency!,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: withdrawAccount.value!.method!.isCrypto!,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(withdrawAccount.value!.method!.minWithdraw!) ?? 0.0;
    final double max =
        double.tryParse(withdrawAccount.value!.method!.maxWithdraw!) ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          withdrawAccount.value!.currency!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          withdrawAccount.value!.currency!,
        ),
      );
      return false;
    }

    return true;
  }

  // Fetch Withdraw Accounts
  Future<void> fetchWithdrawAccounts() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.withdrawAccountEndpoint,
      );

      if (response.status == Status.completed) {
        final withdrawAccountModel = WithdrawAccountModel.fromJson(
          response.data!,
        );
        withdrawAccountList.value = withdrawAccountModel.data!.accounts ?? [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWithdrawAccounts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
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

  // Withdraw Function
  Future<void> submitWithdraw() async {
    isWithdrawLoading.value = true;

    try {
      final Map<String, dynamic> requestBody = {
        'amount': amountController.text.trim(),
        'withdraw_account_id': withdrawAccount.value!.id.toString(),
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.withdrawEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        successWithdrawData.value = response.data!['data'];
        currentStep.value = 2;
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitWithdraw() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isWithdrawLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    converterModel.value = ConverterModel();
    withdrawAccount.value = Accounts();
    withdrawAccountController.clear();
    amountController.clear();
    calculatedCharge.value = 0.0;
    totalAmount.value = 0.0;
    isAmountFocused.value = false;
    isWithdrawAccountFocused.value = false;
  }

  @override
  void onClose() {
    super.onClose();
    withdrawAccountFocusNode.dispose();
    withdrawAccountController.dispose();
    amountFocusNode.dispose();
    amountController.dispose();
  }
}

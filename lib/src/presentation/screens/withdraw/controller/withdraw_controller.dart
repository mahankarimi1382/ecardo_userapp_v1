import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class WithdrawController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isWithdrawLoading = false.obs;
  final RxBool isChargeConverterLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble calculatedCharge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  // phase1-fix (P0-7): fee calculation failed → Review must never show/confirm 0.00
  final RxBool chargeLoadFailed = false.obs;
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
  final RxList<Wallets> userWalletsList = <Wallets>[].obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  /// Effective available balance for percentage chip calculations
  double get availableBalance {
    final targetCurrency = (withdrawAccount.value?.currency ?? 'USD')
        .toUpperCase()
        .trim();
    if (userWalletsList.isNotEmpty) {
      final match = userWalletsList.firstWhereOrNull(
        (w) => (w.code ?? '').toUpperCase().trim() == targetCurrency,
      );
      if (match != null && match.balance != null) {
        final parsed = double.tryParse(match.balance.toString());
        if (parsed != null && parsed >= 0) return parsed;
      }
    }
    final rawBalance = userModel.value.data?.balance;
    if (rawBalance != null && rawBalance.isNotEmpty) {
      final parsed = double.tryParse(rawBalance);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0.0;
  }

  /// Dynamic daily withdrawal limit for the active account/method
  double get dailyLimitMax {
    final rawMax = withdrawAccount.value?.method?.maxWithdraw;
    if (rawMax != null && rawMax.isNotEmpty) {
      final parsed = double.tryParse(rawMax);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 500.0;
  }

  /// Daily used withdrawal limit
  double get dailyLimitUsed => 0.0;

  /// Sets amount based on percentage fraction (e.g. 0.25, 0.5, 0.75, 1.0)
  void setAmountPercentage(double fraction) {
    final balance = availableBalance;
    final calculated = balance * fraction;
    final isCrypto = withdrawAccount.value?.method?.isCrypto ?? false;
    final decimals = isCrypto ? 6 : 2;
    amountController.text = calculated.toStringAsFixed(decimals);
    reviewCalculate();
  }

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
        double.tryParse(withdrawAccount.value?.method?.charge ?? '0') ?? 0.0;

    if (withdrawAccount.value?.method?.chargeType == 'percentage') {
      calculatedCharge.value = (baseAmount * charge / 100);
      totalAmount.value = baseAmount + calculatedCharge.value;
      chargeLoadFailed.value = false;
    } else {
      // Fixed fee: directly in the withdrawal account's currency
      calculatedCharge.value = charge;
      totalAmount.value = baseAmount + charge;
      chargeLoadFailed.value = false;
    }
  }

  // Get Charge Converter (fallback for multi-currency conversion)
  Future<void> getChargeConverter() async {
    isChargeConverterLoading.value = true;
    chargeLoadFailed.value = false;
    try {
      final acc = withdrawAccount.value;
      if (acc == null) {
        calculatedCharge.value = 0.0;
        totalAmount.value = double.tryParse(amountController.text) ?? 0.0;
        return;
      }
      final charge = double.tryParse(acc.method?.charge ?? '0') ?? 0.0;
      calculatedCharge.value = charge;
      totalAmount.value =
          (double.tryParse(amountController.text) ?? 0.0) + charge;
    } catch (e, stackTrace) {
      chargeLoadFailed.value = true;
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isChargeConverterLoading.value = false;
    }
  }

  // Validate Amount Step
  bool validateAmountStep() {
    if (chargeLoadFailed.value) {
      ToastHelper().showErrorToast(localization.allControllerLoadError);
      return false;
    }
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

    final acc = withdrawAccount.value;
    if (acc == null) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationSelectWithdrawAccount,
      );
      return false;
    }

    final currency = acc.currency ?? '';
    final isCrypto = acc.method?.isCrypto ?? false;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode:
          Get.find<SettingsService>().getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          Get.find<SettingsService>().getSetting("site_currency_decimals") ??
          '2',
      isCrypto: isCrypto,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min = double.tryParse(acc.method?.minWithdraw ?? '') ?? 0.0;
    final double max =
        double.tryParse(acc.method?.maxWithdraw ?? '') ?? double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          currency,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.withdrawValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          currency,
        ),
      );
      return false;
    }

    final double balance = availableBalance;
    final double totalRequired = enteredAmount + calculatedCharge.value;
    if (totalRequired > balance) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationInsufficientBalance(
          balance.toStringAsFixed(calculateDecimals),
          currency,
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

  // Fetch Wallets for Multi-Currency Balances
  Future<void> fetchUserWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?exchange",
      );
      if (response.status == Status.completed && response.data != null) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        final wList = walletsModel.data?.wallets ?? [];
        userWalletsList.assignAll(wList);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUserWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  // Withdraw Function
  Future<void> submitWithdraw({String? passcode}) async {
    // v1.0.24: guard against double submission while a request is in flight.
    if (isWithdrawLoading.isTrue) return;
    isWithdrawLoading.value = true;
    final wasPasscodeProvided = passcode != null && passcode.isNotEmpty;

    try {
      final Map<String, dynamic> requestBody = {
        'amount': amountController.text.trim(),
        'withdraw_account_id': withdrawAccount.value!.id.toString(),
        if (passcode != null && passcode.isNotEmpty)
          'passcode': PasscodeHelper.normalize(passcode),
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.withdrawEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        successWithdrawData.value = response.data!['data'];
        currentStep.value = 2;
        AppEventBus.emit(BalanceChangedEvent(sourceModule: 'withdraw'));
        ToastHelper().showSuccessToast(response.data!["message"]);
      } else if (response.status == Status.error) {
        final msg = response.message?.toLowerCase() ?? '';
        if (msg.contains('timed out') || msg.contains('timeout')) {
          throw Exception(response.message ?? 'Request timed out');
        }
        if (PasscodeHelper.isPasscodeRequired(
          response.message,
          wasPasscodeProvided: wasPasscodeProvided,
        )) {
          isWithdrawLoading.value = false;
          final dynamic verified = await Get.bottomSheet<dynamic>(
            const VerifyPasscodeBottomSheet(),
          );
          if (verified != null && verified.toString().isNotEmpty) {
            await submitWithdraw(passcode: verified.toString());
            return;
          }
        } else if (PasscodeHelper.isPasscodeInvalid(response.message)) {
          ToastHelper().showErrorToast(
            l10nPickAuto(
              en: 'The transaction passcode entered is incorrect.',
              fa: 'رمز عبور معامله وارد شده نادرست است.',
              ar: 'رمز مرور المعاملة المدخل غير صحيح.',
              zh: '输入的交易密码不正确。',
            ),
          );
        } else {
          ToastHelper().showErrorToast(
            response.message ?? localization.allControllerLoadError,
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitWithdraw() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      final errStr = e.toString().toLowerCase();
      final isTimeout =
          NetworkErrorHelper.isTimeout(e) ||
          errStr.contains('timed out') ||
          errStr.contains('timeout') ||
          errStr.contains('connectiontimeout') ||
          errStr.contains('receivetimeout') ||
          (e is DioException &&
              (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.sendTimeout ||
                  e.type == DioExceptionType.receiveTimeout));
      if (isTimeout) {
        ToastHelper().showWarningToast(
          l10nPickAuto(
            en: 'Request timed out on response. Please verify in Transaction History before trying again to prevent duplicate withdrawal.',
            fa: 'زمان پاسخ درخواست به پایان رسید. لطفاً قبل از تلاش مجدد، تاریخچه تراکنش‌ها را بررسی کنید تا از برداشت تکراری جلوگیری شود.',
            ar: 'انتهت مهلة استجابة الطلب. يرجى التحقق من سجل المعاملات قبل المحاولة مرة أخرى لمنع تكرار السحب.',
            zh: '请求响应超时。请在重试前在交易记录中核实，以避免重复提现。',
          ),
        );
        return;
      }
      if (PasscodeHelper.isPasscodeRequired(
        e,
        wasPasscodeProvided: wasPasscodeProvided,
      )) {
        isWithdrawLoading.value = false;
        final dynamic verified = await Get.bottomSheet<dynamic>(
          const VerifyPasscodeBottomSheet(),
        );
        if (verified != null && verified.toString().isNotEmpty) {
          await submitWithdraw(passcode: verified.toString());
          return;
        }
      } else if (PasscodeHelper.isPasscodeInvalid(e)) {
        ToastHelper().showErrorToast(
          l10nPickAuto(
            en: 'The transaction passcode entered is incorrect.',
            fa: 'رمز عبور معامله وارد شده نادرست است.',
            ar: 'رمز مرور المعاملة المدخل غير صحيح.',
            zh: '输入的交易密码不正确。',
          ),
        );
      } else {
        ToastHelper().showErrorToast(localization.allControllerLoadError);
      }
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

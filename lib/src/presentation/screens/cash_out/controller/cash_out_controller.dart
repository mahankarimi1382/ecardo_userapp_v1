import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
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
import 'package:ecardo_user/src/presentation/screens/cash_out/model/cash_out_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/model/cash_out_wallet_model.dart';

class CashOutController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCashOutLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxBool isCashoutConfigLoading = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool chargeLoadFailed = false.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<CashOutConfigModel> cashOutConfig = CashOutConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successCashOutData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  AppLocalizations? get localization =>
      Get.context != null ? AppLocalizations.of(Get.context!) : null;

  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> cashOutWalletsList = <Wallets>[].obs;

  final RxBool isAgentAidFocused = false.obs;
  final FocusNode agentAidFocusNode = FocusNode();
  final agentAidController = TextEditingController();

  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    agentAidFocusNode.addListener(_handleAgentAidFocusChange);
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void onClose() {
    agentAidFocusNode.removeListener(_handleAgentAidFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    agentAidFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  void _handleAgentAidFocusChange() {
    isAgentAidFocused.value = agentAidFocusNode.hasFocus;
  }

  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  void setAmountPercentage(double fraction) {
    final w = wallet.value;
    if (w == null) return;
    final balance = double.tryParse(w.balance ?? '0') ?? 0.0;
    final effectiveBalance = balance > 0
        ? balance
        : (double.tryParse(w.cashoutLimit?.max ?? '1000') ?? 1000.0);
    final calculated = effectiveBalance * fraction;
    final isCrypto = w.isCrypto ?? false;
    final decimals = isCrypto ? 6 : 2;
    amountController.text = calculated.toStringAsFixed(decimals);
    _calculateCharge();
  }

  Future<void> nextStepWithValidation() async {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      await fetchCashOutConfig();
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
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
    } finally {}
  }

  Future<void> fetchCashOutConfig() async {
    isCashoutConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.cashOutConfigEndpoint,
      );

      if (response.status == Status.completed) {
        cashOutConfig.value = CashOutConfigModel.fromJson(response.data!);
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCashOutConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
    } finally {
      isCashoutConfigLoading.value = false;
    }
  }

  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr = cashOutConfig.value.data!.settings!.charge ?? "0";
    final userChargeType =
        cashOutConfig.value.data!.settings!.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
      totalAmount.value = amount + calculatedCharge;
    } else {
      await getChargeConverter();
    }

    isCashoutConfigLoading.value = false;
  }

  Future<void> getChargeConverter() async {
    chargeLoadFailed.value = false;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: cashOutConfig.value.data!.settings!.charge!,
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
            ((double.tryParse(amountController.text) ?? 0.0) + charge.value);
      } else {
        chargeLoadFailed.value = true;
      }
    } catch (e, stackTrace) {
      chargeLoadFailed.value = true;
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
    } finally {}
  }

  bool validateAmountStep() {
    if (chargeLoadFailed.value) {
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
      return false;
    }
    final walletData = wallet.value;
    if (walletData == null || (walletData.name ?? '').isEmpty) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationSelectWallet ?? 'Please select a wallet',
      );
      return false;
    }

    if (agentAidController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationEnterAgentAid ??
            'Please enter agent AID',
      );
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationEnterAmount ?? 'Please enter amount',
      );
      return false;
    }

    final currentWallet = wallet.value;
    if (currentWallet == null) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationSelectWallet ?? 'Please select a wallet',
      );
      return false;
    }

    final walletCode = currentWallet.code ?? '';
    final isCrypto = currentWallet.isCrypto ?? false;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode:
          Get.find<SettingsService>().getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          Get.find<SettingsService>().getSetting("site_currency_decimals") ??
          '2',
      isCrypto: isCrypto,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(currentWallet.cashoutLimit?.min ?? '') ?? 0.0;
    final double max =
        double.tryParse(currentWallet.cashoutLimit?.max ?? '') ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationAmountMinimum(
              min.toStringAsFixed(calculateDecimals),
              walletCode,
            ) ??
            'Minimum cash out amount is ${min.toStringAsFixed(calculateDecimals)} $walletCode',
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization?.cashOutValidationAmountMaximum(
              max.toStringAsFixed(calculateDecimals),
              walletCode,
            ) ??
            'Maximum cash out amount is ${max.toStringAsFixed(calculateDecimals)} $walletCode',
      );
      return false;
    }

    final double availableBalance =
        double.tryParse(currentWallet.balance ?? '') ?? 0.0;
    final double totalRequired = enteredAmount + charge.value;
    if (totalRequired > availableBalance) {
      ToastHelper().showErrorToast(
        localization?.exchangeValidationInsufficientBalance(
              availableBalance.toStringAsFixed(calculateDecimals),
              walletCode,
            ) ??
            'Insufficient balance: ${availableBalance.toStringAsFixed(calculateDecimals)} $walletCode',
      );
      return false;
    }

    return true;
  }

  Future<void> fetchWallets() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?cashout",
      );

      if (response.status == Status.completed) {
        final cashOutWalletsModel = CashOutWalletModel.fromJson(response.data!);
        cashOutWalletsList.assignAll(cashOutWalletsModel.data?.wallets ?? []);

        if (cashOutWalletsList.isNotEmpty) {
          wallet.value = cashOutWalletsList.first;
        } else {
          wallet.value = null;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cashOut({String? passcode}) async {
    if (isCashOutLoading.isTrue) return;
    isCashOutLoading.value = true;
    final wasPasscodeProvided = passcode != null && passcode.isNotEmpty;

    final Map<String, dynamic> requestBody = {
      'agent_number': agentAidController.text.trim(),
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
        endpoint: ApiPath.userCashOutEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successCashOutData.value = response.data!['data'];
        currentStep.value = 2;
      } else if (response.status == Status.error) {
        final msg = response.message?.toLowerCase() ?? '';
        if (msg.contains('timed out') || msg.contains('timeout')) {
          throw Exception(response.message ?? 'Request timed out');
        }
        if (PasscodeHelper.isPasscodeRequired(
          response.message,
          wasPasscodeProvided: wasPasscodeProvided,
        )) {
          isCashOutLoading.value = false;
          final dynamic verified = await Get.bottomSheet<dynamic>(
            const VerifyPasscodeBottomSheet(),
          );
          if (verified != null && verified.toString().isNotEmpty) {
            await cashOut(passcode: verified.toString());
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
            response.message ??
                localization?.allControllerLoadError ??
                'An error occurred while loading data.',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ cashOut() error: $e');
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
            en: 'Request timed out on response. Please verify in Transaction History before trying again to prevent duplicate cash out.',
            fa: 'زمان پاسخ درخواست به پایان رسید. لطفاً قبل از تلاش مجدد، وضعیت تراکنش را بررسی کنید تا از برداشت تکراری جلوگیری شود.',
            ar: 'انتهت مهلة استجابة الطلب. يرجى التحقق من حالة المعاملة قبل إعادة الإرسال لتجنب تكرار السحب.',
            zh: '请求响应超时。请在重新提交前核实交易状态，以避免重复提现。',
          ),
        );
      } else if (PasscodeHelper.isPasscodeRequired(
        e,
        wasPasscodeProvided: wasPasscodeProvided,
      )) {
        isCashOutLoading.value = false;
        final dynamic verified = await Get.bottomSheet<dynamic>(
          const VerifyPasscodeBottomSheet(),
        );
        if (verified != null && verified.toString().isNotEmpty) {
          await cashOut(passcode: verified.toString());
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
        ToastHelper().showErrorToast(
          localization?.allControllerLoadError ??
              'An error occurred while loading data.',
        );
      }
    } finally {
      isCashOutLoading.value = false;
    }
  }

  Future<void> fetchBeneficiary() async {
    isBeneficiaryLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.beneficiaryEndpoint}?type=agent",
      );

      if (response.status == Status.completed) {
        beneficiaryModel.value = BeneficiaryModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      isBeneficiaryLoading.value = false;
      debugPrint('❌ fetchBeneficiary() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ??
            'An error occurred while loading data.',
      );
    } finally {
      isBeneficiaryLoading.value = false;
    }
  }

  void clearFields() {
    converterModel.value = ConverterModel();
    agentAidController.clear();
    amountController.clear();
    totalAmount.value = 0.0;
    charge.value = 0.0;
  }
}

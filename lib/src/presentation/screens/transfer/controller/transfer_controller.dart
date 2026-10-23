import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';

class TransferController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
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
  AppLocalizations get localization {
    final ctx = Get.context;
    if (ctx != null) {
      final loc = AppLocalizations.of(ctx);
      if (loc != null) return loc;
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> transferWalletsList = <Wallets>[].obs;

  final Rxn<Map<String, dynamic>> lookedUpRecipient =
      Rxn<Map<String, dynamic>>();
  final RxBool isLookingUpRecipient = false.obs;
  Timer? _recipientLookupDebounce;
  bool _isAdvancingStep = false;

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
    recipientUidController.addListener(_handleRecipientUidChange);
  }

  @override
  void onClose() {
    _recipientLookupDebounce?.cancel();
    recipientUidController.removeListener(_handleRecipientUidChange);
    recipientUidFocusNode.removeListener(_handleRecipientUidFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    amountController.removeListener(_handleAmountTextChange);
    recipientUidFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  void _handleRecipientUidChange() {
    _recipientLookupDebounce?.cancel();
    _recipientLookupDebounce = Timer(
      const Duration(milliseconds: 400),
      () => lookupRecipient(recipientUidController.text.trim()),
    );
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
    if (_isAdvancingStep || isTransferConfigLoading.isTrue) return;
    _isAdvancingStep = true;
    try {
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
    } finally {
      _isAdvancingStep = false;
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
    amountController.text = decimals == 0
        ? targetAmount.round().toString()
        : targetAmount.toStringAsFixed(decimals);
    calculateLiveCharge();
  }

  Future<void> lookupRecipient(String accountNumber) async {
    final cleanAccount = accountNumber.trim();
    if (cleanAccount.length < 3) {
      lookedUpRecipient.value = null;
      isLookingUpRecipient.value = false;
      return;
    }

    isLookingUpRecipient.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.userTransferEndpoint}/lookup-recipient?account_number=$cleanAccount',
      );

      if (response.status == Status.completed && response.data != null) {
        final dynamic data = response.data?['data'];
        if (data is Map<String, dynamic>) {
          lookedUpRecipient.value = data;
        } else if (data is Map) {
          lookedUpRecipient.value = Map<String, dynamic>.from(data);
        } else {
          lookedUpRecipient.value = null;
        }
      } else {
        lookedUpRecipient.value = null;
      }
    } catch (e) {
      lookedUpRecipient.value = null;
    } finally {
      isLookingUpRecipient.value = false;
    }
  }

  Beneficiaries? findBeneficiaryByAccount(String accountNumber) {
    final cleanAccount = accountNumber.trim();
    if (cleanAccount.isEmpty) return null;
    final list = beneficiaryModel.value.data?.beneficiaries;
    if (list != null && list.isNotEmpty) {
      try {
        return list.firstWhere(
          (b) => (b.accountNumber?.trim() == cleanAccount),
        );
      } catch (_) {}
    }

    final lookedUp = lookedUpRecipient.value;
    if (lookedUp != null) {
      final lookedUpAccount =
          (lookedUp['account_number'] ??
                  lookedUp['accountNumber'] ??
                  lookedUp['uid'])
              ?.toString()
              .trim();

      final isMatch =
          (lookedUpAccount != null && lookedUpAccount == cleanAccount) ||
          (lookedUpAccount == null &&
              recipientUidController.text.trim() == cleanAccount) ||
          recipientUidController.text.trim() == cleanAccount;

      if (isMatch) {
        final name =
            lookedUp['name']?.toString() ??
            lookedUp['nickname']?.toString() ??
            cleanAccount;
        final avatar = lookedUp['avatar']?.toString();
        return Beneficiaries(
          accountNumber: cleanAccount,
          nickname: name,
          receiver: Receiver(name: name, avatar: avatar),
        );
      }
    }

    return null;
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
      calculatedCharge = MoneyMathHelper.calculatePercentCharge(
        amount,
        percent,
      );
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

    final currentWallet = wallet.value;
    if (currentWallet == null) {
      ToastHelper().showErrorToast(localization.transferValidationSelectWallet);
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
        double.tryParse(currentWallet.transferLimit?.min ?? '') ?? 0.0;
    final double max =
        double.tryParse(currentWallet.transferLimit?.max ?? '') ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.transferValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          walletCode,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.transferValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          walletCode,
        ),
      );
      return false;
    }

    final double availableBalance =
        double.tryParse(currentWallet.balance ?? '') ?? 0.0;
    final double totalRequired = enteredAmount + charge.value;
    if (totalRequired > availableBalance) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationInsufficientBalance(
          availableBalance.toStringAsFixed(calculateDecimals),
          walletCode,
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
    final wasPasscodeProvided = passcode != null && passcode.isNotEmpty;

    final currentWallet = wallet.value;
    final Map<String, dynamic> requestBody = {
      'account_number': recipientUidController.text.trim(),
      'amount': amountController.text.trim(),
      'wallet_id': currentWallet?.isDefault == true
          ? "default"
          : (currentWallet?.id?.toString() ?? "default"),
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
      } else if (response.status == Status.error) {
        final msg = response.message?.toLowerCase() ?? '';
        if (msg.contains('timed out') || msg.contains('timeout')) {
          throw Exception(response.message ?? 'Request timed out');
        }
        if (PasscodeHelper.isPasscodeRequired(
          response.message,
          wasPasscodeProvided: wasPasscodeProvided,
        )) {
          isTransferAmountLoading.value = false;
          final dynamic verified = await Get.bottomSheet<dynamic>(
            const VerifyPasscodeBottomSheet(),
          );
          if (verified != null && verified.toString().isNotEmpty) {
            await transferAmount(passcode: verified.toString());
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
      debugPrint('❌ transferAmount() error: $e');
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
            en: 'Request timed out on response. Please verify in Transaction History before trying again to prevent duplicate transfer.',
            fa: 'زمان پاسخ درخواست به پایان رسید. لطفاً قبل از تلاش مجدد، تاریخچه تراکنش‌ها را بررسی کنید تا از انتقال تکراری جلوگیری شود.',
            ar: 'انتهت مهلة استجابة الطلب. يرجى التحقق من سجل المعاملات قبل المحاولة مرة أخرى لمنع تكرار التحويل.',
            zh: '请求响应超时。请在重试前在交易记录中核实，以避免重复转账。',
          ),
        );
      } else if (PasscodeHelper.isPasscodeRequired(
        e,
        wasPasscodeProvided: wasPasscodeProvided,
      )) {
        isTransferAmountLoading.value = false;
        final dynamic verified = await Get.bottomSheet<dynamic>(
          const VerifyPasscodeBottomSheet(),
        );
        if (verified != null && verified.toString().isNotEmpty) {
          await transferAmount(passcode: verified.toString());
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
      isTransferAmountLoading.value = false;
    }
  }

  Future<void> fetchTransferWallets() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
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
          // Prioritize national default currency wallet (e.g. IRT for Iran, CNY for China),
          // fallback to first available. The user can switch to any wallet at any time.
          final nationalWallet = transferWalletsList.firstWhereOrNull(
            (w) => w.isNationalDefault == true,
          );
          wallet.value = nationalWallet ?? transferWalletsList.first;
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
    lookedUpRecipient.value = null;
    hasError.value = false;
    errorMessage.value = '';
  }
}

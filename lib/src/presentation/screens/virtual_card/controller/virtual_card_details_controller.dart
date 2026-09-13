import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_card_details_bsi_card_provider_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/widgets/web_view_screen.dart';

class VirtualCardDetailsController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isCardBalanceTopUpLoading = false.obs;
  final RxBool isUpdateCardStatusLoading = false.obs;
  final RxBool showAccountNumber = false.obs;
  final localization = AppLocalizations.of(Get.context!);

  // Virtual Card Details Model
  final Rx<VirtualCardDetailsModel> virtualCardDetailsModel =
      VirtualCardDetailsModel().obs;
  final Rx<VirtualCardDetailsBsiCardProviderModel>
  virtualCardDetailsBsiCardProviderModel =
      VirtualCardDetailsBsiCardProviderModel().obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final FocusNode amountFocusNode = FocusNode();
  final RxString amount = ''.obs;
  final amountController = TextEditingController();
  final RxList<Wallets> irrWallets = <Wallets>[].obs;

  // Review Amounts
  final RxDouble baseAmount = 0.0.obs;
  final RxDouble calculatedCharge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    amountController.addListener(() {
      amount.value = amountController.text;
    });
  }

  @override
  void onClose() {
    super.onClose();
    amountFocusNode.dispose();
    amountController.dispose();
  }

  // Fetch Virtual Card Details
  Future<void> fetchVirtualCardDetails({required String cardId}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getVirtualCardsEndpoint}/$cardId",
      );
      if (response.status == Status.completed) {
        virtualCardDetailsModel.value = VirtualCardDetailsModel();
        virtualCardDetailsModel.value = VirtualCardDetailsModel.fromJson(
          response.data!,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchVirtualCardDetails() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Virtual Card Details Bsi Card Provider
  Future<void> fetchVirtualCardDetailsBsiCardProvider({
    required String cardId,
  }) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getVirtualCardBsiProviderDetailsEndpoint}/$cardId",
      );
      if (response.status == Status.completed) {
        virtualCardDetailsBsiCardProviderModel.value =
            VirtualCardDetailsBsiCardProviderModel();
        virtualCardDetailsBsiCardProviderModel.value =
            VirtualCardDetailsBsiCardProviderModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchVirtualCardDetailsBsiCardProvider() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Card Update Status
  Future<void> cardUpdateStatus({required String cardId}) async {
    isUpdateCardStatusLoading.value = true;
    try {
      final card = virtualCardDetailsModel.value.data;
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.normalizeActionEndpoint(
          card?.actions?.statusEndpoint,
          "${ApiPath.postUpdateStatusEndpoint}/${card?.cardId ?? cardId}",
        ),
        data: null,
      );
      if (response.status == Status.completed) {
        final responseData = response.data!['data'];
        final redirectUrl = responseData is Map
            ? responseData['redirect_url']?.toString()
            : null;
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          await Get.to<Map<String, dynamic>>(
            () => WebViewScreen(paymentUrl: redirectUrl),
          );
        }
        ToastHelper().showSuccessToast(response.data!["message"]);
        await fetchVirtualCardDetails(cardId: card?.id?.toString() ?? cardId);
        Get.find<VirtualCardController>().fetchVirtualCards();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ cardUpdateStatus() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isUpdateCardStatusLoading.value = false;
    }
  }

  // Card Balance Top Up
  Future<void> cardBalanceTopUp({required String cardId}) async {
    if (!validateAmountStep()) {
      return;
    }

    isCardBalanceTopUpLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "amount": amountController.text,
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: "${ApiPath.postCardBalanceTopUpEndpoint}/$cardId",
        data: requestBody,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        amountController.clear();
        Get.back();
        await fetchVirtualCardDetails(cardId: cardId);
        Get.find<VirtualCardController>().fetchVirtualCards();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ cardBalanceTopUp() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isCardBalanceTopUpLoading.value = false;
    }
  }

  Future<void> fetchIrrWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );
      if (response.status != Status.completed) return;

      final model = WalletsModel.fromJson(response.data!);
      irrWallets.assignAll(
        (model.data?.wallets ?? []).where(
          (wallet) => wallet.code?.toUpperCase() == 'IRR',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ fetchIrrWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  Future<void> cardBalanceTopUpFromContract({
    required String cardId,
    required String fundingSource,
    int? walletId,
    int? gatewayMethodId,
  }) async {
    final card = virtualCardDetailsModel.value.data;
    final funding = card?.funding;
    if (funding == null) {
      await cardBalanceTopUp(cardId: cardId);
      return;
    }

    final amount = int.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountGreaterThanZero,
      );
      return;
    }
    if (funding.minimumTopup > 0 && amount < funding.minimumTopup) {
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.vcMinTopup(funding.minimumTopup, card?.currency ?? ''),
      );
      return;
    }
    if (funding.maximumTopup > 0 && amount > funding.maximumTopup) {
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.vcMaxTopup(funding.maximumTopup, card?.currency ?? ''),
      );
      return;
    }
    if (fundingSource == 'irr_wallet' && walletId == null) {
      ToastHelper().showErrorToast(AppLocalizations.of(Get.context!)!.vcSelectIrrWallet);
      return;
    }
    if (fundingSource == 'gateway' && gatewayMethodId == null) {
      ToastHelper().showErrorToast(AppLocalizations.of(Get.context!)!.vcSelectGateway);
      return;
    }

    isCardBalanceTopUpLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.normalizeActionEndpoint(
          card?.actions?.topupEndpoint,
          ApiPath.postIrrCardTopUpEndpoint(cardId: cardId),
        ),
        data: {
          'funding_source': fundingSource,
          'wallet_id': fundingSource == 'irr_wallet' ? walletId : null,
          'gateway_method_id': fundingSource == 'gateway'
              ? gatewayMethodId
              : null,
          'amount': amount,
        },
      );
      if (response.status != Status.completed) return;

      final responseData = response.data!['data'];
      final redirectUrl = responseData is Map
          ? responseData['redirect_url']?.toString()
          : null;
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        await Get.to<Map<String, dynamic>>(
          () => WebViewScreen(paymentUrl: redirectUrl),
        );
      }

      final orderData = responseData is Map ? responseData['order'] : null;
      final order = orderData is Map
          ? orderData.cast<String, dynamic>()
          : <String, dynamic>{};
      final status = order['status']?.toString().toLowerCase() ?? '';
      final failureMessage = order['failure_message']?.toString().trim() ?? '';
      if (status == 'provisioning_failed' ||
          status == 'failed' ||
          status == 'cancelled') {
        ToastHelper().showErrorToast(
          failureMessage.isNotEmpty
              ? failureMessage
              : AppLocalizations.of(Get.context!)!.vcTopupNotCompleted,
        );
        return;
      }

      ToastHelper().showSuccessToast(
        response.data!['message']?.toString() ?? AppLocalizations.of(Get.context!)!.vcTopupSubmitted,
      );
      amountController.clear();
      Get.back();
      await fetchVirtualCardDetails(cardId: cardId);
      await Get.find<VirtualCardController>().fetchVirtualCards();
    } catch (e, stackTrace) {
      debugPrint('❌ cardBalanceTopUpFromContract() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isCardBalanceTopUpLoading.value = false;
    }
  }

  // Review Calculate Function
  void reviewCalculate() {
    final SettingsService settingsService = Get.find();
    baseAmount.value = double.tryParse(amountController.text) ?? 0.0;

    // PAYMENT-FIX (P-3): `getSetting("card_topup_charge")!` and
    // `double.tryParse(...)!` crashed when the setting was absent or not a
    // number (e.g. settings not loaded yet). Safe-parse with a 0-charge
    // fallback, matching the hardened validateAmountStep above.
    // TODO(lead): confirm whether the backend guarantees the
    // card_topup_charge / card_topup_charge_type settings; if so, surface a
    // config error instead of silently computing a 0 charge.
    final double? chargeSetting = double.tryParse(
      settingsService.getSetting("card_topup_charge") ?? '',
    );

    if (settingsService.getSetting("card_topup_charge_type") == 'percentage') {
      calculatedCharge.value =
          (baseAmount.value * (chargeSetting ?? 0.0) / 100);
    } else if (settingsService.getSetting("card_topup_charge_type") ==
        'fixed') {
      calculatedCharge.value = chargeSetting ?? 0.0;
    } else {
      calculatedCharge.value = 0.0;
    }

    totalAmount.value = baseAmount.value + calculatedCharge.value;
  }

  void reviewContractTopUp({
    required String fundingSource,
    int? gatewayMethodId,
  }) {
    final rawAmount = amountController.text.replaceAll(',', '');
    baseAmount.value = double.tryParse(rawAmount) ?? 0;
    final funding = virtualCardDetailsModel.value.data?.funding;

    if (funding == null) {
      reviewCalculate();
      return;
    }

    final productCharge = _calculateCharge(
      baseAmount.value,
      funding.topupFeeType,
      funding.topupFee,
    );
    final gateway = fundingSource == 'gateway'
        ? funding.gateways.firstWhereOrNull(
            (item) => item.id == gatewayMethodId,
          )
        : null;
    final gatewayCharge = gateway == null
        ? 0
        : _calculateCharge(
            baseAmount.value + productCharge,
            gateway.chargeType,
            gateway.charge,
          );

    calculatedCharge.value = productCharge + gatewayCharge;
    totalAmount.value = baseAmount.value + calculatedCharge.value;
  }

  static double _calculateCharge(
    double amount,
    String? type,
    num charge,
  ) {
    if (type == 'percentage') {
      return amount * charge.toDouble() / 100;
    }
    if (type == 'fixed') {
      return charge.toDouble();
    }
    return 0;
  }

  // Validate Amount Step
  bool validateAmountStep() {
    final SettingsService settingsService = Get.find();
    // v1.0.24: settings can be missing or unparseable (unloaded splash / bad
    // server value) — safe-parse with sane defaults instead of crashing on
    // `double.tryParse(...)!` / `int.parse(...)`.
    final int decimals = int.tryParse(
          settingsService.getSetting("site_currency_decimals") ?? '',
        ) ??
        2;
    final double minimumTopup = double.tryParse(
          settingsService.getSetting("min_card_topup") ?? '',
        ) ??
        1.0;
    final double maximumTopup = double.tryParse(
          settingsService.getSetting("max_card_topup") ?? '',
        ) ??
        0.0;

    // Validate Amount
    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.cardDetailsEnterAmount);
      return false;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountGreaterThanZero,
      );
      return false;
    }

    if (minimumTopup > 0 && amount < minimumTopup) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountMinimumLimit(
          minimumTopup.toStringAsFixed(decimals),
        ),
      );
      return false;
    }

    if (maximumTopup > 0 && amount > maximumTopup) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountMaximumLimit(
          maximumTopup.toStringAsFixed(decimals),
        ),
      );
      return false;
    }

    // v1.0.24: client-side balance guard — the main wallet must cover the
    // top-up amount before we hit the API (mirrors exchange_controller).
    final double walletBalance = double.tryParse(
          Get.find<HomeController>().userModel.value.data?.balance ?? '',
        ) ??
        0.0;
    if (amount > walletBalance) {
      ToastHelper().showErrorToast(
        localization!.exchangeValidationInsufficientBalance(
          walletBalance.toStringAsFixed(decimals),
          settingsService.getSetting("site_currency") ?? 'USD',
        ),
      );
      return false;
    }

    return true;
  }
}

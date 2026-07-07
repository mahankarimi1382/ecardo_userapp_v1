import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_card_details_bsi_card_provider_model.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';

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
      final provider =
          virtualCardDetailsModel.value.data?.provider?.toLowerCase() ??
          virtualCardDetailsBsiCardProviderModel.value.data?.data?.brand
              ?.toLowerCase() ??
          '';
      final response = await Get.find<NetworkService>().post(
        endpoint: "${ApiPath.postUpdateStatusEndpoint}/$cardId",
        data: null,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        if (provider == "bsicards" || provider == "digital") {
          await fetchVirtualCardDetailsBsiCardProvider(cardId: cardId);
        } else {
          await fetchVirtualCardDetails(cardId: cardId);
        }
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

  // Review Calculate Function
  void reviewCalculate() {
    final SettingsService settingsService = Get.find();
    baseAmount.value = double.tryParse(amountController.text) ?? 0.0;

    if (settingsService.getSetting("card_topup_charge_type") == 'percentage') {
      calculatedCharge.value =
          (baseAmount.value *
          double.tryParse(settingsService.getSetting("card_topup_charge")!)! /
          100);
    } else if (settingsService.getSetting("card_topup_charge_type") ==
        'fixed') {
      calculatedCharge.value = double.tryParse(
        settingsService.getSetting("card_topup_charge")!,
      )!;
    } else {
      calculatedCharge.value = 0.0;
    }

    totalAmount.value = baseAmount.value + calculatedCharge.value;
  }

  // Validate Amount Step
  bool validateAmountStep() {
    final SettingsService settingsService = Get.find();
    final String decimals = settingsService.getSetting(
      "site_currency_decimals",
    )!;
    final String minimumTopup = settingsService.getSetting("min_card_topup")!;
    final String maximumTopup = settingsService.getSetting("max_card_topup")!;

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

    if (double.tryParse(minimumTopup)! > 0 &&
        amount < double.tryParse(minimumTopup)!) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountMinimumLimit(
          double.tryParse(minimumTopup)!.toStringAsFixed(int.parse(decimals)),
        ),
      );
      return false;
    }

    if (double.tryParse(maximumTopup)! > 0 &&
        amount > double.tryParse(maximumTopup)!) {
      ToastHelper().showErrorToast(
        localization!.cardDetailsAmountMaximumLimit(
          double.tryParse(maximumTopup)!.toStringAsFixed(int.parse(decimals)),
        ),
      );
      return false;
    }

    return true;
  }
}

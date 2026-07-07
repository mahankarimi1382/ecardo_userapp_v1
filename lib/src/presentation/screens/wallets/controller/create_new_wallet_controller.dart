import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class CreateNewWalletController extends GetxController {
  // Global Variables
  final RxBool isLoading = true.obs;
  final RxBool isCreateWalletLoading = false.obs;
  final RxList<Wallets> walletsList = <Wallets>[].obs;

  // Currency
  final RxBool isCurrencyFocused = false.obs;
  final FocusNode currencyFocusNode = FocusNode();
  final currencyController = TextEditingController();
  final Rxn<CurrenciesData> currency = Rxn<CurrenciesData>();
  final RxList<CurrenciesData> currenciesList = <CurrenciesData>[].obs;

  @override
  void onInit() {
    super.onInit();
    currencyController.clear();
    loadData();
    currencyFocusNode.addListener(_handleCurrencyFocusChange);
  }

  Future<void> loadData() async {
    isLoading.value = true;

    await fetchWallets();
    await fetchCurrencies();

    isLoading.value = false;
  }

  @override
  void onClose() {
    currencyFocusNode.removeListener(_handleCurrencyFocusChange);
    currencyFocusNode.dispose();
    super.onClose();
  }

  // Currency focus change handler
  void _handleCurrencyFocusChange() {
    isCurrencyFocused.value = currencyFocusNode.hasFocus;
  }

  // Fetch Wallets From API
  Future<void> fetchWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Fetch the list of currencies
  Future<void> fetchCurrencies() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.currenciesEndpoint,
      );
      if (response.status == Status.completed) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);

        currenciesList.clear();

        final existingCurrencies = walletsList.map((w) => w.code);
        currenciesList.assignAll(
          currenciesModel.data!.where(
            (currency) => !existingCurrencies.contains(currency.code),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCurrencies() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Create a new wallet
  Future<void> createWallet() async {
    isCreateWalletLoading.value = true;
    try {
      final Map<String, String> requestBody = {
        "currency_id": currency.value!.id.toString(),
      };
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.walletsEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        clearFields();
        Get.back();
        Get.find<WalletsController>().fetchWallets();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ createWallet() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCreateWalletLoading.value = false;
    }
  }

  void clearFields() {
    currencyController.clear();
    currenciesList.clear();
    walletsList.clear();
  }
}

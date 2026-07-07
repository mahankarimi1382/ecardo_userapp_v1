import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/model/payment_links_history_model.dart';

import '../../../../common/services/settings_service.dart';
import '../../wallets/model/currencies_model.dart';

class PaymentLinksController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isCreatePaymentLinkLoading = false.obs;
  final RxBool isListLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isListLoadingMore = false.obs;
  final Rx<PaymentLinksHistoryModel> paymentLinksHistoryModel =
      PaymentLinksHistoryModel().obs;
  final RxList<PaymentLinks> allPaymentLinks = <PaymentLinks>[].obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final FocusNode amountFocusNode = FocusNode();
  final amountController = TextEditingController();

  // Currency
  final RxBool isCurrencyFocused = false.obs;
  final FocusNode currencyFocusNode = FocusNode();
  final currencyController = TextEditingController();
  final Rxn<CurrenciesData> currency = Rxn<CurrenciesData>();
  final RxList<CurrenciesData> currenciesList = <CurrenciesData>[].obs;

  // Amount
  final RxBool isNoteFocused = false.obs;
  final FocusNode noteFocusNode = FocusNode();
  final noteController = TextEditingController();

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxBool hasMoreData = true.obs;

  // Payment Links Filter
  final RxBool isPaymentLinkNumberFocused = false.obs;
  final FocusNode paymentLinkNumberFocusNode = FocusNode();
  final paymentLinkNumberController = TextEditingController();
  final RxString currentFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    paymentLinkNumberFocusNode.addListener(_handlePaymentLinkNumberFocusChange);
    amountFocusNode.addListener(_handlePaymentLinkAmountFocusChange);
    currencyFocusNode.addListener(_handlePaymentLinkCurrencyFocusChange);
    noteFocusNode.addListener(_handlePaymentLinkNoteFocusChange);
    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    allPaymentLinks.clear();
  }

  @override
  void onClose() {
    paymentLinkNumberFocusNode.removeListener(
      _handlePaymentLinkNumberFocusChange,
    );
    paymentLinkNumberFocusNode.dispose();
    paymentLinkNumberController.dispose();
    amountFocusNode.removeListener(_handlePaymentLinkAmountFocusChange);
    amountFocusNode.dispose();
    amountController.dispose();
    currencyFocusNode.removeListener(_handlePaymentLinkCurrencyFocusChange);
    currencyFocusNode.dispose();
    currencyController.dispose();
    noteFocusNode.removeListener(_handlePaymentLinkNoteFocusChange);
    noteFocusNode.dispose();
    noteController.dispose();
    super.onClose();
  }

  // Payment Link Number focus change handler
  void _handlePaymentLinkNumberFocusChange() {
    isPaymentLinkNumberFocused.value = paymentLinkNumberFocusNode.hasFocus;
  }

  // Create Payment Link Amount focus change handler
  void _handlePaymentLinkAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  // Create Payment Link Currency focus change handler
  void _handlePaymentLinkCurrencyFocusChange() {
    isCurrencyFocused.value = currencyFocusNode.hasFocus;
  }

  // Create Payment Link Note focus change handler
  void _handlePaymentLinkNoteFocusChange() {
    isNoteFocused.value = noteFocusNode.hasFocus;
  }

  // Apply filter
  void applyFilter() {
    currentFilter.value = paymentLinkNumberController.text.trim();
    fetchPaymentLinksHistory(isRefresh: true);
    paymentLinkNumberController.clear();
    currentFilter.value = '';
  }

  // Clear filter
  void clearFilter() {
    paymentLinkNumberController.clear();
    currentFilter.value = '';
    fetchPaymentLinksHistory(isRefresh: true);
  }

  // Build query parameters
  String _buildQueryParameters() {
    List<String> params = [
      'page=${currentPage.value}',
      'per_page=${perPage.value}',
    ];

    if (currentFilter.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(currentFilter.value)}');
    }

    return params.join('&');
  }

  // Fetch Payment Link
  Future<void> fetchPaymentLinksHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      resetPagination();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (currentPage.value == 1) {
      isListLoading.value = true;
    } else {
      isListLoadingMore.value = true;
    }

    try {
      final queryParams = _buildQueryParameters();
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.paymentLinksEndpoint}?$queryParams",
      );

      if (response.status == Status.completed) {
        final newPaymentLinksHistoryModel = PaymentLinksHistoryModel.fromJson(
          response.data!,
        );
        final newPaymentLinksHistory =
            newPaymentLinksHistoryModel.data?.paymentLinks ?? [];

        if (isRefresh) {
          allPaymentLinks.clear();
        }
        allPaymentLinks.addAll(newPaymentLinksHistory);
        paymentLinksHistoryModel.value = newPaymentLinksHistoryModel;

        if (newPaymentLinksHistory.length < perPage.value) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchPaymentLinks() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isListLoading.value = false;
      isListLoadingMore.value = false;
    }
  }

  // Load more Payment History History
  Future<void> loadMoreGiftHistory() async {
    if (!isListLoadingMore.value && hasMoreData.value) {
      await fetchPaymentLinksHistory();
    }
  }

  // Fetch the list of currencies
  Future<void> fetchCurrencies() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.currenciesEndpoint,
      );
      if (response.status == Status.completed) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);

        currenciesList.clear();
        currenciesList.assignAll(currenciesModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCurrencies() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createLink() async {
    isCreatePaymentLinkLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'amount': amountController.text,
      'currency':
          currencyController.text ==
              Get.find<SettingsService>().getSetting("site_currency").toString()
          ? currencyController.text
          : currency.value?.code,
      'note': noteController.text,
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.createPaymentLinksEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        selectedScreen.value = 0;
        clearFields();
        fetchPaymentLinksHistory(isRefresh: true);
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ createLink() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCreatePaymentLinkLoading.value = false;
    }
  }

  void clearFields() {
    isAmountFocused.value = false;
    amountController.clear();
    isCurrencyFocused.value = false;
    currencyController.clear();
    currency.value = null;
    currenciesList.clear();
    isNoteFocused.value = false;
    noteController.clear();
  }
}

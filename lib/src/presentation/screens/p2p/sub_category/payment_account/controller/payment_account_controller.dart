import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

import '../../../../../../network/api/api_path.dart';

class PaymentAccountController extends GetxController {
  final Rx<PaymentAccountResponseModel> paymentAccountResponse =
      PaymentAccountResponseModel().obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isAddMode = false.obs;
  final Rxn<PaymentAccount> selectedAccount = Rxn<PaymentAccount>();
  final RxList<CurrenciesData> fiatCurrencies = <CurrenciesData>[].obs;
  final RxnInt selectedCurrencyIdFilter = RxnInt();
  final RxString selectedCurrencyLabel = ''.obs;
  final RxBool isFiatCurrenciesLoading = false.obs;
  final TextEditingController currencyFilterController = TextEditingController();

  @override
  void onInit() {
    fetchPaymentAccounts();
    super.onInit();
  }

  @override
  void onClose() {
    currencyFilterController.dispose();
    super.onClose();
  }

  Future<void> fetchPaymentAccounts() async {
    isLoading.value = true;
    try {
      final currencyId = selectedCurrencyIdFilter.value;
      final response = await Get.find<NetworkService>().get(
        endpoint: currencyId == null
            ? ApiPath.paymentAccountEndpoint
            : '${ApiPath.paymentAccountEndpoint}?currency_id=$currencyId',
      );
      if (response.status == Status.completed) {
        paymentAccountResponse.value = PaymentAccountResponseModel.fromJson(
          response.data!,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchPaymentAccounts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFiatCurrencies() async {
    if (isFiatCurrenciesLoading.value) return;
    isFiatCurrenciesLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: '${ApiPath.currenciesEndpoint}?type=fiat',
      );
      if (response.status == Status.completed && response.data != null) {
        final model = CurrenciesModel.fromJson(response.data!);
        fiatCurrencies
          ..clear()
          ..assignAll(model.data ?? <CurrenciesData>[]);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchFiatCurrencies() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isFiatCurrenciesLoading.value = false;
    }
  }

  Future<void> applyCurrencyFilter(CurrenciesData? currency) async {
    if (currency?.id == null) return;
    selectedCurrencyIdFilter.value = currency!.id;
    selectedCurrencyLabel.value = currency.code ?? currency.name ?? '';
    currencyFilterController.text = selectedCurrencyLabel.value;
    await fetchPaymentAccounts();
  }

  Future<void> clearCurrencyFilter() async {
    selectedCurrencyIdFilter.value = null;
    selectedCurrencyLabel.value = '';
    currencyFilterController.clear();
    await fetchPaymentAccounts();
  }

  Future<void> deletePaymentAccount(String accountId) async {
    try {
      isLoading.value = true;
      final response = await Get.find<NetworkService>().delete(
        endpoint: '${ApiPath.paymentAccountEndpoint}/$accountId',
      );

      if (response.status == Status.completed) {
        await fetchPaymentAccounts();
        ToastHelper().showSuccessToast(response.data!['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('deletePaymentAccount() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onEditAccount(PaymentAccount account) {
    isAddMode.value = false;
    selectedAccount.value = account;
    isEditMode.value = true;
  }

  void onCancelEdit() {
    isEditMode.value = false;
    selectedAccount.value = null;
  }

  Future<void> onEditSuccess() async {
    onCancelEdit();
    await fetchPaymentAccounts();
  }

  void onAddPaymentMethod() {
    isEditMode.value = false;
    selectedAccount.value = null;
    isAddMode.value = true;
  }

  void onCancelAdd() {
    isAddMode.value = false;
  }

  Future<void> onAddSuccess() async {
    onCancelAdd();
    await fetchPaymentAccounts();
  }
}

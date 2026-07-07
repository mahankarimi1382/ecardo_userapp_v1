import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

import '../../../../../l10n/app_localizations.dart';

class P2pController extends GetxController {
  final localization = AppLocalizations.of(Get.context!)!;
  final RxInt selectedTopTabIndex = 0.obs;
  final RxBool cameFromCreateAdSuccess = false.obs;
  final RxInt selectedTradeTypeIndex = 0.obs;
  final RxString selectedAsset = ''.obs;
  final RxString selectedFiat = ''.obs;
  final RxString selectedFiatSymbol = ''.obs;
  final RxString selectedAmount = 'Amount'.obs;
  final RxString selectedPayment = 'Payment'.obs;
  final RxString selectedAmountValue = ''.obs;
  final RxnInt selectedAssetId = RxnInt();
  final RxnInt selectedFiatId = RxnInt();
  final RxBool isCurrenciesLoading = false.obs;
  final RxBool isPaymentMethodsLoading = false.obs;
  final RxBool isOpeningPaymentMethodFilterSheet = false.obs;
  final RxList<CurrenciesData> assetCurrencies = <CurrenciesData>[].obs;
  final RxList<CurrenciesData> fiatCurrencies = <CurrenciesData>[].obs;
  final RxList<PaymentAccount> availablePaymentAccounts =
      <PaymentAccount>[].obs;
  final RxList<int> selectedPaymentMethodIds = <int>[].obs;

  final List<String> topTabs = const [
    'P2P',
    'My Orders',
    'Payment Accounts',
    'My Ads',
    'Create Ad',
    'Apply Verification',
  ];

  final TextEditingController assetController = TextEditingController();
  final TextEditingController fiatController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentController = TextEditingController(
    text: 'Payment',
  );

  List<String> get assetOptions => assetCurrencies
      .map((item) => (item.code ?? item.name ?? '').trim())
      .where((value) => value.isNotEmpty)
      .toList();

  List<String> get fiatOptions => fiatCurrencies
      .map((item) => (item.code ?? item.name ?? '').trim())
      .where((value) => value.isNotEmpty)
      .toList();
  final RxBool isMarketplaceLoading = false.obs;
  final RxBool isMarketplacePaginationLoading = false.obs;
  final RxBool hasMoreMarketplaceData = true.obs;
  final RxInt marketplaceCurrentPage = 1.obs;
  final int marketplacePerPage = 15;
  final RxList<Ad> p2pAds = <Ad>[].obs;
  final Rxn<P2PMarketPlaceResponseModel> marketplaceResponse =
      Rxn<P2PMarketPlaceResponseModel>();

  String get marketplaceQueryType =>
      selectedTradeTypeIndex.value == 0 ? 'sell' : 'buy';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      if (arguments['initial_tab'] is int) {
        final tabIndex = arguments['initial_tab'] as int;
        if (tabIndex >= 0 && tabIndex < topTabs.length) {
          selectedTopTabIndex.value = tabIndex;
        }
      }
      if (arguments['from_create_ad_success'] == true) {
        cameFromCreateAdSuccess.value = true;
      }
    }
    fetchInitialCurrenciesAndMarketplace();
  }

  @override
  void onClose() {
    assetController.dispose();
    fiatController.dispose();
    amountController.dispose();
    paymentController.dispose();
    super.onClose();
  }

  void onTopTabSelected(int index) {
    selectedTopTabIndex.value = index;
    if (index == 0 && p2pAds.isEmpty && !isMarketplaceLoading.value) {
      fetchInitialCurrenciesAndMarketplace();
    }
  }

  void onTradeTypeChanged(int index) {
    selectedTradeTypeIndex.value = index;
    clearAmountFilter(refresh: false);
    clearPaymentMethodFilter(refresh: false);
    fetchMarketplaceAds(isRefresh: true);
  }

  void onAssetSelected(String value) {
    if (value.isEmpty) return;
    final selected = assetCurrencies.firstWhere(
      (item) => (item.code ?? item.name ?? '').trim() == value,
      orElse: () => CurrenciesData(),
    );
    if (selected.id == null) return;
    selectedAssetId.value = selected.id;
    selectedAsset.value = selected.code ?? selected.name ?? value;
    assetController.text = selectedAsset.value;
    fetchMarketplaceAds(isRefresh: true);
  }

  void onFiatSelected(String value) {
    if (value.isEmpty) return;
    final selected = fiatCurrencies.firstWhere(
      (item) => (item.code ?? item.name ?? '').trim() == value,
      orElse: () => CurrenciesData(),
    );
    if (selected.id == null) return;
    selectedFiatId.value = selected.id;
    selectedFiat.value = selected.code ?? selected.name ?? value;
    selectedFiatSymbol.value = selected.symbol?.trim().isNotEmpty == true
        ? selected.symbol!.trim()
        : '\$';
    fiatController.text = selectedFiat.value;
    clearPaymentMethodFilter(refresh: false);
    fetchMarketplaceAds(isRefresh: true);
  }

  void applyAmountFilter(String value) {
    final amountText = value.trim();
    if (amountText.isEmpty) {
      clearAmountFilter(refresh: true);
      return;
    }
    selectedAmountValue.value = amountText;
    selectedAmount.value = amountText;
    amountController.text = amountText;
    fetchMarketplaceAds(isRefresh: true);
  }

  void clearAmountFilter({bool refresh = true}) {
    selectedAmountValue.value = '';
    selectedAmount.value = 'Amount';
    amountController.clear();
    if (refresh) {
      fetchMarketplaceAds(isRefresh: true);
    }
  }

  Future<void> fetchPaymentMethodsByFiat() async {
    if (selectedFiatId.value == null) {
      ToastHelper().showErrorToast('Please select fiat first');
      return;
    }

    isPaymentMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.paymentAccountEndpoint}?currency_id=${selectedFiatId.value}',
      );

      if (response.status != Status.completed || response.data == null) {
        availablePaymentAccounts.clear();
        return;
      }

      final paymentAccountResponse = PaymentAccountResponseModel.fromJson(
        response.data!,
      );
      final accounts =
          paymentAccountResponse.data?.paymentAccounts ?? <PaymentAccount>[];

      availablePaymentAccounts
        ..clear()
        ..assignAll(accounts.where((account) => account.id != null).toList());
    } catch (e, stackTrace) {
      debugPrint('fetchPaymentMethodsByFiat() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to load payment methods');
    } finally {
      isPaymentMethodsLoading.value = false;
    }
  }

  void togglePaymentMethodFilter(PaymentAccount account) {
    final paymentMethodId = account.paymentMethod?.id ?? account.id;
    if (paymentMethodId == null) return;

    if (selectedPaymentMethodIds.contains(paymentMethodId)) {
      selectedPaymentMethodIds.remove(paymentMethodId);
    } else {
      selectedPaymentMethodIds.add(paymentMethodId);
    }
    selectedPaymentMethodIds.refresh();
  }

  void applyPaymentMethodFilter() {
    if (selectedPaymentMethodIds.isEmpty) {
      selectedPayment.value = 'Payment';
      paymentController.text = selectedPayment.value;
    } else if (selectedPaymentMethodIds.length == 1) {
      PaymentAccount? selectedAccount;
      for (final account in availablePaymentAccounts) {
        final paymentMethodId = account.paymentMethod?.id ?? account.id;
        if (paymentMethodId == selectedPaymentMethodIds.first) {
          selectedAccount = account;
          break;
        }
      }
      selectedPayment.value = selectedAccount?.paymentMethod?.name ?? 'Payment';
      paymentController.text = selectedPayment.value;
    } else {
      selectedPayment.value = '${selectedPaymentMethodIds.length} Methods';
      paymentController.text = selectedPayment.value;
    }

    fetchMarketplaceAds(isRefresh: true);
  }

  void clearPaymentMethodFilter({bool refresh = true}) {
    selectedPaymentMethodIds.clear();
    selectedPayment.value = 'Payment';
    paymentController.text = selectedPayment.value;
    if (refresh) {
      fetchMarketplaceAds(isRefresh: true);
    }
  }

  void onP2pBackPressed() {
    if (cameFromCreateAdSuccess.value) {
      Get.offAllNamed(BaseRoute.navigation);
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  void _resetMarketplacePagination() {
    marketplaceCurrentPage.value = 1;
    hasMoreMarketplaceData.value = true;
    p2pAds.clear();
  }

  Future<void> fetchInitialCurrenciesAndMarketplace() async {
    await fetchStepOneCurrencies();
    await fetchMarketplaceAds(isRefresh: true);
  }

  Future<void> fetchStepOneCurrencies() async {
    isCurrenciesLoading.value = true;
    try {
      await Future.wait([
        fetchCurrencies(type: 'crypto'),
        fetchCurrencies(type: 'fiat'),
      ]);
      _setInitialCurrencySelections();
    } finally {
      isCurrenciesLoading.value = false;
    }
  }

  Future<void> fetchCurrencies({required String type}) async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: '${ApiPath.currenciesEndpoint}?type=$type',
      );

      if (response.status == Status.completed && response.data != null) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);
        final items = currenciesModel.data ?? <CurrenciesData>[];
        if (type == 'crypto') {
          assetCurrencies
            ..clear()
            ..assignAll(items);
        } else {
          fiatCurrencies
            ..clear()
            ..assignAll(items);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchCurrencies(type: $type) error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void _setInitialCurrencySelections() {
    if (assetCurrencies.isNotEmpty && selectedAssetId.value == null) {
      final firstAsset = assetCurrencies.first;
      selectedAssetId.value = firstAsset.id;
      selectedAsset.value = firstAsset.code ?? firstAsset.name ?? '';
      assetController.text = selectedAsset.value;
    }

    if (fiatCurrencies.isNotEmpty && selectedFiatId.value == null) {
      final firstFiat = fiatCurrencies.first;
      selectedFiatId.value = firstFiat.id;
      selectedFiat.value = firstFiat.code ?? firstFiat.name ?? '';
      selectedFiatSymbol.value = firstFiat.symbol?.trim().isNotEmpty == true
          ? firstFiat.symbol!.trim()
          : '\$';
      fiatController.text = selectedFiat.value;
    }
  }

  Future<void> fetchMarketplaceAds({bool isRefresh = false}) async {
    if (isRefresh) {
      _resetMarketplacePagination();
    }

    if (!hasMoreMarketplaceData.value && !isRefresh) return;

    if (marketplaceCurrentPage.value == 1) {
      isMarketplaceLoading.value = true;
    } else {
      isMarketplacePaginationLoading.value = true;
    }

    try {
      final queryParams = <String>[
        'page=${marketplaceCurrentPage.value}',
        'per_page=$marketplacePerPage',
        'type=$marketplaceQueryType',
      ];

      if (selectedAssetId.value != null) {
        queryParams.add('asset_currency_id=${selectedAssetId.value}');
      }
      if (selectedFiatId.value != null) {
        queryParams.add('fiat_currency_id=${selectedFiatId.value}');
      }
      if (selectedAmountValue.value.trim().isNotEmpty) {
        queryParams.add('min_amount=${selectedAmountValue.value.trim()}');
      }
      if (selectedPaymentMethodIds.isNotEmpty) {
        for (final paymentMethodId in selectedPaymentMethodIds) {
          queryParams.add('payment_method_id[]=$paymentMethodId');
        }
      }

      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.p2pMarketPlaceEndpoint}?${queryParams.join('&')}',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = P2PMarketPlaceResponseModel.fromJson(response.data!);
        marketplaceResponse.value = model;

        final fetchedAds = model.data?.ads ?? <Ad>[];
        if (isRefresh) {
          p2pAds.clear();
        }
        p2pAds.addAll(fetchedAds);

        final pagination = model.data?.pagination;
        if (pagination?.lastPage != null) {
          hasMoreMarketplaceData.value =
              marketplaceCurrentPage.value < (pagination!.lastPage ?? 1);
        } else {
          hasMoreMarketplaceData.value =
              fetchedAds.length >= marketplacePerPage;
        }

        if (hasMoreMarketplaceData.value) {
          marketplaceCurrentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMarketplaceAds() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to load marketplace ads');
    } finally {
      isMarketplaceLoading.value = false;
      isMarketplacePaginationLoading.value = false;
    }
  }

  Future<void> loadMoreMarketplaceAds() async {
    if (isMarketplacePaginationLoading.value || !hasMoreMarketplaceData.value) {
      return;
    }
    await fetchMarketplaceAds();
  }
}

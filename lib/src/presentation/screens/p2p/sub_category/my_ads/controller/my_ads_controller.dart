import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/model/my_ads_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

class MyAdsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int perPage = 15;

  final RxList<Ad> adsList = <Ad>[].obs;
  final Rxn<MyAdsResponseModel> myAdsResponseModel = Rxn<MyAdsResponseModel>();
  final RxBool isFilterCurrenciesLoading = false.obs;

  final RxString selectedStatusFilter = ''.obs;
  final RxString selectedTypeFilter = ''.obs;
  final RxnInt selectedFiatCurrencyIdFilter = RxnInt();
  final RxnInt selectedAssetCurrencyIdFilter = RxnInt();

  final RxString selectedFiatFilterLabel = ''.obs;
  final RxString selectedAssetFilterLabel = ''.obs;

  final RxList<CurrenciesData> fiatCurrencies = <CurrenciesData>[].obs;
  final RxList<CurrenciesData> assetCurrencies = <CurrenciesData>[].obs;

  final List<String> statusFilterOptions = const [
    'active',
    'pending',
    'inactive',
    'completed',
    'cancelled',
  ];
  final List<String> typeFilterOptions = const ['buy', 'sell'];

  @override
  void onInit() {
    super.onInit();
    fetchFilterCurrencies();
    fetchMyAds(isRefresh: true);
  }

  void _resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    adsList.clear();
  }

  Future<void> fetchMyAds({bool isRefresh = false}) async {
    if (isRefresh) {
      _resetPagination();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isPaginationLoading.value = true;
    }

    try {
      final queryParams = <String>[
        'page=${currentPage.value}',
        'per_page=$perPage',
      ];

      if (selectedStatusFilter.value.isNotEmpty) {
        queryParams.add('status=${selectedStatusFilter.value}');
      }
      if (selectedTypeFilter.value.isNotEmpty) {
        queryParams.add('type=${selectedTypeFilter.value}');
      }
      if (selectedFiatCurrencyIdFilter.value != null) {
        queryParams.add('fiat_currency=${selectedFiatCurrencyIdFilter.value}');
      }
      if (selectedAssetCurrencyIdFilter.value != null) {
        queryParams.add('asset_currency=${selectedAssetCurrencyIdFilter.value}');
      }

      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.getAdsEndpoint}?${queryParams.join('&')}',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = MyAdsResponseModel.fromJson(response.data!);
        myAdsResponseModel.value = model;

        final fetchedAds = model.data?.ads ?? <Ad>[];

        if (isRefresh) {
          adsList.clear();
        }
        adsList.addAll(fetchedAds);

        final pagination = model.data?.pagination;
        if (pagination?.lastPage != null) {
          hasMoreData.value = currentPage.value < (pagination!.lastPage ?? 1);
        } else {
          hasMoreData.value = fetchedAds.length >= perPage;
        }

        if (hasMoreData.value) {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMyAds() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  Future<void> fetchFilterCurrencies() async {
    isFilterCurrenciesLoading.value = true;
    try {
      await Future.wait([
        _fetchCurrenciesByType(type: 'fiat'),
        _fetchCurrenciesByType(type: 'crypto'),
      ]);
    } finally {
      isFilterCurrenciesLoading.value = false;
    }
  }

  Future<void> _fetchCurrenciesByType({required String type}) async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: '${ApiPath.currenciesEndpoint}?type=$type',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = CurrenciesModel.fromJson(response.data!);
        final items = model.data ?? <CurrenciesData>[];
        if (type == 'fiat') {
          fiatCurrencies
            ..clear()
            ..assignAll(items);
        } else {
          assetCurrencies
            ..clear()
            ..assignAll(items);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('_fetchCurrenciesByType($type) error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> applyFilters({
    required String status,
    required String type,
    required int? fiatCurrencyId,
    required String fiatLabel,
    required int? assetCurrencyId,
    required String assetLabel,
  }) async {
    selectedStatusFilter.value = status;
    selectedTypeFilter.value = type;
    selectedFiatCurrencyIdFilter.value = fiatCurrencyId;
    selectedAssetCurrencyIdFilter.value = assetCurrencyId;
    selectedFiatFilterLabel.value = fiatLabel;
    selectedAssetFilterLabel.value = assetLabel;
    await fetchMyAds(isRefresh: true);
  }

  Future<void> clearFilters() async {
    selectedStatusFilter.value = '';
    selectedTypeFilter.value = '';
    selectedFiatCurrencyIdFilter.value = null;
    selectedAssetCurrencyIdFilter.value = null;
    selectedFiatFilterLabel.value = '';
    selectedAssetFilterLabel.value = '';
    await fetchMyAds(isRefresh: true);
  }

  Future<void> loadMoreMyAds() async {
    if (isPaginationLoading.value || !hasMoreData.value) return;
    await fetchMyAds();
  }

  Future<List<PaymentAccount>> fetchPaymentAccountsByFiat({
    required int fiatCurrencyId,
  }) async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.paymentAccountEndpoint}?currency_id=$fiatCurrencyId',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = PaymentAccountResponseModel.fromJson(response.data!);
        return model.data?.paymentAccounts ?? <PaymentAccount>[];
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPaymentAccountsByFiat() error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
    return <PaymentAccount>[];
  }

  Future<void> deleteAds(String adId) async {
    try {
      isLoading.value = true;
      final response = await Get.find<NetworkService>().delete(
        endpoint: '${ApiPath.getAdsEndpoint}/$adId',
      );

      if (response.status == Status.completed) {
        await fetchMyAds(isRefresh: true);
        ToastHelper().showSuccessToast(response.data?['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('deleteAds() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAd({
    required String adId,
    required int assetCurrencyId,
    required int fiatCurrencyId,
    required String type,
    required double minAmount,
    required double maxAmount,
    required double price,
    required double totalAmount,
    required int paymentDuration,
    required String description,
    required String autoResponseMessage,
    required List<int> paymentMethodIds,
  }) async {
    try {
      isLoading.value = true;
      final response = await Get.find<NetworkService>().post(
        endpoint: '${ApiPath.getAdsEndpoint}/$adId',
        data: {
          'asset_currency_id': assetCurrencyId,
          'fiat_currency_id': fiatCurrencyId,
          'type': type,
          'min_amount': minAmount,
          'max_amount': maxAmount,
          'price': price,
          'total_amount': totalAmount,
          'payment_duration': paymentDuration,
          'description': description,
          'auto_response_message': autoResponseMessage,
          'payment_method_ids': paymentMethodIds,
          '_method': 'PUT',
        },
      );

      if (response.status == Status.completed) {
        await fetchMyAds(isRefresh: true);
        ToastHelper().showSuccessToast(response.data?['message']);
        return true;
      }
    } catch (e, stackTrace) {
      debugPrint('updateAd() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }

    return false;
  }

  Future<void> updateAdStatus({
    required String adId,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.updateAdStatusEndpoint(adId: adId),
        data: {'status': status, '_method': 'PATCH'},
      );

      if (response.status == Status.completed) {
        await fetchMyAds(isRefresh: true);
        ToastHelper().showSuccessToast(response.data?['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('updateAdStatus() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

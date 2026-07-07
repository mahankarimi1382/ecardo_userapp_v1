import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_history_model.dart';

class GiftCardHistoryController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isGiftCardHistoryLoading = false.obs;
  final RxBool isFilter = false.obs;
  final Rx<GiftCardHistoryModel> giftCardHistoryModel =
      GiftCardHistoryModel().obs;

  // Search
  final RxBool isSearchFocused = false.obs;
  final FocusNode searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(_handleTransactionIdFocusChange);
  }

  @override
  void onClose() {
    searchFocusNode.removeListener(_handleTransactionIdFocusChange);
    searchFocusNode.dispose();
    super.onClose();
  }

  // Search focus change handler
  void _handleTransactionIdFocusChange() {
    isSearchFocused.value = searchFocusNode.hasFocus;
  }

  // Build query parameters for filtering
  List<String> _buildQueryParams() {
    final queryParams = <String>[];
    queryParams.add('page=${currentPage.value}&per_page=15');

    if (searchController.text.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchController.text)}');
    }

    return queryParams;
  }

  // Fetch Gift Card History From API
  Future<void> fetchGiftCardHistory() async {
    searchController.clear();
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.getGiftCardPurchasedHistoryEndpoint}?page=${currentPage.value}&per_page=15',
      );

      if (response.status == Status.completed) {
        giftCardHistoryModel.value = GiftCardHistoryModel.fromJson(
          response.data!,
        );
        if (giftCardHistoryModel.value.data!.giftCards!.length <
            giftCardHistoryModel.value.data!.meta!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchGiftCardHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch More Gift Card History
  Future<void> loadMoreGiftCardHistory() async {
    searchController.clear();
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;

    try {
      final queryParams = _buildQueryParams();
      final endpoint =
          '${ApiPath.getGiftCardPurchasedHistoryEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        final newGiftCardHistoryModel = GiftCardHistoryModel.fromJson(
          response.data!,
        );

        if (newGiftCardHistoryModel.data!.giftCards!.isEmpty) {
          hasMorePages.value = false;
        } else {
          giftCardHistoryModel.value.data!.giftCards!.addAll(
            newGiftCardHistoryModel.data!.giftCards!,
          );
          giftCardHistoryModel.refresh();
          if (newGiftCardHistoryModel.data!.giftCards!.length <
              giftCardHistoryModel.value.data!.meta!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreGiftCardHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }

  // Fetch Dynamic Gift Card History
  Future<void> fetchDynamicGiftCardHistory() async {
    try {
      isGiftCardHistoryLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final queryParams = _buildQueryParams();
      final endpoint =
          '${ApiPath.getGiftCardPurchasedHistoryEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        searchController.clear();
        giftCardHistoryModel.value = GiftCardHistoryModel.fromJson(
          response.data!,
        );
        if (giftCardHistoryModel.value.data!.giftCards == null ||
            giftCardHistoryModel.value.data!.giftCards!.isEmpty) {
          giftCardHistoryModel.value.data!.giftCards = [];
          hasMorePages.value = false;
        } else if (giftCardHistoryModel.value.data!.giftCards!.length <
            giftCardHistoryModel.value.data!.meta!.perPage!) {
          hasMorePages.value = false;
        }
      } else {
        giftCardHistoryModel.value.data!.giftCards = [];
        hasMorePages.value = false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchDynamicGiftCardHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isGiftCardHistoryLoading.value = false;
      isFilter.value = false;
    }
  }

  // Reset all filters
  void resetFilters() {
    searchController.clear();
    isFilter.value = true;
    fetchDynamicGiftCardHistory();
  }
}

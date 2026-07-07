import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_history_model.dart';

class GiftHistoryController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<GiftHistoryModel> giftHistoryModel = GiftHistoryModel().obs;
  final RxList<Gifts> allGifts = <Gifts>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxBool hasMoreData = true.obs;

  // Gift Code Filter
  final RxBool isGiftCodeFocused = false.obs;
  final FocusNode giftCodeFocusNode = FocusNode();
  final giftCodeController = TextEditingController();
  final RxString currentFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    giftCodeFocusNode.addListener(_handleGiftCodeFocusChange);
    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    allGifts.clear();
  }

  @override
  void onClose() {
    giftCodeFocusNode.removeListener(_handleGiftCodeFocusChange);
    giftCodeFocusNode.dispose();
    giftCodeController.dispose();
    super.onClose();
  }

  // Gift Code focus change handler
  void _handleGiftCodeFocusChange() {
    isGiftCodeFocused.value = giftCodeFocusNode.hasFocus;
  }

  // Apply filter
  void applyFilter() {
    currentFilter.value = giftCodeController.text.trim();
    fetchGiftHistory(isRefresh: true);
    giftCodeController.clear();
    currentFilter.value = '';
  }

  // Clear filter
  void clearFilter() {
    giftCodeController.clear();
    currentFilter.value = '';
    fetchGiftHistory(isRefresh: true);
  }

  // Build query parameters
  String _buildQueryParameters() {
    List<String> params = [
      'page=${currentPage.value}',
      'per_page=${perPage.value}',
    ];

    if (currentFilter.value.isNotEmpty) {
      params.add('code=${Uri.encodeComponent(currentFilter.value)}');
    }

    return params.join('&');
  }

  // Fetch Gift History
  Future<void> fetchGiftHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      resetPagination();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final queryParams = _buildQueryParameters();
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.giftHistoryEndpoint}?$queryParams",
      );

      if (response.status == Status.completed) {
        final newGiftHistoryModel = GiftHistoryModel.fromJson(response.data!);
        final newGiftHistory = newGiftHistoryModel.data?.gifts ?? [];

        if (isRefresh) {
          allGifts.clear();
        }
        allGifts.addAll(newGiftHistory);
        giftHistoryModel.value = newGiftHistoryModel;

        if (newGiftHistory.length < perPage.value) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchGiftHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more Gift History
  Future<void> loadMoreGiftHistory() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchGiftHistory();
    }
  }
}

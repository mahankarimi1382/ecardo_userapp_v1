import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_redeem_history_model.dart';

class GiftRedeemHistoryController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isTransactionsLoading = false.obs;
  final RxBool isFilter = false.obs;
  final Rx<GiftRedeemHistoryModel> giftRedeemHistoryModel =
      GiftRedeemHistoryModel().obs;

  // Code
  final RxBool isCodeFocused = false.obs;
  final FocusNode codeFocusNode = FocusNode();
  final codeController = TextEditingController();

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    codeFocusNode.addListener(_handleCodeFocusChange);
  }

  @override
  void onClose() {
    codeFocusNode.removeListener(_handleCodeFocusChange);
    codeFocusNode.dispose();
    super.onClose();
  }

  // Code focus change handler
  void _handleCodeFocusChange() {
    isCodeFocused.value = codeFocusNode.hasFocus;
  }

  // Build query parameters for filtering
  List<String> _buildQueryParams() {
    final queryParams = <String>[];
    queryParams.add('page=${currentPage.value}&per_page=15');

    if (codeController.text.isNotEmpty) {
      queryParams.add('code=${Uri.encodeComponent(codeController.text)}');
    }

    return queryParams;
  }

  // Fetch Transactions From API
  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.giftRedeemHistoryEndpoint}?page=${currentPage.value}&per_page=15',
      );

      if (response.status == Status.completed) {
        giftRedeemHistoryModel.value = GiftRedeemHistoryModel.fromJson(
          response.data!,
        );
        if (giftRedeemHistoryModel.value.data!.gifts!.length <
            giftRedeemHistoryModel.value.data!.pagination!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch More Transactions
  Future<void> loadMoreTransactions() async {
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;

    try {
      final queryParams = _buildQueryParams();
      final endpoint =
          '${ApiPath.giftRedeemHistoryEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        final newTransactions = GiftRedeemHistoryModel.fromJson(response.data!);

        if (newTransactions.data!.gifts!.isEmpty) {
          hasMorePages.value = false;
        } else {
          giftRedeemHistoryModel.value.data!.gifts!.addAll(
            newTransactions.data!.gifts!,
          );
          giftRedeemHistoryModel.refresh();
          if (newTransactions.data!.gifts!.length <
              giftRedeemHistoryModel.value.data!.pagination!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }

  // Fetch Dynamic Transactions (with all filters)
  Future<void> fetchDynamicTransactions() async {
    try {
      isTransactionsLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final queryParams = _buildQueryParams();
      final endpoint =
          '${ApiPath.giftRedeemHistoryEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        giftRedeemHistoryModel.value = GiftRedeemHistoryModel.fromJson(
          response.data!,
        );
        if (giftRedeemHistoryModel.value.data!.gifts == null ||
            giftRedeemHistoryModel.value.data!.gifts!.isEmpty) {
          giftRedeemHistoryModel.value.data!.gifts = [];
          hasMorePages.value = false;
        } else if (giftRedeemHistoryModel.value.data!.gifts!.length <
            giftRedeemHistoryModel.value.data!.pagination!.perPage!) {
          hasMorePages.value = false;
        }
      } else {
        giftRedeemHistoryModel.value.data!.gifts = [];
        hasMorePages.value = false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchDynamicTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isTransactionsLoading.value = false;
      isFilter.value = false;
    }
  }

  // Reset all filters
  void resetFilters() {
    codeController.clear();
    isFilter.value = true;
    fetchDynamicTransactions();
  }
}

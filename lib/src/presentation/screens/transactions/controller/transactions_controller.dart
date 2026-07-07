import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';

class TransactionsController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isTransactionsLoading = false.obs;
  final RxBool isFilter = false.obs;
  final RxList<String> typesList = <String>[
    "All",
    "Deposit",
    "Manual Deposit",
    "Withdraw",
    "Withdraw Auto",
    "Send Money",
    "Receive Money",
    "Cash Received",
    "Refund",
    "Referral",
    "Exchange",
    "Gift Redeemed",
    "Signup Bonus",
    "Cash In",
    "Cash Out",
    "Credit",
    "Debit",
    "Request Money",
    "Invoice",
    "Pay Bill",
  ].obs;
  final RxList<String> statusList = <String>[
    "Success",
    "Pending",
    "Failed",
  ].obs;
  final RxInt selectedTypeIndex = 0.obs;
  final RxInt selectedStatusIndex = (-1).obs;
  final Rx<TransactionsModel> transactionsModel = TransactionsModel().obs;

  // Transactions ID
  final RxBool isTransactionIdFocused = false.obs;
  final FocusNode transactionIdFocusNode = FocusNode();
  final transactionIdController = TextEditingController();

  // Status and Type filters
  final RxString status = "".obs;
  final RxString selectedType = "".obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    transactionIdFocusNode.addListener(_handleTransactionIdFocusChange);
  }

  @override
  void onClose() {
    transactionIdFocusNode.removeListener(_handleTransactionIdFocusChange);
    transactionIdFocusNode.dispose();
    super.onClose();
  }

  // Transaction Id focus change handler
  void _handleTransactionIdFocusChange() {
    isTransactionIdFocused.value = transactionIdFocusNode.hasFocus;
  }

  // Build query parameters for filtering
  List<String> _buildQueryParams() {
    final queryParams = <String>[];
    queryParams.add('page=${currentPage.value}&per_page=15');

    if (transactionIdController.text.isNotEmpty) {
      queryParams.add(
        'txn=${Uri.encodeComponent(transactionIdController.text)}',
      );
    }

    if (status.value.isNotEmpty) {
      queryParams.add('status=${Uri.encodeComponent(status.value)}');
    }

    if (selectedType.value.isNotEmpty) {
      queryParams.add('type=${Uri.encodeComponent(selectedType.value)}');
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
            '${ApiPath.transactionsEndpoint}?page=${currentPage.value}&per_page=15',
      );

      if (response.status == Status.completed) {
        transactionsModel.value = TransactionsModel.fromJson(response.data!);
        if (transactionsModel.value.data!.transactions!.length <
            transactionsModel.value.data!.meta!.perPage!) {
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
          '${ApiPath.transactionsEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        final newTransactions = TransactionsModel.fromJson(response.data!);

        if (newTransactions.data!.transactions!.isEmpty) {
          hasMorePages.value = false;
        } else {
          transactionsModel.value.data!.transactions!.addAll(
            newTransactions.data!.transactions!,
          );
          transactionsModel.refresh();
          if (newTransactions.data!.transactions!.length <
              transactionsModel.value.data!.meta!.perPage!) {
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
          '${ApiPath.transactionsEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        transactionsModel.value = TransactionsModel.fromJson(response.data!);
        if (transactionsModel.value.data!.transactions == null ||
            transactionsModel.value.data!.transactions!.isEmpty) {
          transactionsModel.value.data!.transactions = [];
          hasMorePages.value = false;
        } else if (transactionsModel.value.data!.transactions!.length <
            transactionsModel.value.data!.meta!.perPage!) {
          hasMorePages.value = false;
        }
      } else {
        transactionsModel.value.data!.transactions = [];
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
    selectedStatusIndex.value = -1;
    status.value = "";
    transactionIdController.clear();
    isFilter.value = true;
    fetchDynamicTransactions();
  }

  // Check if any filters are currently active
  bool hasActiveFilters() {
    return selectedType.value.isNotEmpty ||
        status.value.isNotEmpty ||
        transactionIdController.text.isNotEmpty ||
        selectedTypeIndex.value != 0;
  }

  // Clear other filters when type is changed
  void clearOtherFiltersOnTypeChange() {
    transactionIdController.clear();
    selectedStatusIndex.value = -1;
    status.value = "";
  }

  // Update status filter when status is selected in bottom sheet
  void updateStatusFilter() {
    if (selectedStatusIndex.value == -1) {
      status.value = "";
    } else {
      status.value = statusList[selectedStatusIndex.value];
    }
  }
}

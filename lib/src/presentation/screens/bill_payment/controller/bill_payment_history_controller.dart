import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/bill_payment_history_model.dart';

class BillPaymentHistoryController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isTransactionsLoading = false.obs;
  final Rx<BillPaymentHistoryModel> billPaymentHistoryModel =
      BillPaymentHistoryModel().obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  // Build query parameters for filtering
  List<String> _buildQueryParams() {
    final queryParams = <String>[];
    queryParams.add('page=${currentPage.value}&per_page=15');

    return queryParams;
  }

  // Fetch Bill Payment History
  Future<void> fetchBillPaymentHistory() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.payBillHistoryEndpoint}?page=${currentPage.value}&per_page=15',
      );

      if (response.status == Status.completed) {
        billPaymentHistoryModel.value = BillPaymentHistoryModel.fromJson(
          response.data!,
        );
        if (billPaymentHistoryModel.value.data!.bills!.length <
            billPaymentHistoryModel.value.data!.meta!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchBillPaymentHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch More Bill Payment History
  Future<void> loadMoreBillPaymentHistory() async {
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;

    try {
      final queryParams = _buildQueryParams();
      final endpoint =
          '${ApiPath.payBillHistoryEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        final newBillPaymentHistory = BillPaymentHistoryModel.fromJson(
          response.data!,
        );

        if (newBillPaymentHistory.data!.bills!.isEmpty) {
          hasMorePages.value = false;
        } else {
          billPaymentHistoryModel.value.data!.bills!.addAll(
            newBillPaymentHistory.data!.bills!,
          );
          billPaymentHistoryModel.refresh();
          if (newBillPaymentHistory.data!.bills!.length <
              billPaymentHistoryModel.value.data!.meta!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreBillPaymentHistory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }
}

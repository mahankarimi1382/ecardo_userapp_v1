import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/received_request_model.dart';

class ReceivedRequestController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmittingAction = false.obs;
  final Rx<ReceivedRequestModel> receivedRequestModel =
      ReceivedRequestModel().obs;
  final RxList<Requests> allReceivedRequest = <Requests>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    allReceivedRequest.clear();
  }

  // Fetch Received Request
  Future<void> fetchReceivedRequest({bool isRefresh = false}) async {
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
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.receivedRequestEndpoint}?type=received&&page=${currentPage.value}&per_page=${perPage.value}",
      );

      if (response.status == Status.completed) {
        final newReceivedRequestModel = ReceivedRequestModel.fromJson(
          response.data!,
        );
        final newReceivedRequest = newReceivedRequestModel.data?.requests ?? [];

        if (isRefresh) {
          allReceivedRequest.clear();
        }
        allReceivedRequest.addAll(newReceivedRequest);
        receivedRequestModel.value = newReceivedRequestModel;
        if (newReceivedRequest.length < perPage.value) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchReceivedRequest() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more transactions
  Future<void> loadMoreTransactions() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchReceivedRequest();
    }
  }

  // Submit Request Action
  Future<void> submitRequestAction({
    required String requestId,
    required String action,
  }) async {
    try {
      isSubmittingAction.value = true;

      final response = await Get.find<NetworkService>().post(
        endpoint:
            "${ApiPath.requestMoneyEndpoint}/$requestId/action?action=$action",
      );

      if (response.status == Status.completed) {
        isSubmittingAction.value = false;
        await fetchReceivedRequest(isRefresh: true);
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ loadMoreTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isSubmittingAction.value = false;
    }
  }
}

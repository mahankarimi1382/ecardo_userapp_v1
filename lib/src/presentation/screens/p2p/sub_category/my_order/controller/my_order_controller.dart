import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/my_order_response_model.dart';

class MyOrderController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int perPage = 15;

  final RxList<Order> orderList = <Order>[].obs;
  final Rxn<MyOrderResponseModel> myOrderResponseModel =
      Rxn<MyOrderResponseModel>();

  final RxString orderNumberFilter = ''.obs;
  final RxString statusFilter = ''.obs;
  final List<String> statusFilterOptions = const [
    'pending_payment',
    'paid',
    'disputed',
    'completed',
    'cancelled',
    'expired',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders(isRefresh: true);
  }

  void _resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    orderList.clear();
  }

  Future<void> fetchMyOrders({bool isRefresh = false}) async {
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

      if (orderNumberFilter.value.isNotEmpty) {
        queryParams.add(
          'order_number=${Uri.encodeComponent(orderNumberFilter.value)}',
        );
      }
      if (statusFilter.value.isNotEmpty) {
        queryParams.add('status=${statusFilter.value}');
      }

      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.getMyOrdersEndPoint}?${queryParams.join('&')}',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = MyOrderResponseModel.fromJson(response.data!);
        myOrderResponseModel.value = model;

        final fetchedOrders = model.data?.orders ?? <Order>[];
        if (isRefresh) {
          orderList.clear();
        }
        orderList.addAll(fetchedOrders);

        final pagination = model.data?.pagination;
        if (pagination?.lastPage != null) {
          hasMoreData.value = currentPage.value < (pagination!.lastPage ?? 1);
        } else {
          hasMoreData.value = fetchedOrders.length >= perPage;
        }

        if (hasMoreData.value) {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMyOrders() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  Future<void> loadMoreMyOrders() async {
    if (isPaginationLoading.value || !hasMoreData.value) return;
    await fetchMyOrders();
  }

  Future<void> applyFilters({
    required String orderNumber,
    required String status,
  }) async {
    orderNumberFilter.value = orderNumber.trim();
    statusFilter.value = status.trim();
    await fetchMyOrders(isRefresh: true);
  }

  Future<void> clearFilters() async {
    orderNumberFilter.value = '';
    statusFilter.value = '';
    await fetchMyOrders(isRefresh: true);
  }
}

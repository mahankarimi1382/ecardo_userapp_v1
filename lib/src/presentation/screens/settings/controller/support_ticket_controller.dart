import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/support_ticket_model.dart';

class SupportTicketController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isInitialDataLoaded = false.obs;
  final Rx<SupportTicketModel> supportTicketModel = SupportTicketModel().obs;

  // Pagination properties
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  // Fetch Support Tickets
  Future<void> fetchSupportTickets() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.supportTicketsEndpoint}?page=$currentPage',
      );

      if (response.status == Status.completed) {
        supportTicketModel.value = SupportTicketModel.fromJson(response.data!);
        if (supportTicketModel.value.data!.tickets!.length <
            supportTicketModel.value.data!.pagination!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchSupportTickets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load More Support Tickets
  Future<void> loadMoreSupportTickets() async {
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;
    try {
      final queryParams = <String>[];
      queryParams.add('page=${currentPage.value}');

      final endpoint =
          '${ApiPath.supportTicketsEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);
      if (response.status == Status.completed) {
        final newTickets = SupportTicketModel.fromJson(response.data!);

        if (newTickets.data!.tickets!.isEmpty) {
          hasMorePages.value = false;
        } else {
          supportTicketModel.value.data!.tickets!.addAll(
            newTickets.data!.tickets!,
          );
          supportTicketModel.refresh();
          if (newTickets.data!.tickets!.length <
              supportTicketModel.value.data!.pagination!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreSupportTickets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }
}

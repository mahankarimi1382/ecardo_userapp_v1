import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/support_ticket_model.dart';

class SupportTicketController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isInitialDataLoaded = false.obs;
  final Rx<SupportTicketModel> supportTicketModel = SupportTicketModel().obs;

  // Pagination properties
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  /// TICKET-FIX: some backend envelopes nest the payload twice
  /// ({status, data: {status, data: {tickets...}}}) or wrap the list under
  /// a different key. Normalize to the shape the model expects: if there
  /// is no 'tickets' key but the inner data holds one, lift it up.
  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    if (json['tickets'] != null) return json;
    final data = json['data'];
    if (data is Map<String, dynamic> && data['tickets'] != null) {
      return {
        ...json,
        'data': {
          'tickets': data['tickets'],
          'pagination': data['pagination'] ?? data['meta'],
        },
      };
    }
    return json;
  }

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
        supportTicketModel.value =
            SupportTicketModel.fromJson(_unwrap(response.data!));
        final tickets = supportTicketModel.value.data?.tickets ?? const [];
        // TICKET-FIX: pagination can be absent depending on the backend
        // envelope — never null-assert it. Fall back to counting tickets
        // against a sane default page size.
        final perPage =
            supportTicketModel.value.data?.pagination?.perPage ?? 15;
        if (tickets.length < perPage) {
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
        final newTickets =
            SupportTicketModel.fromJson(_unwrap(response.data!));
        final incoming = newTickets.data?.tickets ?? const [];

        if (incoming.isEmpty) {
          hasMorePages.value = false;
        } else {
          final current = supportTicketModel.value.data?.tickets;
          if (current == null) {
            // First page never loaded (e.g. deep navigation) — adopt payload.
            supportTicketModel.value = newTickets;
          } else {
            current.addAll(incoming);
            supportTicketModel.refresh();
          }
          // TICKET-FIX: null-safe pagination read.
          final perPage = newTickets.data?.pagination?.perPage ?? 15;
          if (incoming.length < perPage) {
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

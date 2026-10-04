import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/ticket_message_model.dart';

class ReplyTicketController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isReplayTicketLoading = false.obs;
  final RxBool isCloseTicketLoading = false.obs;
  final Rx<TicketMessageModel> ticketMessageModel = TicketMessageModel().obs;
  final MultipleImagePickerController controller = Get.put(
    MultipleImagePickerController(),
  );

  // Message
  final messageController = TextEditingController();

  // Fetch Ticket Message
  Future<void> fetchTicketMessage({required String ticketUid}) async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.supportTicketsEndpoint}/$ticketUid",
      );
      if (response.status == Status.completed) {
        final parsed =
            TicketMessageModel.fromJson(_unwrapTicketPayload(response.data!));
        // TICKET-FIX: only replace the model when the payload actually
        // contains a ticket — a malformed/empty response must not blank
        // out a conversation the user is reading.
        if (parsed.data?.ticket != null || (parsed.data?.messages?.isNotEmpty ?? false)) {
          ticketMessageModel.value = parsed;
        } else if (kDebugMode) {
          debugPrint(
              '⚠️ fetchTicketMessage: empty payload for $ticketUid — keeping current model');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTicketMessage() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  /// TICKET-FIX: tolerate double-nested envelopes and missing 'messages'
  /// (some backends return {ticket, conversation|replies} instead of
  /// {ticket, messages}).
  static Map<String, dynamic> _unwrapTicketPayload(Map<String, dynamic> json) {
    if (json['ticket'] != null || json['messages'] != null) {
      return json;
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final messages =
          data['messages'] ?? data['conversation'] ?? data['replies'];
      return {
        'status': json['status'] ?? data['status'],
        'message': json['message'] ?? data['message'],
        'data': {
          'ticket': data['ticket'],
          if (messages is List) 'messages': messages,
        },
      };
    }
    return json;
  }

  // Submit Reply Ticket
  Future<void> submitReplayTicket({required String ticketUid}) async {
    isReplayTicketLoading.value = true;
    try {
      // v1.0.24: was a raw `dio.Dio()` call without timeout/401-refresh —
      // a dead connection kept the spinner on forever. Route through
      // NetworkService (timeouts + interceptors + error toasts).
      final ApiResponse<Map<String, dynamic>> response;
      if (controller.attachedImages.isEmpty) {
        response = await Get.find<NetworkService>().post(
          endpoint: "${ApiPath.supportTicketsEndpoint}/reply/$ticketUid",
          data: {'message': messageController.text},
        );
      } else {
        final formData = dio.FormData();

        formData.fields.add(MapEntry('message', messageController.text));

        controller.attachedImages.forEach((key, file) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              dio.MultipartFile.fromFileSync(
                file.path,
                // TICKET-FIX: Windows paths use '\', not '/' — split on
                // both so the filename is never the full path.
                filename: file.path.split(RegExp(r'[/\\]')).last,
              ),
            ),
          );
        });

        response = await Get.find<NetworkService>().postMultipart(
          endpoint: "${ApiPath.supportTicketsEndpoint}/reply/$ticketUid",
          data: formData,
        );
      }

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        clearForm();
        await fetchTicketMessage(ticketUid: ticketUid);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitReplayTicket() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isReplayTicketLoading.value = false;
    }
  }

  // Close Ticket
  Future<void> submitCloseTicket({required String ticketUid}) async {
    isCloseTicketLoading.value = true;
    try {
      // TICKET-FIX: was `data: null` — the backend needs an explicit action
      // verb to know what to do. Send the common shapes; an unknown route
      // still surfaces through the error path below.
      final response = await Get.find<NetworkService>().post(
        endpoint: "${ApiPath.supportTicketsEndpoint}/action/$ticketUid",
        data: {'action': 'close', 'status': 'closed'},
      );
      if (response.status == Status.completed) {
        final msg = response.data?['message'];
        ToastHelper().showSuccessToast(msg is String && msg.isNotEmpty
            ? msg
            : (Get.context != null
                ? l10nPick(
                    Get.context!,
                    en: 'Ticket closed',
                    fa: 'تیکت بسته شد',
                    ar: 'تم إغلاق التذكرة',
                    tr: 'Talep kapatıldı',
                    ru: 'Тикет закрыт',
                    zh: '工单已关闭',
                  )
                : 'Ticket closed'));
        await fetchTicketMessage(ticketUid: ticketUid);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitCloseTicket() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCloseTicketLoading.value = false;
    }
  }

  // Clear Form
  void clearForm() {
    messageController.clear();
    controller.clearImages();
  }
}

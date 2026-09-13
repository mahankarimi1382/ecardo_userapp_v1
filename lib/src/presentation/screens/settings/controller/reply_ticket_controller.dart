import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
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
        ticketMessageModel.value = TicketMessageModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTicketMessage() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
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
                filename: file.path.split('/').last,
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
      final response = await Get.find<NetworkService>().post(
        endpoint: "${ApiPath.supportTicketsEndpoint}/action/$ticketUid",
        data: null,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
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
    controller.attachedImages.clear();
  }
}

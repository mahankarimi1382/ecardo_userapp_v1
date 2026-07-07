import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/ticket_message_model.dart';

class ReplyTicketController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isReplayTicketLoading = false.obs;
  final RxBool isCloseTicketLoading = false.obs;
  final Rx<TicketMessageModel> ticketMessageModel = TicketMessageModel().obs;
  final MultipleImagePickerController controller = Get.put(
    MultipleImagePickerController(),
  );
  final TokenService tokenService = Get.find<TokenService>();

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
      final dioInstance = dio.Dio();
      dio.Response response;

      if (controller.attachedImages.isEmpty) {
        response = await dioInstance.post(
          "${ApiPath.baseUrl}${ApiPath.supportTicketsEndpoint}/reply/$ticketUid",
          data: {'message': messageController.text},
          options: dio.Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${tokenService.accessToken.value}',
            },
          ),
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

        response = await dioInstance.post(
          "${ApiPath.baseUrl}${ApiPath.supportTicketsEndpoint}/reply/$ticketUid",
          data: formData,
          options: dio.Options(
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${tokenService.accessToken.value}',
            },
          ),
        );
      }

      if (response.statusCode == 200) {
        final resData = response.data;
        ToastHelper().showSuccessToast(resData["message"]);
        clearForm();
        await fetchTicketMessage(ticketUid: ticketUid);
      }
    } on dio.DioException catch (e) {
      if (e.response!.statusCode == 422) {
        isReplayTicketLoading.value = false;
        ToastHelper().showErrorToast(e.response!.data["message"]);
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

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
import 'package:ecardo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';

class AddNewTicketController extends GetxController {
  // Global Variables — dynamic localization lookup for language-switch reactivity
  AppLocalizations? get localization =>
      Get.context == null ? null : AppLocalizations.of(Get.context!);
  final isAddTicketLoading = false.obs;
  final MultipleImagePickerController multipleImagePickerController = Get.put(
    MultipleImagePickerController(),
  );
  final attachments = <int>[].obs;
  int _nextId = 0;

  // Title
  final RxBool isTitleFocused = false.obs;
  final FocusNode titleFocusNode = FocusNode();
  final titleController = TextEditingController();

  // Description
  final RxBool isDescriptionFocused = false.obs;
  final FocusNode descriptionFocusNode = FocusNode();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    addAttachment();
    titleFocusNode.addListener(() {
      isTitleFocused.value = titleFocusNode.hasFocus;
    });
    descriptionFocusNode.addListener(() {
      isDescriptionFocused.value = descriptionFocusNode.hasFocus;
    });
  }

  void addAttachment() {
    attachments.add(_nextId++);
  }

  void removeAttachment(int id) {
    attachments.remove(id);
    multipleImagePickerController.attachedImages.remove(id);
  }

  Future<void> addNewTicket() async {
    isAddTicketLoading.value = true;
    try {
      final ApiResponse<Map<String, dynamic>> response;

      if (multipleImagePickerController.attachedImages.isEmpty) {
        // Direct JSON POST when there are no file attachments (fast & lightweight)
        response = await Get.find<NetworkService>().post(
          endpoint: ApiPath.supportTicketsEndpoint,
          data: {
            'title': titleController.text.trim(),
            'message': descriptionController.text.trim(),
          },
        );
      } else {
        final formDataPayload = dio.FormData.fromMap({
          'title': titleController.text.trim(),
          'message': descriptionController.text.trim(),
        });

        multipleImagePickerController.attachedImages.forEach((key, value) {
          formDataPayload.files.add(
            MapEntry(
              'attachments[]',
              dio.MultipartFile.fromFileSync(
                value.path,
                filename: value.path.split('/').last,
              ),
            ),
          );
        });

        response = await Get.find<NetworkService>().postMultipart(
          endpoint: ApiPath.supportTicketsEndpoint,
          data: formDataPayload,
        );
      }

      if (response.status == Status.completed) {
        final responseData = response.data!;
        ToastHelper().showSuccessToast(
          responseData["message"] is String
              ? responseData["message"]
              : (localization?.addNewTicketSuccess ?? 'Ticket created successfully!'),
        );
        clearForm();
        Get.back();
        if (Get.isRegistered<SupportTicketController>()) {
          Get.find<SupportTicketController>().fetchSupportTickets();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ addNewTicket() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ?? 'Failed to submit ticket',
      );
    } finally {
      isAddTicketLoading.value = false;
    }
  }

  // Validate
  bool validateForm() {
    // Validate Title
    if (titleController.text.trim().isEmpty) {
      ToastHelper().showErrorToast(
        localization?.addNewValidationEnterTitle ?? 'Please enter title',
      );
      return false;
    }

    // Validate Description
    if (descriptionController.text.trim().isEmpty) {
      ToastHelper().showErrorToast(
        localization?.addNewValidationEnterDescription ?? 'Please enter description',
      );
      return false;
    }

    return true;
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    multipleImagePickerController.attachedImages.clear();
    attachments.clear();
    _nextId = 0;
    addAttachment();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.onClose();
  }
}

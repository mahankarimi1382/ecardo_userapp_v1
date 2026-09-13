import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';

class AddNewTicketController extends GetxController {
  // Global Variables
  final localization = AppLocalizations.of(Get.context!)!;
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
      final formDataPayload = dio.FormData.fromMap({
        'title': titleController.text,
        'message': descriptionController.text,
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

      // v1.0.24: was a raw `dio.Dio()` call without timeout/401-refresh —
      // a dead connection kept the spinner on forever. Route through
      // NetworkService.postMultipart (timeouts + interceptors + error toasts).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: ApiPath.supportTicketsEndpoint,
        data: formDataPayload,
      );

      if (response.status == Status.completed) {
        final responseData = response.data!;
        ToastHelper().showSuccessToast(
          responseData["message"] is String
              ? responseData["message"]
              : localization.addNewTicketSuccess,
        );
        clearForm();
        Get.back();
        Get.find<SupportTicketController>().fetchSupportTickets();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ addNewTicket() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isAddTicketLoading.value = false;
    }
  }

  // Validate
  bool validateForm() {
    // Validate Title
    if (titleController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.addNewValidationEnterTitle);
      return false;
    }

    // Validate Description
    if (descriptionController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.addNewValidationEnterDescription,
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

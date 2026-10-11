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
  AppLocalizations? get localization =>
      Get.context != null ? AppLocalizations.of(Get.context!) : null;
  final isAddTicketLoading = false.obs;
  final MultipleImagePickerController multipleImagePickerController = Get.put(
    MultipleImagePickerController(),
  );
  final attachments = <int>[].obs;
  int _nextId = 0;

  // Department & Priority
  final RxString selectedDepartment = 'finance'.obs;
  final RxString selectedPriority = 'low'.obs;

  // Title
  final RxBool isTitleFocused = false.obs;
  final FocusNode titleFocusNode = FocusNode();
  final titleController = TextEditingController();
  final RxInt titleLength = 0.obs;

  // Description
  final RxBool isDescriptionFocused = false.obs;
  final FocusNode descriptionFocusNode = FocusNode();
  final descriptionController = TextEditingController();
  final RxInt descriptionLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    titleFocusNode.addListener(() {
      isTitleFocused.value = titleFocusNode.hasFocus;
    });
    descriptionFocusNode.addListener(() {
      isDescriptionFocused.value = descriptionFocusNode.hasFocus;
    });
    titleController.addListener(() {
      titleLength.value = titleController.text.length;
    });
    descriptionController.addListener(() {
      descriptionLength.value = descriptionController.text.length;
    });
  }

  int addAttachmentSlot() {
    final id = _nextId++;
    attachments.add(id);
    return id;
  }

  void addAttachment() {
    addAttachmentSlot();
  }

  void removeAttachment(int id) {
    attachments.remove(id);
    multipleImagePickerController.attachedImages.remove(id);
    multipleImagePickerController.update();
  }

  Future<void> addNewTicket() async {
    isAddTicketLoading.value = true;
    try {
      final formDataPayload = dio.FormData.fromMap({
        'title': titleController.text.trim(),
        'message': descriptionController.text.trim(),
        'department': selectedDepartment.value,
        'priority': selectedPriority.value,
      });

      multipleImagePickerController.attachedImages.forEach((key, value) {
        formDataPayload.files.add(
          MapEntry(
            'attachments[]',
            dio.MultipartFile.fromFileSync(
              value.path,
              // TICKET-FIX: split on both '/' and '\' so Windows paths
              // never leak the full path as the upload filename.
              filename: value.path.split(RegExp(r'[/\\]')).last,
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
              : (localization?.addNewTicketSuccess ?? 'Ticket created successfully'),
        );
        clearForm();
        Get.back();
        Get.find<SupportTicketController>().fetchSupportTickets();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ addNewTicket() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localization?.allControllerLoadError ?? 'Error',
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
        localization?.addNewValidationEnterDescription ??
            'Please enter description',
      );
      return false;
    }

    return true;
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    titleLength.value = 0;
    descriptionLength.value = 0;
    selectedDepartment.value = 'finance';
    selectedPriority.value = 'low';
    multipleImagePickerController.attachedImages.clear();
    attachments.clear();
    _nextId = 0;
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

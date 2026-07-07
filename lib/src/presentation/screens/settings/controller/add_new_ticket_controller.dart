import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';

class AddNewTicketController extends GetxController {
  // Global Variables
  final localization = AppLocalizations.of(Get.context!)!;
  final isAddTicketLoading = false.obs;
  final MultipleImagePickerController multipleImagePickerController = Get.put(
    MultipleImagePickerController(),
  );
  final TokenService tokenService = Get.find<TokenService>();
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
      final dioInstance = dio.Dio();
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

      final response = await dioInstance.post(
        "${ApiPath.baseUrl}${ApiPath.supportTicketsEndpoint}",
        data: formDataPayload,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        ToastHelper().showSuccessToast(
          responseData["message"] is String
              ? responseData["message"]
              : localization.addNewTicketSuccess,
        );
        clearForm();
        Get.back();
        Get.find<SupportTicketController>().fetchSupportTickets();
      }
    } on dio.DioException catch (e) {
      if (e.response!.statusCode == 422) {
        ToastHelper().showErrorToast(e.response!.data["message"]);
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

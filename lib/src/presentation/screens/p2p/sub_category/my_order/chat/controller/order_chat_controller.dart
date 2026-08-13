/// کنترلر چت سفارش P2P
/// کاربر می‌تواند پیام متنی و فایل ضمیمه ارسال کند
/// از XFile به جای dart:io File استفاده شده برای سازگاری وب

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/model/order_message_response_model.dart'
    as chat_model;

/// کنترلر مدیریت پیام‌های چت سفارش P2P
/// بارگذاری پیام‌ها، ارسال پیام جدید و مدیریت فایل ضمیمه
/// XFile برای سازگاری با وب و موبایل استفاده شده است
class OrderChatController extends GetxController {
  /// شناسه سفارش برای بارگذاری و ارسال پیام
  final String orderId;

  OrderChatController({required this.orderId});

  /// وضعیت بارگذاری پیام‌ها
  final RxBool isLoading = false.obs;
  /// وضعیت ارسال پیام
  final RxBool isSending = false.obs;

  /// لیست پیام‌های چت
  final RxList<chat_model.Message> messages = <chat_model.Message>[].obs;

  /// فایل ضمیمه انتخاب‌شده (XFile برای سازگاری وب و موبایل)
  final Rxn<XFile> selectedAttachment = Rxn<XFile>();

  /// کنترلر ورودی پیام متنی
  final TextEditingController messageController = TextEditingController();

  /// کنترلر اسکرول برای رفتن به آخرین پیام
  final ScrollController scrollController = ScrollController();

  /// انتخاب‌گر تصویر
  final ImagePicker _imagePicker = ImagePicker();

  /// سرویس توکن برای احراز هویت
  final TokenService tokenService = Get.find<TokenService>();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// بارگذاری پیام‌های سفارش از سرور
  Future<void> fetchMessages() async {
    if (orderId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.orderMessageEndpoint(orderId: orderId),
      );
      if (response.status == Status.completed && response.data != null) {
        final model = chat_model.OrderMessageResponseModel.fromJson(
          response.data!,
        );
        messages
          ..clear()
          ..assignAll(model.data?.messages ?? <chat_model.Message>[]);
        _scrollToBottom();
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMessages() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// انتخاب تصویر ضمیمه از گالری یا دوربین
  /// XFile در هر دو پلتفرم وب و موبایل کار می‌کند
  Future<void> pickAttachment(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      selectedAttachment.value = picked;
    }
  }

  /// حذف فایل ضمیمه انتخاب‌شده
  void clearAttachment() {
    selectedAttachment.value = null;
  }

  /// ارسال پیام جدید (متنی + ضمیمه اختیاری)
  /// از XFile.readAsBytes() برای سازگاری وب استفاده می‌شود
  Future<void> sendMessage() async {
    if (orderId.isEmpty) return;

    final text = messageController.text.trim();
    final attachment = selectedAttachment.value;
    if (text.isEmpty && attachment == null) {
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.p2pWriteMessageOrAttach,
      );
      return;
    }

    isSending.value = true;
    try {
      final formData = dio.FormData();
      formData.fields.add(MapEntry('id', orderId));
      formData.fields.add(MapEntry('message', text));

      /// ارسال فایل ضمیمه با bytes (سازگار با وب و موبایل)
      if (attachment != null) {
        final fileBytes = await attachment.readAsBytes();
        formData.files.add(
          MapEntry(
            'attachment',
            dio.MultipartFile.fromBytes(
              fileBytes,
              filename: attachment.name,
              contentType: _contentTypeForFile(attachment.name),
            ),
          ),
        );
      }

      final response = await dio.Dio().post(
        '${ApiPath.baseUrl}${ApiPath.orderMessageEndpoint(orderId: orderId)}',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        messageController.clear();
        selectedAttachment.value = null;
        await fetchMessages();
      }
    } on dio.DioException catch (e) {
      final message = e.response?.data?['message'];
      ToastHelper().showErrorToast(
        (message is String && message.isNotEmpty)
            ? message
            : AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } catch (e, stackTrace) {
      debugPrint('sendMessage() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// اسکرول خودکار به آخرین پیام
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// تشخیص نوع محتوای فایل بر اساس پسوند
  static dio.ContentType _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return dio.ContentType('application', 'pdf');
    if (lower.endsWith('.png')) return dio.ContentType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return dio.ContentType('image', 'jpeg');
    }
    if (lower.endsWith('.webp')) return dio.ContentType('image', 'webp');
    return dio.ContentType('application', 'octet-stream');
  }
}

/// کنترلر چت سفارش P2P
/// کاربر می‌تواند پیام متنی و فایل ضمیمه ارسال کند
/// از XFile به جای dart:io File استفاده شده برای سازگاری وب

import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
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

  /// phase3-fix: polling timer — cancelled in onClose.
  Timer? _pollTimer;

  /// انتخاب‌گر تصویر
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    // phase3-fix: light 12s polling while the chat is open — counterpart
    // replies appear without manual pull-to-refresh (audit A7-P2-4).
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      fetchMessages(showLoading: false);
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// بارگذاری پیام‌های سفارش از سرور
  Future<void> fetchMessages({bool showLoading = true}) async {
    if (orderId.isEmpty) return;

    if (showLoading) isLoading.value = true;
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
      if (showLoading) isLoading.value = false;
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

      // v1.0.24: was a raw `dio.Dio()` call without timeout/401-refresh —
      // a dead connection kept the spinner on forever. Route through
      // NetworkService.postMultipart (timeouts + interceptors + error toasts).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: ApiPath.orderMessageEndpoint(orderId: orderId),
        data: formData,
      );

      if (response.status == Status.completed) {
        messageController.clear();
        selectedAttachment.value = null;
        await fetchMessages();
      }
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
  /// در Dio 5.x از DioMediaType به جای ContentType استفاده شده
  static dio.DioMediaType _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return dio.DioMediaType('application', 'pdf');
    if (lower.endsWith('.png')) return dio.DioMediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return dio.DioMediaType('image', 'jpeg');
    }
    if (lower.endsWith('.webp')) return dio.DioMediaType('image', 'webp');
    return dio.DioMediaType('application', 'octet-stream');
  }
}

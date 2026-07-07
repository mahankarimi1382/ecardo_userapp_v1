import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/order_message_response_model.dart'
    as chat_model;

class OrderChatController extends GetxController {
  final String orderId;

  OrderChatController({required this.orderId});

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxList<chat_model.Message> messages = <chat_model.Message>[].obs;
  final Rxn<File> selectedAttachment = Rxn<File>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
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

  Future<void> pickAttachment(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      selectedAttachment.value = File(picked.path);
    }
  }

  void clearAttachment() {
    selectedAttachment.value = null;
  }

  Future<void> sendMessage() async {
    if ( orderId.isEmpty) return;

    final text = messageController.text.trim();
    final attachment = selectedAttachment.value;
    if (text.isEmpty && attachment == null) {
      ToastHelper().showErrorToast('Please write a message or add attachment');
      return;
    }

    isSending.value = true;
    try {
      final formData = dio.FormData();
      formData.fields.add(MapEntry('id', orderId));
      formData.fields.add(MapEntry('message', text));
      if (attachment != null) {
        formData.files.add(
          MapEntry(
            'attachment',
            await dio.MultipartFile.fromFile(
              attachment.path,
              filename: attachment.path.split('/').last,
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
}

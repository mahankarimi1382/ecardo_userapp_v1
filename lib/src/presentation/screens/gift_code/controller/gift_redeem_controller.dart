import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class GiftRedeemController extends GetxController {
  // Global Variables
  final RxBool isGiftRedeemLoading = false.obs;

  // Gift Code
  final RxBool isGiftCodeFocused = false.obs;
  final FocusNode giftCodeFocusNode = FocusNode();
  final giftCodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    giftCodeFocusNode.addListener(_handleGiftCodeFocusChange);
  }

  @override
  void onClose() {
    giftCodeFocusNode.removeListener(_handleGiftCodeFocusChange);
    giftCodeFocusNode.dispose();
    super.onClose();
  }

  // Gift code4 focus change handler
  void _handleGiftCodeFocusChange() {
    isGiftCodeFocused.value = giftCodeFocusNode.hasFocus;
  }

  // Gift Code Redeem
  Future<void> giftCodeRedeem() async {
    isGiftRedeemLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "code": giftCodeController.text,
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.giftRedeemEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        giftCodeController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ giftCodeRedeem() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isGiftRedeemLoading.value = false;
    }
  }
}

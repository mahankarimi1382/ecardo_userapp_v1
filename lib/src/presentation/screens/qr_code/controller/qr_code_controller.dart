import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/model/qr_code_model.dart';

class QrCodeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<QrCodeModel> qrCodeModel = QrCodeModel().obs;
  final Rx<UserModel> userModel = UserModel().obs;

  bool get hasQrData {
    final data = qrCodeModel.value.data;
    return data != null && data.trim().isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      await Future.wait([fetchQrCode(), fetchUser()]);
      if (!hasQrData) {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQrCode() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.qrCodeEndpoint,
      );
      if (response.status == Status.completed) {
        qrCodeModel.value = QrCodeModel.fromJson(response.data!);
      } else {
        hasError.value = true;
      }
    } catch (e, stackTrace) {
      hasError.value = true;
      debugPrint('❌ fetchQrCode() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      final ctx = Get.context;
      if (ctx != null) {
        ToastHelper().showErrorToast(
          AppLocalizations.of(ctx)!.allControllerLoadError,
        );
      }
    }
  }

  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }
}

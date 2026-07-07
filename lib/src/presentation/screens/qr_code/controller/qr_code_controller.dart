import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/qr_code/model/qr_code_model.dart';

class QrCodeController extends GetxController {
  // Global variables
  final RxBool isLoading = false.obs;
  final Rx<QrCodeModel> qrCodeModel = QrCodeModel().obs;
  final Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load initial data
  Future<void> loadData() async {
    isLoading.value = true;
    await fetchQrCode();
    await fetchUser();
    isLoading.value = false;
  }

  // Fetch QR
  Future<void> fetchQrCode() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.qrCodeEndpoint,
      );
      if (response.status == Status.completed) {
        qrCodeModel.value = QrCodeModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchQrCode() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Fetch User
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
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }
}

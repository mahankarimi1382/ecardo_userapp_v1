import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class UpdateBeneficiaryController extends GetxController {
  final RxBool isBeneficiaryUpdateLoading = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final nickNameController = TextEditingController();

  VoidCallback? onBeneficiaryCreated;

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

  // Update Beneficiary from API
  Future<void> updateBeneficiary({required String beneficiaryId}) async {
    isBeneficiaryUpdateLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "nickname": nickNameController.text,
      };

      final response = await Get.find<NetworkService>().put(
        endpoint: "${ApiPath.beneficiaryEndpoint}/$beneficiaryId",
        data: requestBody,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        Get.back();
        if (onBeneficiaryCreated != null) {
          onBeneficiaryCreated!();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ updateBeneficiary() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isBeneficiaryUpdateLoading.value = false;
    }
  }
}

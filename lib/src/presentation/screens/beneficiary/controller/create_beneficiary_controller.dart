import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class CreateBeneficiaryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCreateBeneficiaryLoading = false.obs;

  // Account Number
  final accountNumberController = TextEditingController();

  // Nick Name
  final nickNameController = TextEditingController();

  VoidCallback? onBeneficiaryCreated;

  final RxBool shouldReopenBottomSheet = false.obs;

  Future<void> createBeneficiary() async {
    isCreateBeneficiaryLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "account_number": accountNumberController.text,
        "nickname": nickNameController.text,
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.beneficiaryEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        accountNumberController.clear();
        nickNameController.clear();
        Get.back();
        if (onBeneficiaryCreated != null) {
          onBeneficiaryCreated!();
        }
        shouldReopenBottomSheet.value = true;
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e) {
      debugPrint('❌ createBeneficiary() error: $e');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCreateBeneficiaryLoading.value = false;
    }
  }

  Future<void> deleteBeneficiary({required String beneficiaryId}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().delete(
        endpoint: "${ApiPath.beneficiaryEndpoint}/$beneficiaryId",
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        if (onBeneficiaryCreated != null) {
          onBeneficiaryCreated!();
        }
      }
    } catch (e) {
      debugPrint('❌ deleteBeneficiary() error: $e');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

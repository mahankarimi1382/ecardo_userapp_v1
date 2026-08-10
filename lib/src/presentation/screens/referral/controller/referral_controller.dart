import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referral_model.dart';

class ReferralController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final Rx<ReferralModel> referralModel = ReferralModel().obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferral();
  }

  // Fetch Referral
  Future<void> fetchReferral() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralInfoEndpoint,
      );
      if (response.status == Status.completed) {
        referralModel.value = ReferralModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchReferral() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

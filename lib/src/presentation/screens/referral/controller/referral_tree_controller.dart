import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/referral/model/referral_tree_model.dart';

class ReferralTreeController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final Rx<ReferralTreeModel> referralTreeModel = ReferralTreeModel().obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferralTree();
  }

  // Fetch Referral Tree
  Future<void> fetchReferralTree() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralTreeEndpoint,
      );
      if (response.status == Status.completed) {
        referralTreeModel.value = ReferralTreeModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchReferralTree() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

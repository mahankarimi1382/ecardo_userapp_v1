import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referral_tree_model.dart';

class ReferralTreeController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final Rx<ReferralTreeModel> referralTreeModel = ReferralTreeModel().obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferralTree();
  }

  // Fetch Referral Tree
  Future<void> fetchReferralTree() async {
    isLoading.value = true;
    isError.value = false;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralTreeEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        referralTreeModel.value = ReferralTreeModel.fromJson(response.data!);
      } else {
        isError.value = true;
      }
    } catch (e, stackTrace) {
      isError.value = true;
      debugPrint('❌ fetchReferralTree() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        ToastHelper().showErrorToast(
          AppLocalizations.of(ctx)!.allControllerLoadError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

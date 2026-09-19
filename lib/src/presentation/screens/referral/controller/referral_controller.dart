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

  /// v1.0.41: distinguishes "loaded, maybe empty" from "fetch failed" so the
  /// screen can show a retry state instead of a page full of zeros + a lone
  /// toast (which read as a broken feature).
  final RxBool isError = false.obs;

  final Rx<ReferralModel> referralModel = ReferralModel().obs;

  /// v1.0.41 (P-4 pattern): resolve per call — the previous
  /// `AppLocalizations.of(Get.context!)!` inside the catch path could run
  /// without a localization context.
  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  @override
  void onInit() {
    super.onInit();
    fetchReferral();
  }

  // Fetch Referral
  Future<void> fetchReferral() async {
    isLoading.value = true;
    isError.value = false;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralInfoEndpoint,
      );
      if (response.status == Status.completed) {
        referralModel.value = ReferralModel.fromJson(response.data!);
      } else {
        isError.value = true;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchReferral() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      isError.value = true;
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

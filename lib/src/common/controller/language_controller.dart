import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/language_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class LanguageController extends GetxController {
  /// v1.0.40 (P-4 pattern): resolve per call — the constructor-time capture
  /// froze the locale at controller creation (language switches left stale
  /// strings) and crashed when no localization context existed yet.
  AppLocalizations? get localization =>
      Get.context == null ? null : AppLocalizations.of(Get.context!);
  final RxBool isLoading = false.obs;
  final RxString locale = "".obs;
  final RxList<LanguageData> languagesList = <LanguageData>[].obs;

  Future<void> loadLanguages() async {
    isLoading.value = true;
    await fetchLanguages();
    isLoading.value = false;
  }

  Future<void> fetchLanguages() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.languagesEndpoint,
      );
      if (response.status == Status.completed) {
        final LanguageModel jsonResponse = LanguageModel.fromJson(
          response.data!,
        );
        languagesList.clear();
        languagesList.assignAll(jsonResponse.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchLanguages() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  Future<void> changeLanguage(String selectedLocale) async {
    await Get.find<SettingsService>().saveLanguageLocaleCurrentState(
      selectedLocale,
    );
  }
}

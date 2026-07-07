import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class CountryController extends GetxController {
  final localization = AppLocalizations.of(Get.context!);
  final RxBool isLoading = false.obs;
  final RxList<CountryData> countryList = <CountryData>[].obs;

  Future<void> loadCountries() async {
    isLoading.value = true;
    await fetchCountries();
    isLoading.value = false;
  }

  Future<void> fetchCountries() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.countriesEndpoint,
      );
      if (response.status == Status.completed) {
        final CountryModel jsonResponse = CountryModel.fromJson(response.data!);
        countryList.clear();
        countryList.assignAll(jsonResponse.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCountries() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }
}

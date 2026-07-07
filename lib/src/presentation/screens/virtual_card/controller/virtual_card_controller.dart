import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';

class VirtualCardController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxList<RxBool> showAccountNumberList = <RxBool>[].obs;
  final RxString cardBackgroundImage = ''.obs;

  // Virtual Cards
  final RxList<VirtualCardsData> virtualCardList = <VirtualCardsData>[].obs;

  Future<void> syncCardBackgroundImageFromSettings() async {
    final settings = Get.find<SettingsService>();
    String imageUrl = settings.getSetting('card_bg_image')?.trim() ?? '';

    if (imageUrl.isEmpty) {
      await settings.fetchSettings();
      imageUrl = settings.getSetting('card_bg_image')?.trim() ?? '';
    }

    cardBackgroundImage.value = imageUrl;
  }

  // Fetch Virtual Cards
  Future<void> fetchVirtualCards() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getVirtualCardsEndpoint,
      );
      if (response.status == Status.completed) {
        final virtualCardModel = VirtualCardsModel.fromJson(response.data!);
        virtualCardList.clear();
        virtualCardList.assignAll(virtualCardModel.data!);
        showAccountNumberList.assignAll(
          List.generate(virtualCardList.length, (_) => false.obs),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchVirtualCards() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

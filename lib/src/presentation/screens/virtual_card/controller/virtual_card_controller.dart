import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';

class VirtualCardController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
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
    isError.value = false;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getVirtualCardsEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final virtualCardModel = VirtualCardsModel.fromJson(response.data!);
        virtualCardList.clear();
        if (virtualCardModel.data != null) {
          virtualCardList.assignAll(virtualCardModel.data!);
          showAccountNumberList.assignAll(
            List.generate(virtualCardList.length, (_) => false.obs),
          );
        }
      } else {
        isError.value = true;
      }
    } catch (e, stackTrace) {
      isError.value = true;
      debugPrint('❌ fetchVirtualCards() error: $e');
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

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';

enum CardsLoadState {
  initial,
  loading,
  success,
  empty,
  inactive,
  error,
}

class VirtualCardController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final Rx<CardsLoadState> loadState = CardsLoadState.initial.obs;
  final RxString errorMessage = ''.obs;
  final RxList<RxBool> showAccountNumberList = <RxBool>[].obs;
  final RxString cardBackgroundImage = ''.obs;

  AppLocalizations? get localization =>
      Get.context == null ? null : AppLocalizations.of(Get.context!);

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
    loadState.value = CardsLoadState.loading;
    errorMessage.value = '';
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getVirtualCardsEndpoint,
      );
      if (response.status == Status.completed) {
        final virtualCardModel = VirtualCardsModel.fromJson(response.data!);
        virtualCardList.clear();
        final cards = virtualCardModel.data ?? [];
        virtualCardList.assignAll(cards);
        showAccountNumberList.assignAll(
          List.generate(virtualCardList.length, (_) => false.obs),
        );
        loadState.value =
            cards.isNotEmpty ? CardsLoadState.success : CardsLoadState.empty;
      } else {
        final msg = response.message ?? '';
        errorMessage.value = msg;
        if (msg.toLowerCase().contains('inactive') ||
            msg.toLowerCase().contains('disabled') ||
            msg.toLowerCase().contains('not enabled')) {
          loadState.value = CardsLoadState.inactive;
        } else {
          loadState.value = CardsLoadState.error;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchVirtualCards() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      loadState.value = CardsLoadState.error;
      errorMessage.value =
          localization?.allControllerLoadError ?? 'Failed to load cards';
      ToastHelper().showErrorToast(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}

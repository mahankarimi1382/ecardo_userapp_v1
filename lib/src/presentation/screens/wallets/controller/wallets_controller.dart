import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class WalletsController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isDeleteLoading = false.obs;
  final RxList<Wallets> walletsList = <Wallets>[].obs;
  StreamSubscription? _eventSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchWallets();
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSubscription = AppEventBus.on<AppEvent>().listen((event) {
      if (event is BalanceChangedEvent || event is WalletListChangedEvent) {
        debugPrint('⚡ [WalletsController] auto-refreshing wallets on ${event.runtimeType}');
        fetchWallets();
      }
    });
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    super.onClose();
  }

  // Fetch Wallets From API
  Future<void> fetchWallets() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete Wallet from API
  Future<void> deleteWallet({required String walletId}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().delete(
        endpoint: "${ApiPath.walletsEndpoint}/$walletId",
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        await fetchWallets();
        AppEventBus.emit(WalletListChangedEvent(action: 'delete'));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ deleteWallet() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

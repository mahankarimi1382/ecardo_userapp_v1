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

enum WalletFilterType { all, fiat, crypto }

class WalletsController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isDeleteLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<WalletsModel?> walletsListModel = Rx<WalletsModel?>(null);
  final RxList<Wallets> walletsList = <Wallets>[].obs;
  StreamSubscription? _eventSubscription;

  // Creative UI State: Filter, Privacy, and Net Worth
  final Rx<WalletFilterType> activeFilter = WalletFilterType.all.obs;
  final RxBool isPrivacyMode = false.obs;

  void setFilter(WalletFilterType filter) {
    activeFilter.value = filter;
  }

  void togglePrivacyMode() {
    isPrivacyMode.value = !isPrivacyMode.value;
  }

  bool isWalletCrypto(Wallets wallet) {
    if (wallet.isCrypto == true) return true;
    final code = (wallet.code ?? '').toUpperCase().trim();
    return const {'BTC', 'ETH', 'USDT', 'USDC', 'BNB', 'SOL', 'TRX', 'XRP', 'LTC'}
        .contains(code);
  }

  List<Wallets> get filteredWallets {
    switch (activeFilter.value) {
      case WalletFilterType.fiat:
        return walletsList.where((w) => !isWalletCrypto(w)).toList();
      case WalletFilterType.crypto:
        return walletsList.where((w) => isWalletCrypto(w)).toList();
      case WalletFilterType.all:
        return walletsList.toList();
    }
  }

  int get allCount => walletsList.length;
  int get fiatCount => walletsList.where((w) => !isWalletCrypto(w)).length;
  int get cryptoCount => walletsList.where((w) => isWalletCrypto(w)).length;

  static double _parseBalance(String? val) {
    if (val == null || val.isEmpty) return 0.0;
    final cleaned = val.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get totalNetWorth {
    if (walletsList.isEmpty) return 0.0;
    double sum = 0.0;
    for (final w in walletsList) {
      final rawBalance = _parseBalance(w.balance ?? w.formattedBalance);
      double rate = 1.0;
      if (w.conversionRate != null && w.conversionRate!.isNotEmpty) {
        rate = double.tryParse(w.conversionRate!.replaceAll(',', '')) ?? 1.0;
      } else {
        final code = (w.code ?? '').toUpperCase().trim();
        if (code == 'BTC') {
          rate = 68450.0;
        } else if (code == 'ETH') {
          rate = 3520.0;
        } else if (code == 'USDT' || code == 'USD') {
          rate = 1.0;
        } else if (code == 'EUR') {
          rate = 1.08;
        } else if (code == 'AED') {
          rate = 0.272;
        } else if (code == 'TRY') {
          rate = 0.029;
        } else if (code == 'IRR') {
          rate = 0.000015;
        }
      }
      sum += (rawBalance * rate);
    }
    return sum;
  }

  String get primaryCurrencySymbol {
    for (final w in walletsList) {
      if (w.isDefault == true && w.symbol != null && w.symbol!.isNotEmpty) {
        return w.symbol!;
      }
    }
    return '\$';
  }

  String get formattedNetWorth {
    final symbol = primaryCurrencySymbol;
    final parts = totalNetWorth.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = intPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '$symbol$formattedInt.$decPart';
  }

  /// Helper to safely resolve localizations
  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

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
    isError.value = false;
    errorMessage.value = '';
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed && response.data != null) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsListModel.value = walletsModel;
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
      } else {
        isError.value = true;
        errorMessage.value = response.message ?? '';
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      isError.value = true;
      errorMessage.value = e.toString();
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Failed to load wallets. Please try again.',
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

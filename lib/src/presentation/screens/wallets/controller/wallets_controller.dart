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
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/wallet_live_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';

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
    final next = !isPrivacyMode.value;
    isPrivacyMode.value = next;
    if (Get.isRegistered<SettingsService>()) {
      Get.find<SettingsService>().setPrivacyMode(next);
    }
  }

  bool isWalletCrypto(Wallets wallet) {
    if (wallet.isCrypto == true) return true;
    final code = (wallet.code ?? '').toUpperCase().trim();
    return const {
      'BTC',
      'ETH',
      'USDT',
      'USDC',
      'BNB',
      'SOL',
      'TRX',
      'XRP',
      'LTC',
    }.contains(code);
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

  /// Primary/Default wallet or first available wallet
  Wallets? get primaryWallet {
    if (walletsList.isEmpty) return null;
    return walletsList.firstWhereOrNull((w) => w.isDefault == true) ??
        walletsList.first;
  }

  /// Primary currency code for display (e.g. 'IRT', 'USD', 'EUR')
  String get primaryCurrencyCode {
    return (primaryWallet?.code ?? 'USD').toUpperCase().trim();
  }

  /// Helper to convert a single wallet's balance to USD
  double walletBalanceInUsd(Wallets wallet) {
    final rawBalance = _parseBalance(wallet.balance ?? wallet.formattedBalance);
    if (rawBalance <= 0) return 0.0;

    final code = (wallet.code ?? '').toUpperCase().trim();

    // 1. Stablecoins and USD
    if (code == 'USD' || code == 'USDT' || code == 'USDC') {
      return rawBalance;
    }

    // 2. Cryptocurrencies
    if (isWalletCrypto(wallet)) {
      double? dynamicRate;

      // Dynamic rate lookup from ExchangeRateService
      if (Get.isRegistered<ExchangeRateService>()) {
        final exchangeRates = Get.find<ExchangeRateService>();
        final cryptoRate = exchangeRates.rates[code];
        final usdRate =
            exchangeRates.rates['USD'] ?? exchangeRates.rates['USDT'];
        if (cryptoRate != null && cryptoRate > 0) {
          dynamicRate = (usdRate != null && usdRate > 0)
              ? (cryptoRate / usdRate)
              : cryptoRate;
        }
      }

      // Dynamic rate lookup from WalletLiveRateService (IRR cross-rate against USD)
      if (dynamicRate == null && Get.isRegistered<WalletLiveRateService>()) {
        final liveRates = Get.find<WalletLiveRateService>();
        final cryptoIrr = liveRates.ratesIrr[code];
        final usdIrr = liveRates.ratesIrr['USD'] ?? liveRates.ratesIrr['USDT'];
        if (cryptoIrr != null &&
            cryptoIrr > 0 &&
            usdIrr != null &&
            usdIrr > 0) {
          dynamicRate = cryptoIrr / usdIrr;
        }
      }

      // Conversion rate from wallet model if available and valid
      if (dynamicRate == null &&
          wallet.conversionRate != null &&
          wallet.conversionRate!.isNotEmpty) {
        final parsed = double.tryParse(
          wallet.conversionRate!.replaceAll(',', ''),
        );
        if (parsed != null && parsed > 0) {
          dynamicRate = parsed < 0.001 ? (1.0 / parsed) : parsed;
        }
      }

      // Hardcoded fallback for major cryptos
      if (dynamicRate == null) {
        switch (code) {
          case 'BTC':
            dynamicRate = 68450.0;
          case 'ETH':
            dynamicRate = 3520.0;
          case 'BNB':
            dynamicRate = 600.0;
          case 'SOL':
            dynamicRate = 180.0;
          case 'TRX':
            dynamicRate = 0.16;
          case 'XRP':
            dynamicRate = 0.55;
          case 'LTC':
            dynamicRate = 75.0;
          default:
            dynamicRate = 1.0;
        }
      }

      return rawBalance * dynamicRate;
    }

    // 3. Fiat Currencies
    double? usdToIrr;
    if (Get.isRegistered<WalletLiveRateService>()) {
      final liveRates = Get.find<WalletLiveRateService>();
      usdToIrr = liveRates.ratesIrr['USD'] ?? liveRates.ratesIrr['USDT'];
    }

    if (code == 'IRT' || code == 'TOMAN') {
      double usdToIrt =
          (usdToIrr != null && usdToIrr > 0) ? (usdToIrr / 10.0) : 0.0;
      if (usdToIrt <= 0 &&
          wallet.conversionRate != null &&
          wallet.conversionRate!.isNotEmpty) {
        final parsed = double.tryParse(
          wallet.conversionRate!.replaceAll(',', ''),
        );
        if (parsed != null && parsed > 1000) {
          usdToIrt = parsed;
        } else if (parsed != null && parsed < 0.001) {
          usdToIrt = 1.0 / parsed;
        }
      }
      if (usdToIrt <= 0) usdToIrt = 95000.0;
      return rawBalance / usdToIrt;
    }

    if (code == 'IRR') {
      double rate = usdToIrr ?? 0.0;
      if (rate <= 0 &&
          wallet.conversionRate != null &&
          wallet.conversionRate!.isNotEmpty) {
        final parsed = double.tryParse(
          wallet.conversionRate!.replaceAll(',', ''),
        );
        if (parsed != null && parsed > 10000) {
          rate = parsed;
        } else if (parsed != null && parsed < 0.0001) {
          rate = 1.0 / parsed;
        }
      }
      if (rate <= 0) rate = 950000.0;
      return rawBalance / rate;
    }

    switch (code) {
      case 'EUR':
        return rawBalance * 1.08;
      case 'GBP':
        return rawBalance * 1.30;
      case 'AED':
        return rawBalance / 3.6725;
      case 'TRY':
        return rawBalance / 34.0;
      case 'CNY':
      case 'RMB':
        return rawBalance / 7.24;
      default:
        if (wallet.conversionRate != null &&
            wallet.conversionRate!.isNotEmpty) {
          final parsed = double.tryParse(
            wallet.conversionRate!.replaceAll(',', ''),
          );
          if (parsed != null && parsed > 0) {
            return parsed > 10 ? (rawBalance / parsed) : (rawBalance * parsed);
          }
        }
        return rawBalance;
    }
  }

  /// Total Net Worth calculated in the user's primary/default wallet currency
  double get totalNetWorth {
    if (walletsList.isEmpty) return 0.0;

    double totalUsd = 0.0;
    for (final w in walletsList) {
      totalUsd += walletBalanceInUsd(w);
    }

    final targetCode = primaryCurrencyCode;

    if (targetCode == 'USD' || targetCode == 'USDT' || targetCode == 'USDC') {
      return totalUsd;
    }

    if (targetCode == 'IRT' || targetCode == 'TOMAN') {
      double usdToIrt = 0.0;
      if (Get.isRegistered<WalletLiveRateService>()) {
        final liveRates = Get.find<WalletLiveRateService>();
        final usdIrr = liveRates.ratesIrr['USD'] ?? liveRates.ratesIrr['USDT'];
        if (usdIrr != null && usdIrr > 0) {
          usdToIrt = usdIrr / 10.0;
        }
      }
      if (usdToIrt <= 0) {
        final pw = primaryWallet;
        if (pw?.conversionRate != null && pw!.conversionRate!.isNotEmpty) {
          final parsed = double.tryParse(
            pw.conversionRate!.replaceAll(',', ''),
          );
          if (parsed != null && parsed > 1000) usdToIrt = parsed;
        }
      }
      if (usdToIrt <= 0) usdToIrt = 95000.0;
      return totalUsd * usdToIrt;
    }

    if (targetCode == 'IRR') {
      double usdToIrr = 0.0;
      if (Get.isRegistered<WalletLiveRateService>()) {
        final liveRates = Get.find<WalletLiveRateService>();
        usdToIrr =
            liveRates.ratesIrr['USD'] ?? liveRates.ratesIrr['USDT'] ?? 0.0;
      }
      if (usdToIrr <= 0) {
        final pw = primaryWallet;
        if (pw?.conversionRate != null && pw!.conversionRate!.isNotEmpty) {
          final parsed = double.tryParse(
            pw.conversionRate!.replaceAll(',', ''),
          );
          if (parsed != null && parsed > 10000) usdToIrr = parsed;
        }
      }
      if (usdToIrr <= 0) usdToIrr = 950000.0;
      return totalUsd * usdToIrr;
    }

    if (targetCode == 'EUR') return totalUsd / 1.08;
    if (targetCode == 'GBP') return totalUsd / 1.30;
    if (targetCode == 'AED') return totalUsd * 3.6725;
    if (targetCode == 'TRY') return totalUsd * 34.0;

    return totalUsd;
  }

  /// Total portfolio value in USD (used for secondary equivalent in banner)
  double get totalPortfolioUsd {
    if (walletsList.isEmpty) return 0.0;
    double totalUsd = 0.0;
    for (final w in walletsList) {
      totalUsd += walletBalanceInUsd(w);
    }
    return totalUsd;
  }

  String get primaryCurrencySymbol {
    final pw = primaryWallet;
    if (pw != null && pw.symbol != null && pw.symbol!.isNotEmpty) {
      return pw.symbol!;
    }
    return '\$';
  }

  String get formattedNetWorth {
    final code = primaryCurrencyCode;
    final symbol = primaryCurrencySymbol;
    final isIrt = code == 'IRT' || code == 'TOMAN';
    final isIrr = code == 'IRR';
    final total = totalNetWorth;

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    if (isIrt || isIrr) {
      final intTotal = total.round();
      final formattedInt = intTotal.toString().replaceAllMapped(
        reg,
        (Match m) => '${m[1]},',
      );
      final label = isIrt ? 'تومان' : 'ریال';
      return '$formattedInt $label';
    } else {
      final parts = total.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final formattedInt = intPart.replaceAllMapped(
        reg,
        (Match m) => '${m[1]},',
      );
      return '$symbol$formattedInt.$decPart';
    }
  }

  /// Secondary equivalent string for the Net Worth Banner (e.g. "≈ $150.00 USD" or "≈ 14,250,000 تومان")
  String get secondaryEquivalentNetWorth {
    final code = primaryCurrencyCode;
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    if (code == 'IRT' || code == 'TOMAN' || code == 'IRR') {
      final usdVal = totalPortfolioUsd;
      final parts = usdVal.toStringAsFixed(2).split('.');
      final formattedInt = parts[0].replaceAllMapped(
        reg,
        (Match m) => '${m[1]},',
      );
      return '≈ \$$formattedInt.${parts[1]} USD';
    } else {
      double usdToIrt = 95000.0;
      if (Get.isRegistered<WalletLiveRateService>()) {
        final liveRates = Get.find<WalletLiveRateService>();
        final usdIrr = liveRates.ratesIrr['USD'] ?? liveRates.ratesIrr['USDT'];
        if (usdIrr != null && usdIrr > 0) usdToIrt = usdIrr / 10.0;
      }
      final tomanVal = (totalPortfolioUsd * usdToIrt).round();
      final formattedToman = tomanVal.toString().replaceAllMapped(
        reg,
        (Match m) => '${m[1]},',
      );
      return '≈ $formattedToman تومان';
    }
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
    if (Get.isRegistered<SettingsService>()) {
      final settings = Get.find<SettingsService>();
      isPrivacyMode.value = settings.isPrivacyMode.value;
      ever<bool>(settings.isPrivacyMode, (val) {
        if (isPrivacyMode.value != val) isPrivacyMode.value = val;
      });
    }
    fetchWallets();
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSubscription = AppEventBus.on<AppEvent>().listen((event) {
      if (event is BalanceChangedEvent || event is WalletListChangedEvent) {
        debugPrint(
          '⚡ [WalletsController] auto-refreshing wallets on ${event.runtimeType}',
        );
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
        localizationOrNull?.allControllerLoadError ??
            'Failed to delete wallet. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

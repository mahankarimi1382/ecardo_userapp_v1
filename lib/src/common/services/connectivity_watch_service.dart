import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Watches network + VPN and routes the user to the offline screen / banners.
///
/// Hardened against rapid connectivity flipping, route spam, and unhandled
/// timer/navigation thrashing during transient Wi-Fi/cellular handovers.
class ConnectivityWatchService extends GetxService with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final RxBool isOffline = false.obs;
  final RxBool isVpn = false.obs;
  bool _wasOffline = false;

  Timer? _debounceTimer;
  bool _isNavigating = false;
  DateTime? _lastToastAt;

  static const Duration _offlineDebounce = Duration(milliseconds: 2000);
  static const Duration _onlineDebounce = Duration(milliseconds: 1200);
  static const Duration _toastThrottle = Duration(seconds: 10);

  Future<ConnectivityWatchService> init() async {
    WidgetsBinding.instance.addObserver(this);
    final initial = await _connectivity.checkConnectivity();
    _handleConnectivityChange(initial, immediate: true);
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results, immediate: false);
    });
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _sub?.cancel();
    _sub = null;
    _isNavigating = false;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivity.checkConnectivity().then((results) {
        _handleConnectivityChange(results, immediate: false);
      });
    }
  }

  void _handleConnectivityChange(
    List<ConnectivityResult> results, {
    bool immediate = false,
  }) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    final vpn = results.contains(ConnectivityResult.vpn);

    isOffline.value = offline;
    isVpn.value = vpn && !offline;

    _debounceTimer?.cancel();

    if (offline) {
      // In demo mode, zero-network interactive test is expected — never trap the user:
      if (Get.isRegistered<DemoAccountService>() &&
          DemoAccountService.to.isDemoMode.value) {
        return;
      }
      final route = Get.currentRoute;
      // Never trap the cold-start splash / welcome on a transient none result.
      if (route == BaseRoute.root ||
          route == BaseRoute.splash ||
          route == BaseRoute.welcome) {
        isOffline.value = true;
        return;
      }

      if (immediate) {
        _navigateToNoInternet();
      } else {
        // Debounce to absorb transient network drops/handovers (e.g. 4G to WiFi)
        _debounceTimer = Timer(_offlineDebounce, () {
          if (isOffline.value) {
            _navigateToNoInternet();
          }
        });
      }
      return;
    }

    // Network is back online
    if (_wasOffline) {
      if (immediate) {
        _navigateBackOnline();
      } else {
        // Debounce online restoration to ensure connection has stabilized
        _debounceTimer = Timer(_onlineDebounce, () {
          if (!isOffline.value && _wasOffline) {
            _navigateBackOnline();
          }
        });
      }
    }
  }

  void _navigateToNoInternet() {
    if (_isNavigating) return;
    final route = Get.currentRoute;
    if (route == BaseRoute.noInternetConnection) return;
    if (route == BaseRoute.root ||
        route == BaseRoute.splash ||
        route == BaseRoute.welcome) {
      return;
    }

    _wasOffline = true;
    _isNavigating = true;
    try {
      Get.offAllNamed(BaseRoute.noInternetConnection);
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        _isNavigating = false;
      });
    }
  }

  void _navigateBackOnline() {
    if (_isNavigating) return;
    _wasOffline = false;

    // Throttle toast notifications to prevent spamming the UI
    final now = DateTime.now();
    if (_lastToastAt == null ||
        now.difference(_lastToastAt!) > _toastThrottle) {
      _lastToastAt = now;
      final loc =
          Get.context != null ? AppLocalizations.of(Get.context!) : null;
      ToastHelper().showSuccessToast(
        loc?.networkReconnected ?? 'Back online',
      );
    }

    if (Get.currentRoute == BaseRoute.noInternetConnection) {
      _isNavigating = true;
      try {
        Get.offAllNamed(BaseRoute.splash);
      } finally {
        Future.delayed(const Duration(milliseconds: 600), () {
          _isNavigating = false;
        });
      }
    }
  }
}

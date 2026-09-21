import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Watches network + VPN and routes the user to the offline screen / banners.
class ConnectivityWatchService extends GetxService with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final RxBool isOffline = false.obs;
  final RxBool isVpn = false.obs;
  bool _wasOffline = false;

  Future<ConnectivityWatchService> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _refresh(await _connectivity.checkConnectivity());
    _sub = _connectivity.onConnectivityChanged.listen(_refresh);
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivity.checkConnectivity().then(_refresh);
    }
  }

  Future<void> _refresh(List<ConnectivityResult> results) async {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    final vpn = results.contains(ConnectivityResult.vpn);

    isOffline.value = offline;
    isVpn.value = vpn && !offline;

    if (offline) {
      final route = Get.currentRoute;
      // Never trap the cold-start splash / welcome on a transient none result.
      if (route == BaseRoute.root ||
          route == BaseRoute.splash ||
          route == BaseRoute.welcome) {
        isOffline.value = true;
        return;
      }
      _wasOffline = true;
      if (route != BaseRoute.noInternetConnection) {
        Get.offAllNamed(BaseRoute.noInternetConnection);
      }
      return;
    }

    if (_wasOffline) {
      _wasOffline = false;
      final loc = Get.context != null ? AppLocalizations.of(Get.context!) : null;
      ToastHelper().showSuccessToast(
        loc?.networkReconnected ?? 'Back online',
      );
      if (Get.currentRoute == BaseRoute.noInternetConnection) {
        Get.offAllNamed(BaseRoute.splash);
      }
    }
  }
}

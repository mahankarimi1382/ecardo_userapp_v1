import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

/// Ends the local session after [idleTimeout] of no user interaction while
/// the app is in the foreground. Does not replace server JWT expiry — that
/// still flows through the 401 / refresh path in [NetworkService].
class SessionTimeoutService extends GetxService with WidgetsBindingObserver {
  SessionTimeoutService({this.idleTimeout = const Duration(minutes: 30)});

  final Duration idleTimeout;
  Timer? _timer;
  DateTime _lastActivity = DateTime.now();

  Future<SessionTimeoutService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _arm();
    return this;
  }

  void touch() {
    _lastActivity = DateTime.now();
    _arm();
  }

  void _arm() {
    _timer?.cancel();
    _timer = Timer(idleTimeout, _onIdle);
  }

  Future<void> _onIdle() async {
    final token = Get.isRegistered<TokenService>()
        ? Get.find<TokenService>().accessToken.value
        : null;
    if (token == null || token.isEmpty) return;

    try {
      await Get.find<TokenService>().clearToken();
      await Get.find<SettingsService>().wipeSession();
    } catch (_) {}

    final loc = Get.context != null ? AppLocalizations.of(Get.context!) : null;
    ToastHelper().showErrorToast(
      loc?.unauthorizedDialogTitle ??
          'Your session has expired. Please sign in again.',
    );
    if (Get.currentRoute != BaseRoute.signIn) {
      Get.offAllNamed(BaseRoute.signIn);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final idle = DateTime.now().difference(_lastActivity);
      if (idle >= idleTimeout) {
        _onIdle();
      } else {
        _arm();
      }
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }
}

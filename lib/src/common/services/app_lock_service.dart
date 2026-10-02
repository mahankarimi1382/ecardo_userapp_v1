import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// App lock with hashed PIN + auto-lock on resume.
///
/// PERFORMANCE & LIFECYCLE AUDIT NOTE:
/// This service intentionally uses ZERO background timers or periodic loops.
/// Inactivity/auto-lock is calculated passively on OS lifecycle transitions
/// ([AppLifecycleState.paused] records timestamp; [AppLifecycleState.resumed]
/// computes elapsed delta). This guarantees 0% CPU consumption in background.
class AppLockService extends GetxService with WidgetsBindingObserver {
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _failedKey = 'app_lock_failed_count';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final RxBool locked = false.obs;
  final RxInt failedAttempts = 0.obs;
  DateTime? _pausedAt;
  bool _isResuming = false;

  Future<AppLockService> init() async {
    WidgetsBinding.instance.addObserver(this);
    // Cold start: NEVER start locked automatically.
    locked.value = false;
    try {
      final prefsFail = await _secure.read(key: _failedKey);
      failedAttempts.value = int.tryParse(prefsFail ?? '0') ?? 0;
    } catch (e) {
      failedAttempts.value = 0;
    }
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pausedAt = null;
    _isResuming = false;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }

  Future<void> _onResumed() async {
    if (_isResuming) return;
    _isResuming = true;

    try {
      final loginState = await SettingsService.getLoginCurrentState();
      if (loginState == null || loginState.isEmpty) return;
      if (!await hasPinSet()) return;
      final timeout = await getAutoLockTimeout();
      // 0 = Never auto-lock on resume
      if (timeout == Duration.zero) return;

      if (timeout.inMilliseconds < 0) {
        // immediate: any backgrounding locks
        await lock();
        return;
      }
      final paused = _pausedAt;
      if (paused == null) return;
      if (DateTime.now().difference(paused) >= timeout) {
        await lock();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppLockService._onResumed error: $e\n$st');
      }
    } finally {
      _isResuming = false;
    }
  }

  static bool isPreAuthRoute(String? route) {
    if (route == null || route.isEmpty) return true;
    return route == BaseRoute.root ||
        route == BaseRoute.splash ||
        route == BaseRoute.noInternetConnection ||
        route == BaseRoute.welcome ||
        route == BaseRoute.signIn ||
        route == BaseRoute.emailOtpLogin ||
        route == BaseRoute.twoFactorAuth ||
        route == BaseRoute.email ||
        route == BaseRoute.verifyEmail ||
        route == BaseRoute.signUpStatus ||
        route == BaseRoute.setUpPassword ||
        route == BaseRoute.forgotPassword ||
        route == BaseRoute.forgotPasswordPinVerification ||
        route == BaseRoute.resetPassword ||
        route == BaseRoute.appUpdate;
  }

  Future<bool> isLocked() async => locked.value;

  Future<void> lock() async {
    try {
      final loginState = await SettingsService.getLoginCurrentState();
      if (loginState == null || loginState.isEmpty) return;
      if (!await hasPinSet()) return;
      if (isPreAuthRoute(Get.currentRoute)) return;
      locked.value = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppLockService.lock error: $e');
      }
    }
  }

  Future<bool> unlock(String pin) async {
    try {
      final ok = await verifyPin(pin);
      if (ok) {
        locked.value = false;
        failedAttempts.value = 0;
        await _secure.write(key: _failedKey, value: '0');
        return true;
      }
      failedAttempts.value++;
      await _secure.write(
        key: _failedKey,
        value: '${failedAttempts.value}',
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppLockService.unlock error: $e');
      }
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 4 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN must be 4 digits');
    }
    final salt = _randomSalt();
    final hash = _hash(pin, salt);
    await _secure.write(key: _pinSaltKey, value: salt);
    await _secure.write(key: _pinHashKey, value: hash);
  }

  Future<bool> hasPinSet() async {
    try {
      final h = await _secure.read(key: _pinHashKey);
      return h != null && h.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppLockService.hasPinSet error: $e');
      }
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    try {
      final salt = await _secure.read(key: _pinSaltKey);
      final hash = await _secure.read(key: _pinHashKey);
      if (salt == null || hash == null) return false;
      return _hash(pin, salt) == hash;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppLockService.verifyPin error: $e');
      }
      return false;
    }
  }

  Future<void> clearPin() async {
    try {
      await _secure.delete(key: _pinHashKey);
      await _secure.delete(key: _pinSaltKey);
      await _secure.delete(key: _failedKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppLockService.clearPin error: $e');
      }
    }
    locked.value = false;
    failedAttempts.value = 0;
  }

  /// 0 = never (only when auto-login off locks on resume),
  /// negative = immediate, else minutes from settings.
  Future<Duration> getAutoLockTimeout() async {
    if (!Get.isRegistered<SettingsService>()) return Duration.zero;
    final m = await Get.find<SettingsService>().getAppLockMinutes();
    if (m < 0) return const Duration(milliseconds: -1); // immediate sentinel
    if (m == 0) return Duration.zero;
    return Duration(minutes: m);
  }

  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().setAppLockMinutes(minutes);
    }
  }

  void debugForceLock() {
    if (kDebugMode) locked.value = true;
  }

  String _randomSalt() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }
}

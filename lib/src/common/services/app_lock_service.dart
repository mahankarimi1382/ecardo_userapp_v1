import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// App lock with hashed PIN + auto-lock on resume.
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

  Future<AppLockService> init() async {
    WidgetsBinding.instance.addObserver(this);
    final hasLocalUnlock = await _hasLocalUnlockMethod();
    final autoLogin = Get.isRegistered<SettingsService>()
        ? await Get.find<SettingsService>().getAutoLogin()
        : true;
    // Cold start: if PIN set and auto-login off → start locked.
    if (hasLocalUnlock && !autoLogin) {
      locked.value = true;
    }
    final prefsFail = await _secure.read(key: _failedKey);
    failedAttempts.value = int.tryParse(prefsFail ?? '0') ?? 0;
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
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
    if (!await _hasLocalUnlockMethod()) return;
    final timeout = await getAutoLockTimeout();
    if (timeout == Duration.zero) {
      // "never" unless auto-login is off → lock every resume
      final autoLogin = await Get.find<SettingsService>().getAutoLogin();
      if (!autoLogin) await lock();
      return;
    }
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
  }

  Future<bool> isLocked() async => locked.value;

  Future<void> lock() async {
    if (!await _hasLocalUnlockMethod()) return;
    locked.value = true;
  }

  Future<bool> _hasLocalUnlockMethod() async {
    if (await hasPinSet()) return true;
    // getBiometricEnableOrDisable is a static prefs reader (not instance method).
    return await SettingsService.getBiometricEnableOrDisable() == true;
  }

  Future<bool> unlock(String pin) async {
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
    final h = await _secure.read(key: _pinHashKey);
    return h != null && h.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(key: _pinSaltKey);
    final hash = await _secure.read(key: _pinHashKey);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  Future<void> clearPin() async {
    await _secure.delete(key: _pinHashKey);
    await _secure.delete(key: _pinSaltKey);
    await _secure.delete(key: _failedKey);
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

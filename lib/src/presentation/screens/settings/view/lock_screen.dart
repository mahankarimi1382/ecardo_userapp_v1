import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Full-screen PIN gate. Shown by [AppLockWrapper] when locked.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _error;
  bool _bioTried = false;

  AppLockService get _lock => Get.find<AppLockService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBio());
  }

  Future<void> _tryBio() async {
    if (_bioTried) return;
    _bioTried = true;
    try {
      final bio = BiometricAuthService();
      if (await bio.isEnabled() && await bio.canAuthenticate()) {
        final ok = await bio.authenticate(reason: 'باز کردن قفل eCardo');
        if (ok && mounted) {
          _lock.locked.value = false;
          _lock.failedAttempts.value = 0;
        }
      }
    } catch (_) {}
  }

  Future<void> _onDigit(String d) async {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) {
      final ok = await _lock.unlock(_pin);
      if (!mounted) return;
      if (ok) {
        setState(() => _pin = '');
        return;
      }
      final fails = _lock.failedAttempts.value;
      if (fails >= 5) {
        await _forceLogout();
        return;
      }
      setState(() {
        _pin = '';
        _error = fails >= 3
            ? 'رمز اشتباه — $fails تلاش ناموفق'
            : 'PIN نادرست';
      });
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _forceLogout() async {
    try {
      if (Get.isRegistered<SettingsService>()) {
        await Get.find<SettingsService>().wipeSession();
      }
    } catch (_) {}
    await _lock.clearPin();
    Get.offAllNamed(BaseRoute.signIn);
  }

  Future<void> _forgotPin() async {
    final go = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('فراموشی PIN'),
        content: const Text(
          'برای تنظیم مجدد PIN باید از حساب خارج شوید و دوباره وارد شوید. داده‌های سرور حذف نمی‌شوند.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('انصراف')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('خروج')),
        ],
      ),
    );
    if (go == true) await _forceLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightPrimary,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.lock_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'قفل eCardo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PIN چهار رقمی را وارد کنید',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.white : Colors.white24,
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFFFCDD2))),
            ],
            const Spacer(),
            _keypad(),
            TextButton(
              onPressed: _forgotPin,
              child: const Text(
                'فراموشی PIN',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              if (k.isEmpty) return const SizedBox(width: 72, height: 72);
              return InkWell(
                onTap: () {
                  if (k == '⌫') {
                    _backspace();
                  } else {
                    _onDigit(k);
                  }
                },
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  child: Text(
                    k,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

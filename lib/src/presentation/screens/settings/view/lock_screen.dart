import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

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
    final reasonText = l10nPick(
      context,
      en: 'Unlock eCardo',
      fa: 'باز کردن قفل eCardo',
      ar: 'فتح قفل eCardo',
      zh: '解锁 eCardo',
    );
    try {
      final bio = BiometricAuthService();
      if (await bio.isEnabled() && await bio.canAuthenticate()) {
        final ok = await bio.authenticate(reason: reasonText);
        if (ok && mounted) {
          _lock.locked.value = false;
          _lock.failedAttempts.value = 0;
        }
      }
    } catch (_) {}
  }

  Future<void> _onDigit(String d) async {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
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
            ? l10nPick(
                context,
                en: 'Incorrect PIN — $fails failed attempts',
                fa: 'رمز اشتباه — $fails تلاش ناموفق',
                ar: 'رمز خاطئ — $fails محاولات فاشلة',
                zh: '密码错误 — 已尝试失败 $fails 次',
              )
            : l10nPick(
                context,
                en: 'Incorrect PIN',
                fa: 'PIN نادرست',
                ar: 'رمز PIN غير صحيح',
                zh: 'PIN码错误',
              );
      });
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
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
    HapticFeedback.lightImpact();
    final go = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Text(
          l10nPick(context, en: 'Forgot PIN?', fa: 'فراموشی PIN', ar: 'هل نسيت الرمز؟', zh: '忘记密码？'),
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          l10nPick(
            context,
            en: 'To reset your PIN, you need to sign out and log back in. Your server data is preserved.',
            fa: 'برای تنظیم مجدد PIN باید از حساب خارج شوید و دوباره وارد شوید. داده‌های سرور حذف نمی‌شوند.',
            ar: 'لإعادة تعيين الرمز، يجب تسجيل الخروج والدخول مجدداً. بياناتك على الخادم محفوظة.',
            zh: '如需重置密码，您需要退出登录并重新登录。服务器数据将被完整保留。',
          ),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              l10nPick(context, en: 'Sign Out', fa: 'خروج', ar: 'خروج', zh: '退出登录'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (go == true) await _forceLogout();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.deepBlack : AppColors.lightPrimary;

    return Material(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.huge),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.white, size: 40),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              l10nPick(
                context,
                en: 'eCardo Security Lock',
                fa: 'قفل eCardo',
                ar: 'قفل eCardo',
                zh: 'eCardo 安全锁',
              ),
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              l10nPick(
                context,
                en: 'Enter 4-digit PIN',
                fa: 'PIN چهار رقمی را وارد کنید',
                ar: 'أدخل رمز PIN المكون من 4 أرقام',
                zh: '输入4位PIN码',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return AnimatedContainer(
                  duration: AppSpacing.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.white : AppColors.white.withValues(alpha: 0.25),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFFFCDD2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const Spacer(),
            _keypad(),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _forgotPin,
              child: Text(
                l10nPick(
                  context,
                  en: 'Forgot PIN?',
                  fa: 'فراموشی PIN',
                  ar: 'نسيت الرمز؟',
                  zh: '忘记PIN码？',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.bottomSafe(context, 12)),
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
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
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

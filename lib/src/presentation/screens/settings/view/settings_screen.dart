import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';


import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/transaction_pin/transaction_pin_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Grouped settings hub — account / security / notifications / permissions /
/// personalization / general. No heavy packages; Material icons only.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HomeController homeController = Get.find();
  final SettingsService settings = Get.find();
  final BiometricAuthService _bio = BiometricAuthService();

  bool _bioSupported = false;
  bool _bioEnabled = false;
  bool _autoLogin = true;
  int _lockMinutes = 0;
  bool _notifFinancial = true;
  bool _notifPromo = false;
  bool _notifSound = true;
  bool _notifVibrate = true;
  String _themePref = 'system';
  String _rateUnit = 'irr';
  String _version = '';
  bool _notifGranted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!homeController.isSettingsInitialized.value) {
      homeController.loadUser();
      homeController.isSettingsInitialized.value = true;
    }
    _load();
  }

  Future<void> _load() async {
    final supported = await _bio.isSupported();
    var enabled = await _bio.isEnabled();
    if (enabled && !await _bio.canAuthenticate()) {
      await settings.saveBiometricEnableOrDisable(false);
      enabled = false;
    }
    final lock = await settings.getAppLockMinutes();
    final auto = await settings.getAutoLogin();
    final fin = await settings.getNotifPref(SettingsService.notifFinancialKey);
    final promo = await settings.getNotifPref(
      SettingsService.notifPromoKey,
      def: false,
    );
    final sound = await settings.getNotifPref(SettingsService.notifSoundKey);
    final vib = await settings.getNotifPref(SettingsService.notifVibrateKey);
    final theme = await settings.getThemeModePref();
    final unit = await settings.getRateUnit();
    final notif = await Permission.notification.status;
    String ver = '';
    try {
      final info = await PackageInfo.fromPlatform();
      ver = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _bioSupported = supported;
      _bioEnabled = enabled;
      _lockMinutes = lock;
      _autoLogin = auto;
      _notifFinancial = fin;
      _notifPromo = promo;
      _notifSound = sound;
      _notifVibrate = vib;
      _themePref = theme;
      _rateUnit = unit;
      _version = ver;
      _notifGranted = notif.isGranted || notif.isLimited;
      _loading = false;
    });
  }

  Future<void> _toggleBio(bool value) async {
    if (value) {
      final ok = await _bio.enable();
      if (ok && mounted) setState(() => _bioEnabled = true);
    } else {
      final ok = await _bio.disable();
      if (ok && mounted) setState(() => _bioEnabled = false);
    }
  }

  Future<void> _confirmLogout() async {
    final go = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('خروج از حساب'),
        content: const Text('از حساب کاربری خارج می‌شوید؟'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('انصراف')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('خروج')),
        ],
      ),
    );
    if (go == true) await homeController.submitLogout();
  }

  Future<void> _changePin() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10nPick(Get.context!, en: 'App Lock PIN (4 digits)', fa: 'PIN قفل دستگاه (۴ رقم)', ar: 'رمز قفل التطبيق', zh: '设备锁定PIN')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN جدید'),
            ),
            TextField(
              controller: c2,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'تکرار PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('انصراف')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('ذخیره')),
        ],
      ),
    );
    if (ok == true && c1.text.length == 4 && c1.text == c2.text) {
      if (Get.isRegistered<AppLockService>()) {
        await Get.find<AppLockService>().setPin(c1.text);
      }
      await settings.setAppPin('set');
      Get.snackbar('PIN', 'ذخیره شد', snackPosition: SnackPosition.BOTTOM);
    } else if (ok == true) {
      Get.snackbar('PIN', 'PIN باید ۴ رقم و یکسان باشد', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _applyTheme(String mode) {
    setState(() => _themePref = mode);
    if (Get.isRegistered<LocaleThemeService>()) {
      Get.find<LocaleThemeService>().setThemeModePref(mode);
    } else {
      settings.setThemeModePref(mode);
      Get.changeThemeMode(switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.settingsScreenTitle),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.page,
                12,
                AppSpacing.page,
                32,
              ),
              children: [
                _group(l10nPick(context, en: 'Account', fa: 'حساب کاربری', ar: 'الحساب', zh: '账户'), [
                  _navTile(
                    Icons.person_outline,
                    'پروفایل',
                    'نام و عکس',
                    () => Get.toNamed(BaseRoute.profileSettings),
                  ),
                  if (settings.getSetting('kyc_verification') == '1')
                    _navTile(
                      Icons.badge_outlined,
                      loc.settingsIdVerification,
                      null,
                      () => Get.toNamed(BaseRoute.kycHistory),
                    ),
                  _navTile(
                    Icons.delete_outline,
                    'حذف حساب',
                    'از طریق پشتیبانی درخواست دهید',
                    () async {
                      if (settings.getSetting('user_ticket') == '1') {
                        Get.toNamed(BaseRoute.supportTickets);
                      } else {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('حذف حساب'),
                            content: const Text(
                              'برای حذف حساب با پشتیبانی eCardo تماس بگیرید.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('باشه'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ]),
                _group(l10nPick(context, en: 'Security', fa: 'امنیت', ar: 'الأمان', zh: '安全'), [
                  _navTile(
                    Icons.lock_outline,
                    loc.settingsChangePassword,
                    l10nPick(context, en: 'Account password', fa: 'رمز ورود حساب', ar: 'كلمة مرور الحساب', zh: '登录密码'),
                    () => Get.toNamed(BaseRoute.changePassword),
                  ),
                  _navTile(
                    Icons.vpn_key_outlined,
                    l10nPick(context, en: 'Transaction PIN', fa: 'رمز انتقال وجه', ar: 'رمز التحويل', zh: '转账密码'),
                    l10nPick(context, en: '4–6 digits for transfers & payments', fa: '۴ تا ۶ رقم برای انتقال و پرداخت', ar: '4–6 أرقام للتحويل والدفع', zh: '转账与支付用4–6位'),
                    () {
                      Get.to(() => const TransactionPinScreen());
                    },
                  ),
                  if (settings.getSetting('fa_verification') == '1')
                    _navTile(
                      Icons.security,
                      loc.settingsTwoFactorAuthentication,
                      l10nPick(context, en: 'Google Authenticator — login only', fa: 'ورود دو مرحله‌ای — فقط لاگین', ar: 'المصادقة الثنائية — تسجيل الدخول فقط', zh: '双重认证—仅登录'),
                      () => Get.toNamed(BaseRoute.twoFactorAuthentication),
                    ),
                  _navTile(
                    Icons.password_outlined,
                    l10nPick(context, en: 'Payment OTP generator', fa: 'رمزساز پرداخت (رمز یک‌بارمصرف)', ar: 'مولّد OTP للدفع', zh: '支付一次性密码'),
                    l10nPick(context, en: 'For web / pro-pay pages only', fa: 'فقط برای صفحه پرداخت وب', ar: 'لصفحات الدفع على الويب فقط', zh: '仅用于网页支付'),
                    () => Get.toNamed(BaseRoute.dynamicPassword),
                  ),
                  if (_bioSupported)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('ورود با بیومتریک'),
                      subtitle: Text(
                        _bioEnabled
                            ? 'فعال'
                            : 'با اثر انگشت یا چهره وارد شوید',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _bioEnabled,
                      onChanged: _toggleBio,
                    )
                  else
                    const SizedBox.shrink(),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.login),
                    title: const Text('ورود خودکار'),
                    value: _autoLogin,
                    onChanged: (v) async {
                      await settings.setAutoLogin(v);
                      setState(() => _autoLogin = v);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('قفل خودکار اپ'),
                    subtitle: Text(_lockLabel(_lockMinutes)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      final v = await showModalBottomSheet<int>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final e in {
                                -1: 'فوری (با هر بار خروج از اپ)',
                                1: '۱ دقیقه',
                                5: '۵ دقیقه',
                                15: '۱۵ دقیقه',
                                0: 'هرگز',
                              }.entries)
                                ListTile(
                                  title: Text(e.value),
                                  onTap: () => Navigator.pop(ctx, e.key),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (v != null) {
                        await settings.setAppLockMinutes(v);
                        setState(() => _lockMinutes = v);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.pin_outlined),
                    title: Text(l10nPick(context, en: 'App Lock PIN', fa: 'PIN قفل دستگاه', ar: 'رمز قفل التطبيق', zh: '设备锁定PIN')),
                    subtitle: Text(l10nPick(context, en: 'Local device unlock only — not transfer PIN', fa: 'فقط باز کردن قفل اپ — نه رمز انتقال', ar: 'لفتح التطبيق فقط — ليس رمز التحويل', zh: '仅用于解锁应用，非转账密码')),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: _changePin,
                  ),
                ]),
                _group(l10nPick(context, en: 'Notifications', fa: 'اعلان‌ها', ar: 'الإشعارات', zh: '通知'), [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _notifGranted
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: _notifGranted ? AppColors.success : AppColors.error,
                    ),
                    title: const Text('دسترسی اعلان سیستم'),
                    subtitle: Text(_notifGranted ? 'فعال' : 'غیرفعال — برای تراکنش‌ها لازم است'),
                    trailing: _notifGranted
                        ? null
                        : TextButton(
                            onPressed: () => openAppSettings(),
                            child: const Text('تنظیمات'),
                          ),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('اعلان مالی'),
                    value: _notifFinancial,
                    onChanged: (v) async {
                      await settings.setNotifPref(
                        SettingsService.notifFinancialKey,
                        v,
                      );
                      setState(() => _notifFinancial = v);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('اعلان تبلیغاتی'),
                    value: _notifPromo,
                    onChanged: (v) async {
                      await settings.setNotifPref(
                        SettingsService.notifPromoKey,
                        v,
                      );
                      setState(() => _notifPromo = v);
                    },
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('اعلان امنیتی'),
                    subtitle: Text('همیشه فعال'),
                    trailing: Icon(Icons.lock, size: 18, color: AppColors.success),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('صدا'),
                    value: _notifSound,
                    onChanged: (v) async {
                      await settings.setNotifPref(
                        SettingsService.notifSoundKey,
                        v,
                      );
                      setState(() => _notifSound = v);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('ویبره'),
                    value: _notifVibrate,
                    onChanged: (v) async {
                      await settings.setNotifPref(
                        SettingsService.notifVibrateKey,
                        v,
                      );
                      setState(() => _notifVibrate = v);
                    },
                  ),
                  _navTile(
                    Icons.list_alt,
                    loc.settingsAllNotification,
                    null,
                    () => Get.toNamed(BaseRoute.notifications),
                  ),
                ]),
                _group(l10nPick(context, en: 'Permissions', fa: 'دسترسی‌ها', ar: 'الصلاحيات', zh: '权限'), [
                  _navTile(
                    Icons.admin_panel_settings_outlined,
                    'مدیریت دسترسی‌ها',
                    'دوربین، گالری، اعلان، …',
                    () => Get.toNamed(BaseRoute.permissionsSettings),
                  ),
                ]),
                _group(l10nPick(context, en: 'Personalization', fa: 'شخصی‌سازی', ar: 'التخصيص', zh: '个性化'), [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language),
                    title: Text(l10nPick(context, en: 'Language', fa: 'زبان', ar: 'اللغة', zh: '语言')),
                    subtitle: Text(LocaleThemeService.nativeName(
                      Localizations.localeOf(context).languageCode,
                    )),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      final code = await showModalBottomSheet<String>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final c in LocaleThemeService.supported)
                                ListTile(
                                  title: Text(LocaleThemeService.nativeName(c)),
                                  trailing: Localizations.localeOf(context).languageCode == c
                                      ? const Icon(Icons.check, color: AppColors.success)
                                      : null,
                                  onTap: () => Navigator.pop(ctx, c),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (code != null && Get.isRegistered<LocaleThemeService>()) {
                        await Get.find<LocaleThemeService>().setLanguage(code);
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('تم'),
                    subtitle: Text(_themeLabel(_themePref)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      final v = await showModalBottomSheet<String>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final e in {
                                'system': 'سیستم',
                                'light': 'روشن',
                                'dark': 'تیره',
                              }.entries)
                                ListTile(
                                  title: Text(e.value),
                                  onTap: () => Navigator.pop(ctx, e.key),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (v != null) _applyTheme(v);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.currency_exchange),
                    title: const Text('واحد نمایش نرخ'),
                    subtitle: Text(_rateUnit == 'toman' ? 'تومان' : 'ریال (IRR)'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      final v = await showModalBottomSheet<String>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('ریال (IRR)'),
                                onTap: () => Navigator.pop(ctx, 'irr'),
                              ),
                              ListTile(
                                title: const Text('تومان'),
                                onTap: () => Navigator.pop(ctx, 'toman'),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (v != null) {
                        await settings.setRateUnit(v);
                        setState(() => _rateUnit = v);
                      }
                    },
                  ),
                ]),
                _group(l10nPick(context, en: 'General', fa: 'عمومی', ar: 'عام', zh: '通用'), [
                  if (settings.getSetting('user_ticket') == '1')
                    _navTile(
                      Icons.support_agent,
                      loc.settingsSupport,
                      null,
                      () => Get.toNamed(BaseRoute.supportTickets),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: const Text('درباره ما'),
                    subtitle: Text(_version.isEmpty ? 'eCardo' : 'نسخه $_version'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.policy_outlined),
                    title: const Text('قوانین و حریم خصوصی'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Get.toNamed(BaseRoute.privacyPolicy),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.system_update),
                    title: const Text('بررسی به‌روزرسانی'),
                    onTap: () {
                      if (Get.isRegistered<AppUpdateController>()) {
                        Get.find<AppUpdateController>().checkForUpdate();
                      } else {
                        Get.toNamed(BaseRoute.appUpdate);
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    loc.settingsSignOut,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
    );
  }

  String _lockLabel(int m) {
    if (m < 0) return 'فوری';
    if (m == 0) return 'هرگز';
    if (m == 1) return '۱ دقیقه';
    return '$m دقیقه';
  }

  String _themeLabel(String m) => switch (m) {
        'light' => 'روشن',
        'dark' => 'تیره',
        _ => 'سیستم',
      };

  Widget _group(String title, List<Widget> children) {
    final visible = children.where((c) => c is! SizedBox).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: visible),
          ),
        ],
      ),
    );
  }

  Widget _navTile(
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}

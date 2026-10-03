import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final go = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: cardBg,
        title: Text(
          l10nPick(
            context,
            en: 'Sign out',
            fa: 'خروج از حساب',
            ar: 'تسجيل الخروج',
            tr: 'Çıkış Yap',
            ru: 'Выход из аккаунта',
            zh: '退出登录',
          ),
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10nPick(
            context,
            en: 'You will be signed out of your account.',
            fa: 'از حساب کاربری خارج می‌شوید؟',
            ar: 'هل أنت متأكد من تسجيل الخروج من حسابك؟',
            tr: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
            ru: 'Вы действительно хотите выйти из своего аккаунта?',
            zh: '确定要退出当前账户吗？',
          ),
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              l10nPick(
                context,
                en: 'Cancel',
                fa: 'انصراف',
                ar: 'إلغاء',
                tr: 'İptal',
                ru: 'Отмена',
                zh: '取消',
              ),
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              l10nPick(
                context,
                en: 'Sign out',
                fa: 'خروج',
                ar: 'خروج',
                tr: 'Çıkış',
                ru: 'Выйти',
                zh: '退出',
              ),
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (go == true) await homeController.submitLogout();
  }

  Future<void> _changePin() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: cardBg,
        title: Text(
          l10nPick(
            context,
            en: 'App Lock PIN (4 digits)',
            fa: 'PIN قفل دستگاه (۴ رقم)',
            ar: 'رمز قفل التطبيق',
            zh: '设备锁定PIN',
          ),
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'New PIN', fa: 'PIN جدید'),
              ),
            ),
            TextField(
              controller: c2,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Repeat PIN', fa: 'تکرار PIN'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              l10nPick(context, en: 'Save', fa: 'ذخیره'),
              style: TextStyle(
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true && c1.text.length == 4 && c1.text == c2.text) {
      if (Get.isRegistered<AppLockService>()) {
        await Get.find<AppLockService>().setPin(c1.text);
      }
      await settings.setAppPin('set');
      if (!mounted) return;
      Get.snackbar(
        'PIN',
        l10nPick(context, en: 'Saved', fa: 'ذخیره شد'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (ok == true) {
      Get.snackbar(
        'PIN',
        l10nPick(
          context,
          en: 'The PIN must be 4 digits and match',
          fa: 'PIN باید ۴ رقم و یکسان باشد',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );
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
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final dividerColor = isDark
        ? AppColors.lightWarmGray.withValues(alpha: 0.08)
        : AppColors.lightWarmGray.withValues(alpha: 0.22);

    if (loc == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          loc.settingsScreenTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: scaffoldBg,
        foregroundColor: primaryTextColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.page,
                12,
                AppSpacing.page,
                AppSpacing.bottomSafe(context, 32),
              ),
              children: [
                _group(
                  l10nPick(
                    context,
                    en: 'Account',
                    fa: 'حساب کاربری',
                    ar: 'الحساب',
                    zh: '账户',
                  ),
                  [
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.person_rounded,
                        iconColor: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF2563EB),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Profile',
                        fa: 'پروفایل',
                        ar: 'الملف الشخصي',
                        zh: '个人资料',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Name and photo',
                        fa: 'نام و عکس',
                        ar: 'الاسم والصورة',
                        zh: '姓名与照片',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.profileSettings),
                    ),
                    if (settings.getSetting('kyc_verification') == '1')
                      _navTile(
                        context: context,
                        isDark: isDark,
                        leading: _iconBox(
                          icon: Icons.badge_rounded,
                          iconColor: isDark
                              ? const Color(0xFF5EEAD4)
                              : const Color(0xFF0D9488),
                          backgroundColor: isDark
                              ? const Color(0xFF134E4A).withValues(alpha: 0.5)
                              : const Color(0xFFF0FDFA),
                        ),
                        title: loc.settingsIdVerification,
                        subtitle: l10nPick(
                          context,
                          en: 'Tier & document status',
                          fa: 'وضعیت سطح و مدارک',
                          ar: 'حالة المستوى والمستندات',
                        ),
                        onTap: () => Get.toNamed(BaseRoute.idVerification),
                      ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'Demo & Testing Lab',
                    fa: 'آزمایشگاه تست و دمو (QA Lab)',
                    ar: 'مختبر الحساب التجريبي',
                    zh: '演示与测试实验室',
                  ),
                  [
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.biotech_rounded,
                        iconColor: isDark
                            ? const Color(0xFFC4B5FD)
                            : const Color(0xFF7C3AED),
                        backgroundColor: isDark
                            ? const Color(0xFF2E1065).withValues(alpha: 0.5)
                            : const Color(0xFFF5F3FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Tester Control Panel',
                        fa: 'تنظیمات اکانت تست (کنترل‌پنل دمو)',
                        ar: 'لوحة تحكم الحساب التجريبي',
                        zh: '测试与演示控制台',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Switch KYC levels, recharge wallets, and test mock flows',
                        fa: 'تغییر آنی وضعیت KYC، شارژ مجدد کیف پول‌ها و ریست تست',
                        ar: 'تعديل KYC وشحن المحافظ وتجربة الخدمات',
                        zh: '切换KYC级别、重置多币种钱包、管理模拟数据',
                      ),
                      onTap: () {
                        if (DemoAccountService.isDemoAvailableInThisBuild &&
                            Get.isRegistered<DemoAccountService>()) {
                          DemoAccountService.to
                              .showTesterControlBottomSheet(context);
                        }
                      },
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'Security',
                    fa: 'امنیت',
                    ar: 'الأمان',
                    zh: '安全',
                  ),
                  [
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.lock_rounded,
                        iconColor: isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF4F46E5),
                        backgroundColor: isDark
                            ? const Color(0xFF312E81).withValues(alpha: 0.5)
                            : const Color(0xFFEEF2FF),
                      ),
                      title: loc.settingsChangePassword,
                      subtitle: l10nPick(
                        context,
                        en: 'Account password',
                        fa: 'رمز ورود حساب',
                        ar: 'كلمة مرور الحساب',
                        zh: '登录密码',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.changePassword),
                    ),
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.dialpad_rounded,
                        iconColor: isDark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFFD97706),
                        backgroundColor: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.5)
                            : const Color(0xFFFFFBEB),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Transaction PIN',
                        fa: 'رمز انتقال وجه',
                        ar: 'رمز التحويل',
                        zh: '转账密码',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: '4–6 digits for transfers & payments',
                        fa: '۴ تا ۶ رقم برای انتقال و پرداخت',
                        ar: '4–6 أرقام للتحويل والدفع',
                        zh: '转账与支付用4–6位',
                      ),
                      onTap: () {
                        Get.to(() => const TransactionPinScreen());
                      },
                    ),
                    if (settings.getSetting('fa_verification') == '1')
                      _navTile(
                        context: context,
                        isDark: isDark,
                        leading: _iconBox(
                          icon: Icons.phonelink_lock_rounded,
                          iconColor: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF059669),
                          backgroundColor: isDark
                              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                              : const Color(0xFFECFDF5),
                        ),
                        title: loc.settingsTwoFactorAuthentication,
                        subtitle: l10nPick(
                          context,
                          en: 'Google Authenticator — login only',
                          fa: 'ورود دو مرحله‌ای — فقط لاگین',
                          ar: 'المصادقة الثنائية — تسجيل الدخول فقط',
                          zh: '双重认证—仅登录',
                        ),
                        onTap: () =>
                            Get.toNamed(BaseRoute.twoFactorAuthentication),
                      ),
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.password_rounded,
                        iconColor: isDark
                            ? const Color(0xFF7DD3FC)
                            : const Color(0xFF0284C7),
                        backgroundColor: isDark
                            ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                            : const Color(0xFFF0F9FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Payment OTP generator',
                        fa: 'رمزساز پرداخت (رمز یک‌بارمصرف)',
                        ar: 'مولّد OTP للدفع',
                        zh: '支付一次性密码',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'For web / pro-pay pages only',
                        fa: 'فقط برای صفحه پرداخت وب',
                        ar: 'لصفحات الدفع على الويب فقط',
                        zh: '仅用于网页支付',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.dynamicPassword),
                    ),
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.devices_rounded,
                        iconColor: isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF6366F1),
                        backgroundColor: isDark
                            ? const Color(0xFF312E81).withValues(alpha: 0.5)
                            : const Color(0xFFEEF2FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Devices & Active Sessions',
                        fa: 'دستگاه‌ها و نشست‌های فعال',
                        ar: 'الأجهزة والجلسات النشطة',
                        zh: '设备与活动会话',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Manage signed-in devices and terminate sessions',
                        fa: 'مدیریت دستگاه‌های متصل، این دستگاه و خروج اضطراری',
                        ar: 'إدارة الأجهزة المتصلة والجلسات النشطة',
                        zh: '管理已登录设备与紧急会话终止',
                      ),
                      onTap: () =>
                          Get.toNamed(BaseRoute.deviceSessionsSecurity),
                    ),
                    if (_bioSupported)
                      _switchTile(
                        isDark: isDark,
                        leading: _iconBox(
                          icon: Icons.fingerprint_rounded,
                          iconColor: isDark
                              ? const Color(0xFF2DD4BF)
                              : const Color(0xFF0D9488),
                          backgroundColor: isDark
                              ? const Color(0xFF134E4A).withValues(alpha: 0.5)
                              : const Color(0xFFF0FDFA),
                        ),
                        title: l10nPick(
                          context,
                          en: 'Sign in with biometrics',
                          fa: 'ورود با بیومتریک',
                          ar: 'الدخول بالبصمة',
                          zh: '生物识别登录',
                        ),
                        subtitle: _bioEnabled
                            ? l10nPick(context, en: 'Enabled', fa: 'فعال')
                            : l10nPick(
                                context,
                                en: 'Sign in with your fingerprint or face',
                                fa: 'با اثر انگشت یا چهره وارد شوید',
                              ),
                        value: _bioEnabled,
                        onChanged: _toggleBio,
                      )
                    else
                      const SizedBox.shrink(),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.timer_rounded,
                        iconColor: isDark
                            ? const Color(0xFFFB923C)
                            : const Color(0xFFEA580C),
                        backgroundColor: isDark
                            ? const Color(0xFF7C2D12).withValues(alpha: 0.5)
                            : const Color(0xFFFFF7ED),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Auto app lock',
                        fa: 'قفل خودکار اپ',
                        ar: 'قفل التطبيق التلقائي',
                        zh: '自动锁定应用',
                      ),
                      subtitle: _lockLabel(_lockMinutes),
                      onTap: () async {
                        final v = await _showStyledBottomSheet<int>(
                          context: context,
                          isDark: isDark,
                          cardBg: cardBg,
                          primaryTextColor: primaryTextColor,
                          title: l10nPick(
                            context,
                            en: 'Auto app lock duration',
                            fa: 'مدت‌زمان قفل خودکار',
                            ar: 'مدة قفل التطبيق التلقائي',
                          ),
                          items: [
                            for (final e in {
                              -1: l10nPick(
                                context,
                                en: 'Immediately (every time you leave)',
                                fa: 'فوری (با هر بار خروج از اپ)',
                              ),
                              1: l10nPick(
                                context,
                                en: '1 minute',
                                fa: '۱ دقیقه',
                              ),
                              5: l10nPick(
                                context,
                                en: '5 minutes',
                                fa: '۵ دقیقه',
                              ),
                              15: l10nPick(
                                context,
                                en: '15 minutes',
                                fa: '۱۵ دقیقه',
                              ),
                              0: l10nPick(
                                context,
                                en: 'Never',
                                fa: 'هرگز',
                              ),
                            }.entries)
                              _BottomSheetItem(
                                title: e.value,
                                isSelected: _lockMinutes == e.key,
                                value: e.key,
                              ),
                          ],
                        );
                        if (v != null) {
                          await settings.setAppLockMinutes(v);
                          setState(() => _lockMinutes = v);
                        }
                      },
                    ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.pin_rounded,
                        iconColor: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        backgroundColor: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.5)
                            : const Color(0xFFF1F5F9),
                      ),
                      title: l10nPick(
                        context,
                        en: 'App Lock PIN',
                        fa: 'PIN قفل دستگاه',
                        ar: 'رمز قفل التطبيق',
                        zh: '设备锁定PIN',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Local device unlock only — not transfer PIN',
                        fa: 'فقط باز کردن قفل اپ — نه رمز انتقال',
                        ar: 'لفتح التطبيق فقط — ليس رمز التحويل',
                        zh: '仅用于解锁应用，非转账密码',
                      ),
                      onTap: _changePin,
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'Notifications',
                    fa: 'اعلان‌ها',
                    ar: 'الإشعارات',
                    zh: '通知',
                  ),
                  [
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: _notifGranted
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        iconColor:
                            _notifGranted ? AppColors.success : AppColors.error,
                        backgroundColor: _notifGranted
                            ? (isDark
                                ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                                : AppColors.successContainer)
                            : (isDark
                                ? const Color(0xFF450A0A).withValues(alpha: 0.5)
                                : AppColors.errorContainer),
                      ),
                      title: l10nPick(
                        context,
                        en: 'System notification access',
                        fa: 'دسترسی اعلان سیستم',
                        ar: 'إذن إشعارات النظام',
                        zh: '系统通知权限',
                      ),
                      subtitle: _notifGranted
                          ? l10nPick(context, en: 'Enabled', fa: 'فعال')
                          : l10nPick(
                              context,
                              en: 'Disabled — required for transactions',
                              fa: 'غیرفعال — برای تراکنش‌ها لازم است',
                            ),
                      trailing: _notifGranted
                          ? null
                          : TextButton(
                              onPressed: () => openAppSettings(),
                              child: Text(
                                l10nPick(
                                  context,
                                  en: 'Settings',
                                  fa: 'تنظیمات',
                                ),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.lightPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                      onTap: _notifGranted ? null : () => openAppSettings(),
                    ),
                    _switchTile(
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                        backgroundColor: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : const Color(0xFFECFDF5),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Financial notifications',
                        fa: 'اعلان مالی',
                        ar: 'الإشعارات المالية',
                        zh: '资金通知',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Deposits, transfers & payments',
                        fa: 'واریز، انتقال و پرداخت‌ها',
                      ),
                      value: _notifFinancial,
                      onChanged: (v) async {
                        await settings.setNotifPref(
                          SettingsService.notifFinancialKey,
                          v,
                        );
                        setState(() => _notifFinancial = v);
                      },
                    ),
                    _switchTile(
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.campaign_rounded,
                        iconColor: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                        backgroundColor: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.5)
                            : const Color(0xFFFFFBEB),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Promotional notifications',
                        fa: 'اعلان تبلیغاتی',
                        ar: 'إشعارات ترويجية',
                        zh: '推广通知',
                      ),
                      value: _notifPromo,
                      onChanged: (v) async {
                        await settings.setNotifPref(
                          SettingsService.notifPromoKey,
                          v,
                        );
                        setState(() => _notifPromo = v);
                      },
                    ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.shield_rounded,
                        iconColor: isDark
                            ? const Color(0xFF34D399)
                            : AppColors.success,
                        backgroundColor: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : AppColors.successContainer,
                      ),
                      title: l10nPick(
                        context,
                        en: 'Security notifications',
                        fa: 'اعلان امنیتی',
                        ar: 'إشعارات الأمان',
                        zh: '安全通知',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Always on',
                        fa: 'همیشه فعال',
                        ar: 'مفعّل دائماً',
                        zh: '始终开启',
                      ),
                      trailing: const Icon(
                        Icons.lock,
                        size: 18,
                        color: AppColors.success,
                      ),
                      onTap: null,
                    ),
                    _switchTile(
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.volume_up_rounded,
                        iconColor: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Sound',
                        fa: 'صدا',
                        ar: 'الصوت',
                        zh: '声音',
                      ),
                      value: _notifSound,
                      onChanged: (v) async {
                        await settings.setNotifPref(
                          SettingsService.notifSoundKey,
                          v,
                        );
                        setState(() => _notifSound = v);
                      },
                    ),
                    _switchTile(
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.vibration_rounded,
                        iconColor: isDark
                            ? const Color(0xFFA78BFA)
                            : const Color(0xFF7C3AED),
                        backgroundColor: isDark
                            ? const Color(0xFF2E1065).withValues(alpha: 0.5)
                            : const Color(0xFFF5F3FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Vibration',
                        fa: 'ویبره',
                        ar: 'الاهتزاز',
                        zh: '振动',
                      ),
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
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.notifications_none_rounded,
                        iconColor: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                        backgroundColor: isDark
                            ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                            : const Color(0xFFF0F9FF),
                      ),
                      title: loc.settingsAllNotification,
                      subtitle: l10nPick(
                        context,
                        en: 'Notification history & feed',
                        fa: 'تاریخچه اعلان‌ها',
                        ar: 'سجل الإشعارات',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.notifications),
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'Permissions',
                    fa: 'دسترسی‌ها',
                    ar: 'الصلاحيات',
                    zh: '权限',
                  ),
                  [
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.admin_panel_settings_rounded,
                        iconColor: isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF4F46E5),
                        backgroundColor: isDark
                            ? const Color(0xFF312E81).withValues(alpha: 0.5)
                            : const Color(0xFFEEF2FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Manage permissions',
                        fa: 'مدیریت دسترسی‌ها',
                        ar: 'إدارة الأذونات',
                        zh: '管理权限',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Camera, gallery, notifications, …',
                        fa: 'دوربین، گالری، اعلان، …',
                        ar: 'الكاميرا، المعرض، الإشعارات، …',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.permissionsSettings),
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'Personalization',
                    fa: 'شخصی‌سازی',
                    ar: 'التخصيص',
                    zh: '个性化',
                  ),
                  [
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.translate_rounded,
                        iconColor: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                        backgroundColor: isDark
                            ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                            : const Color(0xFFF0F9FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Language',
                        fa: 'زبان',
                        ar: 'اللغة',
                        zh: '语言',
                      ),
                      subtitle: LocaleThemeService.nativeName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      onTap: () async {
                        final currentLang =
                            Localizations.localeOf(context).languageCode;
                        final code = await _showStyledBottomSheet<String>(
                          context: context,
                          isDark: isDark,
                          cardBg: cardBg,
                          primaryTextColor: primaryTextColor,
                          title: l10nPick(
                            context,
                            en: 'Select Language',
                            fa: 'انتخاب زبان',
                            ar: 'اختر اللغة',
                          ),
                          items: [
                            for (final c in LocaleThemeService.supported)
                              _BottomSheetItem(
                                title: LocaleThemeService.nativeName(c),
                                isSelected: currentLang == c,
                                value: c,
                              ),
                          ],
                        );
                        if (code != null &&
                            Get.isRegistered<LocaleThemeService>()) {
                          if (!mounted) return;
                          await Get.find<LocaleThemeService>()
                              .setLanguage(code);
                        }
                      },
                    ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.dark_mode_rounded,
                        iconColor: isDark
                            ? const Color(0xFFA78BFA)
                            : const Color(0xFF7C3AED),
                        backgroundColor: isDark
                            ? const Color(0xFF2E1065).withValues(alpha: 0.5)
                            : const Color(0xFFF5F3FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Theme',
                        fa: 'تم',
                        ar: 'المظهر',
                        zh: '主题',
                      ),
                      subtitle: _themeLabel(_themePref),
                      onTap: () async {
                        final v = await _showStyledBottomSheet<String>(
                          context: context,
                          isDark: isDark,
                          cardBg: cardBg,
                          primaryTextColor: primaryTextColor,
                          title: l10nPick(
                            context,
                            en: 'Select Theme',
                            fa: 'انتخاب تم',
                            ar: 'اختر المظهر',
                          ),
                          items: [
                            _BottomSheetItem(
                              title: l10nPick(
                                context,
                                en: 'System default',
                                fa: 'سیستم',
                                ar: 'النظام',
                                zh: '跟随系统',
                              ),
                              icon: Icons.brightness_auto_rounded,
                              isSelected: _themePref == 'system',
                              value: 'system',
                            ),
                            _BottomSheetItem(
                              title: l10nPick(
                                context,
                                en: 'Light',
                                fa: 'روشن',
                                ar: 'فاتح',
                                zh: '浅色',
                              ),
                              icon: Icons.light_mode_rounded,
                              isSelected: _themePref == 'light',
                              value: 'light',
                            ),
                            _BottomSheetItem(
                              title: l10nPick(
                                context,
                                en: 'Dark',
                                fa: 'تیره',
                                ar: 'داكن',
                                zh: '深色',
                              ),
                              icon: Icons.dark_mode_rounded,
                              isSelected: _themePref == 'dark',
                              value: 'dark',
                            ),
                          ],
                        );
                        if (v != null) _applyTheme(v);
                      },
                    ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                        backgroundColor: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : const Color(0xFFECFDF5),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Rate display unit',
                        fa: 'واحد نمایش نرخ',
                        ar: 'وحدة عرض السعر',
                        zh: '汇率显示单位',
                      ),
                      subtitle: _rateUnit == 'toman'
                          ? _tomanLabel
                          : _rialLabel,
                      onTap: () async {
                        final v = await _showStyledBottomSheet<String>(
                          context: context,
                          isDark: isDark,
                          cardBg: cardBg,
                          primaryTextColor: primaryTextColor,
                          title: l10nPick(
                            context,
                            en: 'Rate display unit',
                            fa: 'واحد نمایش نرخ',
                            ar: 'وحدة عرض السعر',
                          ),
                          items: [
                            _BottomSheetItem(
                              title: _rialLabel,
                              isSelected: _rateUnit == 'irr',
                              value: 'irr',
                            ),
                            _BottomSheetItem(
                              title: _tomanLabel,
                              isSelected: _rateUnit == 'toman',
                              value: 'toman',
                            ),
                          ],
                        );
                        if (v != null) {
                          await settings.setRateUnit(v);
                          setState(() => _rateUnit = v);
                        }
                      },
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                _group(
                  l10nPick(
                    context,
                    en: 'General',
                    fa: 'عمومی',
                    ar: 'عام',
                    zh: '通用',
                  ),
                  [
                    if (settings.getSetting('user_ticket') == '1')
                      _navTile(
                        context: context,
                        isDark: isDark,
                        leading: _iconBox(
                          icon: Icons.support_agent_rounded,
                          iconColor: isDark
                              ? const Color(0xFF2DD4BF)
                              : const Color(0xFF0D9488),
                          backgroundColor: isDark
                              ? const Color(0xFF134E4A).withValues(alpha: 0.5)
                              : const Color(0xFFF0FDFA),
                        ),
                        title: loc.settingsSupport,
                        subtitle: l10nPick(
                          context,
                          en: 'Help & support tickets',
                          fa: 'پشتیبانی و تیکت‌ها',
                          ar: 'الدعم والتذاكر',
                        ),
                        onTap: () => Get.toNamed(BaseRoute.supportTickets),
                      ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.info_rounded,
                        iconColor: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF),
                      ),
                      title: l10nPick(
                        context,
                        en: 'About us',
                        fa: 'درباره ما',
                        ar: 'من نحن',
                        tr: 'Hakkımızda',
                        ru: 'О нас',
                        zh: '关于我们',
                      ),
                      subtitle: _versionLabel(),
                      onTap: null,
                    ),
                    _navTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.policy_rounded,
                        iconColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
                        backgroundColor: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.5)
                            : const Color(0xFFF1F5F9),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Terms and privacy',
                        fa: 'قوانین و حریم خصوصی',
                        ar: 'الشروط والخصوصية',
                        tr: 'Koşullar ve gizlilik',
                        ru: 'Условия и конфиденциальность',
                        zh: '条款与隐私',
                      ),
                      onTap: () => Get.toNamed(BaseRoute.privacyPolicy),
                    ),
                    _actionTile(
                      context: context,
                      isDark: isDark,
                      leading: _iconBox(
                        icon: Icons.system_update_rounded,
                        iconColor: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                        backgroundColor: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : const Color(0xFFECFDF5),
                      ),
                      title: l10nPick(
                        context,
                        en: 'Check for updates',
                        fa: 'بررسی به‌روزرسانی',
                        ar: 'التحقق من التحديثات',
                        tr: 'Güncellemeleri denetle',
                        ru: 'Проверить обновления',
                        zh: '检查更新',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Get the latest features & patches',
                        fa: 'دریافت آخرین نسخه و رفع اشکالات',
                        ar: 'الحصول على أحدث الميزات',
                      ),
                      onTap: () {
                        if (Get.isRegistered<AppUpdateController>()) {
                          Get.find<AppUpdateController>().checkForUpdate();
                        } else {
                          Get.toNamed(BaseRoute.appUpdate);
                        }
                      },
                    ),
                  ],
                  isDark: isDark,
                  cardBg: cardBg,
                  dividerColor: dividerColor,
                ),
                if (Get.isRegistered<DemoAccountService>())
                  Obx(() {
                    final demo = DemoAccountService.to;
                    if (!demo.isDemoMode.value) return const SizedBox.shrink();
                    return _group(
                      l10nPick(
                        context,
                        en: 'Demo & QA Testing Panel',
                        fa: 'کنترل پنل تست و دمو (QA)',
                        ar: 'لوحة اختبار الحساب التجريبي',
                        zh: '演示与测试控制台',
                      ),
                      [
                        _actionTile(
                          context: context,
                          isDark: isDark,
                          leading: _iconBox(
                            icon: Icons.verified_user_rounded,
                            iconColor: AppColors.success,
                            backgroundColor: isDark
                                ? const Color(0xFF064E3B)
                                    .withValues(alpha: 0.5)
                                : AppColors.successContainer,
                          ),
                          title: l10nPick(
                            context,
                            en: 'Simulated KYC Level',
                            fa: 'سطح شبیه‌سازی احراز هویت',
                            ar: 'مستوى التحقق التجريبي',
                            zh: '模拟KYC级别',
                          ),
                          subtitle: switch (demo.demoKycStatus.value) {
                            1 => l10nPick(
                                context,
                                en: 'Level 1: Verified (Active)',
                                fa: 'سطح ۱: تأییدشده (کامل)',
                                ar: 'مستوى 1: موثق',
                                zh: '已认证',
                              ),
                            2 => l10nPick(
                                context,
                                en: 'Level 2: In Review (Pending)',
                                fa: 'در حال بررسی مدارک',
                                ar: 'قيد المراجعة',
                                zh: '审核中',
                              ),
                            3 => l10nPick(
                                context,
                                en: 'Level 3: Rejected with reason',
                                fa: 'رد شده با دلیل نقص مدارک',
                                ar: 'مرفوض مع السبب',
                                zh: '已拒绝',
                              ),
                            _ => l10nPick(
                                context,
                                en: 'Unverified (Guest)',
                                fa: 'احرازنشده',
                                ar: 'غير موثق',
                                zh: '未认证',
                              ),
                          },
                          trailing: const Icon(Icons.swap_horiz_rounded),
                          onTap: () {
                            final current = demo.demoKycStatus.value;
                            final next = (current + 1) % 4;
                            demo.setKycStatus(next);
                          },
                        ),
                        _actionTile(
                          context: context,
                          isDark: isDark,
                          leading: _iconBox(
                            icon: Icons.exit_to_app_rounded,
                            iconColor: AppColors.error,
                            backgroundColor: isDark
                                ? const Color(0xFF450A0A)
                                    .withValues(alpha: 0.5)
                                : AppColors.errorContainer,
                          ),
                          title: l10nPick(
                            context,
                            en: 'Exit Demo Mode',
                            fa: 'خروج از حالت دمو و بازگشت به لاگین',
                            ar: 'الخروج من الوضع التجريبي',
                            zh: '退出演示模式',
                          ),
                          onTap: () => demo.deactivateDemoMode(),
                        ),
                      ],
                      isDark: isDark,
                      cardBg: cardBg,
                      dividerColor: dividerColor,
                    );
                  }),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(
                    loc.settingsSignOut,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppColors.error.withValues(alpha: 0.6)
                          : AppColors.error,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
    );
  }

  String get _rialLabel => l10nPick(
        context,
        en: 'IRR (Rial)',
        fa: 'ریال (IRR)',
        ar: 'ريال (IRR)',
        zh: 'IRR (里亚尔)',
      );

  String get _tomanLabel => l10nPick(
        context,
        en: 'Toman',
        fa: 'تومان',
        ar: 'تومان',
        zh: '托曼',
      );

  String _versionLabel() {
    if (_version.isEmpty) return 'Al Barakat';
    return l10nPick(
      context,
      en: 'Version $_version',
      fa: 'نسخه $_version',
      ar: 'الإصدار $_version',
      tr: 'Sürüm $_version',
      ru: 'Версия $_version',
      zh: '版本 $_version',
    );
  }

  String _lockLabel(int m) {
    if (m < 0) return l10nPick(context, en: 'Immediately', fa: 'فوری');
    if (m == 0) return l10nPick(context, en: 'Never', fa: 'هرگز');
    if (m == 1) return l10nPick(context, en: '1 minute', fa: '۱ دقیقه');
    return l10nPick(context, en: '$m minutes', fa: '$m دقیقه');
  }

  String _themeLabel(String m) => switch (m) {
        'light' => l10nPick(context, en: 'Light', fa: 'روشن', ar: 'فاتح', zh: '浅色'),
        'dark' => l10nPick(context, en: 'Dark', fa: 'تیره', ar: 'داكن', zh: '深色'),
        _ => l10nPick(context, en: 'System default', fa: 'سیستم', ar: 'النظام', zh: '跟随系统'),
      };

  Widget _iconBox({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  Widget _trailingChevron(BuildContext context, bool isDark) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: 20,
      color: isDark ? AppColors.softGray : const Color(0xFF9CA3AF),
    );
  }

  Widget _group(
    String title,
    List<Widget> children, {
    required bool isDark,
    required Color cardBg,
    required Color dividerColor,
  }) {
    final visible = children.where((c) => c is! SizedBox).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final List<Widget> separated = [];
    for (int i = 0; i < visible.length; i++) {
      separated.add(visible[i]);
      if (i < visible.length - 1) {
        separated.add(
          Divider(
            height: 1,
            thickness: 0.8,
            indent: 64,
            endIndent: 14,
            color: dividerColor,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(
                      color: AppColors.lightWarmGray.withValues(alpha: 0.12),
                      width: 1,
                    )
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(children: separated),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required BuildContext context,
    required bool isDark,
    required Widget leading,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        minTileHeight: 52,
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
        trailing: _trailingChevron(context, isDark),
        onTap: onTap,
      ),
    );
  }

  Widget _actionTile({
    required BuildContext context,
    required bool isDark,
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
  }) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        minTileHeight: 52,
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
        trailing: trailing ??
            (onTap != null ? _trailingChevron(context, isDark) : null),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile({
    required bool isDark,
    required Widget leading,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      secondary: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
      value: value,
      onChanged: onChanged,
      activeTrackColor:
          isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
    );
  }

  Future<T?> _showStyledBottomSheet<T>({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color primaryTextColor,
    required String title,
    required List<_BottomSheetItem<T>> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.softGray.withValues(alpha: 0.5)
                        : AppColors.lightWarmGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              for (final item in items)
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    minTileHeight: 48,
                    leading: item.icon != null
                        ? Icon(
                            item.icon,
                            color: item.isSelected
                                ? (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.lightPrimary)
                                : (isDark
                                    ? AppColors.softGray
                                    : AppColors.lightTextSecondary),
                            size: 22,
                          )
                        : null,
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: item.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: item.isSelected
                            ? (isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.lightPrimary)
                            : primaryTextColor,
                      ),
                    ),
                    trailing: item.isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.lightPrimary,
                            size: 22,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, item.value),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetItem<T> {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final T value;

  const _BottomSheetItem({
    required this.title,
    this.icon,
    this.isSelected = false,
    required this.value,
  });
}

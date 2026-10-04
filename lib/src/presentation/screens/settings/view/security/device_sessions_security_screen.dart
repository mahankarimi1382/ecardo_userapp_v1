import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';

/// Supported physical device forms for active sessions.
enum DeviceType {
  phone,
  tablet,
  desktop,
}

/// Category of security event in the audit trail.
enum SecurityAuditType {
  signIn,
  passwordChange,
  newDeviceAlert,
  sessionRevoked,
  twoFactor,
  pinChange,
}

/// Model representing a logged-in active session / device.
class DeviceSessionItem {
  final String id;
  final String deviceName;
  final DeviceType deviceType;
  final String operatingSystem;
  final String browser;
  final String ipAddress;
  final String location;
  final DateTime lastActive;
  final bool isCurrentDevice;

  const DeviceSessionItem({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.operatingSystem,
    required this.browser,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    this.isCurrentDevice = false,
  });

  DeviceSessionItem copyWith({
    String? id,
    String? deviceName,
    DeviceType? deviceType,
    String? operatingSystem,
    String? browser,
    String? ipAddress,
    String? location,
    DateTime? lastActive,
    bool? isCurrentDevice,
  }) {
    return DeviceSessionItem(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      browser: browser ?? this.browser,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      lastActive: lastActive ?? this.lastActive,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }

  IconData get icon {
    switch (deviceType) {
      case DeviceType.phone:
        return Icons.smartphone_rounded;
      case DeviceType.tablet:
        return Icons.tablet_mac_rounded;
      case DeviceType.desktop:
        return Icons.computer_rounded;
    }
  }

  String localizedType(BuildContext context) {
    switch (deviceType) {
      case DeviceType.phone:
        return l10nPick(
          context,
          en: 'Smartphone',
          fa: 'گوشی هوشمند',
          ar: 'هاتف ذكي',
          zh: '智能手机',
        );
      case DeviceType.tablet:
        return l10nPick(
          context,
          en: 'Tablet',
          fa: 'تبلت',
          ar: 'جهاز لوحي',
          zh: '平板电脑',
        );
      case DeviceType.desktop:
        return l10nPick(
          context,
          en: 'Desktop / PC',
          fa: 'رایانه رومیزی',
          ar: 'كمبيوتر مكتبي',
          zh: '桌面电脑',
        );
    }
  }
}

/// Model representing a single event in the security audit trail.
class SecurityAuditLogItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final SecurityAuditType type;
  final String? ipAddress;
  final String? location;

  const SecurityAuditLogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.ipAddress,
    this.location,
  });

  IconData get icon {
    switch (type) {
      case SecurityAuditType.signIn:
        return Icons.login_rounded;
      case SecurityAuditType.passwordChange:
        return Icons.lock_reset_rounded;
      case SecurityAuditType.newDeviceAlert:
        return Icons.notification_important_rounded;
      case SecurityAuditType.sessionRevoked:
        return Icons.remove_circle_outline_rounded;
      case SecurityAuditType.twoFactor:
        return Icons.verified_user_rounded;
      case SecurityAuditType.pinChange:
        return Icons.pin_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case SecurityAuditType.signIn:
        return AppColors.info;
      case SecurityAuditType.passwordChange:
        return AppColors.lightPrimary;
      case SecurityAuditType.newDeviceAlert:
        return AppColors.warning;
      case SecurityAuditType.sessionRevoked:
        return AppColors.error;
      case SecurityAuditType.twoFactor:
      case SecurityAuditType.pinChange:
        return AppColors.success;
    }
  }
}

/// Screen providing comprehensive device session and security controls:
/// - "This Device" hero card with pulsating active indicator and IP badge
/// - "Other Active Devices" list with individual revocation actions
/// - "Terminate All Other Sessions" destructive emergency button
/// - Biometric App Lock & PIN quick settings
/// - Audit log of recent security events
class DeviceSessionsSecurityScreen extends StatefulWidget {
  const DeviceSessionsSecurityScreen({super.key});

  @override
  State<DeviceSessionsSecurityScreen> createState() =>
      _DeviceSessionsSecurityScreenState();
}

class _DeviceSessionsSecurityScreenState
    extends State<DeviceSessionsSecurityScreen> {
  SettingsService? get _settings =>
      Get.isRegistered<SettingsService>() ? Get.find<SettingsService>() : null;
  AppLockService? get _appLock =>
      Get.isRegistered<AppLockService>() ? Get.find<AppLockService>() : null;
  final BiometricAuthService _bio = BiometricAuthService();

  bool _loading = true;
  bool _bioSupported = false;
  bool _bioEnabled = false;
  int _lockMinutes = 0;
  bool _hasPinSet = false;

  late DeviceSessionItem _currentDevice;
  final List<DeviceSessionItem> _otherSessions = [];
  final List<SecurityAuditLogItem> _auditLogs = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Current Device
    _currentDevice = DeviceSessionItem(
      id: 'sess_curr_01',
      deviceName: 'Samsung Galaxy S24 Ultra',
      deviceType: DeviceType.phone,
      operatingSystem: 'Android 14 (One UI 6.1)',
      browser: 'Ecardo App v1.0.88',
      ipAddress: '5.127.189.42',
      location: 'تهران، ایران',
      lastActive: DateTime.now(),
      isCurrentDevice: true,
    );

    // Other active devices
    _otherSessions.addAll([
      DeviceSessionItem(
        id: 'sess_oth_01',
        deviceName: 'Chrome در Windows 11',
        deviceType: DeviceType.desktop,
        operatingSystem: 'Windows 11 Pro 64-bit',
        browser: 'Google Chrome 125.0',
        ipAddress: '185.192.112.5',
        location: 'تهران، ایران',
        lastActive: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        isCurrentDevice: false,
      ),
      DeviceSessionItem(
        id: 'sess_oth_02',
        deviceName: 'iPad Pro 12.9"',
        deviceType: DeviceType.tablet,
        operatingSystem: 'iPadOS 17.5',
        browser: 'Mobile Safari 17.4',
        ipAddress: '2.188.75.140',
        location: 'اصفهان، ایران',
        lastActive: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        isCurrentDevice: false,
      ),
      DeviceSessionItem(
        id: 'sess_oth_03',
        deviceName: 'MacBook Pro 16"',
        deviceType: DeviceType.desktop,
        operatingSystem: 'macOS Sonoma 14.4',
        browser: 'Firefox 126.0',
        ipAddress: '91.240.64.12',
        location: 'دبی، امارات متحده عربی',
        lastActive: DateTime.now().subtract(const Duration(days: 4, hours: 8)),
        isCurrentDevice: false,
      ),
    ]);

    // Initial audit log events
    _auditLogs.addAll([
      SecurityAuditLogItem(
        id: 'audit_01',
        title: 'ورود موفق به نشست فعلی',
        description: 'Samsung Galaxy S24 Ultra • تهران • احراز هویت با اثر انگشت',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        type: SecurityAuditType.signIn,
        ipAddress: '5.127.189.42',
        location: 'تهران، ایران',
      ),
      SecurityAuditLogItem(
        id: 'audit_02',
        title: 'ورود از مرورگر وب',
        description: 'Chrome در Windows 11 • ورود استاندارد با رمز عبور و پیامک',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        type: SecurityAuditType.signIn,
        ipAddress: '185.192.112.5',
        location: 'تهران، ایران',
      ),
      SecurityAuditLogItem(
        id: 'audit_03',
        title: 'هشدار: ورود از دستگاه جدید',
        description: 'iPad Pro 12.9" • اصفهان • تأیید موفق با کد یک‌بارمصرف دومرحله‌ای',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        type: SecurityAuditType.newDeviceAlert,
        ipAddress: '2.188.75.140',
        location: 'اصفهان، ایران',
      ),
      SecurityAuditLogItem(
        id: 'audit_04',
        title: 'تغییر موفقیت‌آمیز رمز ورود حساب',
        description: 'رمز عبور حساب از طریق منوی امنیت تغییر یافت و نشست‌های قدیمی بررسی شدند',
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        type: SecurityAuditType.passwordChange,
      ),
      SecurityAuditLogItem(
        id: 'audit_05',
        title: 'تنظیم رمز یک‌بارمصرف دو مرحله‌ای (2FA)',
        description: 'Google Authenticator برای ورود به حساب کاربری فعال گردید',
        timestamp: DateTime.now().subtract(const Duration(days: 18)),
        type: SecurityAuditType.twoFactor,
      ),
    ]);

    // Read Biometrics & AppLock status from services
    try {
      final supported = await _bio.isSupported();
      final enabled = await _bio.isEnabled();
      final lockMin = _settings != null ? await _settings!.getAppLockMinutes() : 0;
      final pin = _settings != null ? (await _settings!.getAppPin()) ?? '' : '';
      final pinSet = pin.isNotEmpty;

      if (mounted) {
        setState(() {
          _bioSupported = supported;
          _bioEnabled = enabled;
          _lockMinutes = lockMin;
          _hasPinSet = pinSet;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _currentDevice = _currentDevice.copyWith(lastActive: DateTime.now());
      _loading = false;
    });
    ToastHelper().showSuccessToast(
      l10nPick(
        context,
        en: 'Active sessions and device security refreshed',
        fa: 'اطلاعات نشست‌ها و امنیت دستگاه به‌روزرسانی شد',
      ),
    );
  }

  Future<void> _toggleBio(bool value) async {
    HapticFeedback.lightImpact();
    if (value) {
      final ok = await _bio.enable();
      if (ok && mounted) {
        setState(() => _bioEnabled = true);
        _addAudit(
          title: l10nPick(
            context,
            en: 'Biometric Lock Enabled',
            fa: 'فعال‌سازی قفل بیومتریک',
          ),
          description: l10nPick(
            context,
            en: 'Biometric unlock enabled on this device',
            fa: 'ورود با اثر انگشت یا چهره در این دستگاه فعال شد',
          ),
          type: SecurityAuditType.pinChange,
        );
      }
    } else {
      final ok = await _bio.disable();
      if (ok && mounted) {
        setState(() => _bioEnabled = false);
        _addAudit(
          title: l10nPick(
            context,
            en: 'Biometric Lock Disabled',
            fa: 'غیرفعال‌سازی قفل بیومتریک',
          ),
          description: l10nPick(
            context,
            en: 'Biometric unlock turned off',
            fa: 'ورود با اثر انگشت یا چهره غیرفعال شد',
          ),
          type: SecurityAuditType.pinChange,
        );
      }
    }
  }

  Future<void> _changePin() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    if (_hasPinSet && _appLock != null) {
      final cOld = TextEditingController();
      final okOld = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          title: Text(
            l10nPick(context, en: 'Enter Current PIN', fa: 'ورود PIN فعلی'),
            style: AppTextStyles.titleMedium.copyWith(color: textColor),
          ),
          content: TextField(
            controller: cOld,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            style: AppTextStyles.titleLarge.copyWith(color: textColor, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(color: isDark ? AppColors.softGray : AppColors.lightTextHint),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
              ),
              onPressed: () => Get.back(result: true),
              child: Text(l10nPick(context, en: 'Confirm', fa: 'تأیید')),
            ),
          ],
        ),
      );
      if (okOld != true || !mounted) return;
      final valid = await _appLock!.verifyPin(cOld.text);
      if (!valid) {
        if (!mounted) return;
        ToastHelper().showErrorToast(
          l10nPick(context, en: 'Incorrect PIN', fa: 'PIN فعلی نادرست است'),
        );
        return;
      }
    }

    if (!mounted) return;
    await _setAppPin();
  }

  Future<void> _setAppPin() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    final c1 = TextEditingController();
    final c2 = TextEditingController();

    // Pre-capture localized strings before any async gap
    final dialogTitle = l10nPick(context, en: 'Set 4-digit App Lock PIN', fa: 'تنظیم PIN ۴ رقمی قفل اپ');
    final pinLabel1 = l10nPick(context, en: 'New 4-digit PIN', fa: 'PIN جدید (۴ رقم)');
    final pinLabel2 = l10nPick(context, en: 'Repeat PIN', fa: 'تکرار PIN');
    final cancelLabel = l10nPick(context, en: 'Cancel', fa: 'انصراف');
    final saveLabel = l10nPick(context, en: 'Save', fa: 'ذخیره');
    final auditTitle = l10nPick(context, en: 'App Lock PIN Updated', fa: 'تغییر PIN قفل اپ');
    final auditDesc = l10nPick(
      context,
      en: 'Device unlock passcode was set / updated',
      fa: 'رمز عبور قفل محلی دستگاه با موفقیت تنظیم یا تغییر یافت',
    );
    final snackSaved = l10nPick(context, en: 'PIN saved successfully', fa: 'PIN با موفقیت ذخیره شد');
    final snackMismatch = l10nPick(
      context,
      en: 'The PIN must be 4 digits and match',
      fa: 'PIN باید ۴ رقم و یکسان باشد',
    );

    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Text(dialogTitle, style: AppTextStyles.titleMedium.copyWith(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              style: AppTextStyles.titleMedium.copyWith(color: textColor, letterSpacing: 6),
              decoration: InputDecoration(
                labelText: pinLabel1,
                labelStyle: TextStyle(color: isDark ? AppColors.softGray : AppColors.lightTextSecondary),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: c2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              style: AppTextStyles.titleMedium.copyWith(color: textColor, letterSpacing: 6),
              decoration: InputDecoration(
                labelText: pinLabel2,
                labelStyle: TextStyle(color: isDark ? AppColors.softGray : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(saveLabel),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (ok == true && c1.text.length == 4 && c1.text == c2.text) {
      if (_appLock != null) {
        await _appLock!.setPin(c1.text);
      }
      if (_settings != null) {
        await _settings!.setAppPin('set');
      }
      if (!mounted) return;
      setState(() => _hasPinSet = true);
      _addAudit(
        title: auditTitle,
        description: auditDesc,
        type: SecurityAuditType.pinChange,
      );
      ToastHelper().showSuccessToast(snackSaved);
    } else if (ok == true) {
      ToastHelper().showErrorToast(snackMismatch);
    }
  }

  Future<void> _chooseAutoLock() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    // Pre-capture localized strings before any async gap
    final snackMsg = l10nPick(
      context,
      en: 'Auto-lock duration updated',
      fa: 'زمان‌بندی قفل خودکار تنظیم شد',
    );

    final v = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Text(
                l10nPick(
                  context,
                  en: 'Auto App Lock Duration',
                  fa: 'مدت زمان قفل خودکار اپلیکیشن',
                  ar: 'مدة القفل التلقائي',
                  zh: '自动锁定时间',
                ),
                style: AppTextStyles.titleMedium.copyWith(color: textColor),
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            for (final e in {
              -1: l10nPick(
                context,
                en: 'Immediately (every time you leave)',
                fa: 'فوری (با هر بار خروج از اپ)',
              ),
              1: l10nPick(context, en: '1 minute', fa: '۱ دقیقه'),
              5: l10nPick(context, en: '5 minutes', fa: '۵ دقیقه'),
              15: l10nPick(context, en: '15 minutes', fa: '۱۵ دقیقه'),
              0: l10nPick(context, en: 'Never', fa: 'هرگز'),
            }.entries)
              ListTile(
                title: Text(e.value, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
                trailing: _lockMinutes == e.key
                    ? Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20.sp)
                    : null,
                onTap: () => Navigator.pop(ctx, e.key),
              ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (v != null && mounted) {
      if (_settings != null) {
        await _settings!.setAppLockMinutes(v);
      }
      if (!mounted) return;
      setState(() => _lockMinutes = v);
      ToastHelper().showSuccessToast(snackMsg);
    }
  }

  void _addAudit({
    required String title,
    required String description,
    required SecurityAuditType type,
    String? ipAddress,
    String? location,
  }) {
    setState(() {
      _auditLogs.insert(
        0,
        SecurityAuditLogItem(
          id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: description,
          timestamp: DateTime.now(),
          type: type,
          ipAddress: ipAddress,
          location: location,
        ),
      );
    });
  }

  Future<void> _revokeSession(DeviceSessionItem session) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    // Pre-capture localized strings
    final auditTitle = l10nPick(
      context,
      en: 'Device Session Terminated',
      fa: 'نشست دستگاه باطل شد',
    );
    final toastSuccess = l10nPick(
      context,
      en: 'Session on "${session.deviceName}" was revoked.',
      fa: 'نشست دستگاه «${session.deviceName}» با موفقیت پایان یافت.',
    );

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 22.sp),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'Log Out Device?',
                  fa: 'خروج از نشست این دستگاه؟',
                  ar: 'تسجيل الخروج من هذا الجهاز؟',
                  zh: '退出此设备登录？',
                ),
                style: AppTextStyles.titleMedium.copyWith(color: textColor),
              ),
            ),
          ],
        ),
        content: Text(
          l10nPick(
            context,
            en: 'Are you sure you want to log out "${session.deviceName}"?\n'
                'Its session will be revoked immediately and require credentials to sign in again.',
            fa: 'آیا از پایان دادن به نشست دستگاه «${session.deviceName}» اطمینان دارید؟\n'
                'دسترسی این دستگاه بلافاصله لغو شده و برای ورود مجدد نیاز به احراز هویت خواهد داشت.',
            ar: 'هل أنت متأكد من تسجيل الخروج من «${session.deviceName}»؟\n'
                'سيتم إنهاء الجلسة فورًا وسيتطلب تسجيل الدخول مجددًا.',
            zh: '确定要注销设备“${session.deviceName}”吗？\n该会话将立即撤销，需重新凭证登录。',
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.warmWhite.withValues(alpha: 0.85) : AppColors.deepBlack,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              l10nPick(
                context,
                en: 'Log Out',
                fa: 'خروج از این دستگاه',
                ar: 'إنهاء الجلسة',
                zh: '退出设备',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _otherSessions.removeWhere((item) => item.id == session.id);
      });
      _addAudit(
        title: auditTitle,
        description: '${session.deviceName} • ${session.ipAddress} • ${session.location}',
        type: SecurityAuditType.sessionRevoked,
        ipAddress: session.ipAddress,
        location: session.location,
      );
      ToastHelper().showSuccessToast(toastSuccess);
    }
  }

  Future<void> _terminateAllOtherSessions() async {
    HapticFeedback.mediumImpact();
    final count = _otherSessions.length;
    if (count == 0) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    // Pre-capture localized strings
    final auditTitle = l10nPick(
      context,
      en: 'Emergency Revocation Executed',
      fa: 'خروج اضطراری از تمام نشست‌ها اجرا شد',
    );
    final auditDesc = l10nPick(
      context,
      en: '$count active session(s) were terminated immediately.',
      fa: '$count نشست فعال دیگر به صورت اضطراری لغو و مسدود شدند.',
    );
    final toastSuccess = l10nPick(
      context,
      en: 'All other active sessions have been terminated.',
      fa: 'تمامی نشست‌های فعال دیگر با موفقیت مسدود و خارج شدند.',
    );

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.sp),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'Terminate All Other Sessions?',
                  fa: 'خروج اضطراری از تمام نشست‌ها؟',
                  ar: 'إنهاء كل الجلسات الأخرى فورًا؟',
                  zh: '终止所有其他在线会话？',
                ),
                style: AppTextStyles.titleMedium.copyWith(color: textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(
                context,
                en: '$count active device(s) will be logged out immediately.',
                fa: '$count نشست فعال دیگر بلافاصله مسدود و خارج می‌شوند.',
                ar: 'سيتم إنهاء $count جلسة نشطة فورًا.',
                zh: '将立即退出其他 $count 台设备的登录状态。',
              ),
              style: AppTextStyles.titleSmall.copyWith(color: textColor),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              l10nPick(
                context,
                en: 'All active sessions on browsers, tablets, and computers (except this device) '
                    'will be immediately revoked. Anyone using them will be locked out.',
                fa: 'تمامی نشست‌های فعال در مرورگرها، تبلت‌ها و رایانه‌های دیگر بلافاصله مسدود '
                    'شده و دسترسی آن‌ها به حساب شما لغو می‌گردد.',
                ar: 'سيتم إلغاء جميع الجلسات النشطة على الأجهزة الأخرى فورًا.',
                zh: '除当前设备外的所有活动会话将立即撤销，保障账户资金安全。',
              ),
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.45,
                color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              l10nPick(
                context,
                en: 'Terminate All',
                fa: 'تأیید و خروج از همه',
                ar: 'إنهاء الجميع',
                zh: '确认全部终止',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _otherSessions.clear();
      });
      _addAudit(
        title: auditTitle,
        description: auditDesc,
        type: SecurityAuditType.sessionRevoked,
      );
      ToastHelper().showSuccessToast(toastSuccess);
    }
  }

  String _lockLabel(int m) {
    if (m < 0) return l10nPick(context, en: 'Immediately', fa: 'فوری');
    if (m == 0) return l10nPick(context, en: 'Never', fa: 'هرگز');
    if (m == 1) return l10nPick(context, en: '1 minute', fa: '۱ دقیقه');
    return l10nPick(context, en: '$m minutes', fa: '$m دقیقه');
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return l10nPick(context, en: 'Just now', fa: 'همین الان');
    }
    if (diff.inMinutes < 60) {
      return l10nPick(
        context,
        en: '${diff.inMinutes}m ago',
        fa: '${diff.inMinutes} دقیقه پیش',
      );
    }
    if (diff.inHours < 24) {
      return l10nPick(
        context,
        en: '${diff.inHours}h ago',
        fa: '${diff.inHours} ساعت پیش',
      );
    }
    if (diff.inDays < 7) {
      return l10nPick(
        context,
        en: '${diff.inDays}d ago',
        fa: '${diff.inDays} روز پیش',
      );
    }
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Devices & Active Sessions',
            fa: 'دستگاه‌ها و نشست‌های فعال',
            ar: 'الأجهزة والجلسات النشطة',
            zh: '设备与活动会话',
          ),
          style: AppTextStyles.titleMedium.copyWith(color: primaryTextColor),
        ),
        backgroundColor: bgColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10nPick(context, en: 'Refresh', fa: 'به‌روزرسانی'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingSkeleton(isDark)
          : RefreshIndicator(
              onRefresh: _refresh,
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.bottomSafe(context, AppSpacing.xxxl),
                ),
                children: [
                  // 1. "This Device" Hero Card
                  _buildThisDeviceHeroCard(isDark),

                  SizedBox(height: AppSpacing.xl),

                  // 2. "Other Active Devices" Section
                  _buildOtherDevicesSection(isDark),

                  SizedBox(height: AppSpacing.lg),

                  // 3. Emergency Revoke Button (Terminate all other sessions)
                  _buildTerminateAllButton(isDark),

                  SizedBox(height: AppSpacing.xxl),

                  // 4. Biometric App Lock & PIN Quick Settings Section
                  _buildBiometricAndLockSection(isDark),

                  SizedBox(height: AppSpacing.xxl),

                  // 5. Security Activity Audit Log
                  _buildSecurityAuditLogSection(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.page),
      children: [
        Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 1. "This Device" Hero Card
  // ==========================================
  Widget _buildThisDeviceHeroCard(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final iconStyle = SettingsIconTokens.deviceSessions(isDark: isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge + Shield Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PulsingIndicator(
                      color: AppColors.success,
                      size: 9.0,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      l10nPick(
                        context,
                        en: 'Active Now (This Device)',
                        fa: 'نشست فعلی (فعال اکنون)',
                        ar: 'نشط الآن (هذا الجهاز)',
                        zh: '当前在线（本机）',
                      ),
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 20.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Device info main row
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _currentDevice.icon,
                  color: iconStyle.iconColor,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentDevice.deviceName,
                      style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_currentDevice.localizedType(context)} • ${_currentDevice.operatingSystem}',
                      style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          SizedBox(height: AppSpacing.md),

          // Metadata row: IP, Location, App version
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _currentDevice.ipAddress));
                    ToastHelper().showSuccessToast(
                      l10nPick(context, en: 'IP copied to clipboard', fa: 'آدرس IP کپی شد'),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 15.sp,
                          color: secondaryTextColor,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'IP: ${_currentDevice.ipAddress}',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              color: primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 15.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        _currentDevice.location,
                        style: AppTextStyles.bodySmall.copyWith(color: primaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          // Security check assurance banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 7.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryContainer.withValues(alpha: 0.3)
                  : AppColors.lightPrimary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14.sp,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Verified session with end-to-end device fingerprinting.',
                      fa: 'نشست تأییدشده با اثرانگشت دیجیتال امن دستگاه.',
                      ar: 'جلسة موثقة ومشفرة من طرف إلى طرف.',
                      zh: '经设备指纹端到端认证的安全会话。',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. "Other Active Devices" Section
  // ==========================================
  Widget _buildOtherDevicesSection(bool isDark) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: AppSpacing.sm),
          child: Row(
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Other Active Devices',
                  fa: 'سایر نشست‌های فعال',
                  ar: 'الأجهزة النشطة الأخرى',
                  zh: '其他活动设备',
                ),
                style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _otherSessions.isNotEmpty
                      ? (isDark
                          ? AppColors.mainSoftBlue.withValues(alpha: 0.2)
                          : AppColors.lightPrimary.withValues(alpha: 0.12))
                      : (isDark ? AppColors.darkCard : AppColors.greyLight.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '${_otherSessions.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _otherSessions.isNotEmpty
                        ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                        : (isDark ? AppColors.softGray : AppColors.greyDark),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_otherSessions.isEmpty)
          _buildEmptyOtherSessionsCard(isDark)
        else
          Column(
            children: _otherSessions
                .map((session) => _buildDeviceSessionCard(session, isDark))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyOtherSessionsCard(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_good_rounded,
              color: AppColors.success,
              size: 32.sp,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10nPick(
              context,
              en: 'No Other Active Sessions',
              fa: 'هیچ نشست فعال دیگری وجود ندارد',
              ar: 'لا توجد جلسات نشطة أخرى',
              zh: '无其他活动会话',
            ),
            style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10nPick(
              context,
              en: 'Your account is exclusively accessed from this device.',
              fa: 'حساب کاربری شما تنها روی همین دستگاه فعال است.',
              ar: 'يتم استخدام حسابك حصريًا من هذا الجهاز.',
              zh: '您的账户目前仅在此设备上登录。',
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSessionCard(DeviceSessionItem session, bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final iconStyle = SettingsIconTokens.deviceSessions(isDark: isDark);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  session.icon,
                  color: iconStyle.iconColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.deviceName,
                      style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${session.operatingSystem} • ${session.browser}',
                      style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              // Individual Log Out Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.h),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(Icons.logout_rounded, size: 14.sp),
                label: Text(
                  l10nPick(
                    context,
                    en: 'Log Out',
                    fa: 'خروج',
                    ar: 'إنهاء',
                    zh: '登出',
                  ),
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                ),
                onPressed: () => _revokeSession(session),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                size: 13.sp,
                color: secondaryTextColor,
              ),
              SizedBox(width: 4.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: session.ipAddress));
                  ToastHelper().showSuccessToast(
                    l10nPick(context, en: 'IP copied', fa: 'IP کپی شد'),
                  );
                },
                child: Text(
                  session.ipAddress,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontFamily: 'monospace',
                    color: secondaryTextColor,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.place_outlined,
                size: 13.sp,
                color: secondaryTextColor,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  session.location,
                  style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.access_time_rounded,
                size: 13.sp,
                color: secondaryTextColor,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatRelativeTime(session.lastActive),
                style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. Destructive Action: Terminate All Other Sessions
  // ==========================================
  Widget _buildTerminateAllButton(bool isDark) {
    final hasOthers = _otherSessions.isNotEmpty;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: hasOthers
              ? AppColors.error.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (hasOthers ? AppColors.error : AppColors.softGray)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: hasOthers ? AppColors.error : AppColors.softGray,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Terminate All Other Sessions',
                        fa: 'خروج اضطراری از تمام نشست‌ها',
                        ar: 'خروج اضطراري من جميع الجلسات',
                        zh: '紧急终止所有其他会话',
                      ),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: hasOthers ? AppColors.error : (isDark ? AppColors.softGray : AppColors.greyDark),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(
                        context,
                        en: 'Immediately revokes access on all other phones and computers.',
                        fa: 'قطع فوری دسترسی تمامی مرورگرها، گوشی‌ها و تبلت‌های دیگر.',
                        ar: 'إنهاء الجلسات فورًا على جميع الأجهزة الأخرى.',
                        zh: '立即注销其他所有电脑和手机上的登录状态。',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasOthers
                    ? AppColors.error
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.greyLight.withValues(alpha: 0.8)),
                foregroundColor: hasOthers
                    ? AppColors.white
                    : (isDark ? AppColors.softGray : AppColors.greyDark),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              icon: Icon(Icons.no_accounts_rounded, size: 18.sp),
              label: Text(
                l10nPick(
                  context,
                  en: 'Terminate All Other Devices',
                  fa: 'خروج از تمام دستگاه‌های دیگر',
                  ar: 'إنهاء كل الجلسات الأخرى',
                  zh: '终止所有其他设备',
                ),
                style: AppTextStyles.labelMedium,
              ),
              onPressed: hasOthers ? _terminateAllOtherSessions : null,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Biometric App Lock & PIN Quick Settings Section
  // ==========================================
  Widget _buildBiometricAndLockSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final bioStyle = SettingsIconTokens.biometric(isDark: isDark);
    final autoLockStyle = SettingsIconTokens.autoAppLock(isDark: isDark);
    final pinStyle = SettingsIconTokens.appLockPin(isDark: isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: AppSpacing.sm),
          child: Text(
            l10nPick(
              context,
              en: 'Biometric & Local App Lock',
              fa: 'تنظیمات قفل اپلیکیشن و بیومتریک',
              ar: 'قفل التطبيق والمصادقة البيومترية',
              zh: '生物识别与应用锁定',
            ),
            style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.h),
          child: Column(
            children: [
              // Biometric toggle
              if (_bioSupported)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: bioStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: bioStyle.iconColor,
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Biometric Sign In / Unlock',
                      fa: 'ورود با اثر انگشت یا چهره',
                      ar: 'الدخول بالبصمة أو الوجه',
                      zh: '指纹或面容快速解锁',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                  ),
                  subtitle: Text(
                    _bioEnabled
                        ? l10nPick(
                            context,
                            en: 'Enabled — quick security check',
                            fa: 'فعال — ورود سریع و امن',
                          )
                        : l10nPick(
                            context,
                            en: 'Sign in with your fingerprint or face',
                            fa: 'قفل‌گشایی سریع با بیومتریک این دستگاه',
                          ),
                    style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                  ),
                  value: _bioEnabled,
                  activeTrackColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  onChanged: _toggleBio,
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.greyLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.softGray,
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Biometric Authentication',
                      fa: 'احراز هویت بیومتریک',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(color: isDark ? AppColors.softGray : AppColors.greyDark),
                  ),
                  subtitle: Text(
                    l10nPick(
                      context,
                      en: 'Not supported or not configured on this hardware',
                      fa: 'سخت‌افزار بیومتریک روی این دستگاه فعال نیست',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGray),
                  ),
                ),

              Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

              // Auto App Lock duration
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: autoLockStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: autoLockStyle.iconColor,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  l10nPick(
                    context,
                    en: 'Auto App Lock',
                    fa: 'قفل خودکار اپلیکیشن',
                    ar: 'قفل التطبيق التلقائي',
                    zh: '应用自动锁定',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                ),
                subtitle: Text(
                  _lockLabel(_lockMinutes),
                  style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _lockLabel(_lockMinutes),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: isDark ? AppColors.softGray : AppColors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
                onTap: _chooseAutoLock,
              ),

              Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

              // App Lock PIN
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: pinStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.pin_outlined,
                    color: pinStyle.iconColor,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  l10nPick(
                    context,
                    en: 'App Lock PIN',
                    fa: 'PIN قفل دستگاه',
                    ar: 'رمز قفل التطبيق',
                    zh: '应用锁定PIN',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                ),
                subtitle: Text(
                  _hasPinSet
                      ? l10nPick(
                          context,
                          en: 'Active • Tap to change',
                          fa: 'تنظیم شده • برای تغییر کلیک کنید',
                        )
                      : l10nPick(
                          context,
                          en: 'Not configured • Tap to set 4 digits',
                          fa: 'تنظیم نشده • برای تعیین ۴ رقم کلیک کنید',
                        ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _hasPinSet ? AppColors.success : secondaryTextColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _hasPinSet
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        _hasPinSet
                            ? l10nPick(context, en: 'Configured', fa: 'فعال')
                            : l10nPick(
                                context,
                                en: 'Not set',
                                fa: 'تنظیم نشده',
                              ),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _hasPinSet ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: isDark ? AppColors.softGray : AppColors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
                onTap: _changePin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. Security Activity Audit Log
  // ==========================================
  Widget _buildSecurityAuditLogSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 4.h),
          child: Text(
            l10nPick(
              context,
              en: 'Security Activity Audit Log',
              fa: 'گزارش فعالیت‌های امنیتی',
              ar: 'سجل تدقيق النشاط الأمني',
              zh: '安全活动审计日志',
            ),
            style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: AppSpacing.sm),
          child: Text(
            l10nPick(
              context,
              en: 'Recent sign-ins, password updates, and session events on your account.',
              fa: 'آخرین ورودها، تغییرات گذرواژه و رویدادهای حساس حساب شما.',
              ar: 'آخر عمليات تسجيل الدخول وتغييرات كلمة المرور على حسابك.',
              zh: '账户最近的登录记录、密码修改与安全事件。',
            ),
            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            children: [
              for (int i = 0; i < _auditLogs.length; i++) ...[
                _buildAuditLogTile(_auditLogs[i], isDark),
                if (i < _auditLogs.length - 1)
                  Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogTile(SecurityAuditLogItem item, bool isDark) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.titleSmall.copyWith(color: primaryTextColor),
                      ),
                    ),
                    Text(
                      _formatRelativeTime(item.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
                if (item.ipAddress != null || item.location != null) ...[
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      if (item.ipAddress != null)
                        Text(
                          'IP: ${item.ipAddress}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            fontFamily: 'monospace',
                            color: secondaryTextColor,
                          ),
                        ),
                      if (item.location != null)
                        Text(
                          item.location!,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing indicator widget for "Active Now" live state.
class _PulsingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingIndicator({
    this.color = AppColors.success,
    this.size = 10.0,
  });

  @override
  State<_PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 2.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final scale = _animation.value;
              final opacity = (1.0 - (scale - 1.0) / 1.1).clamp(0.0, 1.0);
              return Container(
                width: widget.size * scale,
                height: widget.size * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: opacity * 0.4),
                ),
              );
            },
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

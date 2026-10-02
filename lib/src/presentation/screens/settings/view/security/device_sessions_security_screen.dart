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
        browser: 'Mobile Safari 17.5',
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
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _currentDevice = _currentDevice.copyWith(lastActive: DateTime.now());
      _loading = false;
    });
    Get.snackbar(
      l10nPick(context, en: 'Security Status', fa: 'وضعیت امنیت'),
      l10nPick(
        context,
        en: 'Active sessions and device security refreshed',
        fa: 'اطلاعات نشست‌ها و امنیت دستگاه به‌روزرسانی شد',
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(12.w),
      backgroundColor: AppColors.white,
      colorText: AppColors.black,
    );
  }

  Future<void> _toggleBio(bool value) async {
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
            en: 'Biometric unlock disabled on this device',
            fa: 'ورود با اثر انگشت یا چهره غیرفعال شد',
          ),
          type: SecurityAuditType.pinChange,
        );
      }
    }
  }

  Future<void> _changePin() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.pin_rounded, color: AppColors.lightPrimary, size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'App Lock PIN (4 digits)',
                  fa: 'PIN قفل دستگاه (۴ رقم)',
                  ar: 'رمز قفل التطبيق (4 أرقام)',
                  zh: '应用锁定PIN (4位)',
                ),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10nPick(
                context,
                en: 'This PIN is only used locally to unlock the app on this phone.',
                fa: 'این پین‌کد تنها برای باز کردن قفل اپلیکیشن در این دستگاه کاربرد دارد.',
                ar: 'يُستخدم هذا الرمز محليًا فقط لفتح التطبيق على هذا الجهاز.',
                zh: '此PIN仅在本地用于解锁此设备上的应用。',
              ),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: c1,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'New PIN', fa: 'PIN جدید'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: c2,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Repeat PIN', fa: 'تکرار PIN'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.lock_reset_rounded),
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
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(l10nPick(context, en: 'Save', fa: 'ذخیره')),
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
      setState(() => _hasPinSet = true);
      _addAudit(
        title: l10nPick(context, en: 'App Lock PIN Updated', fa: 'تغییر PIN قفل اپ'),
        description: l10nPick(
          context,
          en: 'Device unlock passcode was set / updated',
          fa: 'رمز عبور قفل محلی دستگاه با موفقیت تنظیم یا تغییر یافت',
        ),
        type: SecurityAuditType.pinChange,
      );
      Get.snackbar(
        'PIN',
        l10nPick(context, en: 'PIN saved successfully', fa: 'PIN با موفقیت ذخیره شد'),
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
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }

  Future<void> _chooseAutoLock() async {
    final v = await showModalBottomSheet<int>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                l10nPick(
                  context,
                  en: 'Auto App Lock Duration',
                  fa: 'مدت زمان قفل خودکار اپلیکیشن',
                  ar: 'مدة القفل التلقائي',
                  zh: '自动锁定时间',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.lightDivider),
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
                title: Text(e.value, style: TextStyle(fontSize: 14.sp)),
                trailing: _lockMinutes == e.key
                    ? Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20.sp)
                    : null,
                onTap: () => Navigator.pop(ctx, e.key),
              ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );

    if (v != null && mounted) {
      if (_settings != null) {
        await _settings!.setAppLockMinutes(v);
      }
      setState(() => _lockMinutes = v);
      Get.snackbar(
        l10nPick(context, en: 'App Lock', fa: 'قفل اپ'),
        l10nPick(
          context,
          en: 'Auto-lock duration updated',
          fa: 'زمان‌بندی قفل خودکار تنظیم شد',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );
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
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 22.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'Log Out Device?',
                  fa: 'خروج از نشست این دستگاه؟',
                  ar: 'تسجيل الخروج من هذا الجهاز؟',
                  zh: '退出此设备登录？',
                ),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColors.black),
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
                borderRadius: BorderRadius.circular(8.r),
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
        title: l10nPick(
          context,
          en: 'Device Session Terminated',
          fa: 'نشست دستگاه باطل شد',
        ),
        description: '${session.deviceName} • ${session.ipAddress} • ${session.location}',
        type: SecurityAuditType.sessionRevoked,
        ipAddress: session.ipAddress,
        location: session.location,
      );
      Get.snackbar(
        l10nPick(context, en: 'Device Terminated', fa: 'خاتمه نشست'),
        l10nPick(
          context,
          en: 'Session on "${session.deviceName}" was revoked.',
          fa: 'نشست دستگاه «${session.deviceName}» با موفقیت پایان یافت.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.white,
        colorText: AppColors.black,
      );
    }
  }

  Future<void> _terminateAllOtherSessions() async {
    final count = _otherSessions.length;
    if (count == 0) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'Terminate All Other Sessions',
                  fa: 'خروج اضطراری از تمام نشست‌ها',
                  ar: 'إنهاء جميع الجلسات الأخرى',
                  zh: '终止所有其他会话',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
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
                en: 'Are you sure you want to terminate all other $count active session(s)?',
                fa: 'آیا از خروج اضطراری از تمامی $count نشست فعال دیگر اطمینان دارید؟',
                ar: 'هل أنت متأكد من إنهاء جميع الجلسات الأخرى ($count)؟',
                zh: '确定要紧急终止其他全部 $count 个活动会话吗？',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
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
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.lightTextSecondary,
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
                borderRadius: BorderRadius.circular(8.r),
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
        title: l10nPick(
          context,
          en: 'Emergency Revocation Executed',
          fa: 'خروج اضطراری از تمام نشست‌ها اجرا شد',
        ),
        description: l10nPick(
          context,
          en: '$count active session(s) were terminated immediately.',
          fa: '$count نشست فعال دیگر به صورت اضطراری لغو و مسدود شدند.',
        ),
        type: SecurityAuditType.sessionRevoked,
      );
      Get.snackbar(
        l10nPick(context, en: 'Emergency Revocation', fa: 'خروج اضطراری'),
        l10nPick(
          context,
          en: 'All other active sessions have been terminated.',
          fa: 'تمامی نشست‌های فعال دیگر با موفقیت مسدود و خارج شدند.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.white,
        colorText: AppColors.black,
      );
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Devices & Active Sessions',
            fa: 'دستگاه‌ها و نشست‌های فعال',
            ar: 'الأجهزة والجلسات النشطة',
            zh: '设备与活动会话',
          ),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.black,
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.lightPrimary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.page,
                  10.h,
                  AppSpacing.page,
                  AppSpacing.bottomSafe(context, 32.h),
                ),
                children: [
                  // 1. "This Device" Hero Card
                  _buildThisDeviceHeroCard(),

                  SizedBox(height: 20.h),

                  // 2. "Other Active Devices" Section
                  _buildOtherDevicesSection(),

                  SizedBox(height: 16.h),

                  // 3. Emergency Revoke Button (Terminate all other sessions)
                  _buildTerminateAllButton(),

                  SizedBox(height: 24.h),

                  // 4. Biometric App Lock & PIN Quick Settings Section
                  _buildBiometricAndLockSection(),

                  SizedBox(height: 24.h),

                  // 5. Security Activity Audit Log
                  _buildSecurityAuditLogSection(),
                ],
              ),
            ),
    );
  }

  // ==========================================
  // 1. "This Device" Hero Card
  // ==========================================
  Widget _buildThisDeviceHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge + Shield Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PulsingIndicator(
                      color: AppColors.success,
                      size: 9.0,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      l10nPick(
                        context,
                        en: 'Active Now (This Device)',
                        fa: 'نشست فعلی (فعال اکنون)',
                        ar: 'نشط الآن (هذا الجهاز)',
                        zh: '当前在线（本机）',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
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

          SizedBox(height: 14.h),

          // Device info main row
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _currentDevice.icon,
                  color: AppColors.lightPrimary,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentDevice.deviceName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_currentDevice.localizedType(context)} • ${_currentDevice.operatingSystem}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),

          // Metadata row: IP, Location, App version
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 15.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'IP: ${_currentDevice.ipAddress}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 15.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        _currentDevice.location,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Security check assurance banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14.sp,
                  color: AppColors.lightPrimary,
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
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.lightPrimary,
                      fontWeight: FontWeight.w500,
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
  Widget _buildOtherDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: AppColors.lightPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _otherSessions.isNotEmpty
                      ? AppColors.lightPrimary.withValues(alpha: 0.12)
                      : AppColors.greyLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_otherSessions.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: _otherSessions.isNotEmpty
                        ? AppColors.lightPrimary
                        : AppColors.greyDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_otherSessions.isEmpty)
          _buildEmptyOtherSessionsCard()
        else
          Column(
            children: _otherSessions
                .map((session) => _buildDeviceSessionCard(session))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyOtherSessionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_good_rounded,
              color: AppColors.success,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            l10nPick(
              context,
              en: 'No Other Active Sessions',
              fa: 'هیچ نشست فعال دیگری وجود ندارد',
              ar: 'لا توجد جلسات نشطة أخرى',
              zh: '无其他活动会话',
            ),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10nPick(
              context,
              en: 'Your account is exclusively accessed from this device.',
              fa: 'حساب کاربری شما تنها روی همین دستگاه فعال است.',
              ar: 'يتم استخدام حسابك حصريًا من هذا الجهاز.',
              zh: '您的账户目前仅在此设备上登录。',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSessionCard(DeviceSessionItem session) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
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
                  color: AppColors.greyLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  session.icon,
                  color: AppColors.black,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.deviceName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${session.operatingSystem} • ${session.browser}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextSecondary,
                      ),
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _revokeSession(session),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: AppColors.lightDivider),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                size: 13.sp,
                color: AppColors.lightTextSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                session.ipAddress,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: 'monospace',
                  color: AppColors.lightTextSecondary,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.place_outlined,
                size: 13.sp,
                color: AppColors.lightTextSecondary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  session.location,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.access_time_rounded,
                size: 13.sp,
                color: AppColors.lightTextSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatRelativeTime(session.lastActive),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.lightTextSecondary,
                ),
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
  Widget _buildTerminateAllButton() {
    final hasOthers = _otherSessions.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasOthers
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasOthers
                ? AppColors.error.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: (hasOthers ? AppColors.error : AppColors.grey)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: hasOthers ? AppColors.error : AppColors.grey,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
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
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: hasOthers ? AppColors.error : AppColors.greyDark,
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
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasOthers
                    ? AppColors.error
                    : AppColors.greyLight.withValues(alpha: 0.8),
                foregroundColor:
                    hasOthers ? AppColors.white : AppColors.greyDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
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
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
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
  Widget _buildBiometricAndLockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
          child: Text(
            l10nPick(
              context,
              en: 'Biometric & Local App Lock',
              fa: 'تنظیمات قفل اپلیکیشن و بیومتریک',
              ar: 'قفل التطبيق والمصادقة البيومترية',
              zh: '生物识别与应用锁定',
            ),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.lightPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          child: Column(
            children: [
              // Biometric toggle
              if (_bioSupported)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.lightPrimary,
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
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  value: _bioEnabled,
                  activeColor: AppColors.lightPrimary,
                  onChanged: _toggleBio,
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.grey,
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Biometric Authentication',
                      fa: 'احراز هویت بیومتریک',
                    ),
                    style: TextStyle(fontSize: 13.sp, color: AppColors.greyDark),
                  ),
                  subtitle: Text(
                    l10nPick(
                      context,
                      en: 'Not supported or not configured on this hardware',
                      fa: 'سخت‌افزار بیومتریک روی این دستگاه فعال نیست',
                    ),
                    style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
                  ),
                ),

              Divider(height: 1, color: AppColors.lightDivider),

              // Auto App Lock duration
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: AppColors.lightPrimary,
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
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _lockLabel(_lockMinutes),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _lockLabel(_lockMinutes),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
                onTap: _chooseAutoLock,
              ),

              Divider(height: 1, color: AppColors.lightDivider),

              // App Lock PIN
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.pin_outlined,
                    color: AppColors.lightPrimary,
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
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
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
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: _hasPinSet
                        ? AppColors.success
                        : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _hasPinSet
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _hasPinSet
                            ? l10nPick(context, en: 'Configured', fa: 'فعال')
                            : l10nPick(
                                context,
                                en: 'Not set',
                                fa: 'تنظیم نشده',
                              ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: _hasPinSet
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.grey,
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
  Widget _buildSecurityAuditLogSection() {
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
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.lightPrimary,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
          child: Text(
            l10nPick(
              context,
              en: 'Recent sign-ins, password updates, and session events on your account.',
              fa: 'آخرین ورودها، تغییرات گذرواژه و رویدادهای حساس حساب شما.',
              ar: 'آخر عمليات تسجيل الدخول وتغييرات كلمة المرور على حسابك.',
              zh: '账户最近的登录记录、密码修改与安全事件。',
            ),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Column(
            children: [
              for (int i = 0; i < _auditLogs.length; i++) ...[
                _buildAuditLogTile(_auditLogs[i]),
                if (i < _auditLogs.length - 1)
                  Divider(height: 1, color: AppColors.lightDivider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogTile(SecurityAuditLogItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Text(
                      _formatRelativeTime(item.timestamp),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                    height: 1.35,
                  ),
                ),
                if (item.ipAddress != null || item.location != null) ...[
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      if (item.ipAddress != null)
                        Text(
                          'IP: ${item.ipAddress}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'monospace',
                            color: AppColors.lightTextTertiary,
                          ),
                        ),
                      if (item.location != null)
                        Text(
                          item.location!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.lightTextTertiary,
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
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity * 0.45),
                  ),
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
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

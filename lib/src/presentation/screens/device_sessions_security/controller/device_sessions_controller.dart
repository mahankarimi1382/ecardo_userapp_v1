import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/model/device_session_model.dart';

/// GetX controller managing Active Device Sessions & Security controls:
/// - Hardware device detection & "This Device" hero metadata
/// - Remote active sessions list with individual & emergency revocation
/// - Biometric & App Lock local policies
/// - Security activity audit trail
class DeviceSessionsController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isTerminatingAll = false.obs;

  final Rx<DeviceSessionItem?> currentDevice = Rx<DeviceSessionItem?>(null);
  final RxList<DeviceSessionItem> otherSessions = <DeviceSessionItem>[].obs;
  final RxList<SecurityAuditLogItem> auditLogs = <SecurityAuditLogItem>[].obs;

  final RxBool bioSupported = false.obs;
  final RxBool bioEnabled = false.obs;
  final RxBool hasPinSet = false.obs;
  final RxInt lockMinutes = 0.obs;

  SettingsService? get _settings =>
      Get.isRegistered<SettingsService>() ? Get.find<SettingsService>() : null;
  final BiometricAuthService _bio = BiometricAuthService();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    try {
      // 1. Detect current hardware device info
      final detected = await _detectCurrentDevice();
      currentDevice.value = detected;

      // 2. Initialize simulated other active sessions
      otherSessions.assignAll([
        DeviceSessionItem(
          id: 'sess_oth_win11',
          deviceName: 'Chrome در Windows 11',
          deviceType: DeviceFormFactor.desktop,
          os: DeviceOs.windows,
          operatingSystem: 'Windows 11 Pro 64-bit',
          browser: 'Google Chrome 128.0',
          appVersion: 'Web Client v1.2',
          ipAddress: '185.192.112.5',
          location: 'تهران، ایران',
          loginTimestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          lastActive: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          isCurrentDevice: false,
        ),
        DeviceSessionItem(
          id: 'sess_oth_ipad',
          deviceName: 'iPad Pro 12.9"',
          deviceType: DeviceFormFactor.tablet,
          os: DeviceOs.ios,
          operatingSystem: 'iPadOS 17.5.1',
          browser: 'Mobile Safari 17.4',
          appVersion: 'Ecardo iOS v1.0.40',
          ipAddress: '2.188.75.140',
          location: 'اصفهان، ایران',
          loginTimestamp: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
          lastActive: DateTime.now().subtract(const Duration(hours: 19, minutes: 40)),
          isCurrentDevice: false,
        ),
        DeviceSessionItem(
          id: 'sess_oth_mac',
          deviceName: 'MacBook Pro 16"',
          deviceType: DeviceFormFactor.desktop,
          os: DeviceOs.macos,
          operatingSystem: 'macOS Sonoma 14.5',
          browser: 'Firefox Developer 127.0',
          appVersion: 'Web Client v1.2',
          ipAddress: '91.240.64.12',
          location: 'دبی، امارات متحده عربی',
          loginTimestamp: DateTime.now().subtract(const Duration(days: 8, hours: 1)),
          lastActive: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
          isCurrentDevice: false,
        ),
      ]);

      // 3. Security Activity Audit Trail
      auditLogs.assignAll([
        SecurityAuditLogItem(
          id: 'audit_01',
          title: 'ورود موفق به نشست فعلی (این دستگاه)',
          description: '${detected.deviceName} • ${detected.location} • احراز هویت با بیومتریک',
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
          type: SecurityAuditType.signIn,
          ipAddress: detected.ipAddress,
          location: detected.location,
        ),
        SecurityAuditLogItem(
          id: 'audit_02',
          title: 'ورود از مرورگر وب (Chrome در Windows)',
          description: 'Windows 11 Pro • تهران • احراز هویت استاندارد با رمز عبور و پیامک',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          type: SecurityAuditType.signIn,
          ipAddress: '185.192.112.5',
          location: 'تهران، ایران',
        ),
        SecurityAuditLogItem(
          id: 'audit_03',
          title: 'هشدار امنیتی: اتصال تبلت جدید',
          description: 'iPad Pro 12.9" • اصفهان • تأیید موفق با کد یک‌بارمصرف دومرحله‌ای (2FA)',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          type: SecurityAuditType.newDeviceAlert,
          ipAddress: '2.188.75.140',
          location: 'اصفهان، ایران',
        ),
        SecurityAuditLogItem(
          id: 'audit_04',
          title: 'تغییر موفقیت‌آمیز رمز عبور حساب',
          description: 'رمز عبور حساب از طریق منوی امنیت تغییر یافت و نشست‌های قدیمی بازبینی شدند',
          timestamp: DateTime.now().subtract(const Duration(days: 8)),
          type: SecurityAuditType.passwordChange,
        ),
        SecurityAuditLogItem(
          id: 'audit_05',
          title: 'فعال‌سازی ورود دو مرحله‌ای (Google 2FA)',
          description: 'Google Authenticator برای ورود به حساب کاربری فعال گردید',
          timestamp: DateTime.now().subtract(const Duration(days: 18)),
          type: SecurityAuditType.twoFactor,
        ),
      ]);

      // 4. Read Biometrics & AppLock configuration
      final supported = await _bio.isSupported();
      final enabled = await _bio.isEnabled();
      final lockMin = _settings != null ? await _settings!.getAppLockMinutes() : 0;
      final hasPin = Get.isRegistered<AppLockService>()
          ? await Get.find<AppLockService>().hasPinSet()
          : await AppLockService().hasPinSet();

      bioSupported.value = supported;
      bioEnabled.value = enabled;
      lockMinutes.value = lockMin;
      hasPinSet.value = hasPin;
    } catch (e) {
      debugPrint('DeviceSessionsController.initData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<DeviceSessionItem> _detectCurrentDevice() async {
    String deviceName = 'Samsung Galaxy S24 Ultra';
    DeviceFormFactor deviceType = DeviceFormFactor.phone;
    DeviceOs os = DeviceOs.android;
    String operatingSystem = 'Android 14 (One UI 6.1)';
    String appVer = 'v1.0.41 (Build 41)';

    try {
      final pInfo = await PackageInfo.fromPlatform()
          .timeout(const Duration(milliseconds: 300));
      appVer = 'v${pInfo.version} (${pInfo.buildNumber})';
    } catch (_) {}

    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        deviceName = web.browserName.name.capitalizeFirst ?? 'Web Browser';
        deviceType = DeviceFormFactor.browser;
        os = DeviceOs.web;
        operatingSystem = web.userAgent ?? 'Web Browser';
      } else if (Platform.isAndroid) {
        final android = await info.androidInfo;
        final model = android.model.isNotEmpty ? android.model : 'Android Device';
        final brand = android.manufacturer.capitalizeFirst ?? '';
        deviceName = brand.isNotEmpty ? '$brand $model' : model;
        deviceType = DeviceFormFactor.phone;
        os = DeviceOs.android;
        operatingSystem = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        deviceName = ios.name.isNotEmpty ? ios.name : 'iPhone';
        deviceType = ios.model.toLowerCase().contains('ipad') ? DeviceFormFactor.tablet : DeviceFormFactor.phone;
        os = DeviceOs.ios;
        operatingSystem = '${ios.systemName} ${ios.systemVersion}';
      } else if (Platform.isWindows) {
        final win = await info.windowsInfo;
        deviceName = win.computerName.isNotEmpty ? win.computerName : 'Windows PC';
        deviceType = DeviceFormFactor.desktop;
        os = DeviceOs.windows;
        operatingSystem = 'Windows 11 (${win.productName})';
      } else if (Platform.isMacOS) {
        final mac = await info.macOsInfo;
        deviceName = mac.computerName.isNotEmpty ? mac.computerName : 'Mac';
        deviceType = DeviceFormFactor.desktop;
        os = DeviceOs.macos;
        operatingSystem = 'macOS ${mac.osRelease}';
      } else if (Platform.isLinux) {
        final linux = await info.linuxInfo;
        deviceName = linux.name;
        deviceType = DeviceFormFactor.desktop;
        os = DeviceOs.linux;
        operatingSystem = linux.prettyName;
      }
    } catch (_) {
      // Graceful fallback to rich defaults
    }

    return DeviceSessionItem(
      id: 'sess_curr_device',
      deviceName: deviceName,
      deviceType: deviceType,
      os: os,
      operatingSystem: operatingSystem,
      browser: 'Ecardo App $appVer',
      appVersion: appVer,
      ipAddress: '5.127.189.42',
      location: 'تهران، ایران',
      loginTimestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 12)),
      lastActive: DateTime.now(),
      isCurrentDevice: true,
    );
  }

  Future<void> refreshSessions(BuildContext context) async {
    final toastMsg = l10nPick(
      context,
      en: 'Active sessions and device security refreshed',
      fa: 'اطلاعات نشست‌ها و امنیت دستگاه به‌روزرسانی شد',
      ar: 'تم تحديث الجلسات النشطة بنجاح',
      zh: '活动会话与设备安全状态已刷新',
    );
    HapticFeedback.lightImpact();
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 450));
    if (currentDevice.value != null) {
      currentDevice.value = currentDevice.value!.copyWith(lastActive: DateTime.now());
    }
    isLoading.value = false;
    ToastHelper().showSuccessToast(toastMsg);
  }

  Future<bool> confirmAndRevokeSessionWithBottomSheet(
    BuildContext context,
    DeviceSessionItem session,
  ) async {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final auditTitle = l10nPick(
      context,
      en: 'Device Session Revoked',
      fa: 'نشست دستگاه باطل شد',
      ar: 'تم إنهاء جلسة الجهاز',
      zh: '已撤销设备会话',
    );
    final toastSuccess = l10nPick(
      context,
      en: 'Session on "${session.deviceName}" was revoked.',
      fa: 'نشست دستگاه «${session.deviceName}» با موفقیت پایان یافت.',
      ar: 'تم إنهاء جلسة «${session.deviceName}» بنجاح.',
      zh: '设备“${session.deviceName}”的会话已终止。',
    );

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                l10nPick(
                  context,
                  en: 'Log Out Device?',
                  fa: 'خروج از این دستگاه؟',
                  ar: 'تسجيل الخروج من هذا الجهاز؟',
                  zh: '退出此设备登录？',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10nPick(
                  context,
                  en: 'Are you sure you want to log out "${session.deviceName}"?',
                  fa: 'آیا از پایان دادن به نشست دستگاه «${session.deviceName}» اطمینان دارید؟',
                  ar: 'هل أنت متأكد من إنهاء جلسة «${session.deviceName}»؟',
                  zh: '确定要注销设备“${session.deviceName}”吗？',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.greyLight.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: session.os.brandColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Center(
                        child: Icon(session.icon, color: session.os.brandColor, size: 22.sp),
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
                          SizedBox(height: 2.h),
                          Text(
                            '${session.operatingSystem} • ${session.clientVersion}',
                            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor, fontSize: 11.5.sp),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'IP: ${session.ipAddress} • ${session.location}',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                l10nPick(
                  context,
                  en: 'Its session will be revoked immediately and require credentials to sign in again.',
                  fa: 'دسترسی این دستگاه بلافاصله لغو شده و برای ورود مجدد نیاز به احراز هویت خواهد داشت.',
                  ar: 'سيتم إنهاء الجلسة فورًا وسيتطلب تسجيل الدخول مجددًا.',
                  zh: '该会话将立即撤销，若要再次使用需重新通过凭证登录。',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: secondaryTextColor,
                  height: 1.45,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  icon: Icon(Icons.logout_rounded, size: 18.sp),
                  label: Text(
                    l10nPick(
                      context,
                      en: 'Log Out Device',
                      fa: 'خروج از این دستگاه',
                      ar: 'إنهاء الجلسة',
                      zh: '确认登出',
                    ),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx, true);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: TextButton(
                  child: Text(
                    l10nPick(context, en: 'Cancel', fa: 'انصراف', ar: 'إلغاء', zh: '取消'),
                    style: AppTextStyles.labelMedium.copyWith(color: secondaryTextColor),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      otherSessions.removeWhere((item) => item.id == session.id);
      addAudit(
        title: auditTitle,
        description: '${session.deviceName} • ${session.ipAddress} • ${session.location}',
        type: SecurityAuditType.sessionRevoked,
        ipAddress: session.ipAddress,
        location: session.location,
      );
      ToastHelper().showSuccessToast(toastSuccess);
      return true;
    }
    return false;
  }

  Future<void> revokeSession(BuildContext context, DeviceSessionItem session) async {
    await confirmAndRevokeSessionWithBottomSheet(context, session);
  }

  Future<void> terminateAllOtherSessions(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final count = otherSessions.length;
    if (count == 0) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final auditTitle = l10nPick(
      context,
      en: 'Emergency Revocation Executed',
      fa: 'خروج اضطراری از تمام نشست‌ها اجرا شد',
      ar: 'تم تنفيذ الإنهاء الطارئ لجميع الجلسات',
      zh: '紧急终止所有外部会话',
    );
    final auditDesc = l10nPick(
      context,
      en: '$count active session(s) were terminated immediately.',
      fa: '$count نشست فعال دیگر به صورت اضطراری مسدود و پایان یافتند.',
      ar: 'تم إنهاء $count جلسة نشطة على الفور.',
      zh: '已立即终止其他 $count 个活动会话。',
    );
    final toastSuccess = l10nPick(
      context,
      en: 'All other active sessions have been terminated.',
      fa: 'تمامی نشست‌های فعال دیگر با موفقیت مسدود و خارج شدند.',
      ar: 'تم إنهاء جميع الجلسات الأخرى بنجاح.',
      zh: '所有其他活动会话均已被注销。',
    );

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                l10nPick(
                  context,
                  en: 'Terminate All Other Sessions?',
                  fa: 'خروج اضطراری از سایر دستگاه‌ها؟',
                  ar: 'إنهاء كل الجلسات الأخرى فورًا؟',
                  zh: '终止所有其他活动会话？',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  l10nPick(
                    context,
                    en: '$count active session(s) will be logged out immediately.',
                    fa: '$count نشست فعال دیگر بلافاصله مسدود و خارج می‌شوند.',
                    ar: 'سيتم إنهاء $count جلسة نشطة فورًا.',
                    zh: '将立即退出其他 $count 台设备的登录状态。',
                  ),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                l10nPick(
                  context,
                  en: 'All active sessions on browsers, tablets, and computers (except this device) '
                      'will be immediately revoked. Anyone using them will be locked out.\n\n'
                      'This device will remain safely active.',
                  fa: 'تمامی نشست‌های فعال در مرورگرها، تبلت‌ها و رایانه‌های دیگر بلافاصله مسدود '
                      'شده و دسترسی آن‌ها به حساب شما لغو می‌گردد.\n\n'
                      'نشست شما روی همین دستگاه همچنان فعال و امن باقی خواهد ماند.',
                  ar: 'سيتم إلغاء جميع الجلسات النشطة على الأجهزة الأخرى فورًا.',
                  zh: '除当前设备外的所有活动会话将立即撤销，保障账户与资金安全。',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: secondaryTextColor,
                  height: 1.45,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  icon: Icon(Icons.no_accounts_rounded, size: 20.sp),
                  label: Text(
                    l10nPick(
                      context,
                      en: 'Confirm & Terminate All ($count)',
                      fa: 'تأیید و خروج از همه ($count دستگاه)',
                      ar: 'تأكيد وإنهاء الجميع ($count)',
                      zh: '确认全部终止 ($count)',
                    ),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(ctx, true);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: TextButton(
                  child: Text(
                    l10nPick(context, en: 'Cancel', fa: 'انصراف', ar: 'إلغاء', zh: '取消'),
                    style: AppTextStyles.labelMedium.copyWith(color: secondaryTextColor),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      isTerminatingAll.value = true;
      HapticFeedback.heavyImpact();
      otherSessions.clear();
      addAudit(
        title: auditTitle,
        description: auditDesc,
        type: SecurityAuditType.sessionRevoked,
      );
      isTerminatingAll.value = false;
      ToastHelper().showSuccessToast(toastSuccess);
    }
  }

  void addAudit({
    required String title,
    required String description,
    required SecurityAuditType type,
    String? ipAddress,
    String? location,
  }) {
    auditLogs.insert(
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
  }

  Future<void> toggleBiometric(bool value, BuildContext context) async {
    final titleOn = l10nPick(
      context,
      en: 'Biometric Lock Enabled',
      fa: 'فعال‌سازی قفل بیومتریک',
      ar: 'تم تفعيل القفل البيومتري',
      tr: 'Biyometrik Kilit Etkinleştirildi',
      ru: 'Биометрическая блокировка включена',
      zh: '生物识别锁定已启用',
    );
    final descOn = l10nPick(
      context,
      en: 'Biometric unlock enabled on this device',
      fa: 'ورود با اثر انگشت یا چهره در این دستگاه فعال شد',
      ar: 'تم تفعيل الدخول بالبصمة أو الوجه على هذا الجهاز',
      tr: 'Bu cihazda biyometrik kilit açma etkinleştirildi',
      ru: 'Биометрическая разблокировка включена на этом устройстве',
      zh: '此设备已启用生物识别解锁',
    );
    final titleOff = l10nPick(
      context,
      en: 'Biometric Lock Disabled',
      fa: 'غیرفعال‌سازی قفل بیومتریک',
      ar: 'تم إيقاف القفل البيومتري',
      tr: 'Biyometrik Kilit Devre Dışı Bırakıldı',
      ru: 'Биометрическая блокировка отключена',
      zh: '生物识别锁定已禁用',
    );
    final descOff = l10nPick(
      context,
      en: 'Biometric unlock turned off',
      fa: 'ورود با اثر انگشت یا چهره غیرفعال شد',
      ar: 'تم إيقاف الدخول بالبصمة أو الوجه',
      tr: 'Biyometrik kilit açma kapatıldı',
      ru: 'Биометрическая разблокировка отключена',
      zh: '生物识别解锁已关闭',
    );

    HapticFeedback.lightImpact();
    if (value) {
      final ok = await _bio.enable();
      if (ok) {
        bioEnabled.value = true;
        addAudit(
          title: titleOn,
          description: descOn,
          type: SecurityAuditType.pinChange,
        );
      }
    } else {
      final ok = await _bio.disable();
      if (ok) {
        bioEnabled.value = false;
        addAudit(
          title: titleOff,
          description: descOff,
          type: SecurityAuditType.pinChange,
        );
      }
    }
  }
}

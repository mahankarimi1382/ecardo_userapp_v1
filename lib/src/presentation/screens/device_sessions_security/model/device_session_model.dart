import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Supported physical device forms for active sessions.
enum DeviceFormFactor { phone, tablet, desktop, browser }

/// Backwards compatibility alias
typedef DeviceType = DeviceFormFactor;

/// Supported operating systems with dedicated branding and icons.
enum DeviceOs {
  android,
  ios,
  windows,
  macos,
  linux,
  web;

  IconData get icon {
    switch (this) {
      case DeviceOs.android:
        return Icons.android_rounded;
      case DeviceOs.ios:
        return Icons.apple;
      case DeviceOs.windows:
        return Icons.window_rounded;
      case DeviceOs.macos:
        return Icons.laptop_mac_rounded;
      case DeviceOs.linux:
        return Icons.terminal_rounded;
      case DeviceOs.web:
        return Icons.language_rounded;
    }
  }

  Color get brandColor {
    switch (this) {
      case DeviceOs.android:
        return const Color(0xFF34A853);
      case DeviceOs.ios:
        return const Color(0xFF555555);
      case DeviceOs.windows:
        return const Color(0xFF0078D4);
      case DeviceOs.macos:
        return const Color(0xFF5E5CE6);
      case DeviceOs.linux:
        return const Color(0xFFE95420);
      case DeviceOs.web:
        return AppColors.mainSoftBlue;
    }
  }

  String localizedName(BuildContext context) {
    switch (this) {
      case DeviceOs.android:
        return 'Android';
      case DeviceOs.ios:
        return 'iOS';
      case DeviceOs.windows:
        return 'Windows';
      case DeviceOs.macos:
        return 'macOS';
      case DeviceOs.linux:
        return 'Linux';
      case DeviceOs.web:
        return l10nPick(
          context,
          en: 'Web Browser',
          fa: 'مرورگر وب',
          ar: 'متصفح الويب',
          zh: '网页浏览器',
        );
    }
  }
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
  final DeviceFormFactor deviceType;
  final DeviceOs os;
  final String operatingSystem;
  final String browser;
  final String? appVersion;
  final String ipAddress;
  final String location;
  final DateTime loginTimestamp;
  final DateTime lastActive;
  final bool isCurrentDevice;

  const DeviceSessionItem({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    this.os = DeviceOs.android,
    required this.operatingSystem,
    required this.browser,
    this.appVersion,
    required this.ipAddress,
    required this.location,
    required this.loginTimestamp,
    required this.lastActive,
    this.isCurrentDevice = false,
  });

  DeviceSessionItem copyWith({
    String? id,
    String? deviceName,
    DeviceFormFactor? deviceType,
    DeviceOs? os,
    String? operatingSystem,
    String? browser,
    String? appVersion,
    String? ipAddress,
    String? location,
    DateTime? loginTimestamp,
    DateTime? lastActive,
    bool? isCurrentDevice,
  }) {
    return DeviceSessionItem(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      os: os ?? this.os,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      browser: browser ?? this.browser,
      appVersion: appVersion ?? this.appVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      loginTimestamp: loginTimestamp ?? this.loginTimestamp,
      lastActive: lastActive ?? this.lastActive,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }

  String get clientVersion => appVersion ?? browser;

  IconData get icon {
    switch (deviceType) {
      case DeviceFormFactor.phone:
        if (os == DeviceOs.ios) {
          return Icons.phone_iphone_rounded;
        }
        return Icons.phone_android_rounded;
      case DeviceFormFactor.tablet:
        return Icons.tablet_mac_rounded;
      case DeviceFormFactor.desktop:
        return Icons.laptop_mac_rounded;
      case DeviceFormFactor.browser:
        if (os == DeviceOs.macos || os == DeviceOs.windows) {
          return Icons.laptop_mac_rounded;
        }
        return Icons.language_rounded;
    }
  }

  /// Formatted last active timestamp using Jalali for Persian ("دیروز ۱۴:۳۰", "امروز ۱۰:۱۵")
  /// and localized relative format for other languages.
  String formattedJalaliOrRelative(BuildContext context) {
    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    if (isFa) {
      return JalaliDateHelper.formatDateTime(lastActive);
    }
    return formattedRelativeLastActive(context);
  }

  String localizedType(BuildContext context) {
    switch (deviceType) {
      case DeviceFormFactor.phone:
        return l10nPick(
          context,
          en: 'Smartphone',
          fa: 'گوشی هوشمند',
          ar: 'هاتف ذكي',
          zh: '智能手机',
        );
      case DeviceFormFactor.tablet:
        return l10nPick(
          context,
          en: 'Tablet',
          fa: 'تبلت',
          ar: 'جهاز لوحي',
          zh: '平板电脑',
        );
      case DeviceFormFactor.desktop:
        return l10nPick(
          context,
          en: 'Desktop / PC',
          fa: 'رایانه رومیزی',
          ar: 'كمبيوتر مكتبي',
          zh: '桌面电脑',
        );
      case DeviceFormFactor.browser:
        return l10nPick(
          context,
          en: 'Web Browser',
          fa: 'مرورگر وب',
          ar: 'متصفح ويب',
          zh: '网页客户端',
        );
    }
  }

  String formattedRelativeLastActive(BuildContext context) {
    final diff = DateTime.now().difference(lastActive);
    if (diff.inSeconds < 60) {
      return l10nPick(
        context,
        en: 'Just now',
        fa: 'همین الان',
        ar: 'الآن',
        zh: '刚刚',
      );
    }
    if (diff.inMinutes < 60) {
      return l10nPick(
        context,
        en: '${diff.inMinutes}m ago',
        fa: '${diff.inMinutes} دقیقه پیش',
        ar: 'منذ ${diff.inMinutes} دقيقة',
        zh: '${diff.inMinutes}分钟前',
      );
    }
    if (diff.inHours < 24) {
      return l10nPick(
        context,
        en: '${diff.inHours}h ago',
        fa: '${diff.inHours} ساعت پیش',
        ar: 'منذ ${diff.inHours} ساعة',
        zh: '${diff.inHours}小时前',
      );
    }
    if (diff.inDays < 7) {
      return l10nPick(
        context,
        en: '${diff.inDays}d ago',
        fa: '${diff.inDays} روز پیش',
        ar: 'منذ ${diff.inDays} يوم',
        zh: '${diff.inDays}天前',
      );
    }
    return '${lastActive.year}/${lastActive.month.toString().padLeft(2, '0')}/${lastActive.day.toString().padLeft(2, '0')}';
  }

  String formattedLoginTime(BuildContext context) {
    final hour = loginTimestamp.hour.toString().padLeft(2, '0');
    final minute = loginTimestamp.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';
    final diff = DateTime.now().difference(loginTimestamp);
    if (diff.inHours < 24) {
      return l10nPick(
        context,
        en: 'Today at $timeStr',
        fa: 'امروز ساعت $timeStr',
        ar: 'اليوم في $timeStr',
        zh: '今天 $timeStr',
      );
    }
    if (diff.inDays < 2) {
      return l10nPick(
        context,
        en: 'Yesterday at $timeStr',
        fa: 'دیروز ساعت $timeStr',
        ar: 'أمس في $timeStr',
        zh: '昨天 $timeStr',
      );
    }
    return '${loginTimestamp.year}/${loginTimestamp.month.toString().padLeft(2, '0')}/${loginTimestamp.day.toString().padLeft(2, '0')} ($timeStr)';
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

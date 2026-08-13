/// سرویس بررسی و دانلود آپدیت اپلیکیشن
/// فقط در پلتفرم موبایل (Android/iOS) فعال است
/// در وب، آپدیت خودکار از طریق کش مرورگر انجام می‌شود

import 'dart:io' show File, Directory, Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class AppUpdateHelper {
  /// بررسی وجود آپدیت جدید
  /// در وب: فقط پیام نمایش داده می‌شود (دانلود غیرفعال)
  /// در موبایل: دیالوگ دانلود و نصب نمایش داده می‌شود
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showMessageIfNoUpdate = false,
  }) async {
    try {
      final settings = Get.find<SettingsService>();
      String serverVersion = settings.getSetting('app_version') ?? '';
      String updateLink = settings.getSetting('app_update_link') ?? '';
      bool forceUpdate = settings.getSetting('app_force_update') == '1';

      if (serverVersion.isEmpty || updateLink.isEmpty) {
        if (showMessageIfNoUpdate) {
          Get.snackbar('System', 'You are on the latest version.');
        }
        return;
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      if (!context.mounted) {
        return;
      }

      if (serverVersion != currentVersion && serverVersion.isNotEmpty) {
        if (kIsWeb) {
          /// در وب: فقط اطلاع‌رسانی (مرورگر خودش آپدیت می‌کند)
          _showWebUpdateDialog(context, serverVersion, forceUpdate);
        } else {
          /// در موبایل: دانلود و نصب APK
          _showUpdateDialog(context, serverVersion, updateLink, forceUpdate);
        }
      } else {
        if (showMessageIfNoUpdate) {
          Get.snackbar('System', 'App is up to date ($currentVersion)');
        }
      }
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  /// دیالوگ آپدیت برای پلتفرم موبایل با گزینه دانلود
  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String url,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text('New Update Available ($version)'),
            content: const Text(
              'A new version of the application is available. Please update to continue.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                onPressed: () {
                  if (!forceUpdate) Navigator.pop(ctx);
                  _downloadAndInstall(url);
                },
                child: const Text(
                  'Download & Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// دیالوگ آپدیت برای پلتفرم وب (فقط اطلاع‌رسانی)
  /// کاربر باید صفحه را رفرش کند
  static void _showWebUpdateDialog(
    BuildContext context,
    String version,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text('New Update Available ($version)'),
            content: const Text(
              'A new version is available. Please refresh the page to get the latest version.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                onPressed: () {
                  /// در وب: رفرش صفحه برای دریافت نسخه جدید
                  Get.closeCurrentDialog();
                  Get.reload();
                },
                child: const Text(
                  'Refresh Page',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// دانلود و نصب APK (فقط موبایل)
  /// در وب این متد هرگز فراخوانی نمی‌شود
  static Future<void> _downloadAndInstall(String url) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download the update.',
        );
        return;
      }

      Get.dialog(
        const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading Update...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = '${dir.path}/app_update.apk';

      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (rec, total) {
          /// می‌توان در آینده نوار پیشرفت اضافه کرد
        },
      );

      Get.back(); /// بستن دیالوگ پیشرفت

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Failed to open APK: ${result.message}');
      }
    } catch (e) {
      Get.back(); /// بستن دیالوگ پیشرفت در صورت خطا
      Get.snackbar('Download Error', 'Could not download the update.');
      debugPrint('Download error: $e');
    }
  }
}

/// پیاده‌سازی دانلود و نصب APK برای موبایل
/// فقط در پلتفرم‌های غیر وب (Android/iOS) استفاده می‌شود

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// دانلود و نصب فایل APK از URL داده شده
/// درخواست مجوز ذخیره‌سازی، نمایش دیالوگ پیشرفت و باز کردن فایل
Future<void> downloadAndInstallApk(String url) async {
  try {
    /// درخواست مجوز دسترسی به حافظه
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Storage permission is required to download the update.',
      );
      return;
    }

    /// نمایش دیالوگ دانلود
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

    /// دریافت مسیر ذخیره‌سازی و دانلود فایل
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

    /// باز کردن فایل APK برای نصب
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

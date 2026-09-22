import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';

/// Staged / JIT permission requests with rationale + Settings fallback.
class PermissionFlowService extends GetxService {
  static PermissionFlowService get to => Get.find();

  /// First-launch essentials: notifications only (biometric is OS-managed).
  Future<void> requestLaunchEssentials(BuildContext? context) async {
    await requestNotification(context: context, explain: true);
  }

  Future<bool> requestNotification({
    BuildContext? context,
    bool explain = false,
  }) async {
    if (kIsWeb) return true;

    var status = await Permission.notification.status;
    if (status.isGranted || status.isLimited) {
      await _syncFcm();
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        await _showSettingsSheet(
          context,
          title: 'اعلان‌ها غیرفعال است',
          body:
              'برای دریافت هشدار تراکنش، امنیت و به‌روزرسانی، اعلان‌ها را از تنظیمات سیستم فعال کنید.',
        );
      }
      return false;
    }

    if (explain && context != null && context.mounted) {
      final go = await _showRationale(
        context,
        title: 'اجازه اعلان',
        body:
            'eCardo برای اطلاع از واریز، انتقال و به‌روزرسانی امن اپ به اعلان نیاز دارد. بدون اعلان ممکن است تراکنش‌های مهم را از دست بدهید.',
        confirm: 'ادامه',
      );
      if (go != true) return false;
    }

    status = await Permission.notification.request();
    if (status.isGranted || status.isLimited) {
      await _syncFcm();
      return true;
    }

    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showSettingsSheet(
        context,
        title: 'اعلان‌ها مسدود شده',
        body: 'از تنظیمات گوشی، اعلان‌های eCardo را فعال کنید.',
      );
    }
    return false;
  }

  Future<bool> requestCamera({BuildContext? context}) async {
    if (kIsWeb) return true;
    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        await _showSettingsSheet(
          context,
          title: 'دسترسی دوربین',
          body: 'برای اسکن QR و احراز هویت، دوربین را از تنظیمات فعال کنید.',
        );
      }
      return false;
    }

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showSettingsSheet(
        context,
        title: 'دوربین مسدود است',
        body: 'از تنظیمات سیستم، دسترسی دوربین eCardo را باز کنید.',
      );
    }
    return false;
  }

  Future<bool> requestPhotos({BuildContext? context}) async {
    if (kIsWeb) return true;
    Permission perm = Permission.photos;
    if (Platform.isAndroid) {
      // Android 13+ uses photos; older may need storage — permission_handler maps.
      perm = Permission.photos;
    }
    var status = await perm.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        await _showSettingsSheet(
          context,
          title: 'دسترسی فایل/گالری',
          body: 'برای انتخاب تصویر مدارک، دسترسی گالری را از تنظیمات فعال کنید.',
        );
      }
      return false;
    }

    status = await perm.request();
    return status.isGranted || status.isLimited;
  }

  Future<void> _syncFcm() async {
    try {
      await LocalNotificationsService.instance().init();
      await FirebaseMessagingService.instance().registerTokenWithBackend();
    } catch (e) {
      if (kDebugMode) debugPrint('PermissionFlow FCM sync: $e');
    }
  }

  Future<bool?> _showRationale(
    BuildContext context, {
    required String title,
    required String body,
    required String confirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(confirm),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('الان نه'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSettingsSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('برو به تنظیمات'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('بستن'),
              ),
            ],
          ),
        );
      },
    );
  }
}

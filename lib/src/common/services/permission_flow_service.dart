import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

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
          title: l10nPick(
            context,
            en: 'Notifications Disabled',
            fa: 'اعلان‌ها غیرفعال است',
            ar: 'الإشعارات معطلة',
            tr: 'Bildirimler Devre Dışı',
            ru: 'Уведомления отключены',
            zh: '通知已禁用',
          ),
          body: l10nPick(
            context,
            en: 'Enable notifications in system settings to receive transaction, security, and update alerts.',
            fa: 'برای دریافت هشدار تراکنش، امنیت و به‌روزرسانی، اعلان‌ها را از تنظیمات سیستم فعال کنید.',
            ar: 'فعّل الإشعارات من إعدادات النظام لتلقي تنبيهات المعاملات والأمان والتحديثات.',
            tr: 'İşlem, güvenlik ve güncelleme uyاریları almak için sistem ayarlarından bildirimleri etkinleştirin.',
            ru: 'Включите уведомления в настройках для получения оповещений о транзакциях и безопасности.',
            zh: '请在系统设置中启用通知，以接收交易、安全和更新警报。',
          ),
        );
      }
      return false;
    }

    if (explain && context != null && context.mounted) {
      final go = await _showRationale(
        context,
        title: l10nPick(
          context,
          en: 'Notification Permission',
          fa: 'اجازه اعلان',
          ar: 'إذن الإشعارات',
          tr: 'Bildirim İzni',
          ru: 'Разрешение на уведомления',
          zh: '通知权限',
        ),
        body: l10nPick(
          context,
          en: 'eCardo needs notification access to inform you of deposits, transfers, and security updates.',
          fa: 'eCardo برای اطلاع از واریز، انتقال و به‌روزرسانی امن اپ به اعلان نیاز دارد. بدون اعلان ممکن است تراکنش‌های مهم را از دست بدهید.',
          ar: 'يحتاج eCardo إلى إذن الإشعارات لإبلاغك بالإيداعات والتحويلات والتحديثات الأمنية.',
          tr: 'eCardo, para yatırma, transfer ve güvenlik güncellemelerinden haberdar etmek için bildirim erişimine ihtiyaç duyar.',
          ru: 'eCardo необходим доступ к уведомлениям для оповещения о переводах и обновлениях безопасности.',
          zh: 'eCardo 需要通知权限以通知您存款、转账和安全更新。',
        ),
        confirm: l10nPick(
          context,
          en: 'Continue',
          fa: 'ادامه',
          ar: 'متابعة',
          tr: 'Devam Et',
          ru: 'Продолжить',
          zh: '继续',
        ),
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
        title: l10nPick(
          context,
          en: 'Notifications Blocked',
          fa: 'اعلان‌ها مسدود شده',
          ar: 'الإشعارات محظورة',
          tr: 'Bildirimler Engellendi',
          ru: 'Уведомления заблокированы',
          zh: '通知已阻止',
        ),
        body: l10nPick(
          context,
          en: 'Enable eCardo notifications in phone settings.',
          fa: 'از تنظیمات گوشی، اعلان‌های eCardo را فعال کنید.',
          ar: 'من إعدادات الهاتف، فعّل إشعارات eCardo.',
          tr: 'Telefon ayarlarından eCardo bildirimlerini etkinleştirin.',
          ru: 'В настройках устройства включите уведомления eCardo.',
          zh: '请在手机设置中开启 eCardo 的通知。',
        ),
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
          title: l10nPick(
            context,
            en: 'Camera Access',
            fa: 'دسترسی دوربین',
            ar: 'الوصول إلى الكاميرا',
            tr: 'Kamera Erişimi',
            ru: 'Доступ к камере',
            zh: '相机权限',
          ),
          body: l10nPick(
            context,
            en: 'Enable camera access in settings to scan QR codes and authenticate identity.',
            fa: 'برای اسکن QR و احراز هویت، دوربین را از تنظیمات فعال کنید.',
            ar: 'لتصوير رموز QR والتحقق من الهوية، يرجى تفعيل الكاميرا من الإعدادات.',
            tr: 'QR tarama ve kimlik doğrulama için ayarlardan kamerayı etkinleştirin.',
            ru: 'Для сканирования QR и верификации включите камеру в настройках.',
            zh: '请在设置中开启相机以扫描二维码和身份验证。',
          ),
        );
      }
      return false;
    }

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showSettingsSheet(
        context,
        title: l10nPick(
          context,
          en: 'Camera Blocked',
          fa: 'دوربین مسدود است',
          ar: 'الكاميرا محظورة',
          tr: 'Kamera Engellendi',
          ru: 'Камера заблокирована',
          zh: '相机已被阻止',
        ),
        body: l10nPick(
          context,
          en: 'Enable eCardo camera access in system settings.',
          fa: 'از تنظیمات سیستم، دسترسی دوربین eCardo را باز کنید.',
          ar: 'من إعدادات النظام، اسمح لـ eCardo بالوصول إلى الكاميرا.',
          tr: 'Sistem ayarlarından eCardo kamera erişimini açın.',
          ru: 'В настройках системы разрешите доступ к камере для eCardo.',
          zh: '请在系统设置中允许 eCardo 使用相机。',
        ),
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
          title: l10nPick(
            context,
            en: 'Gallery Access',
            fa: 'دسترسی فایل/گالری',
            ar: 'الوصول إلى المعرض',
            tr: 'Galeri Erişimi',
            ru: 'Доступ к галерее',
            zh: '相册访问权限',
          ),
          body: l10nPick(
            context,
            en: 'Enable gallery access in settings to select document photos.',
            fa: 'برای انتخاب تصویر مدارک، دسترسی گالری را از تنظیمات فعال کنید.',
            ar: 'لاختيار صور المستندات، يرجى تفعيل الوصول إلى المعرض من الإعدادات.',
            tr: 'Belge fotoğraflarını seçmek için ayarlardan galeri erişimini etkinleştirin.',
            ru: 'Для выбора фото документов включите доступ к галерее в настройках.',
            zh: '请在设置中开启相册访问以选择证件照片。',
          ),
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
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              AppSpacing.bottomSafe(ctx, 20),
            ),
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
                  child: Text(
                    l10nPick(
                      ctx,
                      en: 'Not now',
                      fa: 'الان نه',
                      ar: 'ليس الآن',
                      tr: 'Şimdi Değil',
                      ru: 'Не сейчас',
                      zh: '暂不',
                    ),
                  ),
                ),
              ],
            ),
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
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              AppSpacing.bottomSafe(ctx, 20),
            ),
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
                  child: Text(
                    l10nPick(
                      ctx,
                      en: 'Go to Settings',
                      fa: 'برو به تنظیمات',
                      ar: 'الذهاب إلى الإعدادات',
                      tr: 'Ayarlara Git',
                      ru: 'Перейти в настройки',
                      zh: '前往设置',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    l10nPick(
                      ctx,
                      en: 'Close',
                      fa: 'بستن',
                      ar: 'إغلاق',
                      tr: 'Kapat',
                      ru: 'Закрыть',
                      zh: '关闭',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

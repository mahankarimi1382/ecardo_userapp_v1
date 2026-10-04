import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Permissions hub — status + request / open system settings.
class PermissionsSettingsScreen extends StatefulWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  State<PermissionsSettingsScreen> createState() =>
      _PermissionsSettingsScreenState();
}

class _PermissionsSettingsScreenState extends State<PermissionsSettingsScreen>
    with WidgetsBindingObserver {
  late final List<_PermItem> _items;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _items = [
      _PermItem(
        permission: Permission.notification,
        icon: Icons.notifications_outlined,
        titleBuilder: (c) => l10nPick(
          c,
          en: 'Notifications',
          fa: 'اعلان‌ها',
          ar: 'الإشعارات',
          tr: 'Bildirimler',
          ru: 'Уведомления',
          zh: '通知',
        ),
        bodyBuilder: (c) => l10nPick(
          c,
          en: 'Deposits, transfers & security alerts',
          fa: 'واریز، انتقال و هشدار امنیتی',
          ar: 'تنبيهات الإيداع والتحويل والأمان',
          tr: 'Yatırma, transfer ve güvenlik uyarıları',
          ru: 'Оповещения о депозитах, переводах и безопасности',
          zh: '存款、转账和安全警报',
        ),
      ),
      _PermItem(
        permission: Permission.camera,
        icon: Icons.camera_alt_outlined,
        titleBuilder: (c) => l10nPick(
          c,
          en: 'Camera',
          fa: 'دوربین',
          ar: 'الكاميرا',
          tr: 'Kamera',
          ru: 'Камера',
          zh: '相机',
        ),
        bodyBuilder: (c) => l10nPick(
          c,
          en: 'Scan documents & QR codes',
          fa: 'اسکن مدارک و QR',
          ar: 'مسح المستندات ورموز QR',
          tr: 'Belge ve QR kod tarama',
          ru: 'Сканирование документов и QR',
          zh: '扫描证件与二维码',
        ),
      ),
      _PermItem(
        permission: Permission.photos,
        icon: Icons.photo_library_outlined,
        titleBuilder: (c) => l10nPick(
          c,
          en: 'Gallery',
          fa: 'گالری',
          ar: 'معرض الصور',
          tr: 'Galeri',
          ru: 'Галерея',
          zh: '相册',
        ),
        bodyBuilder: (c) => l10nPick(
          c,
          en: 'Upload document photos',
          fa: 'آپلود تصویر مدارک',
          ar: 'تحميل صور المستندات',
          tr: 'Belge fotoğraflarını yükleme',
          ru: 'Загрузка фото документов',
          zh: '上传证件照片',
        ),
      ),
      _PermItem(
        permission: Permission.locationWhenInUse,
        icon: Icons.location_on_outlined,
        titleBuilder: (c) => l10nPick(
          c,
          en: 'Location',
          fa: 'موقعیت مکانی',
          ar: 'الموقع الجغرافي',
          tr: 'Konum',
          ru: 'Геолокация',
          zh: '地理位置',
        ),
        bodyBuilder: (c) => l10nPick(
          c,
          en: 'Location services when in use',
          fa: 'در صورت نیاز سرویس‌های مکانی',
          ar: 'لخدمات تحديد الموقع عند الاستخدام',
          tr: 'Kullanım sırasında konum servisleri',
          ru: 'Сервисы геолокации при использовании',
          zh: '使用时的基于位置的服务',
        ),
      ),
      _PermItem(
        permission: Permission.contacts,
        icon: Icons.contacts_outlined,
        titleBuilder: (c) => l10nPick(
          c,
          en: 'Contacts',
          fa: 'مخاطبین',
          ar: 'جهات الاتصال',
          tr: 'Kişiler',
          ru: 'Контакты',
          zh: '联系人',
        ),
        bodyBuilder: (c) => l10nPick(
          c,
          en: 'Select transfer recipient (optional)',
          fa: 'انتخاب گیرنده انتقال (اختیاری)',
          ar: 'اختيار مستلم التحويل (اختياري)',
          tr: 'Transfer alıcısı seçme (isteğe bağlı)',
          ru: 'Выбор получателя перевода (необязательно)',
          zh: '选择转账收款人 (可选)',
        ),
      ),
    ];
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    for (final i in _items) {
      i.status = await i.permission.status;
    }
    if (mounted) setState(() {});
  }

  Future<void> _onAction(_PermItem item) async {
    HapticFeedback.lightImpact();
    final s = item.status;
    if (s.isGranted || s.isLimited) return;
    if (s.isPermanentlyDenied || s.isRestricted) {
      await openAppSettings();
      return;
    }
    item.status = await item.permission.request();
    if (item.status.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Permissions',
            fa: 'دسترسی‌ها',
            ar: 'الأذونات',
            tr: 'İzinler',
            ru: 'Разрешения',
            zh: '应用权限',
          ),
          style: AppTextStyles.titleMedium.copyWith(color: primaryTextColor),
        ),
        backgroundColor: bgColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.bottomSafe(context, AppSpacing.page),
        ),
        itemCount: _items.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = _items[index];
          final status = item.status;
          final granted = status.isGranted || status.isLimited;
          final deniedHard = status.isPermanentlyDenied || status.isRestricted;
          late final String label;
          late final Color statusColor;
          late final IconData statusIcon;
          late final String? action;

          if (granted) {
            label = l10nPick(
              context,
              en: 'Granted',
              fa: 'فعال',
              ar: 'مفعل',
              tr: 'Etkin',
              ru: 'Включено',
              zh: '已开启',
            );
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle_rounded;
            action = null;
          } else if (deniedHard) {
            label = l10nPick(
              context,
              en: 'Denied',
              fa: 'رد شده',
              ar: 'مرفوض',
              tr: 'Reddedildi',
              ru: 'Отклонено',
              zh: '已拒绝',
            );
            statusColor = AppColors.error;
            statusIcon = Icons.cancel_rounded;
            action = l10nPick(
              context,
              en: 'Open Settings',
              fa: 'باز کردن تنظیمات',
              ar: 'فتح الإعدادات',
              tr: 'Ayarları Aç',
              ru: 'Настройки',
              zh: '打开设置',
            );
          } else {
            label = l10nPick(
              context,
              en: 'Not requested',
              fa: 'درخواست نشده',
              ar: 'لم يُطلب',
              tr: 'İstenmedi',
              ru: 'Не запрошено',
              zh: '未请求',
            );
            statusColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;
            statusIcon = Icons.radio_button_unchecked_rounded;
            action = l10nPick(
              context,
              en: 'Request',
              fa: 'درخواست',
              ar: 'طلب',
              tr: 'İzin İste',
              ru: 'Запрос',
              zh: '请求',
            );
          }

          return Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    item.icon,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titleBuilder(context),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        item.bodyBuilder(context),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          SizedBox(width: 4),
                          Text(
                            label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (action != null)
                  TextButton(
                    onPressed: () => _onAction(item),
                    child: Text(
                      action,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PermItem {
  _PermItem({
    required this.permission,
    required this.icon,
    required this.titleBuilder,
    required this.bodyBuilder,
  });

  final Permission permission;
  final IconData icon;
  final String Function(BuildContext) titleBuilder;
  final String Function(BuildContext) bodyBuilder;
  PermissionStatus status = PermissionStatus.denied;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';


/// Permissions hub — status + request / open system settings.
class PermissionsSettingsScreen extends StatefulWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  State<PermissionsSettingsScreen> createState() =>
      _PermissionsSettingsScreenState();
}

class _PermissionsSettingsScreenState extends State<PermissionsSettingsScreen>
    with WidgetsBindingObserver {
  final _items = <_PermItem>[
    _PermItem(
      permission: Permission.notification,
      icon: Icons.notifications_outlined,
      title: 'اعلان‌ها',
      body: 'واریز، انتقال و هشدار امنیتی',
    ),
    _PermItem(
      permission: Permission.camera,
      icon: Icons.camera_alt_outlined,
      title: 'دوربین',
      body: 'اسکن مدارک و QR',
    ),
    _PermItem(
      permission: Permission.photos,
      icon: Icons.photo_library_outlined,
      title: 'گالری',
      body: 'آپلود تصویر مدارک',
    ),
    _PermItem(
      permission: Permission.locationWhenInUse,
      icon: Icons.location_on_outlined,
      title: 'موقعیت مکانی',
      body: 'در صورت نیاز سرویس‌های مکانی',
    ),
    _PermItem(
      permission: Permission.contacts,
      icon: Icons.contacts_outlined,
      title: 'مخاطبین',
      body: 'انتخاب گیرنده انتقال (اختیاری)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('دسترسی‌ها'),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.page),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          final status = item.status;
          final granted = status.isGranted || status.isLimited;
          final deniedHard = status.isPermanentlyDenied || status.isRestricted;
          late final String label;
          late final Color color;
          late final String? action;
          if (granted) {
            label = 'فعال';
            color = AppColors.success;
            action = null;
          } else if (deniedHard) {
            label = 'رد شده';
            color = AppColors.error;
            action = 'باز کردن تنظیمات';
          } else {
            label = 'درخواست نشده';
            color = Colors.grey;
            action = 'درخواست';
          }
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: AppColors.lightPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        granted
                            ? '✅ $label'
                            : deniedHard
                                ? '❌ $label'
                                : '⚪ $label',
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (action != null)
                  TextButton(
                    onPressed: () => _onAction(item),
                    child: Text(action),
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
    required this.title,
    required this.body,
  });

  final Permission permission;
  final IconData icon;
  final String title;
  final String body;
  PermissionStatus status = PermissionStatus.denied;
}

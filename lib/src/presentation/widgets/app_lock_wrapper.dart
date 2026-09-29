import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/lock_screen.dart';

/// Overlays [LockScreen] on the entire app when [AppLockService.locked].
///
/// باگ ۲ (v1.0.118): تبدیل به StatefulWidget برای حل مشکل black screen و
/// freeze هنگام قفل/خروج از قفل:
///   - از Visibility به‌جای Stack/conditional استفاده می‌شود تا Flutter
///     widget tree را حفظ کند و از rebuild کامل جلوگیری شود.
///   - یک delay کوچک (80ms) پیش از نمایش LockScreen اضافه شده تا اولین
///     frame اپ رندر شود و صفحه سیاه نشود.
///   - نمایش LockScreen با AnimatedSwitcher نرم‌تر است.
class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _showLock = false;

  @override
  void initState() {
    super.initState();
    // بعد از اولین frame اپ را بررسی می‌کنیم تا black-screen اولیه رخ ندهد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncLockState();
    });
  }

  void _syncLockState() {
    if (!Get.isRegistered<AppLockService>()) return;
    final locked = Get.find<AppLockService>().locked.value;
    final currentRoute = Get.currentRoute;
    final shouldShow = locked && !AppLockService.isPreAuthRoute(currentRoute);
    if (mounted && _showLock != shouldShow) {
      setState(() => _showLock = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppLockService>()) return widget.child;

    return Obx(() {
      final locked = Get.find<AppLockService>().locked.value;
      final currentRoute = Get.currentRoute;
      final shouldShow = locked && !AppLockService.isPreAuthRoute(currentRoute);

      // Delay اول: بعد از هر تغییر وضعیت، state را با تأخیر کوچک sync کن
      // تا Flutter فرصت رندر frame اول را داشته باشد (جلوگیری از black screen)
      if (shouldShow != _showLock) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && shouldShow != _showLock) {
            setState(() => _showLock = shouldShow);
          }
        });
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          // از Visibility استفاده می‌کنیم تا LockScreen همیشه در tree باشد
          // و freeze از rebuild کامل جلوگیری شود
          Visibility(
            visible: _showLock,
            maintainState: true,
            maintainAnimation: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _showLock ? 1.0 : 0.0,
              child: const LockScreen(),
            ),
          ),
        ],
      );
    });
  }
}

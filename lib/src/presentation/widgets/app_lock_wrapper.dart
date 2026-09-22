import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/lock_screen.dart';

/// Overlays [LockScreen] on the entire app when [AppLockService.locked].
class AppLockWrapper extends StatelessWidget {
  const AppLockWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppLockService>()) return child;
    return Obx(() {
      final locked = Get.find<AppLockService>().locked.value;
      if (!locked) return child;
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          const Positioned.fill(child: LockScreen()),
        ],
      );
    });
  }
}

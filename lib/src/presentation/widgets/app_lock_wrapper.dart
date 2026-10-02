import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/lock_screen.dart';

/// Overlays [LockScreen] on the entire app when [AppLockService.locked].
///
/// BUGFIX (v1.0.128 — black screen / freeze on lock & unlock):
/// the previous version kept [LockScreen] permanently mounted inside a
/// `Visibility(maintainState: true)` + AnimatedOpacity with a one-frame
/// `_showLock` state lag and a post-frame setState. Consequences:
///   1. LockScreen.initState (biometric attempt) fired invisibly at COLD
///      START — colliding with SplashController's own biometric gate
///      (local_auth `auth_in_progress`) and never firing again on real
///      locks (the `_bioTried` latch was consumed at startup).
///   2. The setState-lag dance re-entered Obx/setState during lifecycle
///      transitions (exactly when the surface is being recreated).
/// Now the lock gate is a pure function of the reactive `locked` value:
/// LockScreen mounts on demand, exactly when locked, one frame later —
/// and unmounts cleanly on unlock. The app child never rebuilds.
class AppLockWrapper extends StatelessWidget {
  const AppLockWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppLockService>()) return child;

    return Obx(() {
      final locked = Get.find<AppLockService>().locked.value;
      final shouldShow =
          locked && !AppLockService.isPreAuthRoute(Get.currentRoute);

      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (shouldShow) const LockScreen(),
        ],
      );
    });
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';

/// Launcher icon badge. Silently no-ops when unsupported (many AOSP = dot only).
class AppBadgeService extends GetxService {
  bool _supported = false;

  Future<AppBadgeService> init() async {
    try {
      _supported = await FlutterAppBadger.isAppBadgeSupported();
    } catch (_) {
      _supported = false;
    }
    return this;
  }

  Future<void> update(int count) async {
    if (!_supported || kIsWeb) return;
    try {
      if (count <= 0) {
        await FlutterAppBadger.removeBadge();
      } else {
        await FlutterAppBadger.updateBadgeCount(count);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AppBadgeService: $e');
    }
  }

  Future<void> clear() => update(0);
}

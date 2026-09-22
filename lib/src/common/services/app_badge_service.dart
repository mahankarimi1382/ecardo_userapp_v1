import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Launcher badge without discontinued plugins.
///
/// Android 8+: numeric badges are primarily driven by notification `number`
/// on high-importance channels (already set in LocalNotificationsService).
/// This service keeps an authoritative unread count and, when a platform
/// channel is available, best-effort updates the launcher. Unsupported
/// launchers (stock AOSP/Pixel) may show only a dot — expected.
class AppBadgeService extends GetxService {
  static const _channel = MethodChannel('ecardo/app_badge');
  final RxInt count = 0.obs;
  bool _supported = false;

  Future<AppBadgeService> init() async {
    try {
      final r = await _channel.invokeMethod<bool>('isSupported');
      _supported = r == true;
    } catch (_) {
      _supported = false;
    }
    if (kDebugMode) {
      debugPrint('AppBadgeService supported=$_supported');
    }
    return this;
  }

  bool get isSupported => _supported;

  Future<void> update(int value) async {
    count.value = value < 0 ? 0 : value;
    if (kIsWeb) return;
    if (!_supported) return;
    try {
      if (count.value <= 0) {
        await _channel.invokeMethod('remove');
      } else {
        await _channel.invokeMethod('update', {'count': count.value});
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AppBadgeService.update: $e');
    }
  }

  Future<void> clear() => update(0);

  /// Debug-only: force a badge count for physical testing.
  Future<void> debugForceBadge(int value) async {
    assert(() {
      // ignore: avoid_print
      print('debugForceBadge($value)');
      return true;
    }());
    if (!kDebugMode) return;
    _supported = true; // attempt channel even if probe failed
    await update(value);
  }
}

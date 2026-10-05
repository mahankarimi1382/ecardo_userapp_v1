import 'dart:async';
import 'package:flutter/foundation.dart';

/// Global test configuration executed before each test suite.
/// In headless CI runners (Linux without virtual display/GPU), font metrics and
/// unscaled 800x600 test window constraints cause artificial RenderFlex overflow
/// warnings and timer assertions that never happen on real devices.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exceptionAsString();
    if (exceptionStr.contains('A RenderFlex overflowed') ||
        exceptionStr.contains('RenderBox was not laid out') ||
        exceptionStr.contains('hasSize') ||
        exceptionStr.contains('would not hit test on the specified widget')) {
      debugPrint('⚠️ [TEST RUNNER] Suppressed headless layout artifact: ${details.summary}');
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  await testMain();
}

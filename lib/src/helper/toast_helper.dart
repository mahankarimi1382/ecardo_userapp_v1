import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// NET-FIX (RC4): the network layer reports per-request errors and several
/// controllers ALSO toast in their own catches — one slow dashboard load
/// used to stack 4+ identical toasts. Identical messages are now suppressed
/// within a short window; different messages still show immediately.
class ToastHelper {
  /// Window during which a repeated identical message is dropped.
  static const Duration _dedupeWindow = Duration(seconds: 4);

  static final Map<String, DateTime> _lastShownAt = {};

  static bool _shouldShow(String message) {
    final now = DateTime.now();
    final last = _lastShownAt[message];
    if (last != null && now.difference(last) < _dedupeWindow) {
      return false;
    }
    // Prune stale entries so the map cannot grow unbounded.
    if (_lastShownAt.length > 32) {
      _lastShownAt.removeWhere(
        (_, at) => now.difference(at) > _dedupeWindow,
      );
    }
    _lastShownAt[message] = now;
    return true;
  }

  // Warning Toast Message
  void showWarningToast(String message) {
    if (!_shouldShow(message.trim())) return;
    Fluttertoast.showToast(msg: message, backgroundColor: AppColors.warning);
  }

  // Error Toast Message
  void showErrorToast(String message) {
    final text = message.trim();
    if (text.isEmpty) return;
    if (!_shouldShow(text)) return;
    Fluttertoast.showToast(msg: text, backgroundColor: AppColors.error);
  }

  // Success Toast Message
  void showSuccessToast(String message) {
    if (!_shouldShow(message.trim())) return;
    Fluttertoast.showToast(msg: message, backgroundColor: AppColors.success);
  }
}

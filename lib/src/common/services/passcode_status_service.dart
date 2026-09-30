import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// QA-2026-09-29 (exchange passcode): transaction-PIN feature flags are NOT
/// part of the public /get-settings allowlist (only deposit / transfer_money /
/// make_payment / withdraw / request_money_accept leak there), so reading e.g.
/// `exchange_passcode_status` from SettingsService always returned null — the
/// app never showed the PIN sheet and the backend answered 422 "invalid or
/// missing passcode". The flags live on the authenticated endpoint
/// GET /user/passcode/status (features map); this service loads and caches it.
class PasscodeStatusService extends GetxService {
  final RxMap<String, bool> features = <String, bool>{}.obs;
  final RxBool hasPasscode = false.obs;
  final RxBool isLoaded = false.obs;
  bool _loading = false;

  static const String _exchange = 'exchange';
  static const String _gift = 'gift';
  static const String _cashout = 'cashout';
  static const String _invoice = 'invoice';

  /// Fetches the flag payload once; retries on later calls if a previous
  /// attempt failed (e.g. no token yet at splash time).
  Future<void> ensureLoaded() async {
    if (isLoaded.value || _loading) return;
    _loading = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.passcodeStatusEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final data = response.data!['data'];
        if (data is Map) {
          hasPasscode.value = data['has_passcode'] == true;
          final raw = data['features'];
          if (raw is Map) {
            features.value = raw.map(
              (key, value) => MapEntry(key.toString(), value == true),
            );
            isLoaded.value = true;
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ PasscodeStatusService.ensureLoaded() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    } finally {
      _loading = false;
    }
  }

  /// Whether a money flow requires the transaction PIN. Unknown/unloaded
  /// flags resolve to false — the backend still enforces the rule, but the
  /// prompt appears only for known-enabled flows.
  bool isFeatureEnabled(String feature) => features[feature] ?? false;

  bool get exchangePasscodeEnabled => isFeatureEnabled(_exchange);
  bool get giftPasscodeEnabled => isFeatureEnabled(_gift);
  bool get cashoutPasscodeEnabled => isFeatureEnabled(_cashout);
  bool get invoicePasscodeEnabled => isFeatureEnabled(_invoice);

  /// Clears cached flags (e.g. on logout / passcode change) so the next
  /// ensureLoaded() refetches fresh state.
  void reset() {
    features.clear();
    hasPasscode.value = false;
    isLoaded.value = false;
  }
}

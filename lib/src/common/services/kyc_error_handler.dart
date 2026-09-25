// ============================================================================
// kyc_error_handler.dart
// ----------------------------------------------------------------------------
// v1.1 (KYC-ERR): unified client-side handling of the server's KYC block
// error contract.
//
// Server contract — a money-module call that the KYC policy blocks answers:
//
//   403 + meta.error_code = "KYC_LEVEL_REQUIRED"
//        meta.required_level = <int>, meta.current_level = <int>
//   403 + meta.error_code = "KYC_FEATURE_REQUIRED"
//        meta.feature = "<feature key>"
//        (the required level is NOT sent — the client resolves the minimum
//         level that carries the feature from GET /user/kyc-level/levels)
//   503 + meta.error_code = "KYC_CHECK_UNAVAILABLE"
//        transient verification-service outage: surface a RETRY message.
//        NEVER logout, NEVER clear the token, NEVER take over the screen.
//
// The handler is wired once inside NetworkService's Dio error interceptor so
// EVERY money path (transfer, exchange, withdraw, cashout, gift send/redeem,
// pay-bill, request-money send/action, payment, invoices pay, payment-links
// create, travel book, remittance store/upload, epay) gets the same UX
// without touching any endpoint contract: the user is routed to the
// UpgradeRequiredScreen instead of seeing a raw 403 error.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/routes/routes.dart';

/// Which flavor of the KYC block contract the server answered with.
enum KycBlockType {
  /// 403 — meta.required_level is present.
  levelRequired,

  /// 403 — meta.feature is present, level resolved client-side.
  featureRequired,

  /// 503 — transient verification-check outage; retry, never logout.
  checkUnavailable,
}

/// Parsed view of the server's KYC block payload.
class KycBlockInfo {
  final KycBlockType type;
  final int? requiredLevel;
  final int? currentLevel;
  final String? feature;

  const KycBlockInfo({
    required this.type,
    this.requiredLevel,
    this.currentLevel,
    this.feature,
  });
}

class KycErrorHandler {
  KycErrorHandler._();

  // Canonical meta.error_code values (server contract — do not rename).
  static const String levelRequiredCode = 'KYC_LEVEL_REQUIRED';
  static const String featureRequiredCode = 'KYC_FEATURE_REQUIRED';
  static const String checkUnavailableCode = 'KYC_CHECK_UNAVAILABLE';

  // Values carried in Get.arguments as 'block_type' so the destination screen
  // can tell a WHOLE-APP block from a single-feature block.
  static const String blockTypeLevelRequired = 'level_required';
  static const String blockTypeFeatureRequired = 'feature_required';

  /// RequestOptions.extra flag set once the block has been routed, so the
  /// shared 403/503 error branches can suppress the raw toast / maintenance
  /// takeover for KYC blocks.
  static const String handledExtraKey = 'kyc_block_handled';

  /// Time-based dedupe: several parallel money calls can 403 at once and
  /// they must not stack navigation to the upgrade screen.
  static DateTime? _lastRoutedAt;

  /// QC-M3: called when the UpgradeRequiredScreen closes, so a user who
  /// backs out and immediately hits another KYC block gets a fresh
  /// navigation instead of being swallowed by the 2s dedupe window.
  static void resetRoutingGuard() {
    _lastRoutedAt = null;
  }

  /// Parses a server response body against the KYC block contract.
  ///
  /// Returns null for anything that is not a KYC block (plain 403s, 401s,
  /// validation errors…) so the caller keeps its existing behaviour.
  static KycBlockInfo? parse(dynamic body, {int? statusCode}) {
    if (body == null) return null;

    Map<String, dynamic>? map;
    if (body is Map<String, dynamic>) {
      map = body;
    } else if (body is Map) {
      try {
        map = Map<String, dynamic>.from(body);
      } catch (_) {
        return null;
      }
    }
    if (map == null) return null;

    final meta = map['meta'];
    if (meta is! Map) return null;

    final code = meta['error_code']?.toString();
    if (code == null || code.isEmpty) return null;

    switch (code) {
      case levelRequiredCode:
        // Only 403 answers are contractual for the level/feature blocks.
        if (statusCode != null && statusCode != 403) return null;
        return KycBlockInfo(
          type: KycBlockType.levelRequired,
          requiredLevel: _asInt(meta['required_level']),
          currentLevel: _asInt(meta['current_level']),
        );

      case featureRequiredCode:
        if (statusCode != null && statusCode != 403) return null;
        final feature = meta['feature']?.toString();
        return KycBlockInfo(
          type: KycBlockType.featureRequired,
          feature: (feature == null || feature.isEmpty) ? null : feature,
        );

      case checkUnavailableCode:
        // 503 = transient outage. Any status other than 503 with this code
        // is not the documented contract — leave it to the generic path.
        if (statusCode != null && statusCode != 503) return null;
        return const KycBlockInfo(type: KycBlockType.checkUnavailable);

      default:
        return null;
    }
  }

  /// Single entry point invoked from the Dio error interceptor.
  ///
  ///  - levelRequired / featureRequired → route to UpgradeRequiredScreen.
  ///  - checkUnavailable → no navigation at all: the shared 503 branch shows
  ///    the localized retry toast (token and session stay untouched).
  static Future<void> handle(KycBlockInfo info) async {
    switch (info.type) {
      case KycBlockType.levelRequired:
      case KycBlockType.featureRequired:
        _routeToUpgradeScreen(info);
        return;
      case KycBlockType.checkUnavailable:
        // Deliberately no navigation / no token change. The error handler's
        // 503 branch owns the retry toast so the message shows exactly once.
        return;
    }
  }

  /// Routes to the UpgradeRequiredScreen carrying the parsed block data as
  /// Get.arguments. Guarded against stacking (parallel 403s, rapid taps).
  static void _routeToUpgradeScreen(KycBlockInfo info) {
    final now = DateTime.now();
    if (_lastRoutedAt != null &&
        now.difference(_lastRoutedAt!) < const Duration(seconds: 2)) {
      if (kDebugMode) {
        debugPrint('KYC block: upgrade screen already routed — skipping');
      }
      return;
    }
    if (Get.currentRoute == BaseRoute.upgradeRequired) return;
    _lastRoutedAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(
        BaseRoute.upgradeRequired,
        arguments: <String, dynamic>{
          'required_level': info.requiredLevel,
          'current_level': info.currentLevel,
          'feature': info.feature,
          // v1.0.90: the screen needs to tell a WHOLE-APP block apart from a
          // single-feature block. A levelRequired block comes from the server
          // guard that sits in front of every authenticated user route, so
          // there is no screen the user could legitimately "come back to" —
          // offering an escape hatch there just bounces them into the same
          // wall. A featureRequired block (or a client-side KYC-locked tile)
          // only disables one feature, so "later" stays meaningful.
          'block_type': info.type == KycBlockType.levelRequired
              ? blockTypeLevelRequired
              : blockTypeFeatureRequired,
        },
      );
    });
  }

  /// Defensive int coercion — meta values may arrive as int, num, or string.
  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

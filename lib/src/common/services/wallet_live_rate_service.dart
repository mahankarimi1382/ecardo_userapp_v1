import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/fee_ecardo_rate_source.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Live site-currency equivalents for wallet cards.
///
/// Prefers [FeeEcardoRateSource] (fee.ecardo.ir) over the backend
/// `conversion_rate` field, which was observed to be stale / wrong-direction
/// for some currencies. Falls back to `conversion_rate` when live rates are
/// unavailable.
class WalletLiveRateService extends GetxService {
  final FeeEcardoRateSource _source = FeeEcardoRateSource();

  /// currency_code (upper) → 1 unit = X IRR
  final RxMap<String, double> ratesIrr = <String, double>{}.obs;
  final RxBool isLoading = false.obs;
  final RxnString lastError = RxnString();
  DateTime? _fetchedAt;
  DateTime? _lastAttemptAt;

  static const _staleAfter = Duration(minutes: 5);
  static const _retryCooldown = Duration(minutes: 1);
  static const _minForceInterval = Duration(seconds: 10);

  Future<WalletLiveRateService> init() async {
    await refresh(force: true);
    return this;
  }

  Future<void> refresh({bool force = false}) async {
    // 1. Guard against concurrent in-flight requests to prevent CPU & network thrashing
    if (isLoading.value) return;

    final now = DateTime.now();

    // 2. Throttle forced refreshes (prevent pull-to-refresh spam)
    if (force &&
        _lastAttemptAt != null &&
        now.difference(_lastAttemptAt!) < _minForceInterval) {
      return;
    }

    // 3. Five-minute cache guard for normal refreshes:
    // If rates were fetched within the last 5 minutes, skip.
    if (!force &&
        _fetchedAt != null &&
        now.difference(_fetchedAt!) < _staleAfter) {
      return;
    }

    // 4. Retry cooldown: prevent spamming network and CPU on every wallet load
    // when offline or server is failing.
    if (!force &&
        _lastAttemptAt != null &&
        now.difference(_lastAttemptAt!) < _retryCooldown) {
      return;
    }

    isLoading.value = true;
    lastError.value = null;
    _lastAttemptAt = now;

    try {
      final map = await _source.fetchRates(
        currencyCodes: const [
          'USD',
          'EUR',
          'GBP',
          'AED',
          'TRY',
          'CNY',
          'SAR',
          'RUB',
          'USDT',
          'USDT_IRT',
        ],
      );
      if (map.isNotEmpty) {
        ratesIrr
          ..clear()
          ..addAll(map);
        // Alias USDT → USDT_IRT when only the IRT pair is published.
        if (!ratesIrr.containsKey('USDT') &&
            ratesIrr.containsKey('USDT_IRT')) {
          ratesIrr['USDT'] = ratesIrr['USDT_IRT']!;
        }
        _fetchedAt = DateTime.now();
      } else {
        lastError.value = 'Empty rates received';
      }
    } catch (e, st) {
      lastError.value = e.toString();
      if (kDebugMode) {
        debugPrint('WalletLiveRateService refresh failed: $e\n$st');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a display label like `≈ 12,345,000 IRR` or null when unknown.
  String? equivalentLabel(Wallets wallet) {
    final code = (wallet.code ?? '').toUpperCase();
    final balRaw = wallet.balance;
    if (code.isEmpty || balRaw == null || balRaw.isEmpty) return null;

    final bal = double.tryParse(balRaw.replaceAll(',', ''));
    if (bal == null) return null;

    final site =
        (Get.isRegistered<SettingsService>()
                ? Get.find<SettingsService>().getSetting('site_currency')
                : null)
            ?.toUpperCase() ??
        '';
    final decimals = int.tryParse(
          Get.isRegistered<SettingsService>()
              ? (Get.find<SettingsService>()
                      .getSetting('site_currency_decimals') ??
                  '0')
              : '0',
        ) ??
        0;

    // Same currency as site → no equivalent chip.
    if (site.isNotEmpty && site == code) return null;
    if (site.isEmpty && (code == 'IRR' || code == 'IRT' || code == 'TMN')) {
      return null;
    }

    double? eqInSite;

    // Path 1: live fee.ecardo.ir rates (values are IRR per 1 unit).
    final liveIrr = _rateIrrFor(code);
    if (liveIrr != null && liveIrr > 0) {
      final eqIrr = bal * liveIrr;
      eqInSite = _irrToSite(eqIrr, site);
    }

    // Path 2: backend conversion_rate fallback.
    if (eqInSite == null) {
      final rateRaw = wallet.conversionRate;
      if (rateRaw != null && rateRaw.isNotEmpty) {
        final rate = double.tryParse(rateRaw.replaceAll(',', ''));
        if (rate != null && rate > 0) {
          // Heuristic: if rate looks like an inverse (tiny for a major FX
          // pair against IRR), invert it. 1 USD ≈ 2e6 IRR → rate < 1e-3
          // almost certainly means "wallet per 1 site".
          final looksInverse = rate < 0.001 &&
              (code == 'USD' ||
                  code == 'EUR' ||
                  code == 'GBP' ||
                  code == 'USDT');
          eqInSite = looksInverse ? (bal / rate) : (bal * rate);
        }
      }
    }

    if (eqInSite == null || !eqInSite.isFinite) return null;

    final labelCurrency = site.isNotEmpty
        ? site
        : (code == 'IRR' || code == 'IRT' ? '' : 'IRR');
    if (labelCurrency.isEmpty) return null;

    final abs = eqInSite.abs();
    final fixed = decimals.clamp(0, 8);
    String formatted;
    if (abs >= 1000) {
      formatted = _withThousands(eqInSite, fixed > 2 ? 0 : fixed);
    } else {
      formatted = eqInSite.toStringAsFixed(fixed);
    }
    return '≈ $formatted $labelCurrency';
  }

  double? _rateIrrFor(String code) {
    if (ratesIrr.containsKey(code)) return ratesIrr[code];
    if (code == 'USDT' && ratesIrr.containsKey('USDT_IRT')) {
      return ratesIrr['USDT_IRT'];
    }
    // IRR is the base (1 IRR = 1). IRT/TMN/TOMAN are Toman: 1 unit = 10 IRR.
    // Fixed 2026-09-25: IRT wallets were undervalued exactly 10x (12M Toman showed ~$5 instead of ~$51).
    if (code == 'IRR') return 1;
    if (code == 'IRT' || code == 'TMN' || code == 'TOMAN') return 10;
    return null;
  }

  double _irrToSite(double eqIrr, String site) {
    if (site.isEmpty ||
        site == 'IRR' ||
        site == 'IRT' ||
        site == 'TMN' ||
        site == 'TOMAN') {
      // Display in IRR (or Toman if site insists on TMN — keep IRR units).
      return eqIrr;
    }
    final sitePerIrrUnit = _rateIrrFor(site);
    if (sitePerIrrUnit == null || sitePerIrrUnit <= 0) return eqIrr;
    return eqIrr / sitePerIrrUnit;
  }

  static String _withThousands(double value, int decimals) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final neg = parts[0].startsWith('-');
    var intPart = neg ? parts[0].substring(1) : parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final fromEnd = intPart.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final head = neg ? '-${buf.toString()}' : buf.toString();
    if (parts.length > 1 && decimals > 0) return '$head.${parts[1]}';
    return head;
  }
}

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

  static const _staleAfter = Duration(minutes: 5);

  Future<WalletLiveRateService> init() async {
    await refresh(force: true);
    return this;
  }

  Future<void> refresh({bool force = false}) async {
    if (!force &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < _staleAfter &&
        ratesIrr.isNotEmpty) {
      return;
    }
    isLoading.value = true;
    lastError.value = null;
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
    // IRR / IRT / TMN are the base.
    if (code == 'IRR' || code == 'IRT' || code == 'TMN') return 1;
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

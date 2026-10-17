import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const supportedCodes = ['en', 'fa', 'ar', 'zh', 'tr', 'ru'];

  group('UX-I18N-01 — Supported Locales and Delegates', () {
    test('all 6 target locales are declared and supported by delegate', () {
      final supportedLanguageCodes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();

      for (final code in supportedCodes) {
        expect(
          supportedLanguageCodes.contains(code),
          isTrue,
          reason: 'Locale $code must be in supportedLocales',
        );
        expect(
          AppLocalizations.delegate.isSupported(Locale(code)),
          isTrue,
          reason: 'Delegate must support locale $code',
        );
      }
    });

    test('all 6 locales load cleanly via AppLocalizations.delegate', () async {
      for (final code in supportedCodes) {
        final loc = await AppLocalizations.delegate.load(Locale(code));
        expect(loc, isNotNull);
        expect(loc.localeName, code);
      }
    });
  });

  group('UX-I18N-01 — Core Financial Keys Exist Across All 6 Catalogs', () {
    test('financial keys are populated and non-empty for all locales', () async {
      for (final code in supportedCodes) {
        final loc = await AppLocalizations.delegate.load(Locale(code));

        expect(loc.actionButtonTransfer.trim(), isNotEmpty);
        expect(loc.bottomNavTransfer.trim(), isNotEmpty);
        expect(loc.exchangeTitle.trim(), isNotEmpty);
        expect(loc.remittanceTitle.trim(), isNotEmpty);
        expect(loc.remittanceSendAmount.trim(), isNotEmpty);
        expect(loc.remittanceGetQuote.trim(), isNotEmpty);
        expect(loc.remittanceReviewConfirm.trim(), isNotEmpty);
        expect(loc.p2pP2p.trim(), isNotEmpty);
        expect(loc.addMoneySuccess.trim(), isNotEmpty);
        expect(loc.addMoneyValidationSelectWallet.trim(), isNotEmpty);
      }
    });

    test('Arabic remittance keys are localized into Arabic and not English', () async {
      final arLoc = await AppLocalizations.delegate.load(const Locale('ar'));

      expect(arLoc.remittanceTitle, equals('الحوالات الدولية'));
      expect(arLoc.remittanceHistoryTitle, equals('سجل الحوالات'));
      expect(arLoc.remittanceDetailsTitle, equals('تفاصيل الحوالة'));
      expect(arLoc.remittanceSendAmount, equals('مبلغ الإرسال'));
      expect(arLoc.remittanceGetQuote, equals('الحصول على عرض سعر'));
      expect(arLoc.remittanceReviewConfirm, equals('المراجعة والتأكيد'));
      expect(arLoc.remittanceTermsNotice.contains('بإرسال هذا الطلب'), isTrue);
    });
  });

  group('UX-I18N-01 — Core Auth Keys Exist Across All 6 Catalogs', () {
    test('auth keys are populated and non-empty for all locales', () async {
      for (final code in supportedCodes) {
        final loc = await AppLocalizations.delegate.load(Locale(code));

        expect(loc.signInButton.trim(), isNotEmpty);
        expect(loc.signInEmail.trim(), isNotEmpty);
        expect(loc.signInForgotPassword.trim(), isNotEmpty);
        expect(loc.forgotPasswordTitle.trim(), isNotEmpty);
        expect(loc.twoFactorAuthTitle.trim(), isNotEmpty);
        expect(loc.sessionExpiredMessage.trim(), isNotEmpty);
        expect(loc.signInWithTelegram.trim(), isNotEmpty);
        expect(loc.signInTelegramUnavailable.trim(), isNotEmpty);
      }
    });

    test('Chinese and Arabic network/auth keys are localized in native script', () async {
      final zhLoc = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(zhLoc.networkReconnected, equals('网络连接已恢复'));
      expect(zhLoc.vpnHintBanner.contains('检测到 VPN'), isTrue);
      expect(zhLoc.signInWithTelegram, equals('通过 Telegram 继续'));
      expect(zhLoc.sessionExpiredMessage.contains('您的登录会话已过期'), isTrue);

      final arLoc = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(arLoc.networkReconnected, equals('تمت استعادة الاتصال بالإنترنت'));
      expect(arLoc.vpnHintBanner.contains('تم اكتشاف VPN'), isTrue);
      expect(arLoc.signInWithTelegram, equals('المتابعة باستخدام Telegram'));
      expect(arLoc.sessionExpiredMessage.contains('انتهت صلاحية جلستك'), isTrue);
    });
  });

  group('UX-I18N-01 — Core Error and Navigation Keys Exist Across All Catalogs', () {
    test('error and navigation keys are populated and non-empty for all locales', () async {
      for (final code in supportedCodes) {
        final loc = await AppLocalizations.delegate.load(Locale(code));

        expect(loc.allControllerLoadError.trim(), isNotEmpty);
        expect(loc.networkReconnected.trim(), isNotEmpty);
        expect(loc.vpnHintBanner.trim(), isNotEmpty);
        expect(loc.bottomNavHome.trim(), isNotEmpty);
        expect(loc.bottomNavSettings.trim(), isNotEmpty);
        expect(loc.bottomNavMyCards.trim(), isNotEmpty);
        expect(loc.p2pCancel.trim(), isNotEmpty);
      }
    });
  });

  group('UX-I18N-01 — Format Specifiers and Placeholders Verification', () {
    test('parameterized validation messages interpolate parameters properly across all 6 locales', () async {
      for (final code in supportedCodes) {
        final loc = await AppLocalizations.delegate.load(Locale(code));

        final minAmountMsg = loc.addMoneyValidationAmountMinimum('150');
        expect(
          minAmountMsg.contains('150'),
          isTrue,
          reason: 'Locale $code: addMoneyValidationAmountMinimum must interpolate amount',
        );

        final cardMinMsg = loc.cardDetailsAmountMinimumLimit('250');
        expect(
          cardMinMsg.contains('250'),
          isTrue,
          reason: 'Locale $code: cardDetailsAmountMinimumLimit must interpolate amount',
        );

        final rateLockedMsg = loc.remittanceRateLocked(45);
        expect(
          rateLockedMsg.contains('45'),
          isTrue,
          reason: 'Locale $code: remittanceRateLocked must interpolate seconds',
        );

        final p2pMinLimitMsg = loc.p2pAmountMinLimit('25', 'USD');
        expect(
          p2pMinLimitMsg.contains('25') && p2pMinLimitMsg.contains('USD'),
          isTrue,
          reason: 'Locale $code: p2pAmountMinLimit must interpolate min and currency',
        );
      }
    });

    test('addMoneyValidationAmountMinimum copy conveys "at least / minimum" in en, fa, ru, ar, zh, tr', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(en.addMoneyValidationAmountMinimum('10'), equals('Amount must be at least 10'));

      final fa = await AppLocalizations.delegate.load(const Locale('fa'));
      expect(fa.addMoneyValidationAmountMinimum('10'), equals('مبلغ نباید از 10 کمتر باشد'));

      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      expect(ru.addMoneyValidationAmountMinimum('10'), equals('Сумма не должна быть меньше 10'));

      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(ar.addMoneyValidationAmountMinimum('10'), equals('يجب ألا يقل المبلغ عن 10'));

      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(zh.addMoneyValidationAmountMinimum('10'), equals('金额不能低于 10'));

      final tr = await AppLocalizations.delegate.load(const Locale('tr'));
      expect(tr.addMoneyValidationAmountMinimum('10'), equals('Tutar 10 değerinden az olamaz'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppLocalizations> locFor(String code) async {
    return AppLocalizations.delegate.load(Locale(code));
  }

  test('StatusLabelHelper maps success/pending/failed case-insensitively (en)', () async {
    final loc = await locFor('en');
    expect(StatusLabelHelper.localize(loc, 'Success'), loc.transactionStatusSuccess);
    expect(StatusLabelHelper.localize(loc, 'pending'), loc.transactionStatusPending);
    expect(StatusLabelHelper.localize(loc, 'FAILED'), loc.transactionStatusFailed);
    expect(StatusLabelHelper.localize(loc, 'rejected'), loc.transactionStatusFailed);
    expect(StatusLabelHelper.localize(loc, 'weird'), 'weird');
  });

  test('StatusLabelHelper works for fa locale', () async {
    final loc = await locFor('fa');
    expect(StatusLabelHelper.localize(loc, 'success'), loc.transactionStatusSuccess);
    expect(StatusLabelHelper.localize(loc, 'Success'), isNot(equals('Success')));
  });
}

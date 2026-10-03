import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The guarantee certificate is a document users print, hand to a bank, and
/// submit to customs and tender authorities.
///
/// In v1.0.130 it asserted things it could not back:
///
///   - a "Digitally Signed & Sealed by eCardo Banking Partner (HSM
///     RSA-4096)" line in the PDF footer, while no private key exists
///     anywhere in this app;
///   - "Governing Rules: URDG 758 / Central Bank Directives", claiming a
///     regulatory framework the issuer is not party to;
///   - a "SEPAM COMPLIANT" subtitle;
///   - an instruction to scan the QR "to verify validity directly",
///     although the QR encodes only display fields the app already holds;
///   - a SHA-256 "fingerprint" presented beside the QR as an authenticity
///     signal. It is unkeyed over data the holder already has, so anyone can
///     recompute it after editing the amount — a checksum, not a signature.
///
/// These read the widget source, because the offending strings live in the
/// PDF builder and the verification panel, neither of which renders in a unit
/// test without a full layout pass. A source scan fails the build the moment
/// someone puts a claim back.
void main() {
  final file = File(
    'lib/src/guarantee/widgets/guarantee_certificate_widget.dart',
  );

  late String source;

  setUp(() {
    expect(
      file.existsSync(),
      isTrue,
      reason: 'run `flutter test` from the repo root',
    );
    source = file.readAsStringSync();
  });

  /// The source with `//` line comments stripped.
  ///
  /// The fix comments quote the removed claims verbatim to explain what
  /// changed, so a raw substring scan would match its own documentation and
  /// fail forever. Only strings that can actually reach a user are asserted.
  String renderedText() =>
      source.replaceAll(RegExp(r'//.*$', multiLine: true), '');

  test('the source file was found and is non-trivial', () {
    expect(source.length, greaterThan(1000));
  });

  group('must not claim a cryptographic signature', () {
    test('no HSM claim', () {
      expect(renderedText(), isNot(contains('HSM')));
    });

    test('no "Digitally Signed" claim', () {
      expect(renderedText(), isNot(contains('Digitally Signed')));
    });

    test('no "Sealed by" claim naming a signing authority', () {
      expect(
        renderedText(),
        isNot(contains('Sealed by eCardo Banking Partner')),
      );
    });
  });

  group('must not claim regulatory standing', () {
    test('does not assert it is governed by URDG 758', () {
      expect(renderedText(), isNot(contains('Governing Rules: URDG 758')));
    });

    test('does not claim SEPAM compliance outright', () {
      expect(renderedText(), isNot(contains('(SEPAM COMPLIANT)')));
    });
  });

  group('must not promise instant validity verification', () {
    test('no English "verify validity" instruction', () {
      expect(renderedText(), isNot(contains('verify validity')));
    });

    test('no Persian instruction claiming instant verification', () {
      expect(renderedText(), isNot(contains('اعتبارسنجی آنی')));
    });
  });

  group('the checksum must be labelled as a checksum', () {
    test('is not presented as a cryptographic fingerprint', () {
      expect(
        renderedText(),
        isNot(contains('Cryptographic Fingerprint')),
      );
      expect(renderedText(), isNot(contains('اثر انگشت رمزنگاری')));
    });

    test('is rendered with an explicit "Checksum" label', () {
      expect(
        renderedText(),
        contains('Checksum: '),
        reason: 'the visible label must say what it is',
      );
    });
  });

  group('the replacement guidance is present', () {
    test('tells the reader the bank original is what counts', () {
      expect(renderedText(), contains('countersigned'));
    });

    test('tells the Persian reader the same thing', () {
      expect(renderedText(), contains('مهر و امضای بانک'));
    });
  });
}
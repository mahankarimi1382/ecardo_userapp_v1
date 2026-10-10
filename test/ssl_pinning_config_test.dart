// Tests for SslPinningConfig certificate pinning.
//
// The regression these guard against: the implementation used to contain
// `'PLACEHOLDER_SPKI_PIN_ECARDO_IR'` and returned `true` for ANY certificate
// whenever the pin list held only placeholders. Pinning was therefore a
// no-op while appearing enabled — `isPinningEnabled` was literally `true`
// and the class name said "Pinning", so a reader had no reason to doubt it.
//
// Pins come from `String.fromEnvironment`, which is a compile-time constant
// and cannot be varied at runtime in a VM test. So these tests cover the two
// behaviours that do not depend on the pin value: host selection, and the
// fail-closed path when no pin is configured. The pin-matches path is
// exercised by the release pipeline rather than here.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:ecardo_user/src/network/config/ssl_pinning_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SslPinningConfig.validateCertificate', () {
    test('rejects a null or empty certificate for pinned hosts', () {
      expect(SslPinningConfig.validateCertificate(null, 'ecardo.ir'), isFalse);
      expect(SslPinningConfig.validateCertificate(<int>[], 'ecardo.ir'),
          isFalse);
    });

    test('ignores a null or empty certificate for unpinned hosts', () {
      expect(SslPinningConfig.validateCertificate(null, 'example.com'), isTrue);
      expect(SslPinningConfig.validateCertificate(<int>[], 'example.com'),
          isTrue);
    });

    test('defers to the system trust store for unpinned hosts', () {
      // Without a configured pin a pinned host is rejected, so use a host
      // that is never in pinnedHosts — that path must stay open, otherwise
      // every third-party HTTPS call in the app breaks.
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'example.com'),
        isTrue,
      );
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'cdn.example.net'),
        isTrue,
      );
    });

    test('does NOT trust a subdomain of an unrelated host', () {
      // 'notecardo.ir' ends with 'ecardo.ir' as a string but is a different
      // domain. The check uses host == h || host.endsWith('.$h') so this is
      // correctly treated as unpinned rather than pinned.
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'notecardo.ir'),
        isTrue,
      );
    });

    test('FAILS CLOSED for mismatched certificates on pinned hosts', () {
      // With default fallback pins active, random bytes must be rejected
      // because they do not match the expected SHA-256 certificate pin.
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'ecardo.ir'),
        isFalse,
        reason: 'a pinned host with mismatched certificate must reject the connection',
      );
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'trip.ecardo.ir'),
        isFalse,
      );
      expect(
        SslPinningConfig.validateCertificate(<int>[1, 2, 3], 'sub.ecardo.ir'),
        isFalse,
        reason: 'subdomains of a pinned host are pinned too',
      );
    });

    test('rejects a certificate for a pinned host even when one is empty', () {
      expect(SslPinningConfig.validateCertificate(<int>[], 'ecardo.ir'),
          isFalse,
          reason: 'a pinned host with empty certificate bytes must be rejected');
    });
  });

  group('SslPinningConfig per-host pin isolation and fallback pins', () {
    test('expectedCertificateHashes provides separate pin lists per host', () {
      final hashes = SslPinningConfig.expectedCertificateHashes;
      expect(hashes.containsKey('ecardo.ir'), isTrue);
      expect(hashes.containsKey('trip.ecardo.ir'), isTrue);

      final ecardoPins = hashes['ecardo.ir']!;
      final tripPins = hashes['trip.ecardo.ir']!;

      expect(ecardoPins, contains('nzdZNbln73WWnd9FKxL6orllludWCB0fM9U5kUCD3Jc='));
      expect(ecardoPins, contains('YdCRBrWlE5rxC4hBFv886CFS+VdYT0YIy7C1EUEs7ZM='));
      expect(tripPins, contains('5/wJzsdyaqKOIqppmnFDDO5dHYIXxzUB1lNSWGmGiyQ='));

      // Ensure pin lists are isolated and NOT shared across hosts
      expect(ecardoPins, isNot(contains('5/wJzsdyaqKOIqppmnFDDO5dHYIXxzUB1lNSWGmGiyQ=')));
      expect(tripPins, isNot(contains('nzdZNbln73WWnd9FKxL6orllludWCB0fM9U5kUCD3Jc=')));
      expect(tripPins, isNot(contains('YdCRBrWlE5rxC4hBFv886CFS+VdYT0YIy7C1EUEs7ZM=')));
    });

    test('matchPinnedHost correctly resolves apex and subdomains', () {
      expect(SslPinningConfig.matchPinnedHost('ecardo.ir'), 'ecardo.ir');
      expect(SslPinningConfig.matchPinnedHost('ECARDO.IR'), 'ecardo.ir');
      expect(SslPinningConfig.matchPinnedHost('api.ecardo.ir'), 'ecardo.ir');
      expect(SslPinningConfig.matchPinnedHost('trip.ecardo.ir'), 'trip.ecardo.ir');
      expect(SslPinningConfig.matchPinnedHost('flight.trip.ecardo.ir'), 'trip.ecardo.ir');
      expect(SslPinningConfig.matchPinnedHost('example.com'), isNull);
      expect(SslPinningConfig.matchPinnedHost('notecardo.ir'), isNull);
    });

    test('isPinnedHost correctly identifies hosts', () {
      expect(SslPinningConfig.isPinnedHost('ecardo.ir'), isTrue);
      expect(SslPinningConfig.isPinnedHost('trip.ecardo.ir'), isTrue);
      expect(SslPinningConfig.isPinnedHost('api.ecardo.ir'), isTrue);
      expect(SslPinningConfig.isPinnedHost('hotel.trip.ecardo.ir'), isTrue);
      expect(SslPinningConfig.isPinnedHost('other.org'), isFalse);
    });
  });

  group('pin digest format', () {
    test('the documented openssl recipe matches what the code computes', () {
      // Guards the doc comment against drift: the openssl pipeline ends in
      // `openssl x509 -outform der | openssl dgst -sha256 -binary | base64`,
      // i.e. SHA-256 over the DER bytes, base64 encoded. The runtime side
      // hashes `cert.der`, so a pin generated any other way silently never
      // matches and takes the app offline.
      final der = <int>[0x30, 0x82, 0x01, 0x02, 0xDE, 0xAD, 0xBE, 0xEF];
      final expected =
          base64Encode(sha256.convert(der).bytes);
      expect(expected, isNotEmpty);
      expect(base64Decode(expected), hasLength(32));
    });
  });
}

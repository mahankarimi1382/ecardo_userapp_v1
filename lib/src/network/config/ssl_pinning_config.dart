import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// SSL Pinning configuration and runtime certificate fingerprint verification.
///
/// SECURITY (v1.0.126): the previous version short-circuited to `true`
/// whenever the pin list still held placeholders. That made pinning a no-op:
/// any CA the device trusted could mint a certificate for ecardo.ir and pass.
///
/// The pin is the SHA-256 of the full leaf certificate DER, because
/// X509Certificate exposes no SPKI accessor — extracting the public key would
/// mean hand-parsing the certificate in Dart. The trade-off: re-issuing the
/// server certificate invalidates the pin, so an app release must ship before
/// the cert changes. [expectedCertificateHashes] accepts a backup pin for that
/// window.
///
/// Two fixes landed here:
///   1. Pin via build-time --dart-define instead of a checked-in placeholder.
///   2. A pinned host with NO configured pin now fails CLOSED instead of
///      silently allowing every certificate.
class SslPinningConfig {
  /// Whether SSL pinning enforcement is active.
  static const bool isPinningEnabled = true;

  /// Pinned apex host for core API and authentication services.
  static const String ecardoApexHost = 'ecardo.ir';

  /// Pinned host for travel and ticketing services.
  static const String tripApexHost = 'trip.ecardo.ir';

  /// Allowed hostnames for certificate pinning.
  static const List<String> pinnedHosts = [
    tripApexHost,
    ecardoApexHost,
  ];

  /// Verified live fallback certificate pin for ecardo.ir leaf certificate.
  /// Rotated 2026-10-09 by Google Trust Services / Cloudflare.
  static const String defaultEcardoCertPin =
      'nzdZNbln73WWnd9FKxL6orllludWCB0fM9U5kUCD3Jc=';

  /// Previous certificate pin for ecardo.ir (for graceful rotation window).
  static const String previousEcardoCertPin =
      'YdCRBrWlE5rxC4hBFv886CFS+VdYT0YIy7C1EUEs7ZM=';

  /// Verified live fallback certificate pin for trip.ecardo.ir leaf certificate.
  static const String defaultTripCertPin =
      '5/wJzsdyaqKOIqppmnFDDO5dHYIXxzUB1lNSWGmGiyQ=';

  /// SHA-256 certificate pins, base64, separated per host.
  ///
  /// For ecardo.ir:
  ///   Build-time defines: ECARDO_CERT_PIN and ECARDO_CERT_PIN_BACKUP.
  ///   If ECARDO_CERT_PIN is provided via --dart-define, it is used (along with
  ///   any backup pin). If omitted, falls back to [defaultEcardoCertPin] and [previousEcardoCertPin].
  ///
  /// For trip.ecardo.ir:
  ///   Build-time defines: TRIP_CERT_PIN and TRIP_CERT_PIN_BACKUP.
  ///   If TRIP_CERT_PIN is provided via --dart-define, it is used (along with
  ///   any backup pin). If omitted, falls back to [defaultTripCertPin].
  static Map<String, List<String>> get expectedCertificateHashes {
    const ecardoCurrent = String.fromEnvironment('ECARDO_CERT_PIN');
    const ecardoBackup = String.fromEnvironment('ECARDO_CERT_PIN_BACKUP');
    final ecardoPins = <String>[
      if (ecardoCurrent.trim().isNotEmpty)
        ecardoCurrent.trim()
      else ...[
        defaultEcardoCertPin,
        previousEcardoCertPin,
      ],
      if (ecardoBackup.trim().isNotEmpty)
        ecardoBackup.trim(),
    ];

    const tripCurrent = String.fromEnvironment('TRIP_CERT_PIN');
    const tripBackup = String.fromEnvironment('TRIP_CERT_PIN_BACKUP');
    final tripPins = <String>[
      if (tripCurrent.trim().isNotEmpty)
        tripCurrent.trim()
      else
        defaultTripCertPin,
      if (tripBackup.trim().isNotEmpty)
        tripBackup.trim(),
    ];

    return {
      ecardoApexHost: List<String>.unmodifiable(ecardoPins),
      tripApexHost: List<String>.unmodifiable(tripPins),
    };
  }

  /// Matches [host] to the most specific pinned host apex, or null if unpinned.
  ///
  /// For example:
  ///   - 'ecardo.ir' -> 'ecardo.ir'
  ///   - 'api.ecardo.ir' -> 'ecardo.ir'
  ///   - 'trip.ecardo.ir' -> 'trip.ecardo.ir'
  ///   - 'api.trip.ecardo.ir' -> 'trip.ecardo.ir' (longest suffix matches trip, not ecardo)
  ///   - 'example.com' -> null
  static String? matchPinnedHost(String host) {
    final lower = host.trim().toLowerCase();
    // 1. Exact match first
    for (final h in pinnedHosts) {
      if (lower == h) return h;
    }
    // 2. Subdomain match: longest matching apex wins so that subdomains of
    // trip.ecardo.ir match trip.ecardo.ir rather than ecardo.ir.
    String? bestMatch;
    for (final h in pinnedHosts) {
      if (lower.endsWith('.$h')) {
        if (bestMatch == null || h.length > bestMatch.length) {
          bestMatch = h;
        }
      }
    }
    return bestMatch;
  }

  /// Checks whether [host] is one of the pinned hostnames or subdomains.
  static bool isPinnedHost(String host) {
    return matchPinnedHost(host) != null;
  }

  /// Validates the certificate against the pins for [host].
  ///
  /// Fails CLOSED: a pinned host with no configured pin, missing certificate
  /// data, or mismatched pin is rejected.
  ///
  /// NET-FIX (RC1 relief): the fail-closed rule stays for RELEASE builds,
  /// but debug builds are allowed through with a loud warning when allowDebugWithoutPin is true.
  static bool validateCertificate(
    List<int>? certDer,
    String host, {
    bool allowDebugWithoutPin = false,
  }) {
    if (!isPinningEnabled) {
      return true;
    }

    final matchedApex = matchPinnedHost(host);
    if (matchedApex == null) {
      return true; // Not a pinned host — system trust store decides.
    }

    // Pinned host: Missing or empty certificate data MUST fail closed.
    if (certDer == null || certDer.isEmpty) {
      if (allowDebugWithoutPin && kDebugMode) {
        debugPrint(
          '⚠️ [SECURITY-DEBUG] Certificate data missing for pinned host $host — '
          'ALLOWED in debug (system trust only).',
        );
        return true;
      }
      debugPrint(
        '🚨 [SECURITY] Certificate data missing for pinned host: $host — REJECTED.',
      );
      return false;
    }

    final pins = expectedCertificateHashes[matchedApex] ??
        expectedCertificateHashes[host.trim().toLowerCase()] ??
        const <String>[];
    if (pins.isEmpty) {
      if (allowDebugWithoutPin && kDebugMode) {
        debugPrint(
          '⚠️ [SECURITY-DEBUG] No certificate pin configured for $host — '
          'ALLOWED in debug (system trust only).\n'
          '   Release builds fail closed.',
        );
        return true;
      }
      debugPrint(
        '🚨 [SECURITY] No certificate pin configured for $host — REJECTED.',
      );
      return false;
    }

    final actual = base64Encode(sha256.convert(certDer).bytes);
    final isMatched = pins.any((pin) => _constantTimeEquals(pin, actual));

    if (!isMatched) {
      debugPrint('🚨 [SECURITY WARNING] Certificate pin mismatch for host: $host');
      return false;
    }

    return true;
  }

  /// Comparison that does not short-circuit on the first differing character.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

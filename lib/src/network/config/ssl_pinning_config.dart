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

  /// Allowed hostnames for certificate pinning.
  static const List<String> pinnedHosts = [
    'ecardo.ir',
    'trip.ecardo.ir',
  ];

  /// SHA-256 certificate pins, base64, supplied at build time.
  ///
  /// CI publishes the current pin into the build with:
  ///   `flutter build apk --dart-define=ECARDO_CERT_PIN=<pin>`
  ///
  /// Compute a pin with (must match the runtime digest exactly):
  ///   `openssl s_client -connect ecardo.ir:443 -servername ecardo.ir </dev/null 2>/dev/null` \
  ///     | `openssl x509 -outform der` \
  ///     | `openssl dgst -sha256 -binary | openssl enc -base64`
  ///
  /// Keep one BACKUP pin alongside the current one: rotating the certificate
  /// before the release is live bricks every installed app.
  static Map<String, List<String>> get expectedCertificateHashes {
    const current = String.fromEnvironment('ECARDO_CERT_PIN');
    const backup = String.fromEnvironment('ECARDO_CERT_PIN_BACKUP');
    if (current.isEmpty && backup.isEmpty) {
      return const {};
    }
    final pins = [
      if (current.isNotEmpty) current.trim(),
      if (backup.isNotEmpty) backup.trim(),
    ];
    return {for (final host in pinnedHosts) host: pins};
  }

  /// Checks whether [host] is one of the pinned hostnames or subdomains.
  static bool isPinnedHost(String host) {
    return pinnedHosts.any((h) => host == h || host.endsWith('.$h'));
  }

  /// Validates the certificate against the pins for [host].
  ///
  /// Fails CLOSED: a pinned host with no configured pin or missing certificate
  /// data is rejected. That is deliberate — an unconfigured pin or missing cert
  /// means the connection cannot be verified, and accepting the connection there
  /// is the hole this class existed to close.
  ///
  /// NET-FIX (RC1 relief): the fail-closed rule stays for RELEASE builds,
  /// but debug builds are allowed through with a loud warning. A local
  /// `flutter run` without --dart-define=ECARDO_CERT_PIN used to reject
  /// EVERY request to ecardo.ir, surfacing as endless "network errors"
  /// during development while release builds (CI supplies the pin) were
  /// unaffected. Platform trust still applies in debug — this only skips
  /// the extra pin check, it does not accept untrusted certificates.
  static bool validateCertificate(
    List<int>? certDer,
    String host, {
    bool allowDebugWithoutPin = false,
  }) {
    if (!isPinningEnabled) {
      return true;
    }

    if (!isPinnedHost(host)) {
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

    final matchedApex = pinnedHosts.firstWhere(
      (h) => host == h || host.endsWith('.$h'),
      orElse: () => host,
    );
    final pins = expectedCertificateHashes[host] ??
        expectedCertificateHashes[matchedApex] ??
        const <String>[];
    if (pins.isEmpty) {
      if (allowDebugWithoutPin && kDebugMode) {
        debugPrint(
          '⚠️ [SECURITY-DEBUG] No certificate pin configured for $host — '
          'ALLOWED in debug (system trust only).\n'
          '   Release builds fail closed. Build with '
          '--dart-define=ECARDO_CERT_PIN=<base64 sha256 of cert DER>.',
        );
        return true;
      }
      debugPrint(
        '🚨 [SECURITY] No certificate pin configured for $host — REJECTED.\n'
        '   Build with --dart-define=ECARDO_CERT_PIN=<base64 sha256 of cert DER>.',
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

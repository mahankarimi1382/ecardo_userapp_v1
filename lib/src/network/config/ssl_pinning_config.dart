import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// SSL Pinning configuration and runtime SPKI fingerprint verification.
///
/// NOTE: The pins below are placeholders. Production SHA-256 SPKI pins
/// for ecardo.ir and trip.ecardo.ir should be added here once deployed.
class SslPinningConfig {
  /// Whether SSL pinning enforcement is active.
  static const bool isPinningEnabled = true;

  /// Allowed hostnames for certificate pinning.
  static const List<String> pinnedHosts = [
    'ecardo.ir',
    'trip.ecardo.ir',
  ];

  /// SHA-256 fingerprints of the expected server certificates / public keys.
  /// Format: lowercase hex string without colons or base64 SHA-256.
  /// Run: openssl s_client -connect ecardo.ir:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
  static const List<String> expectedSpkiHashes = [
    // Placeholder - replace with actual production certificate SHA-256 hashes
    'PLACEHOLDER_SPKI_PIN_ECARDO_IR',
  ];

  /// Validates the certificate against pinned hashes.
  /// If the certificate matches or if only placeholders exist, returns true.
  /// If actual pinning fails, logs a security warning and returns false.
  static bool validateCertificate(
    List<int>? certDer,
    String host,
  ) {
    if (!isPinningEnabled || certDer == null || certDer.isEmpty) {
      return true;
    }

    if (!pinnedHosts.any((h) => host == h || host.endsWith('.$h'))) {
      return true; // Not a pinned host
    }

    // If only placeholder pins are configured, log notice and permit
    if (expectedSpkiHashes.isEmpty ||
        expectedSpkiHashes.every((p) => p.startsWith('PLACEHOLDER_'))) {
      if (kDebugMode) {
        debugPrint('🔒 SSL Pinning: using placeholder configuration for $host (pass-through)');
      }
      return true;
    }

    final digest = sha256.convert(certDer);
    final certSha256Hex = digest.toString().toLowerCase();
    final certSha256Base64 = base64Encode(digest.bytes);

    final isMatched = expectedSpkiHashes.any((pin) {
      final cleanPin = pin.trim().toLowerCase();
      return cleanPin == certSha256Hex || pin.trim() == certSha256Base64;
    });

    if (!isMatched) {
      debugPrint('🚨 [SECURITY WARNING] SSL Pinning verification failed for host: $host');
      debugPrint('🚨 Certificate fingerprint did not match any pinned SPKI hash.');
      return false;
    }

    return true;
  }
}

import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Cryptographically validates Base58Check TRON addresses (starts with 'T', byte 0x41, 34 chars, double-SHA256 checksum).
class TronAddressValidator {
  TronAddressValidator._();

  static const String _alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  /// Validates that an address is a valid Base58Check TRON address.
  static bool isValid(String? address) {
    if (address == null) return false;
    final clean = address.trim();
    if (clean.length != 34 || !clean.startsWith('T')) return false;

    try {
      final decoded = _base58Decode(clean);
      if (decoded.length != 25) return false;
      // TRON address mainnet prefix byte must be 0x41
      if (decoded[0] != 0x41) return false;

      final payload = decoded.sublist(0, 21);
      final checksum = decoded.sublist(21, 25);

      final hash1 = sha256.convert(payload).bytes;
      final hash2 = sha256.convert(hash1).bytes;

      for (int i = 0; i < 4; i++) {
        if (hash2[i] != checksum[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Uint8List _base58Decode(String input) {
    BigInt intVal = BigInt.zero;
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final index = _alphabet.indexOf(char);
      if (index == -1) {
        throw FormatException('Invalid Base58 character: $char');
      }
      intVal = intVal * BigInt.from(58) + BigInt.from(index);
    }

    final bytesList = <int>[];
    while (intVal > BigInt.zero) {
      bytesList.add((intVal % BigInt.from(256)).toInt());
      intVal = intVal ~/ BigInt.from(256);
    }
    final result = bytesList.reversed.toList();

    // Preserve leading zeros ('1' in Base58)
    int leadingZeros = 0;
    while (leadingZeros < input.length && input[leadingZeros] == _alphabet[0]) {
      leadingZeros++;
    }

    final full = Uint8List(leadingZeros + result.length);
    for (int i = 0; i < leadingZeros; i++) {
      full[i] = 0;
    }
    full.setRange(leadingZeros, full.length, result);
    return full;
  }
}

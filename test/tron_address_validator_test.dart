import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/tron_address_validator.dart';

void main() {
  group('P0 Security — TronAddressValidator Cryptographic Invariants', () {
    test('validates authentic TRON TRC-20 addresses with exact Base58Check checksum', () {
      // Real BIP-44 derived addresses from walet-ecardo engine
      const realAddresses = [
        'TKPnGMKxARzksnZftPJvFapZKsg8MLm5dL',
        'TJeN5zN9EJKWYuD3MLibpWsU8soTQyw9dP',
        'TVr5qz91GmbGTjhaN6T2WKmXJLiBpCqiQd',
        'TYs8cvjbHWB9qYgqzt5J1WszvpKcnZXjjz',
        'TY2i1AcyQt6pMZJpudQZFFwbSt4PTo8Yqk',
      ];

      for (final addr in realAddresses) {
        expect(TronAddressValidator.isValid(addr), isTrue,
            reason: 'Address $addr must be valid');
      }
    });

    test('strictly rejects address with corrupted or invalid Base58Check checksum', () {
      // The invalid fallback address from re-audit finding P0-01
      const invalidChecksumAddress = 'TLwT8x8H71v8qR4qNfM2F1m4P9yQ8sX3kZ';
      expect(TronAddressValidator.isValid(invalidChecksumAddress), isFalse);

      // Mutate one character of a valid address
      const mutated = 'TKPnGMKxARzksnZftPJvFapZKsg8MLm5dM';
      expect(TronAddressValidator.isValid(mutated), isFalse);
    });

    test('strictly rejects non-TRON addresses and malformed inputs', () {
      // Null / empty / blank
      expect(TronAddressValidator.isValid(null), isFalse);
      expect(TronAddressValidator.isValid(''), isFalse);
      expect(TronAddressValidator.isValid('   '), isFalse);

      // Ethereum / EVM address
      expect(TronAddressValidator.isValid('0x742d35Cc6634C0532925a3b844Bc454e4438f44e'), isFalse);

      // Bitcoin address
      expect(TronAddressValidator.isValid('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'), isFalse);

      // Short / Long
      expect(TronAddressValidator.isValid('TKPnGMKxARzksnZftPJvFapZKsg8M'), isFalse);
      expect(TronAddressValidator.isValid('TKPnGMKxARzksnZftPJvFapZKsg8MLm5dLExtraChars'), isFalse);

      // Non-base58 characters (0, O, I, l)
      expect(TronAddressValidator.isValid('TKPnGMKxARzksnZftPJvFapZKsg8MLm500'), isFalse);
    });
  });
}

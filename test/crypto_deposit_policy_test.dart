import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/crypto_deposit_policy.dart';

void main() {
  const validAddress = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';
  final now = DateTime.utc(2026, 10, 19, 9, 0, 0);

  Map<String, dynamic> validPayload({
    Map<String, dynamic> overrides = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'deposits_enabled': true,
      'policy_version': '2026-10-19',
      'wallet_id': 'f5fd1a7a-c940-4342-b2a6-bd8867d9fc00',
      'assignment_id': 'assign-123',
      'user_id': '1',
      'chain': 'TRON',
      'asset': 'USDT',
      'network': 'TRC20',
      'contract_address': CryptoDepositPolicy.usdtTrc20Contract,
      'deposit_address': validAddress,
      'minimum_deposit': '1.000000',
      'required_confirmations': 19,
      'expires_at': '2026-10-19T10:00:00Z',
      ...overrides,
    };
  }

  CryptoDepositPolicyError? errorOf(Map<String, dynamic> data) {
    try {
      CryptoDepositPolicy.fromServerData(data, now: now);
      return null;
    } on CryptoDepositPolicyException catch (error) {
      return error.error;
    }
  }

  group('CryptoDepositPolicy', () {
    test('accepts a complete, consistent server policy', () {
      final policy = CryptoDepositPolicy.fromServerData(
        validPayload(),
        now: now,
      );

      expect(policy.depositsEnabled, isTrue);
      expect(policy.chain, 'TRON');
      expect(policy.asset, 'USDT');
      expect(policy.network, 'TRC20');
      expect(policy.contractAddress, CryptoDepositPolicy.usdtTrc20Contract);
      expect(policy.depositAddress, validAddress);
      expect(policy.minimumDeposit, 1.0);
      expect(policy.requiredConfirmations, 19);
      expect(policy.walletId, 'f5fd1a7a-c940-4342-b2a6-bd8867d9fc00');
      expect(policy.assignmentId, 'assign-123');
    });

    test('accepts a policy without an expiry', () {
      final policy = CryptoDepositPolicy.fromServerData(
        validPayload(overrides: {'expires_at': null}),
        now: now,
      );
      expect(policy.expiresAt, isNull);
      expect(policy.isExpired, isFalse);
    });

    test('rejects a disabled feature even if an address is present', () {
      expect(
        errorOf(validPayload(overrides: {'deposits_enabled': false})),
        CryptoDepositPolicyError.depositsDisabled,
      );
    });

    test('rejects missing wallet id', () {
      expect(
        errorOf(validPayload(overrides: {'wallet_id': ''})),
        CryptoDepositPolicyError.missingField,
      );
    });

    test('rejects malformed wallet id', () {
      expect(
        errorOf(validPayload(overrides: {'wallet_id': 'not-a-uuid'})),
        CryptoDepositPolicyError.invalidWalletId,
      );
    });

    test('rejects a missing assignment id', () {
      expect(
        errorOf(validPayload(overrides: {'assignment_id': ''})),
        CryptoDepositPolicyError.missingField,
      );
    });

    test('rejects a non-TRON chain', () {
      expect(
        errorOf(validPayload(overrides: {'chain': 'ETH'})),
        CryptoDepositPolicyError.unsupportedChain,
      );
    });

    test('rejects USDT_IRT as an on-chain asset', () {
      expect(
        errorOf(validPayload(overrides: {'asset': 'USDT_IRT'})),
        CryptoDepositPolicyError.unsupportedAsset,
      );
    });

    test('rejects an unsupported network', () {
      expect(
        errorOf(validPayload(overrides: {'network': 'BEP20'})),
        CryptoDepositPolicyError.unsupportedNetwork,
      );
    });

    test('rejects a non-official USDT contract', () {
      expect(
        errorOf(
          validPayload(
            overrides: {
              'contract_address': 'TLa2f6VPqDgRE67v1736s7bJ8Ray5wYjU7',
            },
          ),
        ),
        CryptoDepositPolicyError.untrustedContract,
      );
    });

    test('rejects an address with a broken checksum', () {
      expect(
        errorOf(
          validPayload(
            overrides: {
              'deposit_address': 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6u',
            },
          ),
        ),
        CryptoDepositPolicyError.invalidAddress,
      );
    });

    test('rejects zero minimum deposit', () {
      expect(
        errorOf(validPayload(overrides: {'minimum_deposit': '0'})),
        CryptoDepositPolicyError.invalidMinimumDeposit,
      );
    });

    test('rejects an unreasonably large minimum deposit', () {
      expect(
        errorOf(validPayload(overrides: {'minimum_deposit': '100001'})),
        CryptoDepositPolicyError.invalidMinimumDeposit,
      );
    });

    test('rejects fewer than 19 confirmations', () {
      expect(
        errorOf(validPayload(overrides: {'required_confirmations': 18})),
        CryptoDepositPolicyError.invalidConfirmations,
      );
    });

    test('rejects a missing confirmation count', () {
      expect(
        errorOf(validPayload(overrides: {'required_confirmations': null})),
        CryptoDepositPolicyError.invalidConfirmations,
      );
    });

    test('rejects a past expiry', () {
      expect(
        errorOf(
          validPayload(overrides: {'expires_at': '2026-10-19T08:59:59Z'}),
        ),
        CryptoDepositPolicyError.expiredAssignment,
      );
    });

    test('rejects an unparseable expiry', () {
      expect(
        errorOf(validPayload(overrides: {'expires_at': 'not-a-date'})),
        CryptoDepositPolicyError.invalidExpiry,
      );
    });
  });
}

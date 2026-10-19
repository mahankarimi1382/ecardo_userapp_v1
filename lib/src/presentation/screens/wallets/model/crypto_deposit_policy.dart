import 'package:ecardo_user/src/helper/tron_address_validator.dart';

/// Strongly-typed, fail-closed policy for a TRC-20 USDT deposit assignment.
///
/// The client must never derive any of these values locally. Every field is
/// parsed from the authenticated server response and validated together; a
/// single missing/invalid field rejects the whole assignment so no QR code,
/// address or share sheet can ever render.
class CryptoDepositPolicy {
  CryptoDepositPolicy._({
    required this.depositsEnabled,
    required this.policyVersion,
    required this.walletId,
    required this.assignmentId,
    required this.userId,
    required this.chain,
    required this.asset,
    required this.network,
    required this.contractAddress,
    required this.depositAddress,
    required this.minimumDeposit,
    required this.minimumDepositRaw,
    required this.formattedMinimumDeposit,
    required this.requiredConfirmations,
    required this.expiresAt,
    required this.assignmentMode,
  });

  static const String usdtTrc20Contract = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';

  static const Set<String> allowedNetworks = {'TRC20', 'TRON', 'TRON_MAINNET'};

  static const double maxReasonableMinimumDeposit = 100000;

  static const int minimumConfirmations = 19;
  static const int maximumConfirmations = 1000;

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  final bool depositsEnabled;
  final String policyVersion;
  final String walletId;
  final String assignmentId;
  final String userId;
  final String chain;
  final String asset;
  final String network;
  final String contractAddress;
  final String depositAddress;
  final double minimumDeposit;
  final String minimumDepositRaw;
  final String formattedMinimumDeposit;
  final int requiredConfirmations;
  final DateTime? expiresAt;
  final String assignmentMode;

  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && !expiry.isAfter(DateTime.now().toUtc());
  }

  /// Exact amount string formatting without losing token precision.
  static String formatExactAmount(String raw, double parsed) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return parsed.toString();
    if (trimmed.contains('.')) {
      final clean = trimmed
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      return clean.isEmpty ? '0' : clean;
    }
    return trimmed;
  }

  /// Parses and validates the server payload.
  ///
  /// Throws [CryptoDepositPolicyException] on any deviation from the contract.
  factory CryptoDepositPolicy.fromServerData(
    Map<String, dynamic> data, {
    DateTime? now,
    String? expectedWalletId,
  }) {
    final clock = (now ?? DateTime.now()).toUtc();

    final enabled = _readBool(data, 'deposits_enabled');
    if (!enabled) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.depositsDisabled,
      );
    }

    final walletId = _readNonEmpty(data, 'wallet_id');
    if (!_uuid.hasMatch(walletId)) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.invalidWalletId,
      );
    }

    if (expectedWalletId != null &&
        expectedWalletId.trim().isNotEmpty &&
        walletId.toLowerCase() != expectedWalletId.trim().toLowerCase()) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.walletIdMismatch,
      );
    }

    final assignmentId = _readNonEmpty(data, 'assignment_id');
    final userId = _readNonEmpty(data, 'user_id');
    final policyVersion = _readNonEmpty(data, 'policy_version');
    final chain = _readNonEmpty(data, 'chain').toUpperCase();
    final asset = _readNonEmpty(data, 'asset').toUpperCase();
    final network = _readNonEmpty(data, 'network').toUpperCase();
    final contract = _readNonEmpty(data, 'contract_address');
    final address = _readNonEmpty(data, 'deposit_address');

    if (chain != 'TRON') {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.unsupportedChain,
      );
    }
    if (asset != 'USDT') {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.unsupportedAsset,
      );
    }
    if (!allowedNetworks.contains(network)) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.unsupportedNetwork,
      );
    }
    if (contract != usdtTrc20Contract) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.untrustedContract,
      );
    }
    if (!TronAddressValidator.isValid(address)) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.invalidAddress,
      );
    }

    final rawMinStr = data['minimum_deposit']?.toString().trim() ?? '';
    final minimum = _readDecimal(data, 'minimum_deposit');
    if (minimum <= 0 || minimum > maxReasonableMinimumDeposit) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.invalidMinimumDeposit,
      );
    }
    final formattedMin = formatExactAmount(rawMinStr, minimum);

    final confirmations = _readInt(data, 'required_confirmations');
    if (confirmations < minimumConfirmations ||
        confirmations > maximumConfirmations) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.invalidConfirmations,
      );
    }

    final rawMode = data['assignment_mode']?.toString().trim().toLowerCase();
    final assignmentMode = rawMode == 'permanent' ? 'permanent' : 'expiring';

    DateTime? expiresAt;
    final rawExpiry = data['expires_at'];
    if (rawExpiry != null && rawExpiry.toString().trim().isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpiry.toString().trim())?.toUtc();
      if (expiresAt == null) {
        throw const CryptoDepositPolicyException(
          CryptoDepositPolicyError.invalidExpiry,
        );
      }
      if (!expiresAt.isAfter(clock)) {
        throw const CryptoDepositPolicyException(
          CryptoDepositPolicyError.expiredAssignment,
        );
      }
    } else if (assignmentMode != 'permanent') {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.missingExpiry,
      );
    }

    return CryptoDepositPolicy._(
      depositsEnabled: true,
      policyVersion: policyVersion,
      walletId: walletId,
      assignmentId: assignmentId,
      userId: userId,
      chain: chain,
      asset: asset,
      network: network,
      contractAddress: contract,
      depositAddress: address,
      minimumDeposit: minimum,
      minimumDepositRaw: rawMinStr,
      formattedMinimumDeposit: formattedMin,
      requiredConfirmations: confirmations,
      expiresAt: expiresAt,
      assignmentMode: assignmentMode,
    );
  }

  static String _readNonEmpty(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.missingField,
      );
    }
    return value;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1';
  }

  static double _readDecimal(Map<String, dynamic> data, String key) {
    final value = data[key];
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString().trim() ?? '');
    if (parsed == null || !parsed.isFinite) {
      throw const CryptoDepositPolicyException(
        CryptoDepositPolicyError.invalidMinimumDeposit,
      );
    }
    return parsed;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    return int.tryParse(value?.toString().trim() ?? '') ?? -1;
  }
}

enum CryptoDepositPolicyError {
  depositsDisabled,
  missingField,
  invalidWalletId,
  walletIdMismatch,
  unsupportedChain,
  unsupportedAsset,
  unsupportedNetwork,
  untrustedContract,
  invalidAddress,
  invalidMinimumDeposit,
  invalidConfirmations,
  invalidExpiry,
  missingExpiry,
  expiredAssignment,
}

class CryptoDepositPolicyException implements Exception {
  const CryptoDepositPolicyException(this.error, {this.detail});

  final CryptoDepositPolicyError error;
  final String? detail;

  @override
  String toString() =>
      'CryptoDepositPolicyException($error${detail == null ? '' : ': $detail'})';
}

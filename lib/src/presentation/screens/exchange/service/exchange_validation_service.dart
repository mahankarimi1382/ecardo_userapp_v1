import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';

/// Error categories that can arise during exchange amount step validation.
enum ExchangeValidationErrorType {
  none,
  selectFromWallet,
  selectToWallet,
  sameWallet,
  enterAmount,
  amountBelowMinimum,
  amountAboveMaximum,
  insufficientBalance,
}

/// Structured outcome of validating the exchange amount input and wallet selection.
class ExchangeValidationResult {
  const ExchangeValidationResult.valid()
      : isValid = true,
        errorType = ExchangeValidationErrorType.none,
        errorMessage = null,
        limitValue = null,
        currencyCode = null;

  const ExchangeValidationResult.invalid({
    required this.errorType,
    this.errorMessage,
    this.limitValue,
    this.currencyCode,
  }) : isValid = false;

  final bool isValid;
  final ExchangeValidationErrorType errorType;
  final String? errorMessage;
  final double? limitValue;
  final String? currencyCode;
}

/// Encapsulates the computed fee and total amount.
class ExchangeFeeCalculation {
  const ExchangeFeeCalculation({
    required this.charge,
    required this.totalAmount,
  });

  final double charge;
  final double totalAmount;
}

/// Service encapsulating exchange validation rules and financial math.
///
/// Responsibilities:
///   - Validates wallet selection (from/to selected, different currencies).
///   - Validates amount boundaries (min limit, max limit, available balance).
///   - Performs financial math using [MoneyMathHelper] to prevent IEEE-754
///     floating-point rounding errors.
///   - Formats quick-fill percentages for fiat (2 decimals) and crypto (8 decimals).
class ExchangeValidationService {
  const ExchangeValidationService();

  /// Validates the Amount step inputs:
  ///   1. From-wallet selected and non-empty.
  ///   2. To-wallet selected and non-empty.
  ///   3. From and to wallets are different currencies.
  ///   4. Amount is non-empty and > 0.
  ///   5. Amount >= min exchange limit.
  ///   6. Amount <= max exchange limit.
  ///   7. Amount <= available balance in from-wallet.
  ExchangeValidationResult validateAmountStep({
    required Wallets? fromWallet,
    required Wallets? toWallet,
    required String amountText,
    required int decimals,
    AppLocalizations? localizations,
  }) {
    if (fromWallet == null || fromWallet.name?.isEmpty == true) {
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.selectFromWallet,
        errorMessage: localizations?.exchangeValidationSelectFromWallet ??
            'Please select a wallet to exchange from.',
      );
    }

    if (toWallet == null || toWallet.name?.isEmpty == true) {
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.selectToWallet,
        errorMessage: localizations?.exchangeValidationSelectToWallet ??
            'Please select a wallet to exchange to.',
      );
    }

    // Same-currency exchange check (prevent raw 422 from server)
    final fromCode = fromWallet.code?.toUpperCase();
    final toCode = toWallet.code?.toUpperCase();
    if (fromCode != null && fromCode == toCode) {
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.sameWallet,
        errorMessage: localizations?.exchangeValidationSameWallet ??
            'From and to currencies must be different.',
      );
    }

    final trimmed = amountText.trim();
    if (trimmed.isEmpty) {
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.enterAmount,
        errorMessage: localizations?.exchangeValidationEnterAmount ??
            'Please enter an amount.',
      );
    }

    final double enteredAmount = double.tryParse(trimmed) ?? 0.0;
    if (enteredAmount <= 0.0) {
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.enterAmount,
        errorMessage: localizations?.exchangeValidationEnterAmount ??
            'Please enter an amount.',
      );
    }

    final currency = fromWallet.code ?? '';
    final double min =
        double.tryParse(fromWallet.exchangeLimit?.min ?? '') ?? 0.0;
    final double maxRaw =
        double.tryParse(fromWallet.exchangeLimit?.max ?? '') ??
            double.infinity;
    final double max = maxRaw <= 0 ? double.infinity : maxRaw;

    if (min > 0 && enteredAmount < min) {
      final formattedMin = min.toStringAsFixed(decimals);
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.amountBelowMinimum,
        errorMessage: localizations?.exchangeValidationAmountMinimum(
              formattedMin,
              currency,
            ) ??
            'Minimum amount is $formattedMin $currency.',
        limitValue: min,
        currencyCode: currency,
      );
    }

    if (max.isFinite && enteredAmount > max) {
      final formattedMax = max.toStringAsFixed(decimals);
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.amountAboveMaximum,
        errorMessage: localizations?.exchangeValidationAmountMaximum(
              formattedMax,
              currency,
            ) ??
            'Maximum amount is $formattedMax $currency.',
        limitValue: max,
        currencyCode: currency,
      );
    }

    final double availableBalance =
        double.tryParse(fromWallet.balance ?? '') ?? 0.0;
    if (enteredAmount > availableBalance) {
      final formattedBalance = availableBalance.toStringAsFixed(decimals);
      return ExchangeValidationResult.invalid(
        errorType: ExchangeValidationErrorType.insufficientBalance,
        errorMessage: localizations?.exchangeValidationInsufficientBalance(
              formattedBalance,
              currency,
            ) ??
            'Insufficient balance in $currency.',
        limitValue: availableBalance,
        currencyCode: currency,
      );
    }

    return const ExchangeValidationResult.valid();
  }

  /// Synchronous quick check used to determine if Continue button should be enabled.
  bool isAmountValid({
    required Wallets? fromWallet,
    required Wallets? toWallet,
    required String amountText,
  }) {
    if (fromWallet == null || toWallet == null) return false;
    final fromCode = fromWallet.code?.toUpperCase();
    final toCode = toWallet.code?.toUpperCase();
    if (fromCode != null && toCode != null && fromCode == toCode) return false;

    final amount = double.tryParse(amountText.trim()) ?? 0.0;
    if (amount <= 0) return false;

    final double balance = double.tryParse(fromWallet.balance ?? '') ?? 0.0;
    if (balance > 0 && amount > balance) return false;

    final min = double.tryParse(fromWallet.exchangeLimit?.min ?? '') ?? 0.0;
    final maxRaw = double.tryParse(fromWallet.exchangeLimit?.max ?? '') ?? double.infinity;
    final max = maxRaw <= 0 ? double.infinity : maxRaw;

    return (min <= 0 || amount >= min) && amount <= max;
  }

  /// Calculates percentage fee and total using [MoneyMathHelper].
  ExchangeFeeCalculation calculatePercentageCharge({
    required double amount,
    required double percent,
    int decimals = 8,
  }) {
    final charge = MoneyMathHelper.calculatePercentCharge(
      amount,
      percent,
      decimals: decimals,
    );
    final total = MoneyMathHelper.add(amount, charge, decimals: decimals);
    return ExchangeFeeCalculation(charge: charge, totalAmount: total);
  }

  /// Adds a fixed fee to the amount safely using [MoneyMathHelper].
  ExchangeFeeCalculation calculateTotalWithFixedCharge({
    required double amount,
    required double fixedCharge,
    int decimals = 8,
  }) {
    final total = MoneyMathHelper.add(amount, fixedCharge, decimals: decimals);
    return ExchangeFeeCalculation(charge: fixedCharge, totalAmount: total);
  }

  /// Recomputes fee and total for the Amount step preview.
  /// Handles percentage charge directly; for fixed charge preserves [currentCharge].
  ExchangeFeeCalculation calculateChargeForAmountStep({
    required double amount,
    required String? chargeStr,
    required String? chargeType,
    required double currentCharge,
    int decimals = 8,
  }) {
    final userChargeStr = chargeStr ?? '0';
    final userChargeType = chargeType ?? 'fixed';

    if (userChargeType == 'percentage') {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      return calculatePercentageCharge(
        amount: amount,
        percent: percent,
        decimals: decimals,
      );
    } else {
      return calculateTotalWithFixedCharge(
        amount: amount,
        fixedCharge: currentCharge,
        decimals: decimals,
      );
    }
  }

  /// Calculates maximum spendable balance after deducting the fee.
  double calculateMaxSpendable({
    required double balance,
    required double fee,
    int decimals = 8,
  }) {
    if (balance <= 0) return 0.0;
    final net = MoneyMathHelper.subtract(balance, fee, decimals: decimals);
    return net > 0 ? net : 0.0;
  }

  /// Formats percentage of balance for quick-select chips (e.g. 25%, 50%, 75%, 100%).
  String calculateQuickAmountString({
    required double balance,
    required double percent,
    bool isCrypto = false,
  }) {
    if (balance <= 0) return '0';
    final fraction = balance * percent;
    final decimals = isCrypto ? 8 : 2;
    return fraction.toStringAsFixed(decimals);
  }
}

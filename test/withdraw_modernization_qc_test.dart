import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';

void main() {
  group('Withdraw Destination Card Masking Tests', () {
    test('masks Iranian Sheba correctly', () {
      final account = Accounts(
        methodName: 'Bank Mellat',
        currency: 'IRT',
        method: Method(
          fields: [
            Fields(
              name: 'sheba_number',
              value: 'IR820170000000123456789012',
            ),
          ],
        ),
      );

      final masked = WithdrawDestinationCard.maskAccountNumber(account);
      expect(masked, 'IR82 •••• •••• •••• 9012');
    });

    test('masks 16-digit bank card correctly', () {
      final account = Accounts(
        methodName: 'Bank Melli',
        currency: 'IRT',
        method: Method(
          fields: [
            Fields(
              name: 'card_number',
              value: '6037997123456789',
            ),
          ],
        ),
      );

      final masked = WithdrawDestinationCard.maskAccountNumber(account);
      expect(masked, '•••• •••• •••• 6789');
    });

    test('masks crypto address correctly', () {
      final account = Accounts(
        methodName: 'USDT TRC20',
        currency: 'USDT',
        method: Method(
          fields: [
            Fields(
              name: 'wallet_address',
              value: 'TXyz1234567890abcdef1234567890',
            ),
          ],
        ),
      );

      final masked = WithdrawDestinationCard.maskAccountNumber(account);
      expect(masked.contains('••••'), isTrue);
      expect(masked.startsWith('TXyz12'), isTrue);
      expect(masked.endsWith('7890'), isTrue);
    });

    test('falls back to wallet name when no fields exist', () {
      final account = Accounts(
        methodName: 'Primary Payout',
        currency: 'USD',
        walletName: 'Main Dollar Wallet',
        method: Method(fields: []),
      );

      final masked = WithdrawDestinationCard.maskAccountNumber(account);
      expect(masked, 'Main Dollar Wallet');
    });
  });
}

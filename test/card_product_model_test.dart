import 'package:flutter_test/flutter_test.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_product_model.dart';

void main() {
  test('parses IRR card product response with string decimals', () {
    final model = CardProductModel.fromJson({
      'status': 'success',
      'data': [
        {
          'id': 1,
          'name': 'Ecardo IRR Card',
          'code': 'ecardo-irr',
          'currency': 'IRR',
          'issuer': {
            'id': 4,
            'name': 'Iran Issuer',
            'code': 'iran-issuer',
            'country_code': 'IR',
            'currency': 'IRR',
            'provider_type': 'licensed_bank',
            'network': 'Shetab',
            'capabilities': {'external_payments': true},
            'disclosure': 'Issued by a licensed bank.',
          },
          'funding_mode': 'both',
          'minimum_initial_load': 1000000,
          'maximum_initial_load': 4500000000,
          'creation_fee': '10000.0000',
          'topup_fee': '0.5000',
          'application_fields': [],
          'gateways': [],
          'capabilities': {
            'can_create_virtual': true,
            'can_request_physical': false,
            'can_fund_from_irr_wallet': true,
            'can_fund_from_gateway': true,
          },
        },
      ],
    });

    expect(model.status, 'success');
    expect(model.data, hasLength(1));
    expect(model.data.first.currency, 'IRR');
    expect(model.data.first.issuer?.countryCode, 'IR');
    expect(model.data.first.issuer?.network, 'Shetab');
    expect(model.data.first.issuer?.isExternallyUsable, isTrue);
    expect(model.data.first.maximumInitialLoad, 4500000000);
    expect(model.data.first.creationFee, 10000);
    expect(model.data.first.capabilities?.canFundFromGateway, isTrue);
  });

  test('accepts an empty product list', () {
    final model = CardProductModel.fromJson({
      'status': 'success',
      'data': <dynamic>[],
    });

    expect(model.data, isEmpty);
  });
}

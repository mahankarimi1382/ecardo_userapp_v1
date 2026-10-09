import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:ecardo_user/src/common/services/realistic_catalogs/financial_catalog.dart';
import 'package:ecardo_user/src/common/services/realistic_catalogs/commerce_catalog.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/public_live_rate_source.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_api_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    final demoService = Get.put<DemoAccountService>(DemoAccountService());
    demoService.isDemoMode.value = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('E2E All-Modules Realistic Integration & Free Services Hub', () {
    test('1. Free Public Live Rate Source fetches valid rates with 0 API keys', () async {
      final source = PublicLiveRateSource();
      final rates = await source.fetchRates(currencyCodes: ['USD', 'EUR', 'TRY', 'USDT']);

      expect(rates.isNotEmpty, isTrue);
      expect(rates.containsKey('USD'), isTrue);
      expect(rates['USD']!, greaterThan(0));
      expect(rates.containsKey('EUR'), isTrue);
      expect(rates.containsKey('USDT'), isTrue);
      expect(source.lastEntries.isNotEmpty, isTrue);
      expect(source.lastEntries['USD']?.nameFa, isNotEmpty);
      expect(source.lastEntries['USD']?.unit, 'تومان');
    });

    test('2. Financial Domain: Bill payment, Card Products, and Remittance Corridors', () async {
      final bills = FinancialCatalog.getBillServices();
      expect(bills['status'], isTrue);
      final services = bills['data']['services'] as List;
      expect(services.length, greaterThanOrEqualTo(5));
      expect(services.any((s) => s['operator'] == 'همراه اول (MCI)'), isTrue);
      expect(services.any((s) => s['operator'] == 'ایرانسل (MTN Irancell)'), isTrue);

      final cards = FinancialCatalog.getCardProducts();
      expect(cards['status'], 'success');
      final cardProducts = cards['data']['card_products'] as List;
      expect(cardProducts.length, greaterThanOrEqualTo(3));

      final remit = FinancialCatalog.getRemittanceMethods();
      expect(remit['status'], 'success');
      final corridors = remit['data']['corridors'] as List;
      expect(corridors.any((c) => c['currency'] == 'AED'), isTrue);
      expect(corridors.any((c) => c['currency'] == 'TRY'), isTrue);
    });

    test('3. Financial Domain: Stateful Currency Exchange & Bill Pay Balance Deduction', () async {
      final demoService = DemoAccountService.to;
      final initialUsd = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'USD').balance ?? '0');
      final initialEur = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'EUR').balance ?? '0');

      // Execute exchange: swap 50 USD to EUR at rate 0.92
      final exchangeRes = demoService.handleDemoRequest(
        endpoint: '/user/exchange',
        method: 'POST',
        data: {
          'amount': '50.0',
          'from_wallet': 'USD',
          'to_wallet': 'EUR',
          'rate': '0.92',
        },
      );

      expect(exchangeRes?['status'], 'success');
      final updatedUsd = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'USD').balance ?? '0');
      final updatedEur = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'EUR').balance ?? '0');

      expect(updatedUsd, equals(initialUsd - 50.0));
      expect(updatedEur, equals(initialEur + 46.0));

      // Execute bill pay: 500,000 IRR
      final initialIrr = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'IRR').balance ?? '0');
      final billRes = demoService.handleDemoRequest(
        endpoint: '/user/pay-bill',
        method: 'POST',
        data: {
          'amount': '500000',
          'type': 'قبض برق',
        },
      );
      expect(billRes?['status'], 'success');
      expect(billRes?['data']?['reference_id'], isNotEmpty);
      final updatedIrr = double.parse(demoService.demoWallets.firstWhere((w) => w.code == 'IRR').balance ?? '0');
      expect(updatedIrr, equals(initialIrr - 500000.0));
    });

    test('4. Travel Domain: Hotels, Flights, eSIM, Reservation, and Voucher Issuance', () async {
      final repo = TravelApiRepository();

      // Hotel Search
      final hotels = await repo.searchHotels(TravelHotelSearch(
        city: 'تهران',
        checkInDate: DateTime.now().add(const Duration(days: 1)),
        checkOutDate: DateTime.now().add(const Duration(days: 4)),
        roomCount: 1,
        adultCount: 2,
        childCount: 0,
      ));
      expect(hotels.length, greaterThanOrEqualTo(4));
      expect(hotels.any((h) => h.titleKey.contains('اسپیناس')), isTrue);
      expect(hotels.any((h) => h.titleKey.contains('چراغان')), isTrue);

      // Hotel Details
      final hotelDetail = await repo.getOfferDetails(TravelProductType.hotel, 'htl-esp-01');
      expect(hotelDetail.titleKey, contains('اسپیناس'));
      expect(hotelDetail.metadata['stars'], '5');
      expect(hotelDetail.metadata['city'], 'تهران');

      // Flight Search
      final flights = await repo.searchFlights(const TravelFlightSearch());
      expect(flights.length, greaterThanOrEqualTo(4));
      expect(flights.any((f) => f.titleKey.contains('ماهان')), isTrue);
      expect(flights.any((f) => f.titleKey.contains('ترکیش')), isTrue);

      // eSIM Packages
      final esimList = await repo.getEsimPackages('TR');
      expect(esimList.length, greaterThanOrEqualTo(3));
      expect(esimList.any((e) => e.dataLabel.contains('5 GB')), isTrue);

      // Reservation Creation & Wallet Payment
      final reservation = await repo.createReservation(
        type: TravelProductType.hotel,
        productId: 'htl-esp-01',
        expectedTotal: const TravelMoney(amount: 140, currency: 'USD'),
        idempotencyKey: 'idemp-test-9901',
        bookingDetails: const TravelBookingDetails(roomCount: 1, adultCount: 2),
      );
      expect(reservation.id, isNotEmpty);
      expect(reservation.orderNumber, isNotEmpty);

      final paidOrder = await repo.payReservation(
        reservation: reservation,
        idempotencyKey: 'idemp-test-9901',
      );
      expect(paidOrder.status, equals(TravelOrderStatus.issued));
      expect(paidOrder.details['voucher_number'], isNotEmpty);
    });

    test('5. Commerce Domain: Stocks, Escrow, Loans, and Digital Licenses', () async {
      // Stock markets
      final markets = CommerceCatalog.getStockMarkets();
      expect(markets.length, greaterThanOrEqualTo(2));
      expect(markets.first['symbols'], isNotEmpty);
      final symbols = markets.first['symbols'] as List;
      expect(symbols.any((s) => s['ticker'] == 'AAPL'), isTrue);
      expect(symbols.any((s) => s['ticker'] == 'NVDA'), isTrue);

      // Escrow Deals
      final escrowDeals = CommerceCatalog.getEscrowOrders();
      expect(escrowDeals.length, greaterThanOrEqualTo(2));
      expect(escrowDeals.first['contract_no'], contains('ESC-2026'));

      // Commercial Loans
      final loans = CommerceCatalog.getLoanProducts();
      expect(loans.length, greaterThanOrEqualTo(2));
      expect(loans.first['annual_interest_rate'], isNotNull);

      // Digital Licenses
      final licenses = CommerceCatalog.getLicenseProducts();
      expect(licenses.length, greaterThanOrEqualTo(3));
      expect(licenses.any((l) => l['title'].contains('Windows 11')), isTrue);
    });

    test('6. Identity & CRM: KYC Levels, Support Tickets CRM', () async {
      final demoService = DemoAccountService.to;

      // KYC Levels
      final kycRes = demoService.handleDemoRequest(
        endpoint: '/user/kyc-level/levels',
        method: 'GET',
      );
      expect(kycRes?['status'], 'success');
      expect(kycRes?['data']?['current_level'], 3);

      // Support Tickets
      final ticketRes = demoService.handleDemoRequest(
        endpoint: '/user/ticket',
        method: 'GET',
      );
      expect(ticketRes?['status'], 'success');
      final tickets = ticketRes?['data']?['tickets'] as List;
      expect(tickets.length, greaterThanOrEqualTo(2));

      // Create new ticket
      final createTicketRes = demoService.handleDemoRequest(
        endpoint: '/user/ticket',
        method: 'POST',
        data: {'subject': 'تست اتصال سرویس', 'message': 'پیام تست کیفیت'},
      );
      expect(createTicketRes?['status'], 'success');
    });
  });
}

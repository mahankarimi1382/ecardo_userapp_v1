import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/multi_currency_flip_card.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/wallet_card_carousel.dart';

/// Regression cover for the wallet card (v1.0.128).
///
/// The card shipped in v1.0.127 with two defects a read could not catch:
/// every `EdgeInsets` was non-directional (so the balance row and the action
/// buttons landed on the wrong side under fa/ar), and the flip animation
/// drove a `setState` listener *and* an `AnimatedBuilder`, rebuilding the
/// subtree twice per frame.
///
/// These tests pin the two properties that are easy to silently regress:
/// direction-aware layout, and a single face swap during the flip.
///
/// Persian literals are written as code points so the file stays valid
/// regardless of the encoding an editor or shell rewrites it with.
Wallets _wallet({
  String code = 'USD',
  bool isDefault = false,
  bool isCrypto = false,
}) {
  return Wallets(
    id: 1,
    code: code,
    symbol: r'$',
    balance: '1850.00',
    formattedBalance: '1,850.00',
    accountNo: 'IR820540102680020817909002',
    isDefault: isDefault,
    isCrypto: isCrypto,
  );
}

// Persian UI strings under test.
const String kFaDeposit = 'واریز';
const String kFaExchange = 'تبدیل';
const String kFaTransfer = 'انتقال';
const String kFaBalance = 'موجودی در دسترس';

Widget _host(Widget child, {Locale? locale, TextDirection? direction}) {
  final effective = direction ?? TextDirection.ltr;
  return MaterialApp(
    locale: locale ?? (effective == TextDirection.rtl ? const Locale('fa') : const Locale('en')),
    supportedLocales: const [
      Locale('en'),
      Locale('fa'),
      Locale('tr'),
      Locale('ru'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Directionality(
      textDirection: effective,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  group('MultiCurrencyFlipCard direction', () {
    testWidgets('mirrors the action-button order under RTL', (tester) async {
      await tester.pumpWidget(
        _host(
          MultiCurrencyFlipCard(wallet: _wallet(), height: 196),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      // The faces are 3D-rotated, so the back face is reached by flipping.
      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();

      expect(find.text(kFaDeposit), findsOneWidget);
      expect(find.text(kFaExchange), findsOneWidget);
      expect(find.text(kFaTransfer), findsOneWidget);

      // In RTL the first action (Deposit) must sit on the RIGHT, so its x
      // must be greater than the last action's (Transfer).
      final depositX = tester.getCenter(find.text(kFaDeposit)).dx;
      final transferX = tester.getCenter(find.text(kFaTransfer)).dx;
      expect(
        depositX,
        greaterThan(transferX),
        reason: 'RTL must lay the action row out right-to-left',
      );
    });

    testWidgets('keeps LTR order and English copy by default', (tester) async {
      await tester.pumpWidget(
        _host(MultiCurrencyFlipCard(wallet: _wallet(), height: 196)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('1,850.00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Deposit'), findsOneWidget);
      final depositX = tester.getCenter(find.text('Deposit')).dx;
      final transferX = tester.getCenter(find.text('Transfer')).dx;
      expect(depositX, lessThan(transferX));
    });

    testWidgets('uses the Persian balance caption under RTL', (tester) async {
      await tester.pumpWidget(
        _host(
          MultiCurrencyFlipCard(wallet: _wallet(), height: 196),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(kFaBalance), findsOneWidget);
    });

    testWidgets('localizes every card string for Turkish', (tester) async {
      // tr is LTR but was enabled after the card shipped; without explicit
      // `tr:` arguments the card fell back to English for these labels.
      await tester.pumpWidget(
        _host(
          MultiCurrencyFlipCard(wallet: _wallet(isDefault: true), height: 196),
          locale: const Locale('tr'),
          direction: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kullanılabilir Bakiye'), findsOneWidget);
      expect(find.text('Varsayılan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Yatır'), findsOneWidget);
      expect(find.text('Takas'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('localizes card strings for Russian', (tester) async {
      await tester.pumpWidget(
        _host(
          MultiCurrencyFlipCard(wallet: _wallet(), height: 196),
          locale: const Locale('ru'),
          direction: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Доступный баланс'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Пополнить'), findsOneWidget);
      expect(find.text('Обмен'), findsOneWidget);
      expect(find.text('Перевод'), findsOneWidget);
    });
  });

  group('MultiCurrencyFlipCard flip', () {
    testWidgets('shows exactly one face at any point in the animation',
        (tester) async {
      await tester.pumpWidget(
        _host(MultiCurrencyFlipCard(wallet: _wallet(), height: 196)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('Deposit'), findsNothing);

      // The flip runs 450ms with easeInOutCubic and swaps faces at the
      // halfway point (angle >= pi/2), so step past 225ms. Driven with an
      // explicit settle rather than a wall-clock delay, which would make the
      // assertion fragile on a loaded CI machine.
      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Available Balance'),
        findsNothing,
        reason: 'front must be hidden past the halfway point',
      );

      await tester.pumpAndSettle();
      expect(find.text('Deposit'), findsOneWidget);
      expect(find.text('Available Balance'), findsNothing);
    });

    testWidgets('returns to the front face when flipped back', (tester) async {
      await tester.pumpWidget(
        _host(MultiCurrencyFlipCard(wallet: _wallet(), height: 196)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.flip_camera_android_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Deposit'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.flip_to_front_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('Deposit'), findsNothing);
    });
  });

  group('WalletCardCarousel', () {
    testWidgets('renders a single wallet without a dots indicator',
        (tester) async {
      await tester.pumpWidget(
        _host(WalletCardCarousel(wallets: [_wallet()])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('shows one dot per wallet when paging', (tester) async {
      await tester.pumpWidget(
        _host(
          WalletCardCarousel(
            wallets: [_wallet(code: 'USD'), _wallet(code: 'EUR')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets('renders nothing for an empty wallet list', (tester) async {
      await tester.pumpWidget(
        _host(WalletCardCarousel(wallets: [])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Balance'), findsNothing);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('card is sized from the viewport fraction, not raw screen width',
        (tester) async {
      // The card was sized at 86% of screen width inside an 88% viewport, so
      // it overhung its page slot and was clipped by the carousel's height box.
      // Assert against the carousel's own slot width rather than a guessed
      // constant: the PageView lays its pages out edge to edge, so the slot is
      // 88% of the carousel's own width, not of the test surface.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: WalletCardCarousel(
                  wallets: [_wallet(code: 'USD'), _wallet(code: 'EUR')],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final carouselWidth = tester.getSize(find.byType(WalletCardCarousel)).width;
      final pageViewWidth = tester.getSize(find.byType(PageView)).width;

      // Every built card must fit the slot it is drawn in.
      final cards = find.byType(MultiCurrencyFlipCard);
      expect(cards, findsWidgets);
      for (final element in cards.evaluate()) {
        final cardWidth = element.size!.width;
        expect(
          cardWidth,
          lessThanOrEqualTo(pageViewWidth * 0.88 + 0.5),
          reason: 'card ($cardWidth) must fit its $pageViewWidth page slot',
        );
      }

      // And the slot itself must be the 88% viewport, proving the card is
      // measured from the carousel rather than the screen.
      expect(pageViewWidth, lessThanOrEqualTo(carouselWidth));
      expect(pageViewWidth, closeTo(carouselWidth, 0.5));
    });
  });
}
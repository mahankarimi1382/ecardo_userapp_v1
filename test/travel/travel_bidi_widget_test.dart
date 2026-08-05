import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

void main() {
  testWidgets('TravelBidiText follows the first strong character', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            TravelBidiText('تهران Hotel', key: Key('rtl')),
            TravelBidiText('Hotel تهران', key: Key('ltr')),
          ],
        ),
      ),
    );

    expect(
      tester
          .widget<Directionality>(
            find
                .descendant(
                  of: find.byKey(const Key('rtl')),
                  matching: find.byType(Directionality),
                )
                .first,
          )
          .textDirection,
      TextDirection.rtl,
    );
    expect(
      tester
          .widget<Directionality>(
            find
                .descendant(
                  of: find.byKey(const Key('ltr')),
                  matching: find.byType(Directionality),
                )
                .first,
          )
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('TravelBidiText falls back to ambient direction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: TravelBidiText('12345', key: Key('neutral')),
        ),
      ),
    );

    expect(
      tester
          .widget<Directionality>(
            find
                .descendant(
                  of: find.byKey(const Key('neutral')),
                  matching: find.byType(Directionality),
                )
                .first,
          )
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('backend localized maps follow the selected app language', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Text(
            travelBackendText(context, const {
              'en': 'Tehran Hotel',
              'fa': 'هتل تهران',
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('هتل تهران'), findsOneWidget);
    expect(find.text('Tehran Hotel'), findsNothing);
  });
}

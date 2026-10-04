import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_glass_card.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) {
    if (key == 'site_currency') return 'USD';
    if (key == 'site_currency_decimals') return '2';
    return '1';
  }
}

Widget _wrapWithHarness(
  Widget child, {
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => GetMaterialApp(
      theme: theme ?? ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<SettingsService>(_TestSettingsService());
  });

  tearDown(() {
    Get.reset();
  });

  group('MonogramAvatar Suite', () {
    testWidgets('renders single-word and two-word initials accurately',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const Row(
            children: [
              MonogramAvatar(name: 'Sarah Connor', size: 50),
              MonogramAvatar(name: 'Merchant', size: 50),
              MonogramAvatar(name: 'A', size: 50),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SC'), findsOneWidget);
      expect(find.text('ME'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders verified badge when isVerified is true',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const MonogramAvatar(
            name: 'Ali Reza',
            size: 48,
            isVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides verified badge when isVerified is false',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const MonogramAvatar(
            name: 'John Doe',
            size: 48,
            isVerified: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('fires onTap callback when provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithHarness(
          MonogramAvatar(
            name: 'Agent Smith',
            size: 48,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MonogramAvatar));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders cleanly in dark mode without overflow',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const MonogramAvatar(name: 'Dark User', size: 56),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DU'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('QuickAmountSelector Suite', () {
    testWidgets('populates text field with expected percentage on chip tap',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _wrapWithHarness(
          QuickAmountSelector(
            textController: controller,
            availableBalance: 2000.0,
            isCrypto: false,
            currencyCode: 'USD',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find 50% chip and tap it
      expect(find.text('50%'), findsOneWidget);
      await tester.tap(find.text('50%'));
      await tester.pumpAndSettle();

      expect(controller.text, '1000.00');

      // Tap Max chip
      expect(find.text('Max'), findsOneWidget);
      await tester.tap(find.text('Max'));
      await tester.pumpAndSettle();

      expect(controller.text, '2000.00');
    });

    testWidgets('formats 0 decimals for Rial/Toman', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _wrapWithHarness(
          QuickAmountSelector(
            textController: controller,
            availableBalance: 5000000.0,
            isCrypto: false,
            currencyCode: 'IRT',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('50%'));
      await tester.pumpAndSettle();

      expect(controller.text, '2500000');
    });
  });

  group('Glassmorphic Review Cards Suite', () {
    testWidgets('renders EcardoGlassCard with standard and frosted variants',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const Column(
            children: [
              EcardoGlassCard(
                variant: EcardoGlassVariant.standard,
                child: Text('Review Details'),
              ),
              EcardoGlassCard(
                variant: EcardoGlassVariant.accent,
                child: Text('Accent Details'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Details'), findsOneWidget);
      expect(find.text('Accent Details'), findsOneWidget);
    });
  });

  group('RTL Layout & Directionality Suite', () {
    testWidgets('Monogram avatar renders in Persian RTL correctly',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithHarness(
          const MonogramAvatar(
            name: 'رضا کمالی',
            size: 52,
            isVerified: true,
          ),
          locale: const Locale('fa'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MonogramAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

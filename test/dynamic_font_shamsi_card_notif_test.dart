import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  group('Dynamic Font Family Switching by Locale', () {
    testWidgets('English locale selects Plus Jakarta Sans as primary font',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Localizations.override(
                context: context,
                locale: const Locale('en'),
                child: Builder(
                  builder: (innerContext) {
                    capturedContext = innerContext;
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      final light = LightTheme().lightTheme(capturedContext);
      final dark = DarkTheme().darkTheme(capturedContext);

      expect(light.textTheme.bodyMedium?.fontFamily, equals('Plus Jakarta Sans'));
      expect(light.textTheme.bodyMedium?.fontFamilyFallback, contains('Vazirmatn'));

      expect(dark.textTheme.bodyMedium?.fontFamily, equals('Plus Jakarta Sans'));
      expect(dark.textTheme.bodyMedium?.fontFamilyFallback, contains('Vazirmatn'));
    });

    testWidgets('Persian (fa) locale selects Vazirmatn as primary font',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Localizations.override(
                context: context,
                locale: const Locale('fa'),
                child: Builder(
                  builder: (innerContext) {
                    capturedContext = innerContext;
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      final light = LightTheme().lightTheme(capturedContext);
      final dark = DarkTheme().darkTheme(capturedContext);

      expect(light.textTheme.bodyMedium?.fontFamily, equals('Vazirmatn'));
      expect(light.textTheme.bodyMedium?.fontFamilyFallback, contains('Plus Jakarta Sans'));

      expect(dark.textTheme.bodyMedium?.fontFamily, equals('Vazirmatn'));
      expect(dark.textTheme.bodyMedium?.fontFamilyFallback, contains('Plus Jakarta Sans'));
    });

    testWidgets('Arabic (ar) locale selects Vazirmatn as primary font',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Localizations.override(
                context: context,
                locale: const Locale('ar'),
                child: Builder(
                  builder: (innerContext) {
                    capturedContext = innerContext;
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      final light = LightTheme().lightTheme(capturedContext);
      final dark = DarkTheme().darkTheme(capturedContext);

      expect(light.textTheme.bodyMedium?.fontFamily, equals('Vazirmatn'));
      expect(light.textTheme.bodyMedium?.fontFamilyFallback, contains('Plus Jakarta Sans'));

      expect(dark.textTheme.bodyMedium?.fontFamily, equals('Vazirmatn'));
      expect(dark.textTheme.bodyMedium?.fontFamilyFallback, contains('Plus Jakarta Sans'));
    });
  });

  group('Notification Channels Configuration', () {
    test('NotificationChannels constants and IDs match requirements', () {
      expect(NotificationChannels.primaryId, equals('ecardo_default'));
      expect(NotificationChannels.financialId, equals('ecardo_financial'));
      expect(NotificationChannels.securityId, equals('ecardo_security'));
      expect(NotificationChannels.marketingId, equals('ecardo_marketing'));

      expect(NotificationChannels.securityName, isNotEmpty);
      expect(NotificationChannels.securityDescription, isNotEmpty);
      expect(NotificationChannels.marketingName, isNotEmpty);
      expect(NotificationChannels.marketingDescription, isNotEmpty);
      expect(NotificationChannels.financialName, isNotEmpty);
      expect(NotificationChannels.financialDescription, isNotEmpty);
    });
  });

  group('CommonVirtualCardView RTL Physical Layout Isolation', () {
    testWidgets('Front face is isolated in LTR directionality under RTL parent',
        (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: CommonVirtualCardView(
                    title: 'Test Card',
                    value: '1234 5678 9012 3456',
                    firstLabel: 'Expiry',
                    firstValue: '12/28',
                    secondLabel: 'CVC',
                    secondValue: '888',
                    status: 'active',
                    enableFlip: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Directionality widget inside CommonVirtualCardView
      final directionalityFinders = find.byType(Directionality);
      bool foundLtrIsolation = false;
      for (final element in directionalityFinders.evaluate()) {
        final widget = element.widget as Directionality;
        if (widget.textDirection == TextDirection.ltr) {
          foundLtrIsolation = true;
          break;
        }
      }

      expect(foundLtrIsolation, isTrue,
          reason: 'Card front face must be wrapped in Directionality.ltr');
    });
  });

  group('Shamsi (Jalali) Calendar Formatting in Travel', () {
    test('Jalali month and day formatting handles Persian dates accurately', () {
      final gregorianDate = DateTime(2026, 3, 21);
      final jalali = Jalali.fromDateTime(gregorianDate);

      expect(jalali.year, equals(1405));
      expect(jalali.month, equals(1)); // Farvardin
      expect(jalali.day, equals(1));
      expect(jalali.formatter.mN, equals('فروردین'));

      // Check month lengths: Farvardin has 31 days
      expect(jalali.monthLength, equals(31));

      // Test date conversion roundtrip
      final convertedBack = jalali.toDateTime();
      expect(convertedBack.year, equals(gregorianDate.year));
      expect(convertedBack.month, equals(gregorianDate.month));
      expect(convertedBack.day, equals(gregorianDate.day));
    });
  });
}

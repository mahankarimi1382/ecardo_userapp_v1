import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/visa/models/visa_models.dart';
import 'package:ecardo_user/src/visa/screens/visa_catalog_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(
    Widget child, {
    bool isDark = false,
    Locale locale = const Locale('en'),
  }) {
    return GetMaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: isDark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => Scaffold(body: child),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
  });

  tearDown(() {
    Get.reset();
  });

  group('Visa Service - Models & Deserialization Tests', () {
    test('VisaCatalogItem parses full catalog JSON from live API spec', () {
      final json = {
        'id': 2,
        'country_code': 'AE',
        'country_name': 'United Arab Emirates',
        'country_flag': 'https://flagcdn.com/w80/ae.png',
        'visa_type': 'TOURIST_30D',
        'title': '30-Day UAE Tourist Visa (Dubai)',
        'description': 'Single-entry tourist visa valid for 30 days with travel insurance.',
        'gov_fee': '95.00000000',
        'service_fee': '35.00000000',
        'currency': 'USD',
        'processing_days_min': 2,
        'processing_days_max': 5,
        'needs_biometric': false,
        'appeal_supported': false,
        'max_revisions': 3,
        'is_active': true,
        'refund_policy': {
          'c1_pre_payment': '100% refund',
          'gov_fee_refundable_on_rejection': false,
        },
        'required_docs': [
          {
            'key': 'passport_scan',
            'title': 'Valid Passport Scan',
            'type': 'FILE',
            'instructions': 'At least 6 months validity required.',
            'required': true,
          },
          {
            'key': 'personal_photo',
            'title': 'Passport-size Photo',
            'type': 'FILE',
            'instructions': 'White background without filters.',
            'required': true,
          },
        ],
      };

      final item = VisaCatalogItem.fromJson(json);

      expect(item.id, 2);
      expect(item.countryCode, 'AE');
      expect(item.countryName, 'United Arab Emirates');
      expect(item.visaType, 'TOURIST_30D');
      expect(item.govFee, 95.0);
      expect(item.serviceFee, 35.0);
      expect(item.totalFee, 130.0);
      expect(item.currency, 'USD');
      expect(item.processingDaysMin, 2);
      expect(item.processingDaysMax, 5);
      expect(item.processingTimeLabel, '2 - 5');
      expect(item.needsBiometric, isFalse);
      expect(item.isActive, isTrue);
      expect(item.requiredDocs.length, 2);
      expect(item.requiredDocs[0].key, 'passport_scan');
      expect(item.requiredDocs[0].required, isTrue);
    });

    test('VisaRequestModel parses application status and tracking milestones', () {
      final json = {
        'id': 12,
        'case_no': 'ECV-2026-9812',
        'catalog_id': 2,
        'user_id': 5,
        'country_code': 'AE',
        'country_name': 'United Arab Emirates',
        'status': 'SUBMITTED',
        'service_fee': '35.00000000',
        'gov_fee': '95.00000000',
        'currency': 'USD',
        'is_paid': true,
        'created_at': '2026-10-05T08:00:00Z',
        'applicant_info': {
          'full_name': 'Arshia Vafadar',
          'passport_number': 'A98765432',
          'phone': '+989123456789',
        },
        'events': [
          {
            'id': 1,
            'status': 'SUBMITTED',
            'note': 'Application received and documents queued for consular review.',
            'created_at': '2026-10-05T08:05:00Z',
          },
        ],
        'documents': [
          {
            'id': 101,
            'doc_key': 'passport_scan',
            'file_name': 'passport.jpg',
            'status': 'PENDING',
          },
        ],
      };

      final request = VisaRequestModel.fromJson(json);

      expect(request.id, 12);
      expect(request.caseNo, 'ECV-2026-9812');
      expect(request.countryName, 'United Arab Emirates');
      expect(request.status, 'SUBMITTED');
      expect(request.totalFee, 130.0);
      expect(request.applicantName, 'Arshia Vafadar');
      expect(request.applicantPassport, 'A98765432');
      expect(request.events.length, 1);
      expect(request.documents.length, 1);
      expect(request.documents.first.docKey, 'passport_scan');
    });
  });

  group('Visa Service - VisaCatalogScreen UI Tests', () {
    testWidgets('renders Visa Catalog Screen header, search, and action without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const VisaCatalogScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VisaCatalogScreen), findsOneWidget);
      expect(find.text('Visa & Consular Desk'), findsOneWidget);
    });

    testWidgets('renders properly in Persian locale (RTL) without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const VisaCatalogScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VisaCatalogScreen), findsOneWidget);
      expect(find.text('خدمات ویزا و کنسولی'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Theme without layout overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const VisaCatalogScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VisaCatalogScreen), findsOneWidget);
    });
  });
}

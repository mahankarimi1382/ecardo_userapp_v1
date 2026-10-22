import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/add_new_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/support_ticket_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/add_new_ticket/add_new_ticket.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/support_tickets.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('fa')}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fa')],
      locale: locale,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (MethodCall methodCall) async => true,
        );
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    Get.put<LocaleThemeService>(LocaleThemeService());
  });

  tearDown(() {
    Get.reset();
  });

  group('TicketStatusHelper unit tests', () {
    test('Correct colors according to helpdesk specification', () {
      expect(TicketStatusHelper.color('open'), const Color(0xFF10B981));
      expect(TicketStatusHelper.color('in_progress'), const Color(0xFFF59E0B));
      expect(TicketStatusHelper.color('answered'), const Color(0xFF8B5CF6));
      expect(TicketStatusHelper.color('closed'), const Color(0xFF64748B));
      expect(TicketStatusHelper.color('archived'), const Color(0xFF64748B));
    });

    test('Live pulse flag is only true for in_progress status', () {
      expect(TicketStatusHelper.hasPulse('in_progress'), isTrue);
      expect(TicketStatusHelper.hasPulse('open'), isFalse);
      expect(TicketStatusHelper.hasPulse('answered'), isFalse);
      expect(TicketStatusHelper.hasPulse('closed'), isFalse);
    });

    test('isClosed and canReply logic', () {
      expect(TicketStatusHelper.isClosed(status: 'closed'), isTrue);
      expect(TicketStatusHelper.isClosed(status: 'archived'), isTrue);
      expect(TicketStatusHelper.isClosed(status: 'open'), isFalse);

      expect(TicketStatusHelper.canReply(status: 'open'), isTrue);
      expect(TicketStatusHelper.canReply(status: 'in_progress'), isTrue);
      expect(TicketStatusHelper.canReply(status: 'answered'), isTrue);
      expect(TicketStatusHelper.canReply(status: 'closed'), isFalse);
    });
  });

  group('Tickets model unit tests', () {
    test('Parses department, lastReply, and sender flags correctly', () {
      final ticket = Tickets.fromJson({
        'id': 12,
        'uuid': 'TK-9921',
        'title': 'واریز ریالی اعمال نشد',
        'status': 'in_progress',
        'priority': 'high',
        'department': 'finance',
        'last_reply': 'رسید واریز بررسی شد و در حال ثبت است.',
        'last_reply_by': 'support',
        'last_reply_from_user': false,
      });

      expect(ticket.id, 12);
      expect(ticket.uuid, 'TK-9921');
      expect(ticket.department, 'finance');
      expect(ticket.lastReply, 'رسید واریز بررسی شد و در حال ثبت است.');
      expect(ticket.lastReplyFromUser, isFalse);
    });
  });

  group('AddNewTicketController tests', () {
    test('State initialization and department/priority selection', () {
      final c = Get.put(AddNewTicketController());
      expect(c.selectedDepartment.value, 'finance');
      expect(c.selectedPriority.value, 'low');
      expect(c.titleLength.value, 0);
      expect(c.descriptionLength.value, 0);

      c.selectedDepartment.value = 'technical';
      c.selectedPriority.value = 'high';
      expect(c.selectedDepartment.value, 'technical');
      expect(c.selectedPriority.value, 'high');
    });

    test('Validation fails on empty inputs', () {
      final c = Get.put(AddNewTicketController());
      c.titleController.text = '';
      c.descriptionController.text = '';
      expect(c.validateForm(), isFalse);

      c.titleController.text = 'عنوان تیکت';
      c.descriptionController.text = '';
      expect(c.validateForm(), isFalse);

      c.descriptionController.text = 'شرح تیکت';
      expect(c.validateForm(), isTrue);
    });
  });

  group('SupportTickets & AddNewTicket widget smoke tests', () {
    testWidgets(
      'TicketStatusBadge renders with pulse controller for in_progress',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return TicketStatusBadge(
                  status: 'in_progress',
                  isDark: false,
                  localization: l10n,
                );
              },
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(TicketStatusBadge), findsOneWidget);
      },
    );

    testWidgets(
      'SupportTickets list screen renders empty state and filter chips',
      (tester) async {
        final controller = Get.put(SupportTicketController());
        controller.supportTicketModel.value = SupportTicketModel(
          data: SupportTicketData(
            tickets: [],
            pagination: Pagination(total: 0),
          ),
        );
        controller.isLoading.value = false;
        controller.isInitialDataLoaded.value = true;

        await tester.pumpWidget(_wrap(const SupportTickets()));
        await tester.pumpAndSettle();

        expect(find.byType(SupportTickets), findsOneWidget);
        // Floating action button exists
        expect(find.text('ثبت تیکت جدید'), findsOneWidget);
      },
    );

    testWidgets(
      'AddNewTicket screen renders department and priority selectors',
      (tester) async {
        Get.put(AddNewTicketController());
        await tester.pumpWidget(_wrap(const AddNewTicket()));
        await tester.pumpAndSettle();

        expect(find.byType(AddNewTicket), findsOneWidget);
        expect(find.text('دپارتمان / موضوع'), findsOneWidget);
        expect(find.text('اولویت بررسی'), findsOneWidget);
        expect(find.text('راهنمای دریافت پاسخ سریع‌تر'), findsOneWidget);
        expect(find.text('ثبت و ارسال تیکت'), findsOneWidget);
      },
    );
  });
}

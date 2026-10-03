import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_badge_service.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/notification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/notifications_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/notifications/notifications.dart';

class _TestAppUpdateController extends AppUpdateController {
  _TestAppUpdateController() : super(config: AppUpdateConfig.user);

  bool checkCalled = false;
  bool manualPassed = false;

  @override
  Future<void> checkForUpdate({
    bool showSnackbarWhenUpToDate = true,
    bool manual = true,
  }) async {
    checkCalled = true;
    manualPassed = manual;
  }
}

class _TestNotificationController extends NotificationController {
  @override
  Future<void> fetchNotifications() async {
    isLoading.value = false;
  }

  @override
  Future<void> markAsReadNotification() async {}
}

Widget _buildTestApp({
  required Widget home,
  List<GetPage>? pages,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) => GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: home,
      getPages: pages ??
          [
            GetPage(
              name: BaseRoute.notifications,
              page: () => const Notifications(),
            ),
            GetPage(
              name: BaseRoute.supportTickets,
              page: () => const Scaffold(body: Text('SUPPORT_TICKETS_PAGE')),
            ),
            GetPage(
              name: BaseRoute.transactions,
              page: () => const Scaffold(body: Text('TRANSACTIONS_PAGE')),
            ),
            GetPage(
              name: BaseRoute.kycHistory,
              page: () => const Scaffold(body: Text('KYC_HISTORY_PAGE')),
            ),
            GetPage(
              name: BaseRoute.virtualCard,
              page: () => const Scaffold(body: Text('VIRTUAL_CARD_PAGE')),
            ),
          ],
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestAppUpdateController updateController;
  late _TestNotificationController notifController;
  late NotificationHistoryService historyService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    updateController = Get.put<AppUpdateController>(
      _TestAppUpdateController(),
    ) as _TestAppUpdateController;
    notifController = Get.put<NotificationController>(
      _TestNotificationController(),
    ) as _TestNotificationController;
    historyService = Get.put<NotificationHistoryService>(
      NotificationHistoryService(),
    );
    Get.put<AppBadgeService>(AppBadgeService());
  });

  tearDown(() {
    Get.reset();
  });

  group('NotificationRouter logic & routing destinations', () {
    testWidgets('Ticket / support keywords navigate to BaseRoute.supportTickets',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // By type
      NotificationRouter.route(
        null,
        title: 'New Response',
        message: 'Your ticket has been answered',
        type: 'user_ticket_reply',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.supportTickets);
      expect(find.text('SUPPORT_TICKETS_PAGE'), findsOneWidget);

      // By Persian keyword
      Get.back();
      await tester.pumpAndSettle();
      NotificationRouter.route(
        null,
        title: 'پاسخ به تیکت',
        message: 'کارشناس پاسخ داد',
        type: 'system',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.supportTickets);
    });

    testWidgets('Virtual card keywords navigate to BaseRoute.virtualCard',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // By type
      NotificationRouter.route(
        null,
        title: 'Card Issued',
        message: 'Your virtual card is ready to use',
        type: 'virtual_card',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.virtualCard);
      expect(find.text('VIRTUAL_CARD_PAGE'), findsOneWidget);

      // By Persian keyword
      Get.back();
      await tester.pumpAndSettle();
      NotificationRouter.route(
        null,
        title: 'کارت مجازی',
        message: 'کارت شما صادر شد',
        type: 'general',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.virtualCard);
    });

    testWidgets(
        'Update / version keywords trigger AppUpdateController.checkForUpdate(manual: true)',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      expect(updateController.checkCalled, isFalse);

      // By type
      NotificationRouter.route(
        null,
        title: 'Update Ready',
        message: 'Version 2.0 is now available',
        type: 'app_update',
      );
      await tester.pumpAndSettle();
      expect(updateController.checkCalled, isTrue);
      expect(updateController.manualPassed, isTrue);

      // Reset and test by Persian keyword
      updateController.checkCalled = false;
      updateController.manualPassed = false;
      NotificationRouter.route(
        null,
        title: 'بروزرسانی نسخه جدید',
        message: 'لطفا برنامه را آپدیت کنید',
        type: 'system',
      );
      await tester.pumpAndSettle();
      expect(updateController.checkCalled, isTrue);
      expect(updateController.manualPassed, isTrue);
    });

    testWidgets('KYC / verification keywords navigate to BaseRoute.kycHistory',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // By type
      NotificationRouter.route(
        null,
        title: 'Identity Status',
        message: 'KYC tier upgraded',
        type: 'kyc_action',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.kycHistory);
      expect(find.text('KYC_HISTORY_PAGE'), findsOneWidget);

      // By Persian keyword
      Get.back();
      await tester.pumpAndSettle();
      NotificationRouter.route(
        null,
        title: 'احراز هویت',
        message: 'مدارک شناسایی تایید شد',
        type: 'general',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.kycHistory);
    });

    testWidgets(
        'Transfer / transaction / payment keywords navigate to BaseRoute.transactions',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // By type
      NotificationRouter.route(
        null,
        title: 'Deposit Approved',
        message: 'Your 250 USD deposit is confirmed',
        type: 'user_manual_deposit_approved',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.transactions);
      expect(find.text('TRANSACTIONS_PAGE'), findsOneWidget);

      // By keyword
      Get.back();
      await tester.pumpAndSettle();
      NotificationRouter.route(
        null,
        title: 'واریز وجه',
        message: 'تراکنش با موفقیت ثبت شد',
        type: 'system',
      );
      await tester.pumpAndSettle();
      expect(Get.currentRoute, BaseRoute.transactions);
    });

    testWidgets(
        'Otherwise opens alert bottom sheet with full title and message',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      NotificationRouter.route(
        Get.context,
        title: 'Special Holiday Notice',
        message: 'Our offices will observe normal hours during the upcoming holidays.',
        type: 'general',
      );
      await tester.pumpAndSettle();

      // Bottom sheet should be visible
      expect(find.text('Special Holiday Notice'), findsOneWidget);
      expect(
        find.text(
          'Our offices will observe normal hours during the upcoming holidays.',
        ),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);

      // Close button dismisses the bottom sheet
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Special Holiday Notice'), findsNothing);
    });
  });

  group('Notifications UI Interactivity & Visual Indicators', () {
    testWidgets(
        'Server notifications display unread dot, chevron, and are clickable with InkWell',
        (tester) async {
      // Seed server notifications
      notifController.notificationModel.value = NotificationsModel(
        data: NotificationsData(
          unreadCount: 1,
          notifications: [
            Notificationss(
              id: 101,
              title: 'Support Ticket #42 Resolved',
              message: 'Check the solution in your ticket details.',
              type: 'user_ticket_reply',
              isRead: false,
              createdAt: '2026-03-30 12:00:00',
            ),
          ],
        ),
      );

      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // Verify title is rendered
      expect(find.text('Support Ticket #42 Resolved'), findsOneWidget);

      // Verify chevron arrow is rendered
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);

      // Verify InkWell is wrapping the notification
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);

      // Tapping the server notification navigates to Support Tickets
      await tester.tap(find.text('Support Ticket #42 Resolved'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, BaseRoute.supportTickets);
      expect(find.text('SUPPORT_TICKETS_PAGE'), findsOneWidget);
    });

    testWidgets(
        'Local notifications display unread dot, chevron, and are clickable with InkWell',
        (tester) async {
      // Seed local notification history
      historyService.items.assignAll([
        NotificationHistoryItem(
          id: 'loc-1',
          title: 'Payment Received',
          body: 'You received 50 USD from Alice',
          type: 'financial',
          at: DateTime.now(),
          read: false,
        ),
      ]);

      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // Verify title is rendered
      expect(find.text('Payment Received'), findsOneWidget);

      // Verify chevron arrow is present
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);

      // Tap on local notification
      await tester.tap(find.text('Payment Received'));
      await tester.pumpAndSettle();

      // Verify marked as read
      expect(historyService.items.first.read, isTrue);

      // Verify routed to Transactions
      expect(Get.currentRoute, BaseRoute.transactions);
      expect(find.text('TRANSACTIONS_PAGE'), findsOneWidget);
    });

    testWidgets(
        'General notification tap opens detail bottom sheet to view full long text',
        (tester) async {
      historyService.items.assignAll([
        NotificationHistoryItem(
          id: 'loc-2',
          title: 'System Maintenance Notice',
          body:
              'Scheduled server maintenance will take place tonight between 02:00 and 04:00 UTC. Some services might be temporarily paused.',
          type: 'general',
          at: DateTime.now(),
          read: true,
        ),
      ]);

      await tester.pumpWidget(_buildTestApp(home: const Notifications()));
      await tester.pumpAndSettle();

      // Tap local general notification
      await tester.tap(find.text('System Maintenance Notice'));
      await tester.pumpAndSettle();

      // Full message in bottom sheet
      expect(find.text('Notification Details'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.text(
            'Scheduled server maintenance will take place tonight between 02:00 and 04:00 UTC. Some services might be temporarily paused.',
          ),
        ),
        findsOneWidget,
      );
    });
  });
}

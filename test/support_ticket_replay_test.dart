import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/reply_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/ticket_message_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart';

class _MockReplyTicketController extends ReplyTicketController {
  int fetchCallCount = 0;
  int submitCallCount = 0;
  bool shouldPopulateDataOnFetch = false;
  TicketMessageModel? predefinedModel;

  @override
  Future<void> fetchTicketMessage({required String ticketUid}) async {
    fetchCallCount++;
    if (predefinedModel != null) {
      ticketMessageModel.value = predefinedModel!;
    }
  }

  @override
  Future<void> submitReplayTicket({required String ticketUid}) async {
    submitCallCount++;
  }
}

Widget _wrapWithApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    Get.put<LocaleThemeService>(LocaleThemeService());
  });

  tearDown(() {
    Get.reset();
  });

  group('MultipleImagePickerController & ReplyTicketController unit tests', () {
    test('clearImages clears attached images and resets editing id', () {
      final picker = Get.put(MultipleImagePickerController());
      picker.attachedImages[1] = File('path/to/test1.png');
      picker.attachedImages[2] = File('path/to/test2.png');
      picker.currentEditingId.value = 1;

      expect(picker.attachedImages.length, 2);
      expect(picker.currentEditingId.value, 1);

      picker.clearImages();

      expect(picker.attachedImages.isEmpty, isTrue);
      expect(picker.currentEditingId.value, -1);
    });

    test('clearForm clears text and calls clearImages', () {
      final replyController = Get.put(ReplyTicketController());
      replyController.messageController.text = 'Hello world';
      replyController.controller.attachedImages[1] = File('path/to/file.png');

      expect(replyController.messageController.text, 'Hello world');
      expect(replyController.controller.attachedImages.isNotEmpty, isTrue);

      replyController.clearForm();

      expect(replyController.messageController.text, isEmpty);
      expect(replyController.controller.attachedImages.isEmpty, isTrue);
    });
  });

  group('ReplayTicket Screen Widget Tests', () {
    testWidgets(
        'Critical crash fix: null ticket data renders fallback ticketUid in CommonAppBar without throwing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final mockController = _MockReplyTicketController();
      Get.put<ReplyTicketController>(mockController);
      // Model data is null
      mockController.ticketMessageModel.value = TicketMessageModel();

      await tester.pumpWidget(_wrapWithApp(const ReplayTicket(ticketUid: 'FALLBACK-UID-123')));
      await tester.pumpAndSettle();

      final appBarFinder = find.byType(CommonAppBar);
      expect(appBarFinder, findsOneWidget);
      final CommonAppBar appBar = tester.widget(appBarFinder);
      expect(appBar.title, '#FALLBACK-UID-123');
    });

    testWidgets(
        'Ticket uuid from server takes precedence in CommonAppBar title',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final mockController = _MockReplyTicketController();
      Get.put<ReplyTicketController>(mockController);
      mockController.predefinedModel = TicketMessageModel(
        data: TicketMessageData(
          ticket: Ticket(
            uuid: 'SERVER-UUID-999',
            title: 'Help needed',
            status: 'open',
            canReply: true,
          ),
          messages: [],
        ),
      );

      await tester.pumpWidget(_wrapWithApp(const ReplayTicket(ticketUid: 'FALLBACK-UID-123')));
      await tester.pumpAndSettle();

      final appBarFinder = find.byType(CommonAppBar);
      expect(appBarFinder, findsOneWidget);
      final CommonAppBar appBar = tester.widget(appBarFinder);
      expect(appBar.title, '#SERVER-UUID-999');
    });

    testWidgets(
        'Message bubble sender logic and alignments: user messages align right/trailing with primary color, support messages align left/leading with neutral background',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final mockController = _MockReplyTicketController();
      Get.put<ReplyTicketController>(mockController);
      mockController.predefinedModel = TicketMessageModel(
        data: TicketMessageData(
          ticket: Ticket(
            uuid: 'TKT-001',
            status: 'open',
            message: 'Initial user ticket description',
            canReply: true,
            createdAt: '2026-03-01 10:00:00',
            user: TicketUser(
              name: 'John Doe',
              email: 'john@example.com',
            ),
          ),
          messages: [
            Messages(
              id: 1,
              message: 'Support agent response',
              isAdmin: true,
              user: User(
                name: 'Support Agent Jane',
                email: 'jane@support.ecardo.com',
              ),
              createdAtFormatted: '01 Mar, 2026 10:15 AM',
            ),
            Messages(
              id: 2,
              message: 'User follow-up question',
              isAdmin: false,
              user: User(
                name: 'John Doe',
                email: 'john@example.com',
              ),
              createdAtFormatted: '01 Mar, 2026 10:20 AM',
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrapWithApp(const ReplayTicket(ticketUid: 'TKT-001')));
      await tester.pumpAndSettle();

      // Verify all 3 messages rendered
      expect(find.text('Initial user ticket description'), findsOneWidget);
      expect(find.text('Support agent response'), findsOneWidget);
      expect(find.text('User follow-up question'), findsOneWidget);

      // Verify Support Agent details ARE shown for admin message
      expect(find.text('Support Agent Jane'), findsOneWidget);
      expect(find.text('jane@support.ecardo.com'), findsOneWidget);

      // Find the containers for each message
      // 1. Initial user ticket bubble:
      final userTicketText = tester.widget<Text>(find.text('Initial user ticket description'));
      expect(userTicketText.style?.color, AppColors.white);

      // 2. Admin bubble:
      final adminText = tester.widget<Text>(find.text('Support agent response'));
      expect(adminText.style?.color, AppColors.lightTextPrimary.withValues(alpha: 0.80));

      // 3. User follow up bubble:
      final userFollowUpText = tester.widget<Text>(find.text('User follow-up question'));
      expect(userFollowUpText.style?.color, AppColors.white);

      // Verify Row alignments
      // The initial user ticket bubble and follow-up bubble use MainAxisAlignment.end
      // The admin bubble uses MainAxisAlignment.start
      final rowWidgets = tester.widgetList<Row>(find.byType(Row)).toList();

      final bubbleRows = rowWidgets.where((row) =>
          row.crossAxisAlignment == CrossAxisAlignment.start &&
          (row.mainAxisAlignment == MainAxisAlignment.start ||
           row.mainAxisAlignment == MainAxisAlignment.end) &&
          row.children.any((c) => c is Flexible)).toList();

      expect(bubbleRows.length, 3);
      // First is initial user ticket (isMe: true -> MainAxisAlignment.end)
      expect(bubbleRows[0].mainAxisAlignment, MainAxisAlignment.end);
      // Second is admin message (isAdmin: true -> isMe: false -> MainAxisAlignment.start)
      expect(bubbleRows[1].mainAxisAlignment, MainAxisAlignment.start);
      // Third is user message (isAdmin: false -> isMe: true -> MainAxisAlignment.end)
      expect(bubbleRows[2].mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets(
        'Sending message clears text, clears attached images via clearImages(), and refetches conversation',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final mockController = _MockReplyTicketController();
      Get.put<ReplyTicketController>(mockController);
      mockController.predefinedModel = TicketMessageModel(
        data: TicketMessageData(
          ticket: Ticket(
            uuid: 'TKT-002',
            status: 'open',
            canReply: true,
          ),
          messages: [],
        ),
      );

      await tester.pumpWidget(_wrapWithApp(const ReplayTicket(ticketUid: 'TKT-002')));
      await tester.pumpAndSettle();

      final initialFetchCount = mockController.fetchCallCount;

      // Type a message
      mockController.messageController.text = 'This is a test message to support';
      // Attach a mock image to the image picker controller
      mockController.controller.attachedImages[99] = File('path/to/img.png');
      expect(mockController.controller.attachedImages.isNotEmpty, isTrue);

      // Find send button (CommonSolidSendIcon image or its InkWell parent)
      final sendButtonFinder = find.byWidgetPredicate(
        (widget) => widget is InkWell && widget.onTap != null,
      );
      expect(sendButtonFinder, findsWidgets);

      // Tap send button
      await tester.tap(sendButtonFinder.last);
      await tester.pumpAndSettle();

      // Verification:
      // 1. Submit was called
      expect(mockController.submitCallCount, 1);
      // 2. Message controller cleared
      expect(mockController.messageController.text, isEmpty);
      // 3. Images cleared via controller.controller.clearImages()
      expect(mockController.controller.attachedImages.isEmpty, isTrue);
      // 4. Conversation refetched
      expect(mockController.fetchCallCount, greaterThan(initialFetchCount));
    });
  });
}

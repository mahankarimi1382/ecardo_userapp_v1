import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/controller/verify_passcode_controller.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class _MockVerifyPasscodeController extends GetxController
    implements VerifyPasscodeController {
  @override
  final RxBool isPasscodeVerifyLoading = false.obs;
  @override
  final RxBool isPasscodeFocused = false.obs;
  @override
  final FocusNode passcodeFocusNode = FocusNode();
  @override
  final TextEditingController passcodeController = TextEditingController();
  @override
  AppLocalizations? get localization => null;

  bool submitCalled = false;
  bool returnSuccess = true;

  @override
  Future<bool> submitPasscodeVerify() async {
    submitCalled = true;
    return returnSuccess;
  }
}

void main() {
  setUp(() {
    Get.reset();
  });

  Widget wrapWithTheme({required Widget child, bool isDark = false}) {
    return ScreenUtilInit(
      designSize: const Size(376, 812),
      builder: (context, _) => GetMaterialApp(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(body: child),
      ),
    );
  }

  group('VerifyPasscodeBottomSheet Modernization Tests', () {
    testWidgets(
      'renders visual 4-dot indicator and numeric keypad in Light Mode',
      (tester) async {
        final mockController = _MockVerifyPasscodeController();
        Get.put<VerifyPasscodeController>(mockController);

        await tester.pumpWidget(
          wrapWithTheme(child: const VerifyPasscodeBottomSheet()),
        );
        await tester.pumpAndSettle();

        // Check header and indicator
        expect(find.byType(VisualPinDotsIndicator), findsOneWidget);
        expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

        // Check digits 0 to 9 are rendered on the keypad
        for (int i = 0; i <= 9; i++) {
          expect(find.text('$i'), findsOneWidget);
        }
        expect(find.text('C'), findsOneWidget); // Clear button
        expect(
          find.byIcon(Icons.backspace_outlined),
          findsOneWidget,
        ); // Backspace button
      },
    );

    testWidgets(
      'entering digits updates controller text and triggers auto-submit on 4th digit',
      (tester) async {
        final mockController = _MockVerifyPasscodeController();
        Get.put<VerifyPasscodeController>(mockController);

        await tester.pumpWidget(
          wrapWithTheme(child: const VerifyPasscodeBottomSheet()),
        );
        await tester.pumpAndSettle();

        // Tap 9, 0, 2
        await tester.tap(find.text('9'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();

        expect(mockController.passcodeController.text, '902');
        expect(mockController.submitCalled, isFalse);

        // Tap 3 -> 4th digit triggers auto-submit
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(mockController.passcodeController.text, '9023');
        expect(mockController.submitCalled, isTrue);
      },
    );

    testWidgets('backspace and clear buttons update pin state correctly', (
      tester,
    ) async {
      final mockController = _MockVerifyPasscodeController();
      Get.put<VerifyPasscodeController>(mockController);

      await tester.pumpWidget(
        wrapWithTheme(child: const VerifyPasscodeBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Tap 1, 2, 3
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(mockController.passcodeController.text, '123');

      // Tap backspace -> becomes '12'
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(mockController.passcodeController.text, '12');

      // Tap Clear 'C' -> becomes empty
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(mockController.passcodeController.text, '');
    });
  });
}

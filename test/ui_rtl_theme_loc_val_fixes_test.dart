import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_swipe_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_receiver_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/swipe_to_confirm_slider.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';

class _DummyNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestRemittanceController extends RemittanceController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // TASK-UI-01: THEME WCAG CONTRAST
  // =========================================================================
  group('TASK-UI-01: LightTheme WCAG AA Contrast Fix', () {
    testWidgets('onSecondary is deepBlack (#161614) for WCAG 2.2 AA compliance against teal',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      final theme = LightTheme().lightTheme(capturedContext);
      expect(theme.colorScheme.secondary, equals(AppColors.lightSecondary)); // #00BFA6
      expect(theme.colorScheme.onSecondary, equals(AppColors.deepBlack)); // #161614
      expect(theme.colorScheme.onSecondary, isNot(equals(AppColors.white)));
    });
  });

  // =========================================================================
  // TASK-LOC-01: ARABIC LOCALIZATION FALLBACK
  // =========================================================================
  group('TASK-LOC-01: Arabic Localization Fallback to English', () {
    testWidgets('l10nPick falls back to English when Arabic string is absent',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Localizations.override(
                context: context,
                locale: const Locale('ar'),
                child: Builder(
                  builder: (innerContext) {
                    final result = l10nPick(
                      innerContext,
                      en: 'English Text',
                      fa: 'متن فارسی',
                      ar: null, // absent Arabic translation
                    );
                    return Text(result);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('English Text'), findsOneWidget);
      expect(find.text('متن فارسی'), findsNothing);
    });

    testWidgets('l10nPick uses Arabic when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Localizations.override(
                context: context,
                locale: const Locale('ar'),
                child: Builder(
                  builder: (innerContext) {
                    final result = l10nPick(
                      innerContext,
                      en: 'English Text',
                      fa: 'متن فارسی',
                      ar: 'نص عربي',
                    );
                    return Text(result);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('نص عربي'), findsOneWidget);
    });
  });

  // =========================================================================
  // TASK-VAL-01: CLIENT-SIDE SHEBA & DEBIT CARD VALIDATION
  // =========================================================================
  group('TASK-VAL-01: Sheba and 16-Digit Card Validation', () {
    test('Iranian Sheba validation tests', () {
      // Valid Sheba (26 chars: IR + 24 digits)
      expect(
        RemittanceReceiverSection.validateSheba('IR820170000000123456789012'),
        isNull,
      );
      // Valid Sheba with spaces
      expect(
        RemittanceReceiverSection.validateSheba('IR82 0170 0000 0012 3456 7890 12'),
        isNull,
      );
      // Valid lowercase ir
      expect(
        RemittanceReceiverSection.validateSheba('ir820170000000123456789012'),
        isNull,
      );

      // Invalid: missing IR
      expect(
        RemittanceReceiverSection.validateSheba('820170000000123456789012'),
        contains('must start with IR'),
      );
      // Invalid: too short (25 chars)
      expect(
        RemittanceReceiverSection.validateSheba('IR82017000000012345678901'),
        contains('26 characters'),
      );
      // Invalid: too long (27 chars)
      expect(
        RemittanceReceiverSection.validateSheba('IR8201700000001234567890123'),
        contains('26 characters'),
      );
      // Invalid: non-digit characters in digits part
      expect(
        RemittanceReceiverSection.validateSheba('IR82017000000012345678901A'),
        contains('only 24 digits after IR'),
      );
    });

    test('Luhn checksum algorithm tests', () {
      // Standard valid cards
      expect(RemittanceReceiverSection.isValidLuhn('4532015112843211'), isTrue);
      expect(RemittanceReceiverSection.isValidLuhn('4000000000000002'), isTrue);
      // Invalid Luhn
      expect(RemittanceReceiverSection.isValidLuhn('4532015112843218'), isFalse);
      // Wrong length
      expect(RemittanceReceiverSection.isValidLuhn('12345'), isFalse);
    });

    test('16-digit debit card validation tests', () {
      // Valid 16-digit card with valid Luhn
      expect(
        RemittanceReceiverSection.validateCardNumber('4532015112843211'),
        isNull,
      );
      // Valid with spaces and dashes
      expect(
        RemittanceReceiverSection.validateCardNumber('4532-0151-1284-3211'),
        isNull,
      );
      // Too short
      expect(
        RemittanceReceiverSection.validateCardNumber('453201511284321'),
        contains('16 digits'),
      );
      // Non-digits
      expect(
        RemittanceReceiverSection.validateCardNumber('453201511284321A'),
        contains('digits only'),
      );
      // Invalid checksum
      expect(
        RemittanceReceiverSection.validateCardNumber('4532015112843218'),
        contains('checksum'),
      );
    });

    testWidgets('validate returns false when Sheba is invalid', (tester) async {
      Get.testMode = true;
      if (!Get.isRegistered<NetworkService>()) {
        Get.put<NetworkService>(_DummyNetworkService());
      }
      final controller = _TestRemittanceController();
      controller.receiverNameController.text = 'Ali Rezaei';
      controller.receiverPhoneController.text = '+989121234567';
      controller.selectedReceiverCountry.value = 'IR';
      controller.receiverShabaController.text = 'IR123'; // Invalid Sheba

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isValid = RemittanceReceiverSection.validate(context, controller);
              return Text('valid: $isValid');
            },
          ),
        ),
      );

      expect(find.text('valid: false'), findsOneWidget);
    });

    testWidgets('validate returns false when Card is invalid', (tester) async {
      Get.testMode = true;
      if (!Get.isRegistered<NetworkService>()) {
        Get.put<NetworkService>(_DummyNetworkService());
      }
      final controller = _TestRemittanceController();
      controller.receiverNameController.text = 'Ali Rezaei';
      controller.receiverPhoneController.text = '+989121234567';
      controller.selectedReceiverCountry.value = 'IR';
      controller.receiverCardNumberController.text = '1234'; // Invalid Card

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isValid = RemittanceReceiverSection.validate(context, controller);
              return Text('valid: $isValid');
            },
          ),
        ),
      );

      expect(find.text('valid: false'), findsOneWidget);
    });

    testWidgets('validate returns true when Sheba and Card are valid', (tester) async {
      Get.testMode = true;
      if (!Get.isRegistered<NetworkService>()) {
        Get.put<NetworkService>(_DummyNetworkService());
      }
      final controller = _TestRemittanceController();
      controller.receiverNameController.text = 'Ali Rezaei';
      controller.receiverPhoneController.text = '+989121234567';
      controller.selectedReceiverCountry.value = 'IR';
      controller.receiverShabaController.text = 'IR820170000000123456789012';
      controller.receiverCardNumberController.text = '4532015112843211';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isValid = RemittanceReceiverSection.validate(context, controller);
              return Text('valid: $isValid');
            },
          ),
        ),
      );

      expect(find.text('valid: true'), findsOneWidget);
    });
  });

  // =========================================================================
  // TASK-UI-02: MASKING ACCOUNT NUMBERS IN RECEIPTS
  // =========================================================================
  group('TASK-UI-02: WithdrawDestinationCard.maskAccountNumber', () {
    test('masks Iranian Sheba string properly', () {
      final masked = WithdrawDestinationCard.maskAccountNumber('IR820170000000123456789012');
      expect(masked, equals('IR82 •••• •••• •••• 9012'));
    });

    test('masks 16-digit card string properly', () {
      final masked = WithdrawDestinationCard.maskAccountNumber('6037991234567890');
      expect(masked, equals('•••• •••• •••• 7890'));
    });

    test('masks general account string properly', () {
      final masked = WithdrawDestinationCard.maskAccountNumber('123456789');
      expect(masked, equals('12•• •••• 789'));
    });

    test('handles empty and null gracefully', () {
      expect(WithdrawDestinationCard.maskAccountNumber(''), equals(''));
      expect(WithdrawDestinationCard.maskAccountNumber(null), equals(''));
    });
  });

  // =========================================================================
  // TASK-UI-01: RTL SLIDER TESTS (EcardoSwipeButton & SwipeToConfirmSlider)
  // =========================================================================
  group('TASK-UI-01: RTL Swipe Slider Tests', () {
    testWidgets('EcardoSwipeButton works in RTL (Persian/Arabic) mode', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 100,
                  child: EcardoSwipeButton(
                    text: 'تایید انتقال',
                    threshold: 0.8,
                    animateShimmer: false,
                    onSwipeComplete: () => completed = true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // In RTL, thumb arrow points left (Icons.arrow_back_rounded)
      final thumbFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(thumbFinder, findsOneWidget);
      expect(find.text('تایید انتقال'), findsOneWidget);

      // Drag 280px to the left (negative x in screen coords) to swipe in RTL
      await tester.drag(thumbFinder, const Offset(-280, 0));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('SwipeToConfirmSlider works in RTL (Persian/Arabic) mode', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 100,
                  child: SwipeToConfirmSlider(
                    text: 'تایید نهایی',
                    onConfirmed: () => confirmed = true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // In RTL, prompt chevron points left and thumb arrow points left
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      final thumbFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(thumbFinder, findsOneWidget);
      expect(find.text('تایید نهایی'), findsOneWidget);

      // Drag 280px to the left in RTL mode
      await tester.drag(thumbFinder, const Offset(-280, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('EcardoSwipeButton in LTR continues to swipe left-to-right', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 100,
                  child: EcardoSwipeButton(
                    text: 'Swipe to Confirm',
                    threshold: 0.8,
                    animateShimmer: false,
                    onSwipeComplete: () => completed = true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // In LTR, thumb arrow points right (Icons.arrow_forward_rounded)
      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(thumbFinder, findsOneWidget);

      // Drag 280px to the right
      await tester.drag(thumbFinder, const Offset(280, 0));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });
}

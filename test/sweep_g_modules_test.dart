import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referral_model.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/referral_node.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme({
    required Widget child,
    Brightness brightness = Brightness.light,
    Size surfaceSize = const Size(400, 800),
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          useMaterial3: true,
          colorScheme: brightness == Brightness.dark
              ? const ColorScheme.dark(
                  primary: AppColors.mainSoftBlue,
                  surface: AppColors.darkSurface,
                )
              : const ColorScheme.light(
                  primary: AppColors.deepBlack,
                  surface: AppColors.lightBackground,
                ),
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: surfaceSize.width,
              height: surfaceSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. COMMON VIRTUAL CARD VIEW TESTS
  // =========================================================================
  group('CommonVirtualCardView Creative & Token Tests', () {
    testWidgets('renders realistic card visual with masked PAN and EMV chip', (tester) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrapWithTheme(
            brightness: brightness,
            child: const CommonVirtualCardView(
              title: 'Platinum Business',
              value: '•••• •••• •••• 4242',
              firstLabel: 'EXPIRY',
              firstValue: '12/28',
              secondLabel: 'CVC',
              secondValue: '888',
              status: 'active',
              canReveal: true,
              isRevealed: false,
              network: 'Visa',
            ),
          ),
        );

        expect(find.text('Platinum Business'), findsOneWidget);
        expect(find.text('•••• •••• •••• 4242'), findsOneWidget);
        expect(find.text('EXPIRY'), findsOneWidget);
        expect(find.text('12/28'), findsOneWidget);
        expect(find.text('CVC'), findsOneWidget);
        expect(find.text('888'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
      }
    });

    testWidgets('tap on PAN reveal eye icon triggers onReveal callback', (tester) async {
      bool revealed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: CommonVirtualCardView(
            title: 'Platinum Business',
            value: '•••• •••• •••• 4242',
            firstLabel: 'EXPIRY',
            firstValue: '12/28',
            secondLabel: 'CVC',
            secondValue: '888',
            status: 'active',
            canReveal: true,
            isRevealed: false,
            onReveal: () => revealed = true,
          ),
        ),
      );

      final eyeFinder = find.byType(InkWell);
      expect(eyeFinder, findsOneWidget);
      await tester.tap(eyeFinder);
      await tester.pumpAndSettle();

      expect(revealed, isTrue);
    });

    testWidgets('renders frosted-glass freeze overlay when card is frozen', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          child: const CommonVirtualCardView(
            title: 'Travel Card',
            value: '•••• •••• •••• 9999',
            firstLabel: 'BALANCE',
            firstValue: '1,500 USD',
            secondLabel: 'CURRENCY',
            secondValue: 'USD',
            status: 'frozen',
            isFrozen: true,
          ),
        ),
      );

      expect(find.text('CARD FROZEN'), findsOneWidget);
      expect(find.text('Frozen'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  // =========================================================================
  // 2. REFERRAL NODE TESTS
  // =========================================================================
  group('ReferralNode Tests', () {
    testWidgets('renders node with name and fallback monogram in light and dark mode', (tester) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrapWithTheme(
            brightness: brightness,
            child: const ReferralNode(
              name: 'Alexander Hamilton',
              avatarUrl: '',
              isRoot: true,
            ),
          ),
        );

        expect(find.text('Alexander Hamilton'), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      }
    });
  });

  // =========================================================================
  // 3. REFERRAL MODEL SERIALIZATION TESTS
  // =========================================================================
  group('ReferralModel Unit Tests', () {
    test('parses referral model with rules and rewards amount', () {
      final model = ReferralModel.fromJson({
        'status': 'success',
        'message': 'Loaded successfully',
        'data': {
          'amount': '50.00',
          'code': 'ECAR-VIP-777',
          'joined_text': 'Invited 12 friends so far',
          'is_shown_referral_rules': true,
          'rules': [
            {'icon': 'tick', 'rule': 'Friend registers with your invite code'},
            {'icon': 'tick', 'rule': 'Friend completes tier 1 KYC verification'},
            {'icon': 'close', 'rule': 'Duplicate account registrations not allowed'},
          ],
        },
      });

      expect(model.status, 'success');
      expect(model.data?.amount, '50.00');
      expect(model.data?.code, 'ECAR-VIP-777');
      expect(model.data?.rules, hasLength(3));
      expect(model.data?.rules?.first.icon, 'tick');
      expect(model.data?.rules?.last.icon, 'close');
    });
  });
}

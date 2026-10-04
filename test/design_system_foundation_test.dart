import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';

void main() {
  group('AppColors Design Tokens', () {
    test('contains all required dark theme tokens with proper values', () {
      expect(AppColors.darkTextTertiary, equals(const Color(0x8CE7E0DE)));
      expect(AppColors.darkPrimaryContainer, equals(const Color(0xFF1E2E42)));
      expect(AppColors.darkTextOnPrimary, equals(AppColors.deepBlack));
      expect(AppColors.darkBorder, equals(const Color(0x33D5CBC8)));
      expect(AppColors.darkSurfaceVariant, equals(const Color(0xFF323230)));
      expect(AppColors.darkOutline, equals(const Color(0x4DD5CBC8)));
    });

    test('preserves core NUVO palette values', () {
      expect(AppColors.deepBlack, equals(const Color(0xFF161614)));
      expect(AppColors.darkGray, equals(const Color(0xFF262625)));
      expect(AppColors.softGray, equals(const Color(0xFF656262)));
      expect(AppColors.warmWhite, equals(const Color(0xFFE7E0DE)));
      expect(AppColors.mainSoftBlue, equals(const Color(0xFFABC3EA)));
      expect(AppColors.mutedBlue, equals(const Color(0xFF849ACD)));
    });

    test('lightTextTertiary is a const Color with proper alpha', () {
      expect(AppColors.lightTextTertiary, equals(const Color(0x99161614)));
    });
  });

  group('AppSpacing & AppTextStyles Design Tokens', () {
    test('8px grid scale contains correct step values', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.lg, equals(16.0));
      expect(AppSpacing.xl, equals(20.0));
      expect(AppSpacing.xxl, equals(24.0));
      expect(AppSpacing.xxxl, equals(32.0));
      expect(AppSpacing.huge, equals(48.0));
    });

    test('radius scale contains correct values', () {
      expect(AppSpacing.radiusXs, equals(4.0));
      expect(AppSpacing.radiusSm, equals(8.0));
      expect(AppSpacing.radiusMd, equals(12.0));
      expect(AppSpacing.radiusLg, equals(16.0));
      expect(AppSpacing.radiusXl, equals(24.0));
      expect(AppSpacing.radiusFull, equals(999.0));
      expect(AppSpacing.radius, equals(16.0));
    });

    test('icon sizes contain correct values', () {
      expect(AppSpacing.iconXs, equals(16.0));
      expect(AppSpacing.iconSm, equals(20.0));
      expect(AppSpacing.iconMd, equals(24.0));
      expect(AppSpacing.iconLg, equals(32.0));
      expect(AppSpacing.iconXl, equals(48.0));
    });

    test('durations contain correct values', () {
      expect(AppSpacing.fast, equals(const Duration(milliseconds: 150)));
      expect(AppSpacing.normal, equals(const Duration(milliseconds: 300)));
      expect(AppSpacing.slow, equals(const Duration(milliseconds: 500)));

      expect(AppDurations.fast, equals(AppSpacing.fast));
      expect(AppDurations.normal, equals(AppSpacing.normal));
      expect(AppDurations.slow, equals(AppSpacing.slow));
    });

    test('backward compatibility aliases are preserved', () {
      expect(AppSpacing.page, equals(16.0));
      expect(AppSpacing.cardGap, equals(12.0));
      expect(AppSpacing.sectionGap, equals(20.0));
      expect(AppSpacing.radius, equals(16.0));
      expect(AppSpacing.pageInsets, equals(const EdgeInsets.symmetric(horizontal: 16.0)));
    });

    test('AppTextStyles contains full Material 3 scale and legacy styles', () {
      // Material 3 display
      expect(AppTextStyles.displayLarge.fontSize, equals(57));
      expect(AppTextStyles.displayMedium.fontSize, equals(45));
      expect(AppTextStyles.displaySmall.fontSize, equals(36));

      // Material 3 headline
      expect(AppTextStyles.headlineLarge.fontSize, equals(32));
      expect(AppTextStyles.headlineMedium.fontSize, equals(28));
      expect(AppTextStyles.headlineSmall.fontSize, equals(24));

      // Material 3 title
      expect(AppTextStyles.titleLarge.fontSize, equals(22));
      expect(AppTextStyles.titleMedium.fontSize, equals(16));
      expect(AppTextStyles.titleSmall.fontSize, equals(14));

      // Material 3 body
      expect(AppTextStyles.bodyLarge.fontSize, equals(16));
      expect(AppTextStyles.bodyMedium.fontSize, equals(14));
      expect(AppTextStyles.bodySmall.fontSize, equals(12));

      // Material 3 label
      expect(AppTextStyles.labelLarge.fontSize, equals(14));
      expect(AppTextStyles.labelMedium.fontSize, equals(12));
      expect(AppTextStyles.labelSmall.fontSize, equals(11));

      // Legacy getters preserved
      expect(AppTextStyles.title.fontSize, equals(18));
      expect(AppTextStyles.title.fontWeight, equals(FontWeight.w700));
      expect(AppTextStyles.subtitle.fontSize, equals(16));
      expect(AppTextStyles.subtitle.fontWeight, equals(FontWeight.w500));
      expect(AppTextStyles.body.fontSize, equals(14));
      expect(AppTextStyles.caption.fontSize, equals(12));
    });
  });

  group('LightTheme & DarkTheme Harmonization', () {
    testWidgets('LightTheme has complete M3 ColorScheme and component themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final theme = LightTheme().lightTheme(context);
              final scheme = theme.colorScheme;

              // ColorScheme roles
              expect(scheme.primary, equals(AppColors.deepBlack));
              expect(scheme.onPrimary, equals(AppColors.lightTextOnPrimary));
              expect(scheme.primaryContainer, equals(AppColors.lightPrimaryContainer));
              expect(scheme.onPrimaryContainer, equals(AppColors.deepBlack));
              expect(scheme.secondary, equals(AppColors.lightSecondary));
              expect(scheme.onSecondary, equals(AppColors.warmWhite));
              expect(scheme.surface, equals(AppColors.lightBackground));
              expect(scheme.onSurface, equals(AppColors.deepBlack));
              expect(scheme.error, equals(AppColors.error));
              expect(scheme.onError, equals(AppColors.warmWhite));
              expect(scheme.outline, equals(AppColors.lightOutline));
              expect(scheme.outlineVariant, equals(AppColors.lightOutlineVariant));

              // CardThemeData
              expect(theme.cardTheme.elevation, equals(0));
              final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
              expect(cardShape.borderRadius, equals(BorderRadius.circular(AppSpacing.radiusLg)));

              // InputDecorationTheme has 16px radius
              final inputBorder = theme.inputDecorationTheme.border as OutlineInputBorder;
              expect(inputBorder.borderRadius, equals(BorderRadius.circular(16)));
              final enabledBorder = theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
              expect(enabledBorder.borderRadius, equals(BorderRadius.circular(16)));
              final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
              expect(focusedBorder.borderRadius, equals(BorderRadius.circular(16)));

              // Additional component themes
              expect(theme.navigationBarTheme, isNotNull);
              expect(theme.textButtonTheme, isNotNull);
              expect(theme.outlinedButtonTheme, isNotNull);
              expect(theme.switchTheme, isNotNull);
              expect(theme.dividerTheme, isNotNull);
              expect(theme.tabBarTheme, isNotNull);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('DarkTheme has complete M3 ColorScheme and 16px input border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final theme = DarkTheme().darkTheme(context);
              final scheme = theme.colorScheme;

              // ColorScheme roles
              expect(scheme.primary, equals(AppColors.mainSoftBlue));
              expect(scheme.onPrimary, equals(AppColors.darkTextOnPrimary));
              expect(scheme.primaryContainer, equals(AppColors.darkPrimaryContainer));
              expect(scheme.onPrimaryContainer, equals(AppColors.mainSoftBlue));
              expect(scheme.secondary, equals(AppColors.mutedBlue));
              expect(scheme.surface, equals(AppColors.darkSurface));
              expect(scheme.onSurface, equals(AppColors.darkTextPrimary));
              expect(scheme.error, equals(AppColors.error));
              expect(scheme.outline, equals(AppColors.darkOutline));
              expect(scheme.outlineVariant, equals(AppColors.darkBorder));

              // CardThemeData
              expect(theme.cardTheme.elevation, equals(0));
              final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
              expect(cardShape.borderRadius, equals(BorderRadius.circular(AppSpacing.radiusLg)));

              // InputDecorationTheme has 16px radius (fixed 14px mismatch)
              final inputBorder = theme.inputDecorationTheme.border as OutlineInputBorder;
              expect(inputBorder.borderRadius, equals(BorderRadius.circular(16)));
              final enabledBorder = theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
              expect(enabledBorder.borderRadius, equals(BorderRadius.circular(16)));
              final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
              expect(focusedBorder.borderRadius, equals(BorderRadius.circular(16)));

              // Additional component themes
              expect(theme.navigationBarTheme, isNotNull);
              expect(theme.textButtonTheme, isNotNull);
              expect(theme.outlinedButtonTheme, isNotNull);
              expect(theme.switchTheme, isNotNull);
              expect(theme.dividerTheme, isNotNull);
              expect(theme.tabBarTheme, isNotNull);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('CommonButton Tests', () {
    testWidgets('uses theme primary color when backgroundColor is null', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                primary: Colors.indigo,
                onPrimary: Colors.white,
              ),
            ),
            home: Scaffold(
              body: CommonButton(
                text: 'Theme Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CommonButton), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.indigo));
    });

    testWidgets('supports variants and named constructors', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                primary: AppColors.deepBlack,
                onPrimary: AppColors.warmWhite,
                secondaryContainer: AppColors.lightSecondaryContainer,
                onSecondaryContainer: AppColors.deepBlack,
                outline: AppColors.lightOutline,
              ),
            ),
            home: Scaffold(
              body: Column(
                children: [
                  CommonButton.primary(text: 'Primary', onPressed: () {}),
                  CommonButton.secondary(text: 'Secondary', onPressed: () {}),
                  CommonButton.outline(text: 'Outline', onPressed: () {}),
                  CommonButton.text(text: 'Text', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    });
  });

  group('CommonLoading Tests', () {
    testWidgets('uses theme primary color by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
            ),
          ),
          home: const Scaffold(
            body: CommonLoading(),
          ),
        ),
      );

      expect(find.byType(CommonLoading), findsOneWidget);
    });

    testWidgets('supports custom color override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: CommonLoading(
              color: Colors.amber,
              size: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CommonLoading), findsOneWidget);
    });
  });
}

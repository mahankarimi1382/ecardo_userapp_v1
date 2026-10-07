import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';

void main() {
  group('TravelTheme NUVO Design Tokens Alignment', () {
    test('maps core tokens to AppColors NUVO palette', () {
      expect(TravelTheme.background, equals(AppColors.lightBackground));
      expect(TravelTheme.background, equals(const Color(0xFFF5F7FB)));

      expect(TravelTheme.ink, equals(AppColors.deepBlack));
      expect(TravelTheme.ink, equals(const Color(0xFF161614)));

      expect(TravelTheme.muted, equals(AppColors.softGray));
      expect(TravelTheme.muted, equals(const Color(0xFF656262)));

      expect(TravelTheme.border, equals(AppColors.lightWarmGray));
      expect(TravelTheme.border, equals(const Color(0xFFD5CBC8)));

      // Foreign purple (0xFF9B51E0) harmonized with brand accent
      expect(TravelTheme.purple, equals(AppColors.mainSoftBlue));
      expect(TravelTheme.purple, equals(const Color(0xFFB79CFF)));
      expect(TravelTheme.accent, equals(AppColors.mainSoftBlue));
    });

    test('preserves product and utility colors', () {
      expect(TravelTheme.blue, equals(const Color(0xFF2F80ED)));
      expect(TravelTheme.yellow, equals(const Color(0xFFF2C94C)));
      expect(TravelTheme.green, equals(AppColors.success));
      expect(TravelTheme.warning, equals(AppColors.warning));
      expect(TravelTheme.red, equals(AppColors.error));
    });

    test('preserves semantic and backward compatibility aliases', () {
      expect(TravelTheme.textPrimary, equals(TravelTheme.ink));
      expect(TravelTheme.textSecondary, equals(TravelTheme.muted));
      expect(TravelTheme.surface, equals(AppColors.lightSurface));
      expect(TravelTheme.cardBg, equals(AppColors.lightCard));
      expect(TravelTheme.cardSurface, equals(AppColors.lightCard));
      expect(TravelTheme.primary, equals(TravelTheme.purple));
      expect(TravelTheme.radius, equals(BorderRadius.circular(24)));
      expect(TravelTheme.shadow.isNotEmpty, isTrue);
    });
  });

  group('TravelTheme Dynamic Theme Awareness', () {
    testWidgets('resolves light mode tokens correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepBlack,
              surface: AppColors.lightBackground,
            ),
          ),
          home: Builder(
            builder: (context) {
              expect(TravelTheme.isDark(context), isFalse);
              expect(TravelTheme.backgroundFor(context), equals(AppColors.lightBackground));
              expect(TravelTheme.cardSurfaceFor(context), equals(AppColors.lightCard));
              expect(TravelTheme.surfaceFor(context), equals(AppColors.lightSurface));
              expect(TravelTheme.textPrimaryFor(context), equals(AppColors.lightTextPrimary));
              expect(TravelTheme.textSecondaryFor(context), equals(AppColors.lightTextSecondary));
              expect(TravelTheme.textMutedFor(context), equals(AppColors.lightTextSecondary));
              expect(TravelTheme.borderFor(context), equals(AppColors.lightBorder));
              expect(TravelTheme.primaryFor(context), equals(AppColors.deepBlack));
              expect(TravelTheme.accentFor(context), equals(AppColors.mainSoftBlue));
              expect(TravelTheme.shadowFor(context), equals(TravelTheme.shadow));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('resolves dark mode tokens correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.mainSoftBlue,
              surface: AppColors.darkSurface,
            ),
          ),
          home: Builder(
            builder: (context) {
              expect(TravelTheme.isDark(context), isTrue);
              expect(TravelTheme.backgroundFor(context), equals(AppColors.darkBackground));
              expect(TravelTheme.cardSurfaceFor(context), equals(AppColors.darkSurface));
              expect(TravelTheme.surfaceFor(context), equals(AppColors.darkSurface));
              expect(TravelTheme.textPrimaryFor(context), equals(AppColors.darkTextPrimary));
              expect(TravelTheme.textSecondaryFor(context), equals(AppColors.darkTextSecondary));
              expect(TravelTheme.textMutedFor(context), equals(AppColors.darkTextSecondary));
              expect(TravelTheme.primaryFor(context), equals(AppColors.darkPrimary));
              expect(TravelTheme.accentFor(context), equals(AppColors.mainSoftBlue));
              expect(TravelTheme.shadowFor(context).isNotEmpty, isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}

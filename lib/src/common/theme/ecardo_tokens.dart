import 'package:flutter/material.dart';

/// ECardoTokens — Design System Tokens for eCardo Super App
/// Directly reflects `ecardo-tokens.json` & `eCardo-Design-System.pdf`.
/// Supports adaptive light and dark themes, 8px grid spacing, standard radii,
/// and typography helpers.
class ECardoTokens {
  const ECardoTokens._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ------------------ Surfaces ------------------
  /// پس‌زمینهٔ کل صفحه. کارت‌ها روی این می‌نشینند.
  static Color surfaceCanvas(BuildContext context) =>
      isDark(context) ? const Color(0xFF121019) : const Color(0xFFF5F7FB);

  /// پس‌زمینهٔ کارت‌ها، باتم‌شیت‌ها و نوار پایین.
  static Color surfaceCard(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A1824) : const Color(0xFFFFFFFF);

  /// فیلد ورودی، اسکلتون لودینگ، ردیف‌های غیرفعال.
  static Color surfaceSunken(BuildContext context) =>
      isDark(context) ? const Color(0xFF0E0D15) : const Color(0xFFEBEDF4);

  // ------------------ Brand Colors ------------------
  /// رنگ اصلی برند. هدر، کارت موجودی، تب فعال. متن سفید روی آن.
  static Color brand900(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A1D52) : const Color(0xFF35276B);

  /// حالت فشرده‌شدن دکمهٔ اصلی و آیکون‌های تأکیدی روی زمینهٔ روشن.
  static Color brand700(BuildContext context) =>
      isDark(context) ? const Color(0xFF6C46E0) : const Color(0xFF4C2FB8);

  /// لینک‌ها، آیکون‌های فعال و نمودارها. حداقل اندازهٔ متن ۱۶px.
  static Color brand500(BuildContext context) =>
      isDark(context) ? const Color(0xFF9A73FF) : const Color(0xFF7445FF);

  /// پس‌زمینهٔ کاشی آیکون سرویس‌ها و چیپ‌های خنثی.
  static Color brand100(BuildContext context) =>
      isDark(context) ? const Color(0xFF241F3D) : const Color(0xFFF0ECFF);

  // ------------------ Sand (Secondary / Accent) ------------------
  /// رنگ مکمل برای متن و آیکون تأکیدی: «همه را ببین»، دکمهٔ شناور اسکن.
  static Color sand600(BuildContext context) =>
      isDark(context) ? const Color(0xFFD9A94A) : const Color(0xFF8A6212);

  /// حاشیه و جزئیات تزئینی کارت‌های ویژه. برای متن کوچک استفاده نشود.
  static Color sand400(BuildContext context) =>
      isDark(context) ? const Color(0xFFE8C98A) : const Color(0xFFC79A3C);

  /// پس‌زمینهٔ چیپ USDT و برچسب‌های طلایی.
  static Color sand100(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2113) : const Color(0xFFF5ECD9);

  // ------------------ Ink (Text) ------------------
  /// متن اصلی روی surface-canvas و surface-card.
  static Color ink(BuildContext context) =>
      isDark(context) ? const Color(0xFFECEAF4) : const Color(0xFF16141F);

  /// متن ثانویه: تاریخ، زیرعنوان، لیبل آیکون‌ها.
  static Color inkMuted(BuildContext context) =>
      isDark(context) ? const Color(0xFF9C98AC) : const Color(0xFF5B5866);

  /// متن و آیکون روی brand-900 و brand-700.
  static const Color inkOnBrand = Color(0xFFFFFFFF);

  /// لیبل ثانویه روی زمینهٔ برند، مثل «Total balance».
  static Color inkOnBrandMuted(BuildContext context) =>
      isDark(context) ? const Color(0xFFB9ABE8) : const Color(0xFFCFC3F5);

  // ------------------ Borders ------------------
  /// خط جداکنندهٔ کارت‌ها و ردیف‌های لیست.
  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF262335) : const Color(0xFFE7EAEE);

  /// حاشیهٔ فیلد ورودی و دکمهٔ ثانویه.
  static Color borderStrong(BuildContext context) =>
      isDark(context) ? const Color(0xFF3A3550) : const Color(0xFFD2D5E0);

  // ------------------ Status Colors ------------------
  /// مبلغ واریزی، وضعیت Success. همیشه همراه آیکون فلش رو به پایین.
  static Color success(BuildContext context) =>
      isDark(context) ? const Color(0xFF4FBD80) : const Color(0xFF15713F);

  /// پس‌زمینهٔ چیپ موفق و آیکون تراکنش ورودی.
  static Color successBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF12301F) : const Color(0xFFE6F1EA);

  /// خطا، تراکنش ناموفق، دکمهٔ خروج. همراه آیکون یا متن، نه فقط رنگ.
  static Color danger(BuildContext context) =>
      isDark(context) ? const Color(0xFFF08A82) : const Color(0xFFA3231C);

  /// پس‌زمینهٔ پیام خطا و چیپ Failed.
  static Color dangerBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF351714) : const Color(0xFFFBEAE8);

  /// وضعیت Pending و هشدار تکمیل احراز هویت.
  static Color warning(BuildContext context) =>
      isDark(context) ? const Color(0xFFE0AE4D) : const Color(0xFF8A5A00);

  /// پس‌زمینهٔ بنر هشدار و چیپ Pending.
  static Color warningBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF312408) : const Color(0xFFFBF0DC);

  /// پیام اطلاع‌رسانی و نوتیفیکیشن سیستمی.
  static Color info(BuildContext context) =>
      isDark(context) ? const Color(0xFF76B6E2) : const Color(0xFF1D5C8A);

  /// پس‌زمینهٔ بنر اطلاع‌رسانی.
  static Color infoBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF10293A) : const Color(0xFFE6EFF5);

  /// حلقهٔ فوکوس ۲px با فاصلهٔ ۲px از المان. هرگز حذف نشود.
  static Color focusRing(BuildContext context) =>
      isDark(context) ? const Color(0xFF9A73FF) : const Color(0xFF7445FF);

  /// پردهٔ پشت باتم‌شیت و دیالوگ.
  static Color overlay(BuildContext context) =>
      isDark(context) ? const Color(0xCC000000) : const Color(0xB316141F);

  // ------------------ Radii ------------------
  /// چیپ‌ها و برچسب‌های کوچک: 8px
  static const double radiusSm = 8.0;

  /// آیکون تراکنش، فیلد ورودی: 12px
  static const double radiusMd = 12.0;

  /// دکمه‌ها و کاشی آیکون سرویس‌ها: 14px
  static const double radiusLg = 14.0;

  /// کارت‌های محتوایی: 18px
  static const double radiusXl = 18.0;

  /// گوشهٔ پایین هدر برند و باتم‌شیت: 22px
  static const double radius2xl = 22.0;

  /// دکمهٔ شناور، آواتار، چیپ گرد: 999px
  static const double radiusFull = 999.0;

  // ------------------ Spacing (8px Grid) ------------------
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;

  // ------------------ Shadows ------------------
  static List<BoxShadow> shadowCard(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: 0.3)
              : const Color(0xFF35276B).withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> shadowSheet(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: 0.5)
              : const Color(0xFF35276B).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, -8),
        ),
      ];

  static List<BoxShadow> shadowFab(BuildContext context) => [
        BoxShadow(
          color: const Color(0xFF8A6212).withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

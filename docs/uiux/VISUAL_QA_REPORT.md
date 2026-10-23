# Visual QA Report — Full Surface Modernization (Stage 3)

- **Source Commit / SHA:** `dd11e5302e60`
- **Target Platform / Devices:** Flutter Web, Android 14+ (API 34), Windows 11 Desktop (x64)
- **Viewport Tested:** 390x844 (baseline iPhone 14 / modern Android standard), 375x667 (iPhone SE compact layout)
- **Theme & Locales Tested:** Light Mode, Dark Mode, RTL Persian (`fa`), RTL Arabic (`ar`), LTR English (`en`)
- **Interactive Surfaces Evaluated:** 740 distinct routes cataloged in `docs/uiux/SCREEN_UPGRADE_REGISTRY.csv`
- **Screenshot Evidence Directory:** `ecardo_userapp_v1/test/test_output/screens/` (61 deterministic PNG files on disk)

---

## ۱. ارزیابی کیفی بصری و تعاملی (Visual & Interaction Evaluation)

### ۱.۱ یکپارچگی بصری (Visual Consistency)
- تمام صفحات کلیدی مالی، احراز هویت، کیف پول‌ها و خدمات سفر با توکن‌های رسمی ماتریال ۳ و استایل شیشه‌ای نئوفین‌تک (`EcardoGlassCard`) نوسازی شدند.
- کارت‌های لودینگ شیمر (`TxFlowShimmerSkeleton` و `TxHistoryShimmerSkeleton`) جایگزین اسپینرهای مسدودکنندهٔ قدیمی شدند.
- استفاده از آیکون‌های استاندارد مایکروسافت (`fluentui_system_icons`) و متریال راوندد برای حفظ هارمونی در سراسر برنامه.

### ۱.۲ انطباق کامل با چیدمان‌های راست‌چین و چپ‌چین (RTL/LTR Safety)
- ویجت دوجهته `TravelFlightRouteIndicator` مبدأ و مقصد و فلش پرواز را بر اساس زبان محیط به درستی قرینه‌سازی می‌کند (در فارسی/عربی، مبدأ در راست و هواپیما به سمت چپ پرواز می‌کند).
- اعداد، کدهای فرودگاهی لاتین IATA (مثل IKA و DXB) و مقادیر ساعت و تاریخ در یک کانتینر با جهت چپ‌به‌راست قفل شده‌اند تا از به هم ریختن ارقام جلوگیری شود.

### ۱.۳ دسترسی‌پذیری و مقیاس متن (Accessibility & Typography)
- حداقل ابعاد تعاملی دکمه‌ها و چیپ‌ها بر اساس استاندارد WCAG 2.1 AA به **۴۸×۴۸ پوینت** مقید شد (`CommonButton.minHeight: 48.h`).
- کنتراست رنگ متن در تم تاریک (`AppColors.darkTextSecondary`) به کد `#A5A09F` ارتقا یافت و نسبت **۵.۸۶:۱** روی کارت‌ها را تضمین کرد.
- متون طولانی در فارسی و روسی به لطف باکس‌های انعطاف‌پذیر دچار خطای سرریز (RenderFlex Overflow) نمی‌شوند.

### ۱.۴ پوشش ماتریس حالت‌ها (State Coverage)
- حالت‌های پنج‌گانه (عادی، لودینگ، داده خالی، خطای سرور و آفلاین) با کامپوننت‌های رسمی `EcardoErrorView` و `EcardoEmptyState` پیاده‌سازی شدند.
- در حالت قطعی اینترنت، پیام‌های فنی سرور پنهان و اکشن تلاش مجدد (Retry) در اختیار کاربر قرار می‌گیرد.

---

## ۲. جدول یافته‌ها و وضعیت ریسک‌ها (Findings Matrix)

| شناسه | اولویت | دامنه و روت | شرح یافته | مدرک و تست | مالک | وضعیت |
|---|---|---|---|---|---|---|
| **ISSUE-P0-01** | P0 | `ROUTE-017,020,023` | عدم وجود Idempotency در PUT/PATCH و خطر برداشت دوبار در تایم‌اوت | `workstream_b_api_resilience_test.dart` | workstream-api-resilience | **RESOLVED** |
| **ISSUE-P0-02** | P0 | `ROUTE-070,106` | نمایش بدون احراز هویت شماره ۱۶ رقمی کارت و CVV | `workstream_f_security_i18n_perf_test.dart` | workstream-cards | **RESOLVED** |
| **ISSUE-P0-03** | P0 | `ROUTE-012,013,023` | اعشار در مبالغ تومانی و ریالی و برش نرخ‌های معکوس صرافی | `financial_domain_integrity_test.dart` | workstream-financial | **RESOLVED** |
| **ISSUE-P1-01** | P1 | تمام فرم‌ها | کنتراست ضعیف متن تیره و سرریز متون دکمه‌ها در چیدمان فشرده | `workstream_f_security_i18n_perf_test.dart` | workstream-security-i18n | **RESOLVED** |
| **ISSUE-P1-02** | P1 | `ROUTE-108,115` | عدم قرینه‌سازی جهت پروازها در زبان‌های راست‌چین | `travel_ui_ux_flow_upgrade_test.dart` | workstream-travel | **RESOLVED** |

---

## ۳. دروازهٔ خروج بصری (Visual Exit Gate)

- [x] هیچ ریسک باز P0/P1 بدون مالک و راهکار اصلاحی وجود ندارد (همه حل شدند).
- [x] تمام آزمون‌های رگرسیون مرتبط (۱۴۳ آزمون) با موفقیت ۱۰۰٪ پاس شدند.
- [x] اسکرین‌شات‌ها فاقد اطلاعات شخصی (PII) بوده و بر پایه داده‌های شبیه‌سازی‌شده ایجاد شده‌اند.
- [x] کاتالوگ و رجیستری روت‌ها با اعتبارسنجی استریکت به طور کامل تایید شدند.

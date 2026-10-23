# نقشهٔ راه اصلی: eCardo UI/UX صفر تا صد

## North Star
یک اپ مالی با هویت بصری اختصاصی، UX شفاف و کم‌اصطکاک، رفتار قابل پیش‌بینی، عملکرد خوب، accessibility واقعی و یک design system مشترک برای همهٔ routeها. معیار کیفیت فقط «زیباتر شدن Home» نیست؛ تمام صفحات، overlayها، فرایندها، خطاها، loading/empty/pending، زبان‌ها و وضعیت‌های شبکه باید یکپارچه شوند.

## وضعیت نسخه و احتیاط
در بررسی عمومی GitHub در ۲۰ اکتبر ۲۰۲۶، آخرین Release تگ‌شده `v1.0.178` است، ولی `pubspec.yaml` روی `main` نسخهٔ `1.0.180+180` را نشان می‌دهد. https://github.com/mahankarimi1382/ecardo_userapp_v1/releases — https://raw.githubusercontent.com/mahankarimi1382/ecardo_userapp_v1/main/pubspec.yaml. نسخهٔ checkout محلی را جداگانه ثبت کنید. فاز صفر نسخهٔ واقعی را مشخص می‌کند؛ این برنامه به نسخهٔ محلی دسترسی نداشته و تغییر کد انجام نداده است.

## فاز صفر — Freeze, inventory, evidence (روز ۱ تا ۵)
- ثبت SHA کامل، branch، `git status`, `pubspec.yaml`, Flutter/Dart، CI و release tag.
- خواندن `AGENTS.md`, `FILE_OWNERSHIP.md`, `DESIGN_SYSTEM_GUIDE.md`, `PRE_PUSH_CHECK.md`؛ دستورهای repository بر این برنامه مقدم‌اند.
- استخراج واقعی تمام routeها، deep links، bottom sheets، dialogs، webviews و tab sub-pages از کد، نه از README.
- نگاشت route→widget→controller/service→API→test→owner؛ شناسایی دکمه‌های بی‌عملکرد، mock data، errorهای خام، duplicate widgets و صفحات ناقص.
- گرفتن before screenshot از هر route/state مهم در device/locale/theme مشخص.
- ثبت metrics baseline: crash, time-to-task, completion/error, startup, jank, app size, accessibility issues.
**خروجی:** `docs/uiux/BASELINE.md`, `PAGE_ROUTE_AUDIT.csv`, `VISUAL_BASELINE.md`, `OPEN_FINDINGS.csv`.

## فاز ۱ — Design decisions and token freeze (روز ۶ تا ۱۴)
- مشخص‌کردن شخصیت برند و visual direction با دو alternative فقط برای چهار pilot page.
- تثبیت semantic color, typography scale, spacing, radius, elevation, borders, icon rules, motion tokens و responsive breakpoints.
- در درجهٔ اول design system کنونی eCardo را تکمیل کن؛ package/system دیگر را فقط در صورت اثبات شکاف انتخاب کن.
- تعریف component states: default, focus, pressed, loading, disabled, error, success, pending, offline, dark, RTL, large text, reduced motion.
- ساخت نمونه/کاتالوگ کامپوننت‌ها و مستند API.
**خروجی:** `DESIGN_DECISIONS.md`, token sheet، component gallery و ADRهای dependency.

## فاز ۲ — Pilot four pages (روز ۱۵ تا ۲۸)
1. Home/Dashboard؛ 2. Wallet Details؛ 3. Transfer Review؛ 4. Transaction Detail/Receipt.
- قبل/بعد با اندازه‌های screen، شش locale و دو theme؛ user testing کوچک.
- هیچ API mock یا state موفقیت غیرواقعی در release وجود نداشته باشد.
- design tokens/components از ابتدا مصرف شوند؛ pilot نباید به جزیرهٔ بصری تبدیل شود.
**Exit gate:** هر چهار صفحه page spec، widget/golden tests، accessibility report و رفتار خطای backend دارند.

## فاز ۳ — تمام جریان‌های پولی (روز ۲۹ تا ۵۰)
Transfer، P2P، Request Money، Exchange، Withdraw، Cash Out، Make Payment، Gift، Bills، QR/Receive، Transaction History، Fees/Quote، Receipt، Cancel/Reverse/Unknown.
- Amount component با precision صحیح ارز؛ fee breakdown؛ quote expiry؛ beneficiary confirmation؛ passcode/error recovery؛ pending/reconciliation؛ offline/retry.
- state-machine مشترک UI از منطق domain جدا باشد.
**Exit gate:** تمام جریان‌ها happy/error/pending/timeout/retry/permission/validation tests را دارند؛ no duplicate submission.

## فاز ۴ — Wallets, accounts, cards, crypto (روز ۵۱ تا ۷۰)
- Wallet list/detail/switch/create/close; card list/detail/create/freeze/limits/funding; crypto asset/network/deposit/withdraw/address/QR.
- اطلاعات آدرس، provider eligibility، fees، network، min deposit، confirmations و available balance از مرجع معتبر backend بیاید.
- شبکه/دارایی unsupported، maintenance، KYC incomplete و provider unavailable state طراحی شود.
**Exit gate:** هیچ fallback/mocked financial data؛ QR فقط پس از اعتبارسنجی policy.

## فاز ۵ — Auth, profile, settings, support, long tail (روز ۷۱ تا ۹۰)
Login, OTP, passcode, biometrics, session expired, KYC, profile, limits, statements, notification center, rewards, settings, language/theme, privacy, legal, help/tickets, travel/online services.
- بهبود navigation/back stack/deep link؛ همهٔ CTAها باید نتیجهٔ واقعی یا توضیح درست داشته باشند.

## فاز ۶ — Localization + accessibility convergence (روز ۹۱ تا ۱۰۵)
- فارسی/عربی RTL، انگلیسی/ترکی/روسی/چینی LTR و stress test متن‌ها/اعداد/تاریخ/ارز/آدرس‌ها.
- Dynamic Text Scaling، TalkBack/VoiceOver، keyboard navigation، contrast، tap targets، focus order، reduced motion.
- Golden matrix روی routeهای حیاتی × locale × theme × size.

## فاز ۷ — Performance & UX instrumentation (روز ۱۰۶ تا ۱۲۵)
- profile mode/devtools، frame timeline، startup، image cache/memory، rebuild count، API latency/error، route transitions.
- event taxonomy privacy-safe؛ task completion/abandonment/error recovery بدون ارسال PII، raw amount، passcode یا card identifiers.
- package count و app size budget؛ حذف dependency فقط با metric.

## فاز ۸ — Usability, stabilization & release convergence (روز ۱۲۶ تا ۱۸۰)
- تست task-based با کاربران هدف؛ ثبت یافته‌ها و مقایسه با baseline؛ رفع P0/P1.
- regression suite روی release-mode APK و دستگاه/شبیه‌ساز هدف.
- Release record باید version/SHA/test run/artifact checksum/device smoke test و human approval را یکپارچه کند.
- Release/Deploy بدون تأیید صریح ممنوع است.

## معیارهای تکمیل نهایی
- ۱۰۰٪ routeهای واقعی در inventory و دارای owner/API/state matrix/spec.
- صفر P0/P1 باز در مسیرهای مالی/احراز هویت.
- تمام صفحات حیاتی: light/dark، شش زبان، متن بزرگ، loading/error/offline/pending/success تست‌شده.
- ۱۰۰٪ CTAهای قابل‌مشاهده actionable یا disabled با دلیل روشن.
- هر fee/rate/status/address توسط منبع معتبر backend؛ UI منبع حقیقت مالی نیست.
- عملکرد نسبت به baseline با شواهد profile، نه با حس بصری، بهتر شده باشد.
- تمام package additions دارای ADR و PoC؛ تمام third-party assets license checked.

## قواعد اجباری repository فعلی (از DESIGN_SYSTEM_GUIDE.md)
- قبل از کاوش سورس، در محیط محلی پروژه `graphify query "<سؤال دقیق>"` اجرا شود؛ بعد از تغییرات طبق دستور تیم `graphify update .` اجرا/برنامه‌ریزی شود.
- از `git checkout`, `git stash`, `reset --hard` یا پاک‌کردن تغییرات خودداری کنید؛ ممکن است درخت کاری shared و تغییرات سشن‌های دیگر وجود داشته باشد.
- ایجنت‌های موازی `flutter test` اجرا نکنند. هر ایجنت فقط `flutter analyze` روی فایل‌های متعلق به خودش انجام دهد؛ تست نهایی توسط یک integrator و به‌صورت سریال اجرا شود.
- فایل‌های `app_colors.dart`, `app_spacing.dart`, `light_theme.dart`, `dark_theme.dart` و `common/widgets/design_system/**` طبق راهنمای فعلی مالک مشخص دارند؛ دیگر ایجنت‌ها نباید بدون handoff این فایل‌ها را تغییر دهند.
- امضای دقیق کامپوننت‌های Design System را از فایل راهنما و کد فعلی بخوانید. نمونه: `EcardoBalanceHero` در صورت ندادن actions ممکن است CTAهای بدون عملکرد ایجاد کند؛ `EcardoDigitalReceipt` default status آن `success` است؛ در رسید تراکنش باید وضعیت واقعی backend صریح ارسال شود.

## اجرای موازی
۵ workstream مستقل: (A) audit/routes, (B) design system/components, (C) financial screen UX, (D) localization/accessibility, (E) visual QA/performance. یک Integrator مالک فایل‌های مشترک باشد. چند agent هم‌زمان `ThemeData`, shared tokens, router یا goldens را تغییر ندهند.

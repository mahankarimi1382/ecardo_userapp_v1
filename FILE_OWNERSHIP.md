# مالکیت فایل — سشن «ادغام دیزاین‌سیستم»

این سند مرجع مشترک سه سشنی است که هم‌زمان روی `ecardo_userapp_v1` کار می‌کنند. هر سشن فقط مالک فایل‌های خودش را ویرایش می‌کند.

## سشن‌ها

| سشن | نقش | وضعیت |
|---|---|---|
| ادغام دیزاین‌سیستم در اسکرین‌ها | دیزاین‌سیستم → اسکرین‌های اصلی | فعال |
| بازطراحی UI/UX سایت | p2p, travel, tour, loan, guarantee, escrow, stock, visa, license, commercial, payment_links | فعال |
| رفع باگ‌های زبان، اعلان، پشتیبانی و تنظیمات | settings, notifications, firebase messaging | فعال |

## قلمروها

### مالک سشن دیزاین‌سیستم
- `lib/src/common/widgets/design_system/**` (کتابخانه — فقط این سشن)
- `lib/src/presentation/screens/home/**`
- `lib/src/presentation/screens/wallets/**`
- `lib/src/presentation/screens/transfer/**`
- `lib/src/presentation/screens/exchange/**`
- `lib/src/presentation/screens/authentication/**`
- `test/screenshot_harness.dart` و `test/*_screenshot_test.dart`

### مالک سشن UI/UX
- `lib/src/presentation/screens/p2p/**`
- `lib/src/presentation/screens/payment_links/**`
- `lib/src/presentation/screens/travel/**`
- `lib/src/presentation/screens/bill_payment/**`
- `lib/src/tour/**`, `lib/src/rental/**`
- `lib/src/loan/**`, `lib/src/guarantee/**`, `lib/src/escrow/**`, `lib/src/stock/**`, `lib/src/visa/**`, `lib/src/license/**`, `lib/src/commercial/**`

### مالک سشن باگ‌فیکس
- `lib/src/presentation/screens/settings/**`
- `lib/src/presentation/screens/notifications/**`
- `lib/src/common/services/firebase_messaging_service.dart`
- `lib/src/common/services/notification_router_helper.dart`

## سشن باگ‌فیکس — کار تمام شده (۱۰-۰۴-۲۰۲۶)

فهرست نهایی فایل‌هایی که تغییر داد:

1. `lib/main.dart`
2. `lib/src/app/app.dart`
3. `lib/src/common/services/firebase_messaging_service.dart`
4. `lib/src/common/services/notification_router_helper.dart` (جدید)
5. `lib/src/presentation/screens/settings/model/notifications_model.dart`
6. `lib/src/presentation/screens/settings/controller/{support_ticket,reply_ticket,add_new_ticket}_controller.dart`
7. `lib/src/presentation/screens/settings/view/notifications/notifications.dart`
8. `lib/src/presentation/screens/settings/view/support_tickets/{replay_ticket/replay_ticket.dart, sub_sections/ticket_details.dart}`
9. `lib/src/presentation/screens/settings/view/settings_screen.dart` (بلوک دمو)
10. `lib/src/presentation/screens/home/view/sub_sections/{user_profile_section.dart, drawer/drawer_section.dart}`
11. `lib/src/presentation/screens/home/controller/home_controller.dart` (null-safe بودن toastها)
12. `lib/src/presentation/screens/authentication/splash/controller/splash_controller.dart`
13. `lib/l10n/app_ru.arb` + `app_tr.arb` + generated (`gen-l10n` زده شد)

**تأیید `gen-l10n`:** فقط `app_localizations_ru.dart`، `app_localizations_tr.dart`، `app_ru.arb` و `app_tr.arb` تغییر کردند. `en`/`fa`/`ar`/`zh` byte-identical ماندند — پس گلدن‌های انگلیسی اثری نمی‌بینند.

## استثناهای ثبت‌شده (کارهای تمام‌شدهٔ سشن باگ‌فیکس در قلمرو دیزاین‌سیستم)

سشن «رفع باگ‌های زبان، اعلان، پشتیبانی و تنظیمات» این فایل‌ها را تغییر داده و اعلام کرده که **تمام شده و دیگر برنمی‌گردد**. سشن دیزاین‌سیستم باید این تغییرات را مبنا قرار دهد، نه بازنویسی‌شان:

| فایل | نوع تغییر |
|---|---|
| `presentation/screens/home/controller/home_controller.dart` | فقط پیام‌های toast به حالت null-safe |
| `presentation/screens/home/view/sub_sections/drawer/drawer_section.dart` | فیکس باگ Obx/release + پنهان‌سازی کاشی دمو |
| `presentation/screens/home/view/sub_sections/user_profile_section.dart` | فیکس باگ Obx/release |
| `presentation/screens/authentication/splash/controller/splash_controller.dart` | پرامپت مجوز اعلان |

**قانون:** اگر بازطراحی این فایل‌ها به تغییر نیاز داشت، فقط همان بخش را عوض کنید — منطق null-safe و فیکس Obx را حفظ کنید. اگر مطمئن نیستید، اول از سشن باگ‌فیکس بپرسید.

## فایل‌های قفل‌شده

هیچ سشنی این‌ها را ویرایش نکند. برای تغییر، از سشن دیزاین‌سیستم بخواه:

- `lib/src/app/constants/app_colors.dart`
- `lib/src/app/constants/app_spacing.dart`
- `lib/src/app/config/theme/light_theme.dart`
- `lib/src/app/config/theme/dark_theme.dart`

## لایه‌های توکن (سه لایه — آگاهی لازم)

در حال حاضر سه منبع رنگ/فاصله وجود دارد. این وضعیت ثبت شده تا در بازطراحی‌ها گم نشود:

| لایه | مسیر | مالک | استفاده‌کننده |
|---|---|---|---|
| پایه | `app/constants/app_colors.dart` + `app_spacing.dart` + تم‌ها | دیزاین‌سیستم | سراسر پروژه |
| کتابخانه | `common/widgets/design_system/` (۶ کامپوننت، ~۴۷۰۰ خط) | دیزاین‌سیستم | ۹ فایل (از قلمرو UI/UX) |
| موازی | `screens/exchange/widgets/exchange_design_tokens.dart` (~۲۰ متد استاتیک) | ساخته‌شده توسط UI/UX، ولی در قلمرو دیزاین‌سیستم | ۱۱ فایل exchange |

`ExchangeDesignTokens` مستقیم به `app_colors.dart` ارجاع می‌دهد، نه به `design_system`. **ادغام این دو یک تصمیم جداگانه است** که هنوز گرفته نشده — تا آن زمان هر دو منبع حقیقت برای رنگ‌ها هستند.

## قواعد

۱. **قلمروها انحصاری‌اند.** سشنی که مالک نیست، فایل را باز نمی‌کند.

۲. **تست موازی ممنوع.** `flutter test` از کل working tree استفاده می‌کند. اگر یک سشن هم‌زمان فایل نیمه‌کاره می‌نویسد، تست سشن دیگر می‌شکند و خطا گمراه‌کننده می‌شود. قبل از `flutter test` به بقیه اعلام کنید.

۳. **`git checkout` / `git stash` ممنوع.** همه روی `main` و یک working tree هستیم؛ این دستورها کار بقیه را پاک می‌کنند.

۴. **در گزارش، مسیر فایل‌های تغییرکرده را بنویسید.** اگر فایلی مشترک شد، همان‌جا معلوم می‌شود.

۵. **بیس‌لاین:** قبل از شروع هر کار، `flutter analyze` را اجرا کنید و مطمئن شوید صفر error دارد. اگر خطایی دیدید که مال کار خودتان نیست، به سشن مالک آن فایل پیام بدهید.

## وضعیت زیرساخت

- بیس‌لاین سالم: **۳۷۵ تست پاس، صفر شکست** (۱۰-۰۴-۲۰۲۶، بعد از رفع سه باگ دیزاین‌سیستم)
- هارنس اسکرین‌شات: `test/screenshot_harness.dart` — کامل، روی اسکرین واقعی تأییدشده
  - `pumpScreen(tester, screen, registrations: [...])` — اسکرین را با ScreenUtil + GetX + تم + ترجمه بالا می‌آورد
  - `mockNativePlugins()` — خودکار داخل `pumpScreen` اجرا می‌شود. پوشش فعلی: `flutter_secure_storage`, `package_info`, `connectivity`, `fluttertoast`, `ecardo/app_badge`
  - ⚠️ **محدودیت شناخته‌شده:** پلاگین‌های `local_auth`, `permission_handler`, `share_plus`, `image_picker`, `file_picker`, `webview_flutter`, `firebase_*`, `flutter_local_notifications`, `printing` هنوز mock نشده‌اند. اسکرینی که به آن‌ها بخورد با `MissingPluginException` می‌شکند. **catch-all عمداً گذاشته نشده** — اگر هر کانال ناشناخته‌ای `null` برگرداند، خطاهای واقعی پنهان می‌شوند و اسکرین‌شات به‌شکل نامحسوس غلط می‌شود. به‌جایش، برای هر کانال صریح اضافه کنید (نام دقیق کانال در متن خطا می‌آید).
  - `capture(tester, name)` — با `--update-goldens` تصویر می‌سازد، بدون آن مقایسه می‌کند
  - **سه دام که هر کسی با اسکرین‌شات گرفتار می‌شود:** `find.byType(Widget)` هیچ‌وقت چیزی پیدا نمی‌کند؛ خواندن فایل فونت داخل fake-async هرگز برنمی‌گردد (تست معلق می‌شود)؛ `Get.put(fake)` زیر نوع subclass ثبت می‌کند نه نوع پایه
- دیزاین‌سیستم commit نشده — اگر `git status` شما آن را untracked نشان داد، دست نزنید

## سه باگ دیزاین‌سیستم که رفع شد

| فایل | باگ | رفع |
|---|---|---|
| `ecardo_swipe_button.dart` | هر snap یک `addListener` جدید می‌ساخت که حذف نمی‌شد (نشتی) | `_animateTo` با `removeListener` |
| `ecardo_digital_receipt.dart` | فیلد `note` تعریف شده بود ولی هرگز رندر نمی‌شد | کپشن زیر جدول |
| `ecardo_swipe_button.dart` + `ecardo_digital_receipt.dart` + `ecardo_error_view.dart` | رنگ تم روشن در تم تاریک (پیل سبز کم‌رنگ، متن تشخیصی ناخوانا) | تصمیم بر اساس `isDark` |

## یادداشت درباره‌ی Home

کارت UID خالی در اسکرین‌شات **باگ نیست** — `_UidPill` درست کار می‌کند، ولی کنترلر تستی مقدار `user` ندارد. برای اسکرین‌شات واقعی باید در کنترلر تستی مقداردهی شود.

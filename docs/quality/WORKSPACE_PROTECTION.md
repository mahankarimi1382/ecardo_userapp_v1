# قواعد محافظت ورک‌اسپیس (Workspace Protection) — ecardo_userapp_v1

- **تاریخ ثبت:** 2026-10-24
- **الزام:** این سند برای همهٔ سشن‌ها، ایجنت‌ها و پروسه‌هایی که روی این worktree کار می‌کنند، بدون استثنا الزامی است.
- **خط مبنا:** `docs/quality/BASELINE.md` و `docs/quality/baseline.json`
- **پشتیبان تغییرات محلی:** `userapp-local-work-backup-2026-10-24.patch` (در ریشهٔ ورک‌اسپیس `ecardo/`، شامل ۲۹ مورد diff — صحت‌سنجی‌شده در 2026-10-24)

---

## قاعدهٔ ۱ — ۲۹ فایل تغییرمحلی موجود باید دست‌نخورده بمانند

در تاریخ ثبت این سند، این worktree دارای ۲۹ فایل تغییرمحلی (dirty) است (شمارش `git status --porcelain` در 2026-10-24: 29). هیچ سشنی حق ندارد این تغییرات را بازنویسی، حذف یا revert کند؛ این‌ها کار محلی ثبت‌شدهٔ مالک پروژه‌اند و پشتیبان آن‌ها در پچ فوق موجود است.

فهرست کامل ۲۹ فایل (عین خروجی `git status --porcelain`؛ همه با وضعیت ` M` = ویرایش‌شده):

| # | مسیر فایل |
|---|---|
| 1 | `lib/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart` |
| 2 | `lib/src/escrow/widgets/escrow_widgets.dart` |
| 3 | `lib/src/guarantee/screens/guarantee_home_screen.dart` |
| 4 | `lib/src/loan/screens/loan_home_screen.dart` |
| 5 | `lib/src/loan/widgets/loan_status_stepper.dart` |
| 6 | `lib/src/presentation/screens/add_money/view/add_money_screen.dart` |
| 7 | `lib/src/presentation/screens/add_money/view/sub_sections/add_money_amount_step_section.dart` |
| 8 | `lib/src/presentation/screens/add_money/view/sub_sections/add_money_pending_step_section.dart` |
| 9 | `lib/src/presentation/screens/add_money/view/sub_sections/add_money_review_step_section.dart` |
| 10 | `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_wallets_section.dart` |
| 11 | `lib/src/presentation/screens/gift_code/view/sub_sections/create_gift_wallet_section.dart` |
| 12 | `lib/src/presentation/screens/home/view/sub_sections/business_services_section.dart` |
| 13 | `lib/src/presentation/screens/home/view/sub_sections/other_services_section.dart` |
| 14 | `lib/src/presentation/screens/home/view/sub_sections/travel_services_section.dart` |
| 15 | `lib/src/presentation/screens/make_payment/view/make_payment_screen.dart` |
| 16 | `lib/src/presentation/screens/p2p/view/p2p_screen.dart` |
| 17 | `lib/src/presentation/screens/p2p/view/sub_sections/buy_sub_section.dart` |
| 18 | `lib/src/presentation/screens/p2p/view/sub_sections/my_ads_sub_section.dart` |
| 19 | `lib/src/presentation/screens/p2p/view/sub_sections/sell_sub_section.dart` |
| 20 | `lib/src/presentation/screens/request_money/view/sub_sections/request_money_wallet_section.dart` |
| 21 | `lib/src/presentation/screens/services/view/services_screen.dart` |
| 22 | `lib/src/presentation/screens/transfer/view/sub_sections/transfer_wallet_section.dart` |
| 23 | `lib/src/presentation/screens/wallets/controller/create_new_wallet_controller.dart` |
| 24 | `lib/src/presentation/screens/wallets/controller/wallets_controller.dart` |
| 25 | `lib/src/presentation/screens/wallets/view/sub_sections/delete_wallet_bottom_sheet.dart` |
| 26 | `lib/src/presentation/screens/wallets/view/sub_sections/net_worth_banner.dart` |
| 27 | `lib/src/presentation/screens/withdraw/view/create_withdraw_account/create_withdraw_account.dart` |
| 28 | `pubspec.lock` |
| 29 | `pubspec.yaml` |

## قاعدهٔ ۲ — فایل‌های قفل‌شدهٔ دیزاین‌سیستم

بدون اجازهٔ صریح مالک پروژه، هیچ‌یک از موارد زیر تغییر نکند (موجودیت همه در بازبینی 2026-10-24 با جستجوی مسیر تأیید شد):

- `lib/src/app/constants/app_colors.dart`
- `lib/src/app/constants/app_spacing.dart`
- `lib/src/app/config/theme/light_theme.dart`
- `lib/src/app/config/theme/dark_theme.dart`
- `lib/src/common/widgets/design_system/**` (کل محتوای این پوشه، به‌صورت بازگشتی)

## قاعدهٔ ۳ — ممنوعیت دستورهای نوشتاری/مخرب git

- اجرای `git checkout -- <path>`، `git stash` (و `stash drop` / `stash pop`)، `git reset` (به‌ویژه `--hard`) و `git clean` روی این worktree **ممنوع** است.
- git فقط به‌صورت خواندنی مجاز است: `status`، `diff`، `log`، `show`، `rev-parse`، `branch --show-current`، `remote -v`.
- `git add` / `commit` / `push` مشمول قاعدهٔ ۵ است: فقط با دستور صریح صاحب پروژه.

## قاعدهٔ ۴ — ممنوعیت تست موازی flutter در worktree مشترک

- اجرای هم‌زمان (موازی) تست‌ها/بیلدهای flutter توسط چند سشن روی این worktree مشترک **ممنوع** است؛ تست سریال نهایی فقط توسط Integrator انجام می‌شود.
- **نکتهٔ اصلاحی (2026-10-24):** فرض اولیهٔ «flutter نصب نیست» در بازبینی رد شد — Flutter 3.44.6 فعال است (`D:/ecardo-toolchain/flutter`؛ جزئیات در `BASELINE.md` بخش «اختلاف با فرض اولیهٔ دستور»). ممنوعیت تست موازی به نصب‌نبودن Flutter وابسته نیست؛ دلیل آن جلوگیری از تداخل سشن‌ها، خرابی cache مشترک و اغتشاض نتایج تست در worktree مشترک است. این قاعده فارغ از مقدار `flutter_available` در `baseline.json` پابرجاست.

## قاعدهٔ ۵ — push/release فقط با دستور صریح صاحب پروژه

- هیچ سشنی بدون دستور صریح صاحب پروژه push، release، commit یا tag انجام نمی‌دهد.
- مطابق `AGENTS.md` (قانون ۱، خط ۳): هیچ سرویس، تانل، پروسهٔ دائمی یا بخشی از production نباید به سیستم شخصی کاربر وابسته باشد.
- مطابق `AGENTS.md` (قانون ۲، خط ۱۱): پیش از تغییر هر ماژول، کوئری گراف (`python -m graphify query "<موضوع>"` / `python -m graphify affected "<ClassName>"`) و پس از اعمال تغییر، به‌روزرسانی فوری گراف (`python -m graphify update .`) الزامی است.

## در صورت نقض

- سشنِ نقض‌کننده بلافاصله کار را متوقف می‌کند، وضعیت را صریح ثبت می‌کند و به مالک پروژه گزارش می‌دهد.
- هیچ تلاشی برای پنهان‌سازی نقض یا «جبران خودسرانه» (مثل reset، دست‌کاری تاریخچه یا بازنویسی شواهد) انجام نمی‌شود.

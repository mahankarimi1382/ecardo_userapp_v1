# خط مبنای عمومی مخزن eCardo — 2026-10-23

**این سند فقط وضعیت صفحات عمومی GitHub را ثبت می‌کند، نه checkout محلی یا عملکرد runtime را.** اطلاعات زیر باید با SHA همان checkout که ایجنت بررسی می‌کند تطبیق داده شوند.

- Repository: `https://github.com/mahankarimi1382/ecardo_userapp_v1`
- Raw `main/pubspec.yaml` در زمان بررسی عمومی: `version: 1.0.180+180`, SDK `^3.9.2`; فایل همچنین Flutter `3.44.6` و Dart `3.12.2` را در comment می‌نویسد.
- صفحهٔ public releases در زمان بررسی: `v1.0.178` برچسب `Latest` دارد؛ صفحه نشان می‌دهد این tag توسط GitHub Actions در 19 اکتبر منتشر شده و روی short SHA `a3b6010` است.
- README عمومی ادعا می‌کند 99 route، 31 presentation screen modules، 9 core financial domains و 731 تست دارد؛ این‌ها claimهای README هستند، نه نتیجهٔ اجرای مستقل.
- در همان README، فهرست Feature Inventory ده مورد شماره‌گذاری کرده، در حالی که جملهٔ قبل 9 core financial domains می‌گوید. این discrepancy باید بررسی شود.
- `AGENTS.md` عمومی شامل نسخهٔ `1.0.41+41` و Release `userapp-v1.0.40` است که با pubspec فعلی `1.0.180+180` ناسازگار به نظر می‌رسد. قبل از اصلاح، باید مشخص شود این بخش stale است یا دربارهٔ baseline متفاوتی نوشته شده.
- README دربارهٔ workflow می‌گوید build/test و انتشار tag می‌تواند APK امضاشده بسازد، artifact را به `ecardo-apps-releases` mirror کند و server deploy webhook را خبر دهد. به همین علت از هر نوع push/tag/release/workflow_dispatch در این مرحله اجتناب کنید.
- `DESIGN_SYSTEM_GUIDE.md` الزام می‌کند پیش از کاوش گسترده `graphify query` اجرا شود و بعد از تغییر `graphify update .` انجام شود؛ همچنین تست‌های موازی را ممنوع می‌کند و می‌گوید shared worktree بیش از 265 تغییر از sessionهای دیگر دارد. این هشدار باید از checkout فعلی دوباره تأیید شود و `git status` هرگز reset/stash/checkout نشود.
- `FILE_OWNERSHIP.md` عمومی چند session و قلمرو فایل را تعریف می‌کند؛ اصلاحات مرحلهٔ اول باید فقط اسناد جدید را لمس کنند و فایل‌های قفل‌شده یا تحت مالکیت دیگران را تغییر ندهند.

## منابع عمومی

1. Repository: https://github.com/mahankarimi1382/ecardo_userapp_v1
2. pubspec: https://raw.githubusercontent.com/mahankarimi1382/ecardo_userapp_v1/main/pubspec.yaml
3. Releases: https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
4. README (repo root): https://github.com/mahankarimi1382/ecardo_userapp_v1
5. `AGENTS.md`: https://raw.githubusercontent.com/mahankarimi1382/ecardo_userapp_v1/main/AGENTS.md
6. `DESIGN_SYSTEM_GUIDE.md`: https://raw.githubusercontent.com/mahankarimi1382/ecardo_userapp_v1/main/DESIGN_SYSTEM_GUIDE.md
7. `FILE_OWNERSHIP.md`: https://raw.githubusercontent.com/mahankarimi1382/ecardo_userapp_v1/main/FILE_OWNERSHIP.md

## تفسیر درست

این سند ثابت نمی‌کند کد محلی کاربر برابر `main` است. اولین خروجی ایجنت باید `HEAD SHA`, branch, dirty files و version محلی را ثبت کند؛ سپس این baseline عمومی را با وضعیت محلی تطبیق دهد. عدد تست از README نباید به‌عنوان تستی که اکنون اجرا شده معرفی شود.

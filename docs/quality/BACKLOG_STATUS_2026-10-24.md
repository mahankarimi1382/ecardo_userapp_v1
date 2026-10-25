# وضعیت Backlog — 2026-10-24 (به‌روزرسانی کتابدار تسک‌ها)

- **تاریخ ثبت:** 2026-10-24
- **مجری:** کتابدار backlog (سشن code-inspection؛ بدون اجرای Flutter/PHP)
- **شیء تغییر:** فقط ستون `status` در `docs/quality/MASTER_TASK_BACKLOG.csv` (ویرایش جراحی بایت‌به‌بایت با اسکریپت پایتون `docs/quality/_update_backlog_status.py`؛ فقط پسوند `,TODO` انتهای ۳۰ خطِ مجاز جایگزین شد — BOM و CRLF و همهٔ فیلدهای دیگر دست‌نخورده)
- **کامیت مبنا:** `e01aed24190160d8a07352a2680de854be9a534e` (خوانده‌شده با `git rev-parse HEAD` در همین سشن)
- **خلاصهٔ شمارشی:** ۷۸ ردیف داده → **DONE=۲۵**، **BLOCKED=۵**، **TODO=۴۸** (راستی‌آزمایی با `csv.DictReader` پس از نوشتن)

> منبع وضعیت‌ها: اعلان متصدی ورک‌فلو (دستور تسک) به‌علاوهٔ راستی‌آزمایی همین سشن بر وجود فایل‌های شاهد و لنگرهای خطی ارجاعی (با `ls`/`grep`/`sed`). هیچ شاهدی که روی دیسک نبود، ارجاع نشده است.

---

## ۱. DONE — فاز ۰ (ورک‌فلو اول، دیروز)

| task_id | وضعیت | شاهد (مسیر:خط) |
|---|---|---|
| MP-001 | DONE | `docs/quality/BASELINE.md:16,18` (SHA `e01aed24` و شمارش dirty)؛ `docs/quality/WORKSPACE_PROTECTION.md:58-73` (فهرست دستورهای ممنوع و قواعد)؛ `docs/quality/baseline.json:2-6` |
| MP-002 | DONE | `docs/quality/BASELINE.md:16-18`؛ `docs/quality/baseline.json:2-6` — `sha=e01aed24…`، `branch=main`، `version=1.0.182+182`، `dirty_files=29` |
| MP-004 | DONE | `docs/quality/WORKSPACE_PROTECTION.md:58-66` (قواعد ممنوع git/تست موازی)؛ `docs/quality/BASELINE.md:66` (تأیید پچ پشتیبان `userapp-local-work-backup-2026-10-24.patch` با ۲۹ مورد diff) |
| MP-005 | DONE | `docs/quality/WORKSPACE_PROTECTION.md:73` (قاعدهٔ query-پیش‌از-تغییر / update-پس‌از-تغییر گراف) |
| MP-006 | DONE | `docs/quality/WORKSPACE_PROTECTION.md:64-67` (Flutter 3.44.6 فعال در `D:/ecardo-toolchain`؛ ممنوعیت تست موازی مستقل از نصب) |
| MP-007 | DONE | `docs/quality/BASELINE.md:28` (SHA بک‌اند `04a7ec8601fff2c6a2a8ed67773ddbb6718be415`؛ وضعیت دسترسی VERIFIED) |

## ۲. DONE — MP-011 (مخرج‌های استاندارد شمارش)

| task_id | وضعیت | شاهد |
|---|---|---|
| MP-011 | DONE | `docs/quality/CATALOG_COUNT_CONSISTENCY.md:1-9` (تفکیک مخرج ۱۳۷ Route یکتا در برابر ۷۴۰ سطح UI؛ کامیت مبنا `e01aed24`) |

## ۳. DONE — فاز ۲: Transfer/Exchange (ورک‌فلو اول)

| task_id | وضعیت | شاهد |
|---|---|---|
| MP-020 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:14-34` (روش، واژگان verdict و جدول خلاصهٔ §۲) — الگوی شِما/وضعیت per-capability |
| MP-021 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:38-62` (§۳ Transfer؛ verdict BACKEND_IMPLEMENTED در :27؛ گپ‌های صادقانه passcode و transfer/history در :59-60) |
| MP-022 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:64-93` (§۴ Exchange؛ verdict در :28؛ گپ‌های نرخ fee.ecardo.ir در :84 و exchangeHistoryEndpoint بلااستفاده در :89) |

## ۴. DONE — همین دور (2026-10-24)

| task_id | وضعیت | شاهد |
|---|---|---|
| MP-013 | DONE | `docs/quality/MP-013_CHANGELOG.md:1-9` (تنزل صادقانهٔ وضعیت‌ها در ۷۴۰+۷۴۰ ردیف دو کاتالوگ با ویرایش جراحی) |
| MP-010 | DONE | `docs/app-map/MAP_VALIDATION.json` (موجود، ۶۳۳,۹۷۸ بایت؛ `row_count: 740`، `validation: FAIL` ثبت صادقانهٔ خطاها) + ارجاع ساخت در `docs/quality/MP-014_SCAN_RECONCILIATION.md:7` |
| MP-014 | DONE | `docs/quality/MP-014_SCAN_RECONCILIATION.md:1-8` (آشتی‌دادن شمارش دو اسکنر از مسیر پذیرش «مستندسازی تفاوت» + بازشماری فقط-خواندنی) |
| MP-012 | DONE | `docs/app-map/COVERAGE_REPORT.md:18-20` (درصدها با مخرج ۱۳۷) و `:22` (توضیح تجزیهٔ ۷۴۰=۱۳۷+۴۷۵+۷۴+۵۲+۲) |
| MP-018 | DONE | `docs/stage_1/DISCOVERY_SUMMARY.md:63-67` (ارجاع‌های فعلی به `BASELINE.json` و `PROJECT_SURFACE_REPORT.json`؛ ارجاع‌های منقضی حذف‌شده — رأی CLOSED_VERIFIED در `docs/app-map/GAP_REGISTER.csv` ردیف GAP-S2) |
| MP-003 | DONE | `ecardo_userapp_v1/AGENTS.md:17` (`1.0.182+182` — هم‌ارز pubspec؛ رأی CLOSED_VERIFIED در `GAP_REGISTER.csv` ردیف GAP-S1) |
| MP-016 | DONE | `docs/app-map/FLOW_CATALOG.csv` (۱۹ ستونِ قالب استاندارد در خط ۱ + ۱۷ فلو FL-01… با owner/runtime_status/evidence_ref) |
| MP-017 | DONE | `docs/app-map/GAP_REGISTER.csv` (۱۵ ردیف gap شامل GAP-S1…S6 و گپ‌های فلو passcode/endpointهای بلااستفاده با severity/owner/status) |
| MP-023 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:125-143` (§۷.۱ Deposit/Add-money — BACKEND_IMPLEMENTED با ۲ مورد CLIENT_ONLY و ۱ مورد MOCK_ONLY) |
| MP-024 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:145-158` (§۷.۲ Withdraw — هر ۱۰ قابلیت) |
| MP-025 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:160-176` (§۷.۳ Cards — ۹ فلو + CLIENT_ONLY برای سقف/PIN/تعویض) |
| MP-026 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:178-187` (§۷.۴ KYC — هر ۶ قابلیت) |
| MP-027 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:189-202` (§۷.۵ P2P و دامنه‌های باقی) |
| MP-028 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:123` (ادغام ثبت‌شدهٔ MP-023..MP-029)؛ `docs/backend-audit/BACKEND_GAPS.csv:20` (GAP-019 → الزام build-time guard با ارجاع صریح MP-028)؛ `docs/backend-audit/FEATURE_BACKEND_COVERAGE.csv` (۶۳ رجوع mock/sandbox) |
| MP-029 | DONE | `docs/backend-audit/CAPABILITY_STATUS.md:225` (ویرایش جراحی ۴ ردیف + ۳ ردیف جدید در `docs/integration/CONTRACT_REGISTRY.csv` — ثبت‌شده به نام MP-029)؛ `docs/backend-audit/API_CONTRACT_REGISTER.csv` (۲۷ ردیف) |

## ۵. BLOCKED — با دلیل

| task_id | وضعیت | دلیل |
|---|---|---|
| MP-015 | BLOCKED | ابزار `tools/patrol` در ریپو غایب است (غیبتِ ثبت‌شده در شرح خود تسک — `MASTER_TASK_BACKLOG.csv` ردیف MP-015؛ تنها `.agents/skills/patrol-native-e2e` به‌عنوان skill موجود است)؛ sweep ران‌تایم روی ۱۳۷ روت در همین محیط ممکن نیست. عدد Runtime-Verified بدون اجرا درج نشد. |
| MP-015A | BLOCKED | دستگاه موبایل/امولاتور اندروید فعال نیست و دسترسی staging/sandbox نداریم — فقط desktop/windows و مرورگر موجود است؛ اسکرین‌شات خط مبنا روی اپ واقعی ممکن نشد (بند ۴ گیت A با همین دیسپوزیشن قابل بستن است). |
| MP-030 | BLOCKED | نیازمند تصمیم محصول (صاحب پروژه): پیاده‌سازی سمت سرور یا حذف فیلد passcode کلاینت؛ سیم‌کشی یا deprecate ثابت‌های بلااستفاده `api_path.dart:111,123` و مصرف `/user/exchange/rate`. مواد تصمیم آماده است (`CAPABILITY_STATUS.md:59-60,84,89` + گپ‌های GAP_REGISTER)؛ ورودی انسانی مانده است. |
| MP-110 | BLOCKED | اجرای contract test روی sandbox نیازمند اجرای PHP روی سرور/محیط مصوب است (مطابق شرح تسک و قانون ۱ `AGENTS.md` ریشه — سرویس‌دهی روی PC شخصی ممنوع)؛ PHP محلی موجود نیست. |
| MP-111 | BLOCKED | وابسته به MP-110 — تست‌های authorization منفی (نقطهٔ شروع `tests/Feature/Api/HighRiskRoutesTest.php` در بک‌اند) به همان محیط اجرای PHP روی سرور نیاز دارند. |

## ۶. TODO — دست‌نخورده (۴۸ ردیف)

ردپای این سشن در هیچ‌کدام نیست؛ وضعیتشان از قبل و پس از اجرا `TODO` بوده است:

MP-008، MP-019، MP-031، MP-040، MP-041، MP-042، MP-043، MP-044، MP-050، MP-051، MP-052، MP-053، MP-054، MP-055، MP-060، MP-061، MP-062، MP-063، MP-064A، MP-064، MP-065، MP-070، MP-071، MP-072، MP-073، MP-080، MP-081، MP-082، MP-083، MP-090، MP-091، MP-092، MP-093، MP-094، MP-095، MP-100، MP-101، MP-102، MP-103، MP-104، MP-112، MP-113، MP-114، MP-115، MP-120، MP-121، MP-122، MP-123

> **نکتهٔ گیت‌ها:** MP-008 (چک‌لیست خروج فاز ۰) و MP-019 (گیت A) با وجود DONE شدن وابستگی‌هایشان، TODO مانده‌اند — امضای چک‌لیست گیت در دستور این دور اعلام نشد و بدون شاهد بسته نشدند. MP-031 (گیت B) به‌دلیل BLOCKED بودن MP-030 بسته نمی‌شود.

---

## ۷. روش و راستی‌آزمایی (فرمان‌های عیناً اجراشده)

1. **به‌روزرسانی:** `python ecardo_userapp_v1/docs/quality/_update_backlog_status.py` — خروجی: `OK — 30 ردیف status به‌روز شد`؛ شمارش نهایی `TODO=48 DONE=25 BLOCKED=5`؛ اسکریپت پیش از نوشتن اثبات کرد تعداد خطوط تغییر نکرده و هر خط تغییرکرده فقط در پسوند status اختلاف دارد.
2. **راستی‌آزمایی مستقل بایت‌به‌بایت** (علیه نسخهٔ پشتیبان پیش از ویرایش در `C:\Users\talas\AppData\Local\Temp\MASTER_TASK_BACKLOG.csv.bak`): `total split-lines: 80 | differing lines: 30`؛ `all diffs are pure status-suffix changes: True`؛ `BOM preserved: True | pure CRLF: True`؛ فهرست ۳۰ شناسهٔ تغییرکرده دقیقاً با دستور تسک یکی است.
3. **وضعیت git (فقط-خواندنی):** `git rev-parse HEAD` → `e01aed24…`؛ `git status --porcelain` → ۱۱۶ مورد. `docs/quality/` کاملاً untracked است؛ یعنی `MASTER_TASK_BACKLOG.csv` جزو ۲۹ فایل dirty مبنایی (`BASELINE.md:18`) نبود.

## ۸. یادداشت‌های صداقت

- قضاوت DONE/BLOCKED بر اساس اعلان متصدی (دستور تسک) است؛ این سشن وجود فایل‌های شاهد و لنگرهای خطی ارجاعی را راستی‌آزمایی کرد (ls/grep/sed در همین اجرا). محتوای کامل هر سند شاهد راستی‌آزمایی سطری نشده است.
- `git status` امروز ۱۱۶ ورودی نشان می‌دهد در برابر dirty=۲۹ مبنایی — این افق حاصل کار مستندِ سشن‌های دیگر همین روز است (از جمله ۹۹ فایل `lib/` که پیش از این سشن تغییر کرده بودند). **ردپای این سشن فقط ۳ فایل است:** ویرایش جراحی ستون status در `MASTER_TASK_BACKLOG.csv` (دستور تسک) + دو فایل جدید `docs/quality/_update_backlog_status.py` و همین سند. هیچ فایل `lib/`، هیچ‌یک از فایل‌های dirty بالادستی، و هیچ فایل ردیابی‌شدهٔ دیگری دست نخورد.
- هیچ دستور نوشتاری git (add/commit/push/stash/checkout/reset) اجرا نشد؛ فقط `git rev-parse HEAD` و `git status --porcelain` (خواندنی).
- `python -m graphify update .` اجرا نشد زیرا این دور فقط مستندات تغییر داد (ستون status یک CSV + دو فایل جدید)، نه کد — مطابق رأی ثبت‌شدهٔ مشابه در `docs/backend-audit/CAPABILITY_STATUS.md:225` (قانون ۲ `AGENTS.md` ناظر به تغییر کد است).
- Flutter/PHP اجرا نشدند (این اجرا code-inspection است؛ ممنوعیت تست/اجرای موازی رعایت شد).

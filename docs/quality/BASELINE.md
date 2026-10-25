# خط مبنا (Baseline) — ecardo_userapp_v1

- **تاریخ ثبت:** 2026-10-24
- **ثبت‌کننده:** متصدی ثبت خط مبنا و اسناد محافظت ورک‌اسپیس
- **دامنه:** وضعیت قطعی ورک‌اسپیس eCardo در لحظهٔ ثبت؛ این سند مرجع مقایسهٔ تمام تغییرات آتی است و خودش نباید بی‌ثبتِ خط مبنا جدید دست‌کاری شود.

> همهٔ مقادیر این سند در تاریخ 2026-10-24 با دستورهای خواندنی اثبات شده‌اند (`git rev-parse HEAD`، `git branch --show-current`، `git status --porcelain`، `flutter --version`، `python --version`، `node --version`، `command -v php`). هیچ مقداری حدس زده یا از حافظه نوشته نشده است. نسخهٔ ماشین‌خوان این سند: `docs/quality/baseline.json`.

---

## ۱. حقایق قطعی — ریپوی اپلیکیشن کاربر

| مورد | مقدار | مبنا/اثبات (اجراشده در 2026-10-24) |
|---|---|---|
| نام ریپو | `ecardo_userapp_v1` | پوشهٔ ریپو + `git remote -v` → origin به `github.com/mahankarimi1382/ecardo_userapp_v1.git` |
| SHA کامیت HEAD | `e01aed24190160d8a07352a2680de854be9a534e` | `git rev-parse HEAD` |
| شاخهٔ فعال | `main` | `git branch --show-current` |
| تعداد فایل تغییرمحلی (dirty) | **۲۹** | شمارش خروجی `git status --porcelain` → 29 |
| نسخهٔ اپلیکیشن | `1.0.182+182` | `pubspec.yaml` خط ۶: `version: 1.0.182+182` |

فهرست کامل ۲۹ فایل تغییرمحلی در `docs/quality/WORKSPACE_PROTECTION.md` (قاعدهٔ ۱) ثبت شده است.

## ۲. حقایق قطعی — بک‌اند

| مورد | مقدار | مبنا/اثبات (اجراشده در 2026-10-24) |
|---|---|---|
| نام ریپو | `ecardo-backend` | پوشهٔ `ecardo/ecardo-backend` |
| SHA کامیت HEAD | `04a7ec8601fff2c6a2a8ed67773ddbb6718be415` | `git rev-parse HEAD` در `ecardo-backend` |
| شاخهٔ فعال | `feat/uiux-v180-backend` | `git branch --show-current` در `ecardo-backend` |

### ۲.۱ بازپین خط مبنا (2026-10-24، عصر)

در حین اجرای فاز ۰-۲، HEAD بک‌اند با ۶ کامیتِ همان‌روزِ شاخهٔ `agent-financial-ui-rtl` جلو رفت: خط مبنا به‌روزرسانی شد.

- **SHA جدید خط مبنا:** `7a1ae8a0ae0a5551da18d53f6ebb4af320a4d160` (`git rev-parse HEAD`) — در `baseline.json` هم اعمال شد.
- فایل‌های تغییرکرده از `04a7ec86` تا `7a1ae8a0` (خروجی `git diff --name-only 04a7ec86..HEAD`): `app/Console/Commands/{BackfillDefaultWallets,OpsCheck,RepairLedgerAccounts}.php`، `app/Http/Controllers/Api/Auth/User/RegisterController.php`، `app/Http/Controllers/Api/WalletController.php`، `app/Http/Resources/WalletResource.php`، `app/Services/Core/LedgerService.php`.
- **هم‌پوشانی با استنادهای ممیزی:** هیچ‌کدام از فایل‌های استنادی SEC-1..SEC-5 و فلوهای Transfer/Exchange/Withdraw/Cards/KYC/P2P تغییر نکردند؛ فقط `WalletController.php` (اندپوینت `GET /user/wallets` که فلو Exchange برای فهرست کیف‌ها صدا می‌زند) در کامیت `512b3a9` رفتار IR-fallback گرفت — جزئی و غیرباطل‌کننده؛ در ممیزی بعدی دوباره بررسی شود.
- استنادهای خطی ممیزی‌های انجام‌شده به SHA قبلی (`04a7ec86`) معتبر می‌مانند چون فایل‌های مربوطه دست‌نخورده‌اند.

## ۳. وضعیت graphify (عیناً، بدون تغییر)

```text
exit=0؛ Graph: graphify-out/graph.json (199963 nodes) | Traversal: BFS depth=2 | Start: ['ecardo-backend/tests/Feature/Api/HighRiskRoutesTest.php', 'repositories', 'dependencies', 'Routes', 'Tests', 'Map', '_
```

- **صحت‌سنجی مستقل (اجراشده):** فایل `graphify-out/graph.json` (حجم ۱۸۹,۶۲۶,۰۷۹ بایت، مورخ 2026-10-24) با اسکریپت پایتون شمارش شد و خروجی `nodes: 199963` داد — با عدد اعلام‌شده در رشتهٔ بالا مطابق است.
- **صادقانه:** اجزای دیگر رشته (`Traversal: BFS depth=2` و فهرست `Start:` که در منبع ورودی ناقص/بریده آمده) از وضعیت ثبت‌شدهٔ ورودی عیناً نقل شده‌اند و جداگانه بازتولید نشدند؛ فقط وجود فایل گراف و تعداد نودها مستقلاً اثبات شد.

## ۴. بسته‌های ورودی

سه بستهٔ ZIP ورودی استخراج شده‌اند و در `C:/ec_packs` موجودند (بررسی مستقیم پوشه در 2026-10-24):

| بسته | مسیر | محتوای سطح اول (نمونه، از `ls`) |
|---|---|---|
| p1_stage1 | `C:/ec_packs/p1_stage1` | `00_READ_FIRST`, `01_PROMPTS`, `02_SCRIPTS`, `03_TEMPLATES`, `04_PUBLIC_BASELINE` |
| p2_integration | `C:/ec_packs/p2_integration` | `00_README_FA.md`, `01_MASTER_PLAN`, `02_ARCHITECTURE_AND_CONTRACTS`, `03_CATALOGS`, `04_AGENT_PLAYBOOKS` |
| p3_uiux_backend | `C:/ec_packs/p3_uiux_backend` | `00_START_HERE`, `01_ROADMAP`, `02_AGENT_PROMPTS`, `03_CATALOG_TEMPLATES`, `04_EXAMPLE_SPECS` |

## ۵. ابزارهای موجود روی این ماشین

| ابزار | وضعیت | نسخه | مبنا/اثبات (اجراشده در 2026-10-24) |
|---|---|---|---|
| Python | نصب است | 3.13.5 | `python --version` → Python 3.13.5 |
| Node.js | نصب است | v22.23.3 | `node --version` → v22.23.3 |
| git | نصب است | 2.55.0.windows.3 | `git --version` |
| PHP | نصب نیست | — | `command -v php` → NOT_FOUND |
| Flutter | **نصب و فعال است** | 3.44.6 (Dart 3.12.2) | `flutter --version` → exit=0؛ مسیر: `D:/ecardo-toolchain/flutter` |

### اختلاف با فرض اولیهٔ دستور

اطلاعات اولیهٔ ورک‌اسپیس می‌گفت «Flutter نصب نیست»؛ بازبینی 2026-10-24 نشان داد Flutter 3.44.6 در `D:/ecardo-toolchain/flutter` فعال است (خروجی اجراشدهٔ `flutter --version`: «Flutter 3.44.6 • channel stable … Tools • Dart 3.12.2»، exit=0). به همین دلیل مقدار `flutter_available` در `baseline.json` بر اساس مشاهدهٔ مستقیم `true` ثبت شده است. این اختلاف پیش از ثبت، به مالک پروژه escalate شد و با تصمیم صریح او (2026-10-24) به همین صورت درج گردید. قاعدهٔ «تست موازی flutter ممنوع در worktree مشترک و تست سریال نهایی فقط توسط Integrator» فارغ از مقدار این فیلد پابرجاست (→ `WORKSPACE_PROTECTION.md`، قاعدهٔ ۴).

## ۶. پشتیبان تغییرات محلی

- فایل `userapp-local-work-backup-2026-10-24.patch` (حجم ۱۲۹,۲۳۱ بایت، مورخ 2026-10-24، در ریشهٔ ورک‌اسپیس `ecardo/`) شامل **۲۹ مورد diff** است (شمارش `grep -c "^diff --git"` → 29) — هم‌شمار با ۲۹ فایل تغییرمحلی قاعدهٔ ۱؛ نخستین فایل پچ نیز با نخستین فایل dirty یکسان است. **صادقانه:** تطابق تک‌به‌تک هر ۲۹ مسیر بین پچ و `git status --porcelain` به‌صورت کامل بازبینی نشد؛ فقط هم‌شمار بودن و تطابق مورد اول بررسی شد.

## ۷. اسناد و قواعد مرتبط

- قواعد محافظت ورک‌اسپیس: `docs/quality/WORKSPACE_PROTECTION.md`
- نسخهٔ ماشین‌خوان خط مبنا: `docs/quality/baseline.json`
- قواعد الزامی ورک‌اسپیس: `AGENTS.md` در ریشهٔ `ecardo/` — قانون ۱ (خط ۳): ممنوعیت وابستگی production به سیستم شخصی کاربر؛ قانون ۲ (خط ۱۱): الزام پیش‌برد همه‌چیز بر اساس گراف پروژه و به‌روزرسانی مداوم آن.

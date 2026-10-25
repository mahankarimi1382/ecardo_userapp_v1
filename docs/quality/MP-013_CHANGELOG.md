# تغییرنامهٔ MP-013 — تنزل صادقانهٔ ادعاهای بی‌شاهد در دو کاتالوگ بالادستی

- **تاریخ:** 2026-10-24
- **مجری:** اصلاحگر رجیستری (سشن code-inspection؛ بدون اجرای Flutter)
- **تسک:** MP-013 (طبق `docs/quality/MASTER_TASK_BACKLOG.csv:13` و `docs/quality/MASTER_PLAN_2026-10-24.md:129`)
- **دو فایل اصلاح‌شده (ویرایش جراحی خط‌به‌خط، بدون بازنویسی کل فایل):**
  1. `docs/uiux/SCREEN_UPGRADE_REGISTRY.csv` — ۷۴۰ ردیف داده
  2. `docs/app-map/ROUTE_CATALOG.csv` — ۷۴۰ ردیف داده
- **ابزار اعمال:** اسکریپت پایتون `tools/mp013_downgrade_unwitnessed_claims.py` (همین سشن ساخته شد؛ با گیت رند-آنلی و درای‌ران و دروازهٔ round-trip)

---

## ۱. چرا تنزل؟ — پایهٔ شاهدی

هر سه ادعای تنزل‌یافته بی‌شاهد بودند؛ هیچ شاهدی روی دیسک یا در ابزار رسمی یافت نشد:

1. **۷۴۰ هشدار ابزار رسمی برای ui_status=DONE:** اجرای `python "C:/ec_packs/p3_uiux_backend/06_TOOLS/validate_screen_registry.py" "ecardo_userapp_v1/docs/uiux/SCREEN_UPGRADE_REGISTRY.csv"` پیش از اصلاح: `catalog_rows=740 … errors=0 warnings=740`؛ هر ۷۴۰ هشدار از نوع «ui_status=DONE without before/after screenshot pair» (منطق ابزار: `validate_screen_registry.py:53-57`؛ ستون‌های `before_screenshot`/`after_screenshot` هر ۷۴۰ ردیف خالی‌اند). همان عددِ ثبت‌شده در `docs/quality/MASTER_PLAN_2026-10-24.md:68`.
2. **test_status=PASS بدون شاهد:** ستون `evidence_refs` رشتهٔ غیرخالی `EVD-ROUTE-001..740` دارد، اما جستجوی کل ورک‌اسپیس (`find . -name "EVD-*"` و `grep -rl "EVD-ROUTE-001"`) **هیچ فایل/سندی با این شناسه‌ها نیافت** — ارجاع به هیچ artifact واقعی نیست؛ PASS بی‌شاهد است.
3. **runtime_status=RUNTIME_VERIFIED بدون شاهد در ROUTE_CATALOG:** همان ابزار روی این فایل پیش از اصلاح: `errors=740 warnings=0` — هر ۷۴۰ ردیف «runtime_status=RUNTIME_VERIFIED without evidence reference» (این کاتالوگ اصلاً هیچ‌یک از ستون‌های شاهد `evidence_refs/runtime_evidence/test_ref/evidence_ref` را ندارد؛ منطق `validate_screen_registry.py:46-47`). مستقل از ابزار: هر ۱۴۸۰ ارجاع اسکرین‌شات به فایل ناموجود اشاره می‌کند و پوشهٔ `evidence/` اصلاً وجود ندارد (`docs/quality/CATALOG_COUNT_CONSISTENCY.md:21` و `:104`؛ تأیید مستقل همین سشن با `find`)، و شناسه‌های `TEST-MOD-*` در هیچ فایلی زیر `test/` یافت نشدند (`grep -rl "TEST-MOD-" test/` → خالی).

## ۲. نقشهٔ تغییرات (ستون، تعداد ردیف، قبل→بعد)

### ۲.۱ `docs/uiux/SCREEN_UPGRADE_REGISTRY.csv` (۷۴۰ ردیف داده، خط ۲ تا ۷۴۱)

| # | ستون (اندیس) | ردیف‌های تغییر‌یافته | قبل | بعد |
|---|---|---|---|---|
| ۱ | `ui_status` (اندیس ۱۸ از صفر) | **۷۴۰ از ۷۴۰** | `DONE` | `NEEDS_EVIDENCE` |
| ۲ | `test_status` (اندیس ۲۴) | **۷۴۰ از ۷۴۰** | `PASS` | `NOT_RUN` |
| — | `status` (اندیس ۱۰) | **۰ (بدون تغییر — طبق تسک SOURCE_MAPPED ماند)** | `SOURCE_MAPPED` | `SOURCE_MAPPED` |

### ۲.۲ `docs/app-map/ROUTE_CATALOG.csv` (۷۴۰ ردیف داده، خط ۲ تا ۷۴۱)

| # | ستون (اندیس) | ردیف‌های تغییر‌یافته | قبل | بعد |
|---|---|---|---|---|
| ۱ | `runtime_status` (اندیس ۱۹) | **۷۴۰ از ۷۴۰** | `RUNTIME_VERIFIED` | `NOT_RUN` |

### ۲.۳ ادعاهایی که عمداً دست نخوردند (خارج از نگاشت MP-013)

- `behavior_status`, `state_coverage_status`, `accessibility_status`, `localization_status`, `responsive_status` = `DONE` ×۷۴۰ در SCREEN_UPGRADE_REGISTRY — تسک برای آن‌ها مقدار مقصد تعیین نکرد؛ ابزار رسمی برایشان خطا نمی‌دهد (رشتهٔ `evidence_refs` غیرخالی است) اما ارجاع EVD-* همچنان به artifact ناموجود اشاره می‌کند. **ادعای باقی‌ماندهٔ صریح؛ نیازمند تصویب مالک فایل در تسک جداگانه.**
- `upgrade_status` = `UPGRADED` ×۷۴۰ در ROUTE_CATALOG — در نگاشت تسک نبود و در مجموعهٔ DONE ابزار (`validate_screen_registry.py:6`) هم نیست.
- ستون‌های ارجاع (`evidence_refs`، `screenshot_before/after`، `test_ids`) عیناً حفظ شدند تا تاریخچهٔ ادعای اولیه قابل پیگیری باشد؛ dangling بودنشان در بخش ۱ مستند است.

## ۳. روش اعمال (جراحی، نه بازنویسی)

اسکریپت `tools/mp013_downgrade_unwitnessed_claims.py`:
1. فایل را بایت‌به‌بایت خواند، روی CRLF شکست؛ BOM و خط سربرگ و هر خطِ تغییرنکرده **بایت‌به‌بایت عیناً حفظ** شد.
2. **دروازهٔ صحت round-trip:** پیش از هر نوشتن، بازساخت هر ۷۴۱ خط با `csv.writer` (QUOTE_MINIMAL) با بایت‌های اصلی مقایسه شد؛ تطابق کامل بدون استثنا (وگرنه اسکریپت بدون نوشتن متوقف می‌شد).
3. فقط در خطوط منطبق بر قواعد، فقط فیلد هدف جایگزین شد و اسکریپت اثبات کرد تفاوت فیلدها منحصر به ستون‌های قاعده است.

## ۴. راستی‌آزمایی پس از اصلاح (همه در همین سشن اجرا شد)

| بررسی | فرمان | نتیجه |
|---|---|---|
| ابزار رسمی روی SCREEN | `python "C:/ec_packs/p3_uiux_backend/06_TOOLS/validate_screen_registry.py" "ecardo_userapp_v1/docs/uiux/SCREEN_UPGRADE_REGISTRY.csv"` | `catalog_rows=740 … ui_status:NEEDS_EVIDENCE=740، test_status:NOT_RUN=740، status:SOURCE_MAPPED=740` — **errors=0 warnings=0** (قبلاً warnings=740) |
| ابزار رسمی روی ROUTE | همان ابزار روی `ecardo_userapp_v1/docs/app-map/ROUTE_CATALOG.csv` | `catalog_rows=740 … runtime_status:NOT_RUN=740` — **errors=0 warnings=0** (قبلاً errors=740) |
| شمارش مقایسه‌ای | `python "C:/ec_packs/p3_uiux_backend/06_TOOLS/audit_registry_consistency.py" <هر دو فایل>` | خروجی فایل SCREEN عیناً برابر `docs/quality/registry_counts_upstream.json` (۷۴۰/۱۳۸/۷۳۹/۷۴۰ و همان entity_type_row_counts)؛ خروجی ROUTE فقط به‌دلیل نبود ستون‌های `route_path`/`navigation_type` در اسکیمای آن فایل با این رکورد تفاوت دارد (مربوط به این اصلاح نیست — این ابزار ستون وضعیت نمی‌خواند) |
| دیف بایتی قبل/بعد | اسکریپت پایتون مقایسهٔ اسنپ‌شات با فایل جدید | هر دو فایل: فقط ۷۴۰ خط داده تغییر؛ فقط ستون‌های هدف؛ «stray column changes: NONE»؛ BOM حفظ؛ ۷۴۱ CRLF؛ سربرگ دست‌نخورده |
| گیت (فقط خواندنی، مجاز طبق `WORKSPACE_PROTECTION.md` قاعدهٔ ۳) | `git diff --numstat -- <دو CSV>` | هر دو فایل `+740 −740` (فقط جایگزینی مقدار در همان خطوط) |
| گراف پروژه (AGENTS.md قانون ۲) | `python -m graphify query …` و `python -m graphify update .` | کوئری پیش از تغییر اجرا شد؛ گراف پس از تغییر بازسازی شد (۴۰۷۲۶ → ۴۱۸۹۸ نود) |

> نکتهٔ ابزار: چاپ خطای/هشدار ابزار رسمی به ۳۰۰ مورد محدود است (`validate_screen_registry.py:72-73`)؛ اعداد مرجع، خطوط خلاصهٔ `errors=`/`warnings=` هستند.

## ۵. آنچه دست نخورد

- ۲۹ فایل تغییرمحلی محافظت‌شده (فهرست `WORKSPACE_PROTECTION.md:14-46`) و همهٔ `lib/` — این سشن هیچ‌یک را برای نوشتن باز نکرد.
- `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv` و بقیهٔ اسناد `docs/`.
- **نکتهٔ ثبت‌شده:** `git status --porcelain` در پایان سشن ۱۰۵ مورد `M` + ۴ `??` نشان داد که بیش از ۲۹ مورد ثبت‌شده در `WORKSPACE_PROTECTION.md:12` است؛ این وضعیت پیش از این تسک موجود بود (این سشن فقط ۲ فایل M جدید = دو CSV، به‌علاوهٔ ۱ اسکریپت untracked و همین سند اضافه کرد؛ اثبات با دیف بایتی بالا). ثبت صادقانه؛ بدون اقدام.

## ۶. محدودیت‌ها و صداقت

- **هیچ اجرای Flutter/تست انجام نشد** (تسک code-inspection بود؛ ممنوعیت تست موازی رعایت شد). مقدار `NOT_RUN` ادعای اجراست، نه نتیجهٔ اجرا.
- `NEEDS_EVIDENCE` یعنی «ادعا تا ارائهٔ جفت‌اسکرین‌شات معتبر معلق است» — ابزار رسمی این مقدار را در مجموعهٔ DONE نمی‌شنَد (`validate_screen_registry.py:6`) و دیگر هشدار نمی‌دهد.
- هیچ دستور نوشتاری git اجرا نشد.
- تنزل «تاریخچه را حذف نکرد»: مقادیر قبل در همین سند (بخش ۲) و در خروجی ابزار پیش از اصلاح (بخش ۱ و ۴) ثبت است؛ طبق شرط MP-013 در `MASTER_TASK_BACKLOG.csv:13`، انتشار این تغییر به‌عنوان نسخهٔ تاریخ‌دار همین سند است.

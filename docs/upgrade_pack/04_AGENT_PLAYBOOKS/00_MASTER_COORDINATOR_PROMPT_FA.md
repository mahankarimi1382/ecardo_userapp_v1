# پرامپت اصلی هماهنگ‌کنندهٔ eCardo — کشف، یکپارچه‌سازی و ارتقای تمام اپ

شما Integrator اصلی پروژهٔ Flutter eCardo هستید. مأموریت شما اصلاح چند صفحه نیست؛ باید تمام اپلیکیشن، routeها، overlayها، فلوهای تجاری، منطق‌های مالی، APIها، امنیت، localization، accessibility، performance و تست‌هایش را به شکل evidence-driven ارتقا دهید. این سند همراه `01_MASTER_PLAN/01_MASTER_ROADMAP_FULL_APP_FA.md` و دستورهای محلی پروژه اجرا می‌شود.

## Non-negotiable safety
- هیچ Push, tag, Release یا Deploy نکن.
- هیچ تغییر مالی live و هیچ انتقال/پرداخت واقعی برای تست اجرا نکن؛ فقط sandbox/test data مجاز.
- هیچ `git checkout`, `git stash`, `reset --hard` یا حذف تغییرات دیگران. اول working tree را بخوان و دست‌نخورده حفظ کن.
- دستورهای `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, `PRE_PUSH_CHECK.md` مقدم‌اند.
- طبق guide موجود، اول `graphify query`؛ بعد source exploration. بعد از تغییر، Graphify را update کن یا blocker را ثبت کن.
- ایجنت‌های موازی `flutter test` اجرا نکنند؛ final test را integrator به‌صورت سریال اجرا کند. عامل‌ها تنها روی فایل‌های متعلق به خود `flutter analyze` انجام دهند، اگر guide آن را مجاز می‌داند.
- فایل‌های global colors/spacing/themes و `common/widgets/design_system/**` با owner و handoff محافظت شوند.

## Gate A — Discovery, no broad edits
1. ثبت SHA، branch، status، Flutter/Dart، version، test state و release baseline.
2. اجرای `python3 scripts/scan_flutter_app.py --root . --out docs/app-map/generated` یا نسخهٔ هم‌مسیر داخل package.
3. route source + navigation calls + nested/overlay/tab/deep link/runtime walk را با هم reconcile کن.
4. تهیهٔ page-to-controller-to-service-to-API-to-model-to-test matrix.
5. ایجاد findings بر اساس P0–P3 با evidence واقعی. حدس را hypothesis label کن.
6. تا تکمیل inventory و لیست blockers، redesign گسترده را شروع نکن. اگر یک P0 فوری امنیتی/مالی پیدا شد، containment/fix محدود مجاز است و evidence لازم دارد.

## Gate B — Contracts first
1. منبع حقیقت برای هر داده و ماژول مشخص کن.
2. error/status/retry/idempotency/amount/fee/quote contracts را مستند کن.
3. هر معماری یا package change مهم: ADR + PoC + rollback.
4. GetX/Dio و current design system را حفظ کن مگر شواهد قوی علیه آن‌ها وجود داشته باشد.

## Gate C — Full-surface implementation
- هر صفحه و overlay از کاتالوگ یک task ID، owner، page spec، state matrix، tests و screenshot evidence می‌گیرد.
- ترتیب اصلاح بر اساس ریسک و وابستگی است: P0 مالی/auth/security، shared contracts, critical flows, remaining pages, polish.
- UI و domain behavior همزمان بررسی شوند؛ در UI درمان موقتی برای ایراد backend/contract نساز.
- CTA no-op، fake/mock success، hard-coded balance/fee/rate/address و default-success receipt را پیدا و اصلاح/flag کن.
- هر feature کارآمد فعلی حفظ شود؛ حذف behavior فقط با proof و regression tests.

## Gate D — Testing & final evidence
- تمام route statuses, test IDs, source SHA, screenshots, test commands/exit codes ثبت شوند.
- status `BLOCKED` و `DEFERRED` را به زور PASS نکن.
- uncovered route/unknown status باعث شکست completeness claim می‌شود.
- final report بر اساس شمارش route discovery vs runtime vs upgraded vs tested باشد.
- پایان کار به معنی پایان scope محلی است، نه مجوز انتشار remote.

## تقسیم عامل‌ها
استفاده از `01_DISCOVERY_AGENT_PROMPT_FA.md`, `02_API_RESILIENCE_AGENT_PROMPT_FA.md`, `03_FINANCIAL_DOMAIN_AGENT_PROMPT_FA.md`, `04_UIUX_AGENT_PROMPT_FA.md`, `05_QA_AGENT_PROMPT_FA.md`, `06_SECURITY_I18N_PERF_AGENT_PROMPT_FA.md`.
برای هر عامل، task IDs، مسیرهای فایل مجاز، dependent outputs و acceptance criteria ارسال کن. ادغام فقط توسط integrator.

## پاسخ نهایی اجباری
- Scope دقیق و SHA
- inventory counts (source candidates/confirmed/runtime/upgraded/tested/blocked/deferred)
- فایل‌های تغییرکرده با توجیه
- test runs و exit codes
- before/after screenshots and artifact locations
- P0/P1 open issues
- گزارش مواردی که به دلیل ابزار/دسترسی/backend قابل اثبات نبودند
- explicit confirmation: هیچ remote push/release/deploy انجام نشده است

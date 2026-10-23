# نقشهٔ راه اصلی eCardo: یکپارچه‌سازی و ارتقای کامل همهٔ صفحات و منطق‌ها

## مقصد نهایی

eCardo باید به محصولی منسجم تبدیل شود که تمام بخش‌های رابط کاربری، ماژول‌های مالی، سرویس‌های Backend/API، وضعیت‌های عملیاتی، ناوبری و تست‌هایش یک قرارداد مشترک داشته باشند. معیار موفقیت «تغییر رنگ و فاصله» یا ارتقای چند صفحهٔ منتخب نیست؛ معیار آن است که هیچ Route، صفحهٔ تو در تو، overlay، فلو یا ماژول تجاریِ کشف‌شده بدون وضعیت، مالک، قرارداد، تست و تصمیم نهایی رها نشود.

## اصول تغییرناپذیر

1. وضعیت واقعی Backend مرجع حقیقت برای balance، transaction status، fee، rate، limit، eligibility، card state و crypto address/network است.
2. UI نباید منطق حسابداری، محاسبهٔ مبلغِ مرجع یا تصمیم مجوز را مالک شود.
3. هر عملیات مالی باید کنترل تکرار، timeout، نتیجهٔ نامعلوم، retry امن و reconciliation داشته باشد؛ timeout به معنی failure قطعی نیست.
4. رابط کاربری باید برای تمام وضعیت‌های معتبر، از جمله loading/stale/empty/error/offline/pending/unknown/blocked/success، رفتار مشخص داشته باشد.
5. GetX/Dio و design system فعلی ابتدا تقویت می‌شوند؛ مهاجرت معماری یا dependency تنها با شواهد، ADR و PoC.
6. برنامه بر اساس inventory واقعی حرکت می‌کند. اعداد README یا لیست تخمینی صفحه جای استخراج از checkout را نمی‌گیرند.
7. هیچ push، tag، release یا deploy بدون تأیید صریح انجام نمی‌شود.

## فاز 0 — محافظت از checkout و ثبت baseline (روز 1–3)

- خواندن کامل `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, `PRE_PUSH_CHECK.md` و دیگر اسناد محلی.
- اجرای `graphify query` پیش از کاوش خام سورس، طبق guide فعلی پروژه.
- ثبت `git status`, branch، SHA کامل، diff موجود، `pubspec.yaml`, `pubspec.lock`, Flutter/Dart، CI و latest release tag؛ هر اختلاف صریح ثبت شود.
- ممنوع: `git checkout`, `git stash`, `reset --hard`، پاک کردن تغییرات دیگران، تست موازی ممنوع‌شده، push/release/deploy.
- تهیهٔ گزارش ریسک اولیه و فهرست فایل‌های مالکیت‌قفل‌شده.

**خروجی/قبولی:** `BASELINE.md` دارای SHA و ابزارهای دقیق؛ zero accidental edits؛ دستورهای اجرا ثبت شده‌اند.

## فاز 1 — کشف صددرصدی ساختار و مسیرها (روز 4–10)

- اجرای اسکنر Dart در `06_SCRIPTS/scan_flutter_app.py` و بازبینی نتایج دستی.
- استخراج route declarations، navigation calls، screen/widget candidates، controllers، services، repositories، API calls، models، ARB/locales، tests و assets.
- کشف overlayها، nested routes، تب‌ها، multi-step forms، deep linkها، permission-gated screens، notification entry points و dynamic routes.
- ربط‌دادن هر screen به flow، controller/state owner، service/repository، endpoint، model، test، localization keys و owner.
- دسته‌بندی code-only (فقط در سورس)، runtime-verified، unreachable، duplicate، obsolete، hidden/permission-gated و unresolved.
- اجرای مسیرها در محیط test با حساب/دادهٔ مجاز و گرفتن screenshotهای نام‌گذاری‌شده.

**قبولی:** هیچ route/screen-like class بدون دسته‌بندی نمانده؛ موارد dynamic/unreachable و مواردی که backend/access ندارند explicit هستند؛ unresolvedها پنهان نمی‌شوند.

## فاز 2 — قراردادهای مشترک و تصمیم‌های معماری (روز 8–18)

- تعیین قرارداد خطا، loading, stale cache, empty, offline, retry و unknown state.
- تعریف ownership هر داده: balance، transfer، fee/rate quote، card, KYC, wallet address, transaction, notification و support ticket.
- تعریف قرارداد بین moduleها و سازگاری data types؛ جلوگیری از دو منبع حقیقت برای وضعیت تراکنش.
- تعیین rules برای money/decimal/rounding/currency precision، idempotency، optimistic update و rollback.
- تعریف استاندارد naming، navigation, logs, analytics privacy، localization و error mapping.
- ایجاد/تکمیل ADR برای هر تغییر معماری یا dependency مهم.

**قبولی:** `CONTRACT_MATRIX.csv`، `API_ERROR_CONTRACT.md` و `FINANCIAL_INVARIANTS.md` تأیید شده‌اند؛ هیچ اختلاف بحرانی پنهان نیست.

## فاز 3 — زیرساخت مشترک اپ (هفتهٔ 3–5)

- تکمیل network/auth/refresh/session handling مشترک در ساختار موجود.
- یکپارچه‌سازی Result/Error mapping، pagination، request cancellation، timeout، connectivity/stale handling و retry policy.
- تجمیع form field/amount/currency/fee/status/receipt/empty/error/loading primitives با حفظ API و ownership فعلی design system.
- رفع CTAهای بی‌عملکرد و success نمایش‌داده‌شده بدون تأیید Backend.
- اصلاح navigation/back stack/session expiration/deep links و restore state.
- یکسان‌کردن logging و telemetry بدون PII.

**قبولی:** هر سرویس API الگوی consistent دارد؛ همهٔ state widgets منبع داده/رفتار مشخص دارند؛ shared components مالک و تست دارند.

## فاز 4 — هستهٔ مالی و تراکنش‌ها (هفتهٔ 4–9)

به ترتیب وابستگی: amount/currency primitives → fee/rate quote → transfer → exchange → withdraw/cashout → transaction history/detail/receipt → bills/payments → QR/receive/request money.

برای هر flow:
- ثبت flow map و domain rules.
- قرارداد request/response و mapping خطاهای Backend.
- state machine از draft تا review، submit، pending، success/failure/unknown و reconciliation.
- review screen با مبدا، مقصد، دارایی/ارز، مبلغ، breakdown هزینه و مبلغ نهایی؛ quote expiry و limits.
- جلوگیری از double submission، retry ناامن و fake-success؛ نتیجهٔ نامعلوم با lookup transaction status حل شود.
- unit/widget/integration/E2E tests، screenshotها و accessibility.

**قبولی:** در سناریوهای timeout/reconnect هر عملیات با همان idempotency key یا reconciliation امن تعیین تکلیف می‌شود؛ وضعیت pending/unknown به موفقیت جعلی تبدیل نمی‌شود.

## فاز 5 — حساب، کیف پول، کارت و رمزارز (هفتهٔ 7–12)

- account/wallet list/detail/create/switch/close؛ موجودی available/pending و stale state.
- cards: list/detail/create/freeze/unfreeze/limits/funding/fees/provider eligibility/issuance status.
- crypto wallet: asset/network pairing, address, QR, deposit status, withdrawal fee, confirmations, min/max and provider outage.
- احراز صلاحیت از Backend؛ عدم استفاده از fallback address، نرخ یا eligibility محلی.
- کارت/کیف پول/حساب با activity، notifications و receipt هماهنگ باشند.

**قبولی:** عملیات غیرمجاز در UI قابل شروع نیست و Backend هم آن را enforce می‌کند؛ هر تغییر status با منبع حقیقت و زمان refresh مشخص است.

## فاز 6 — احراز هویت، KYC، امنیت، پروفایل و پشتیبانی (هفتهٔ 9–14)

- splash/onboarding/register/login/OTP/passcode/biometrics/session expiration/recovery.
- KYC states: incomplete/submitted/under-review/approved/rejected/expired/action-required.
- profile, limits, statements, notifications, help/tickets, language/theme/privacy/legal/settings.
- امنیت log و screenshot، redaction، clipboard، session invalidation، rate limits و error messages.
- وضعیت ticket و عملیات حساس idempotent باشد تا retry تکراری duplicate ایجاد نکند.

**قبولی:** مسیرهای ورود و احراز هویت state-machine و tests دارند؛ هیچ credential/token/passcode/PII در telemetry ظاهر نمی‌شود.

## فاز 7 — تجربهٔ یکپارچهٔ کل صفحات (موازی از هفتهٔ 3 تا 16)

- ابتدا چهار Pilot: Home, Wallet Details, Transfer Review, Transaction Receipt.
- پس از تأیید tokens و component API، الگوها را به تک‌تک Routeها، overlays، nested screens و states اعمال کن.
- هر صفحه page spec و evidence قبل/بعد دارد؛ نه فقط main state بلکه empty/loading/error/offline/pending/disabled/large text/RTL هم پوشش داده می‌شود.
- حفظ برند eCardo؛ از XPay/xMoney/xPortal/Wise/Revolut الگوی محصولی بیاموز، اما هویت/دارایی/کد را بدون مجوز کپی نکن.
- تمام visible CTAها نتیجهٔ واقعی یا disabled reason دارند؛ همهٔ statusها با متن/icon و رنگ قابل‌تشخیص‌اند.

**قبولی:** هر `ROUTE_CATALOG` item به component usage, spec, screenshot, tests و status متصل است. routeهای خارج از کاتالوگ مشمول gate می‌شوند.

## فاز 8 — Localization، RTL، Accessibility و محتوا (هفتهٔ 11–17)

- پوشش localeهای واقعی checkout را استخراج کن؛ اسناد قبلی fa/ar/en/ru/tr/zh را به‌عنوان ادعای تاریخی بدان، نه وضعیت قطعی.
- ترجمه و key consistency، placeholder plural، currency/date/calendar/number formats، RTL punctuation، mirrored icons، long strings و CJK.
- text scaling، touch targets، contrast، semantics, focus order، TalkBack/VoiceOver، reduced motion و keyboard.
- terminology dictionary مشترک برای finance/security/statuses.

**قبولی:** تمام Routeهای critical روی localeهای پشتیبانی‌شده و light/dark تست شده‌اند؛ هیچ key گمشده یا overflow بحرانی باز نمانده.

## فاز 9 — امنیت، resilience، performance و observability (هفتهٔ 12–18)

- timeout/retry/circuit patterns متناسب با پشتیبانی backend، connectivity transitions، refresh session و stale data.
- profile mode/devtools: startup, frame time, jank, rebuild, image memory/cache, API latency/error, app size.
- privacy-safe metrics: task completion, validation error, safe abandonment, recovery success؛ بدون PII، passcode، raw card data یا amounts مگر policy تأیید‌شده.
- dependency/security/license audit؛ حذف dependency فقط با benchmark.
- بررسی crash، ANR و خطاهای ناوبری روی release-like build.

**قبولی:** قبل/بعد به baseline همان دستگاه/نسخه مقایسه شده؛ improvement ادعایی evidence دارد و هیچ regression P0/P1 ندارد.

## فاز 10 — رگرسیون و اثبات جامعیت (هفتهٔ 17–22)

- اجرای unit + widget + integration + selected E2E/golden suite.
- route×locale×theme×critical state matrix؛ اولویت مسیر مالی و auth، سپس سایر صفحات.
- پوشش dynamic/deep link/nested/overlay/notification entry points.
- اجرای نهایی تست‌ها سریال توسط integrator و روی SHA ثابت؛ هر failure طبقه‌بندی و triage شود.
- بازبینی security, privacy, accessibility, performance, app lifecycle, offline/reconnect.

**قبولی:** test results و screenshots مربوط به همان SHA است؛ هیچ blocker پنهان با وضعیت PASS ثبت نشده.

## فاز 11 — تکمیل backlog و آماده‌سازی انتشار (هفتهٔ 22–26 / تا روز 180)

- رفع P0/P1؛ قبول استثناهای P2 با owner و موعد.
- مقایسهٔ کاتالوگ کشف‌شده با runtime-tested inventory و test inventory.
- تولید گزارش «Done / Not done / Blocked / Deferred» همراه مسیر و مدرک.
- تهیهٔ release checklist و checksum؛ درخواست تأیید صاحب پروژه برای انتشار. خود این plan اجازه انتشار نمی‌دهد.

## تقسیم عامل‌ها

| نقش | مالکیت مسئولیت | ممنوعیت/مرز |
|---|---|---|
| Integrator / Lead | baseline، ownership، merge plan، نهایی‌سازی گزارش و تست سریال | تنها مالک تصمیم‌های cross-cutting و test run نهایی |
| A — Discovery | graph, route inventory, screen/service graph, unresolved list | در فاز کشف هیچ منطق مالی را بازنویسی نکند |
| B — API & resilience | Dio/clients, error mapping, timeouts, session, API contracts | payload/security assumptions را بی‌سند تغییر ندهد |
| C — Financial domain | transfers/exchange/fees/ledger interactions/unknown states | UI مالک محاسبه یا حقیقت مالی نمی‌شود |
| D — UI/UX surfaces | page specs, components usage, all route screens | tokens/theme/shared components فقط با مالکیت/hand-off |
| E — QA automation | test matrix, integration/goldens, runtime screenshots | اجرای موازی `flutter test` ممنوع طبق guide پروژه |
| F — Security/i18n/performance | privacy, RTL/accessibility, profiling, dependency audit | دادهٔ حساس را log نکند؛ dependency بدون ADR اضافه نکند |

## معیار پایان واقعی

- 100% از کشفیات Route/screen-like با یک دسته‌بندی و وضعیت مستند شده‌اند.
- 100% Routeهای in-scope به page spec، component/API owner، تست لازم و خروجی بررسی متصل هستند یا `BLOCKED/DEFERRED` با دلیل دارند.
- 100% جریان‌های مالی critical برای submit/timeout/unknown/retry/reconciliation پوشش داده شده‌اند.
- هیچ P0/P1 باز در امنیت، صحت پول یا مسیر اصلی ورود.
- صفر mock-success یا data fallback مالی در build انتشار.
- تمام قابل مشاهده‌های CTA دارای عملکرد یا دلیل disabled.
- گزارش نهایی شامل evidence path، SHA، command، exit code، screenshots و فهرست unresolvedها است.

> این نقشه زمان‌بندی هدف‌گذاری است، نه تضمین زمان؛ حجم واقعی پس از Phase 1 مشخص می‌شود. اگر discovery نشان دهد حجم یا معماری با فرض‌ها فرق دارد، backlog باید مبتنی بر evidence تنظیم شود، نه اینکه Routeها از قلم بیفتند.

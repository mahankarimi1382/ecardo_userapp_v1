# نقشهٔ راه مرحلهٔ ۲: قراردادهای مشترک، رفع P0/P1 و یکپارچه‌سازی قابل‌اثبات

## نتیجهٔ مورد انتظار
تبدیل inventory مرحلهٔ ۱ به یک مدل عملیاتی از وابستگی‌ها و قراردادهای برنامه؛ سپس اصلاح محدود و کنترل‌شدهٔ خطاهای با اولویت بالا. این مرحله جایگزین ارتقای سراسری UI/UX نیست؛ زیرساخت لازم را ایجاد می‌کند تا مرحلهٔ ارتقا روی تمام صفحات دقیق و کم‌ریسک انجام شود.

## فاز 2.0 — پذیرش خروجی مرحلهٔ ۱
1. خواندن `DISCOVERY_SUMMARY.md`, `ROUTE_CATALOG.csv`, `SCREEN_SERVICE_MATRIX.csv`, `FLOW_CATALOG.csv`, `GAP_REGISTER.csv` و Evidence Ledger.
2. ثبت SHA و مقایسه با SHA مرحلهٔ ۱. اگر هم‌خوان نیست، فقط تفاوت‌ها را ثبت و بخش مرتبط را مجدداً کشف کن.
3. اجرای `graphify query` طبق repo guide؛ خروجی و محدودیت‌ها ثبت شوند.
4. تعیین Module ID / Route ID / Flow ID واقعی. هیچ ماژول پیشنهادی را بدون مشاهدهٔ سورس به‌عنوان قابلیت موجود اعلام نکن.
5. تأیید حداقل یکپارچگی inventory توسط validator؛ داده‌های ناقص `BLOCKED` می‌مانند.

**خروجی:** `docs/integration/INPUT_RECONCILIATION.md` و به‌روزرسانی کاتالوگ‌ها.

## فاز 2.1 — تعریف منابع حقیقت و قراردادها
برای هر قرارداد واقعی، تولیدکننده، مصرف‌کننده، schema، منبع حقیقت، واحد مبلغ، قواعد authorization، وضعیت‌ها، خطاها، timeout/retry و تست قراردادی مشخص شود.

قراردادهایی که معمولاً باید بررسی شوند (فقط اگر در inventory واقعی وجود دارند):
- Auth / session / OTP / passcode
- User profile / KYC / permissions
- Accounts / wallet / balance / ledger / transaction history
- Transfer / exchange / fees / rates / quote expiry
- Cards / issuance / freeze-unfreeze / limits
- Crypto / external networks / address validation / network fee
- Bills / QR / invoices / payment confirmation
- Notifications / deep links / support / settings
- Localization / money formatting / error normalization / analytics

**قاعده:** balance نمایش داده‌شده، وضعیت تراکنش یا کارمزد نباید از حدس UI یا cache منقضی‌شده، حقیقت مالی تولید کند. اگر سیستم backend قرارداد را روشن نکرده، این ابهام به backend owner ارجاع می‌شود؛ اپلیکیشن قرارداد را از خودش اختراع نمی‌کند.

**خروجی:** `docs/integration/CONTRACT_REGISTRY.csv`, `docs/integration/DATA_OWNERSHIP.md`, `docs/integration/API_ERROR_CATALOG.md`.

## فاز 2.2 — ممیزی P0/P1 و containment
ابتدا خطرهایی را جست‌وجو کن که می‌توانند باعث انتقال تکراری، مبلغ یا fee اشتباه، دسترسی بدون مجوز، نمایش موفقیت کاذب یا افشای اطلاعات شوند. این موارد «محل بررسی» هستند، نه باگ قطعی تا وقتی مدرک پیدا شود.

### P0 — اقدام فوری اگر اثبات شد
- احتمال duplicate financial mutation پس از retry / timeout
- authorization یا passcode/KYC gate قابل دور زدن
- مبلغ، ارز، fee، مقصد یا وضعیت نهایی اشتباه
- نمایش success بدون confirmation معتبر backend
- secret/PII حساس در log یا local persistence
- race condition که موجودی/وضعیت مالی ناسازگار تولید کند

در P0، ابتدا عملیات خطرناک را با روش امن و مجاز مهار کن؛ سپس اصلاح کوچک با رگرسیون تست. اگر رفع امن بدون backend change ممکن نیست، blocker و راهکار containment را ثبت کن؛ قرارداد جعلی نساز.

### P1 — اصلاح قبل از گسترش سراسری
- mapping ناقص/ناسازگار فیلدهای API
- error/empty/loading stateهای نامعتبر در فلوهای اصلی
- status polling یا refresh ناکافی و نمایش stale data
- currency/locale/rounding/fee breakdown مبهم
- state duplication بین صفحه‌ها و controllerها
- route یا navigation شکست‌خورده در فلوهای تأییدشده
- عدم تطابق UI با وضعیت سرور پس از cancel/fail/pending

**خروجی:** `docs/integration/P0_P1_REMEDIATION_REPORT.md`, `ISSUE_REGISTER.csv` و شواهد containment.

## فاز 2.3 — اصلاحات اشتراکی و یکپارچه‌سازی محدود
پس از تثبیت قراردادها، روی زیرساخت مشترک به‌ترتیب کار کن:
1. Error normalization و نگاشت خطاهای backend به پیام‌های امن و قابل‌اقدام.
2. مدل stateهای loading/success/empty/error/offline/pending/unknown با حفظ قراردادهای فعلی.
3. قواعد نمایش مبلغ و ارز براساس واحد و locale معتبر.
4. refresh/invalidation داده پس از عملیات موفق/نامعلوم با منبع حقیقت سرور.
5. idempotency/correlation identifiers فقط وقتی backend آن را پشتیبانی کند.
6. auth/session/passcode/settings config با آزمون null/disabled/unknown و fail-closed برای عملیات حساس.
7. contract tests برای serialization/parsing و خطاهای شناخته‌شده.

از refactor بزرگ یا بازنویسی همهٔ Controllerها اجتناب کن. هر تغییر باید یک مشکل واقعی را حل کند و کوچک قابل‌بازگشت باشد.

## فاز 2.4 — بازپخش فلوها و رگرسیون
از inventory واقعی تمام فلوهای بحرانی را اجرا کن. به‌صورت حداقل:
- دخول/خروج/انقضای session
- مشاهدهٔ wallet/balance و تاریخچه
- transfer: quote/review/confirm/result/history؛ فقط sandbox/mock
- exchange: rate/quote expiry/fee/passcode/confirm/unknown status؛ فقط sandbox/mock
- card/KYC، bills/QR و crypto فقط اگر در repo واقعی وجود دارند
- خطاهای network timeout، 401/403، validation، 5xx و پاسخ ناقص
- هم‌زمانی، retry و دوبار لمس‌کردن دکمهٔ تأیید

تمام نتایج را به Route ID، Flow ID، Contract ID و commit/SHA وصل کن.

## فاز 2.5 — Hand-off به مرحلهٔ ۳
مرحلهٔ ۳ ارتقای کامل سطح همهٔ صفحات است. قبل از تحویل، هر صفحه در inventory باید وضعیت قراردادهایش و اولویت‌های فنی را داشته باشد. بخش‌های BLOCKED نیز از قلم نیفتند؛ باید owner و شرط بازشدن blocker داشته باشند.

## ترتیب اجرای چندایجنتی
- Agent A: قراردادهای API و مدل‌های داده — فقط گزارش و پیشنهاد diff؛ فایل‌های مشترک را بدون مالکیت تغییر ندهد.
- Agent B: ریسک‌های مالی/تراکنشی — بررسی read-only، ایجاد تست‌های هدفمند در فایل‌های اختصاصی خود.
- Agent C: تجربهٔ فلو و stateهای UI — بر اساس قراردادهای تأییدشده.
- Agent D: تست/شواهد — طراحی تست و اعتبارسنجی، بدون اجرای Flutter test در حالت موازی.
- Integrator: مالک نهایی قراردادهای مشترک، ادغام diffها و اجرای نهایی سریال تست‌ها.

اگر shared worktree وجود دارد، قبل از هر فایل‌نویسی مالکیت را تعیین کن. از تغییر هم‌زمان فایل مشترک توسط چند agent جلوگیری کن.

## Definition of Done
یک task فقط زمانی بسته می‌شود که: (۱) مدرک defect یا نیاز، (۲) تغییر هدفمند، (۳) تست رگرسیون، (۴) خروجی واقعی تست/analyzer، (۵) وضعیت مرتبط route/flow و (۶) گزارش باقی‌مانده‌ها ثبت شده باشند. «به نظر درست می‌رسد» معیار پذیرش نیست.

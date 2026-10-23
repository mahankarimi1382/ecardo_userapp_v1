# پرامپت اجرایی ایجنت مرحلهٔ ۱ — eCardo Discovery & Mapping

تو مسئول تهیهٔ نقشهٔ واقعی و قابل‌اثبات کل برنامهٔ eCardo هستی. در این مرحله حق نداری صرفاً بر اساس README، نام فایل، دانش قبلی یا حدس نتیجه‌گیری کنی. باید checkout در اختیار خودت را بررسی کنی و همهٔ اعداد به SHA همان checkout نسبت داده شوند.

## ترتیب اجباری

### A. ایمنی و baseline
1. ابتدا دستورهای محلی `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, `PRE_PUSH_CHECK.md` و `START-HERE.md` مورد اشارهٔ پروژه را بخوان. اگر مسیر خارج از checkout در محیط فعلی موجود نیست، آن را BLOCKED ثبت کن.
2. هیچ تغییری در سورس اپ نده. `git checkout`, `git stash`, `git reset --hard`, حذف فایل، push، tag، release، deploy، trigger کردن workflow یا تست مالی واقعی ممنوع.
3. قبل از اکتشاف سورس، قانون Graphify را رعایت کن و `python -m graphify query "..."` را با پرسش مشخص دربارهٔ route/page/service/API/test graph اجرا کن. خروجی و وضعیت فرمان را ثبت کن.
4. خط مبنای branch، full/short HEAD SHA، working-tree status، diff-stat، version در `pubspec.yaml`, tag محلی، نسخه‌های Flutter/Dart و شمار فایل Dart/test را ثبت کن. نتیجهٔ baseline باید خواندنی و ماشینی باشد.
5. هیچ فایلی که تغییرات دیگری روی آن وجود دارد را overwrite نکن. پوشهٔ خروجی را بساز؛ قبل از نوشتن روی مسیر موجود، آن را بررسی کن.

### B. Static discovery کامل
1. اسکنر این بسته را اجرا کن و خروجی را در `docs/app-map/generated/` ذخیره کن.
2. تمام `lib/`, `test/`, `integration_test/`, manifests Android/iOS، ARB localization، assets، links، generated route declarations، deep links، notification handlers، QR entry points، tabs، nested navigators، dialogs و bottom sheets را بررسی کن.
3. Routeها و navigation callها را با گراف پروژه تطبیق بده. کاندیدای Regex را route تاییدشده جا نزن.
4. هر مورد را با شناسهٔ پایدار ثبت کن. منبع، شماره خط، widget، Controller/state owner، service/repository، API path/type، model، guards، status states و تست مربوطه را استخراج کن.
5. تمام flowها را از ورودی کاربر تا نتیجهٔ UI و side effect سرور دنبال کن: auth/KYC, wallet/balance, transfer, exchange, deposit/withdrawal, cards, bills, QR/payment links, travel, support/tickets, notifications, profile/settings و هر ماژول دیگری که واقعاً در checkout پیدا می‌کنی.
6. صفحه‌های ظاهراً مرده، routeهای orphan، routeهای بدون screen، صفحه‌های بدون controller/API/test و دکمه‌های بدون callback را جدا ثبت کن؛ به دلیل اینکه یک مورد هنوز دیده نشده، آن را قطعیاً غایب اعلام نکن.

### C. Runtime/test inventory (بدون اجرای تست در این مرحله)
1. تست‌های unit/widget/integration/golden/screenshot موجود را فهرست کن و به Route/Flow وصل کن.
2. برای هر صفحه وضعیت‌های Loading, Success, Empty, Error, Offline, Auth-required, Disabled و Pending را هرجا کاربرد دارند در ماتریس بنویس.
3. مشخص کن کدام مسیرها فقط از سورس دیده شده‌اند و کدام‌ها در runtime قبلاً شواهد معتبر دارند. در این مرحله اگر نتوانسته‌ای اجرا کنی، `NOT_RUN` بنویس.
4. هر blocker (دسترسی backend، credential، محیط simulator، Graphify نبود، dynamic route) را دقیق ثبت کن.

### D. مستندسازی و گزارش
خروجی نهایی:
- `docs/app-map/LOCAL_BASELINE.md` + `.json`
- `docs/app-map/generated/*`
- `docs/app-map/ROUTE_CATALOG.csv`
- `docs/app-map/SCREEN_SERVICE_MATRIX.csv`
- `docs/app-map/FLOW_CATALOG.csv`
- `docs/app-map/GAP_REGISTER.csv`
- `docs/app-map/TRACEABILITY_MATRIX.csv`
- `docs/app-map/EVIDENCE_LEDGER.csv`
- `docs/app-map/DISCOVERY_SUMMARY.md`

برای هر ادعا SHA منبع، شواهد، محدودیت و status ارائه کن. اختلاف تعداد صفحات یا تست‌ها بین README، AGENTS، pubspec و releases را به‌عنوان mismatch ثبت کن؛ هیچ‌کدام را بی‌مدرک اصلاح نکن.

## Definition of Done

- شمار source candidates و confirmed routes جدا هستند.
- تمام رکوردهای catalog شناسه دارند و route duplicates review شده‌اند.
- تمام ماژول‌های پیدا شده در ماتریس آمده‌اند؛ ماژول‌های README هم با شواهد تأیید یا به عنوان ادعای مستندات ثبت شده‌اند.
- هیچ مورد `RUNTIME_VERIFIED` بدون evidence نیست.
- هیچ مورد `PASS` بدون reference به تست نیست.
- خروجی validator اجرا و گزارش شده است.
- `DISCOVERY_SUMMARY.md` عدد قطعی «پوشش ۱۰۰٪» اعلام نمی‌کند مگر اینکه مسیرهای static، dynamic، tabs, overlays و runtime با هم reconcile شده باشند و unresolvedها صفر باشند.
- هیچ سورس اپ تغییر نکرده و هیچ remote action رخ نداده است.

پاسخ نهایی را با مسیر فایل‌ها، SHA، آمار واقعی، موارد نامعلوم/مسدود، خطاهای validator و صریحاً «بدون push/release/deploy» تمام کن.

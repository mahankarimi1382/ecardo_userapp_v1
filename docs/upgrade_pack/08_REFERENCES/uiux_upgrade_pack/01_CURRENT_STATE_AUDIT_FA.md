# ممیزی وضعیت موجود UI/UX — eCardo

## شواهد عمومی قابل مشاهده
- مخزن: https://github.com/mahankarimi1382/ecardo_userapp_v1
- README معماری Feature-driven GetX، ۹۹ route، ScreenUtil با baseline تقریبی 376×812 dp و امکانات شبکه/نشست را توصیف می‌کند.
- `DESIGN_SYSTEM_GUIDE.md` وجود tokens و shared widgets و screenshot harness را مستند می‌کند.
- فایل design guide فعلی برای ownership، working tree مشترک، اجرای تست و golden update دستورهای سخت دارد. قبل از تقسیم کار، نسخه جاری `AGENTS.md`, `FILE_OWNERSHIP.md` و `DESIGN_SYSTEM_GUIDE.md` را بخوانید و اگر با این بسته تعارض دارند، دستور مخزن مقدم است.
- XPay kit یک مرجع تجاری با mock data است؛ از جمله قابلیت‌هایی را نشان می‌دهد که باید پوشش کاربری‌شان در eCardo بررسی شود، نه اینکه موجودبودن‌شان در eCardo فرض شود.

## محدودیت‌ها
- این ممیزی route به route و اجرای runtime روی checkout محلی نیست؛ به کد محلی/دستگاه دسترسی مستقیم ندارد.
- route count از README به دست آمده و باید به صورت خودکار با `routes.dart` و navigation bindings مقایسه شود.
- وجود component عمومی لزوماً به معنی استفاده درست در تمام صفحات نیست.
- اضافه‌شدن package به `pubspec.yaml` اثبات استفادهٔ درست، مجوز مناسب یا performance خوب نیست.

## کارهای اجباری در checkout
1. `git status --short`, `git rev-parse HEAD`, نسخهٔ `pubspec.yaml` و CI مربوط به همان SHA را ثبت کنید.
2. `lib/src/app/routes/routes.dart` و Bindingها را برای route inventory خروجی بگیرید.
3. برای هر route فایل screen/controller/service/model/API و تست متناظر را ثبت کنید.
4. با harness موجود baseline screenshot از critical flows تهیه کنید؛ goldenها را هم‌زمان از چند agent update نکنید.
5. در هر صفحه، fake/mock data، دکمهٔ بی‌عمل، action بدون loading lock، خطاهای خام backend و stateهای missing را شناسایی کنید.
6. رنگ/spacing/fontهای hardcoded و componentهای تکراری را با design-system source of truth مقایسه کنید.

## دسته‌بندی یافته‌ها
- P0: مبلغ/وضعیت اشتباه، تأیید مالی کاذب، آدرس/شبکهٔ crypto غلط، action مالی دوباره، نمایش PII یا bypass امنیت.
- P1: مسیر حیاتی غیرقابل تکمیل، stateهای pending/error گم‌شده، CTA بی‌اثر، layout blocker، accessibility مانع استفاده.
- P2: ناسازگاری بصری، سلسله‌مراتب ضعیف، empty/loading نامناسب، کندی قابل‌اندازه‌گیری.
- P3: جزئیات polish، motion اختیاری و decoration.

## ریسک‌های رایج که باید به‌صورت evidence-based سنجیده شوند
- Dashboard پر از کارت‌های ریز یا KPIهای کم‌اهمیت که عمل اصلی را عقب می‌اندازند.
- چند سبک دکمه، ورودی، chip، dialog و bottom sheet برای رفتار مشابه.
- نداشتن حالت `pending/unknown` در تراکنش مالی.
- CTA تکراری/رقیب و متن‌های فنی خام از سرور.
- clipping در فارسی/عربی یا متن‌های ترکی/روسی/چینی.
- اندازهٔ متن محدودشده به حدی که تنظیمات accessibility کاربر را بی‌اثر کند.
- اعداد مالی با `double` یا local formatting ناسازگار.
- استفاده از animation سنگین در صفحهٔ ابتدایی، balance یا لیست تراکنش.
- استفاده از تصویر mock/placeholder در Release.

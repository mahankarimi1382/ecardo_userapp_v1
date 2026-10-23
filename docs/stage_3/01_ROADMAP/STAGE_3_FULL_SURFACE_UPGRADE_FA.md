# مرحلهٔ ۳ — ارتقای کامل تمام صفحات و تجربهٔ کاربر eCardo

## 1. نتیجهٔ مورد انتظار
تمام صفحات و مسیرهای کشف‌شده باید با design system واحد، الگوهای تعاملی سازگار، حالت‌های قابل‌اعتماد و آزمون‌های رگرسیون ارتقا یابند. هدف، «تغییر رنگ چند صفحه» نیست؛ هدف کاهش اصطکاک، افزایش وضوح، دسترس‌پذیری، صحت نمایش وضعیت و یکپارچگی تجربه در کل اپ است.

این مرحله از کاتالوگ واقعی Routeهای مرحلهٔ ۱ و قراردادهای مورد تأیید مرحلهٔ ۲ مصرف می‌کند. نام‌های ماژول در نمونه‌ها فقط حوزه‌های کاندیدا هستند؛ رجیستری نهایی باید براساس سورس واقعی ساخته شود.

## 2. اصول طراحی
- eCardo هویت برند خود را حفظ کند؛ الهام از الگوهای XPay، xMoney/xPortal و اپلیکیشن‌های بانکی فقط برای الگوهای حل مسئله است، نه کپی layout، دارایی یا کد.
- اولویت mobile-first، استفادهٔ یک‌دستی، اهداف لمسی مناسب، تایپوگرافی خوانا، سلسله‌مراتب مبلغ/وضعیت و ناوبری قابل‌پیش‌بینی است.
- یک component باید behavior ثابت، semantics قابل‌آزمون و راهکار واحد برای loading/empty/error داشته باشد.
- هر صفحهٔ پیچیده قبل از کدنویسی دارای Screen Spec و acceptance criteria باشد.
- از design tokenها و componentهای موجود استفاده شود؛ Design System جدید موازی نسازید.
- UI از نظر بصری موفقیت عملیات را جعل نکند. وضعیت مالی authoritative است و از قرارداد backend پیروی می‌کند.

## 3. پیش‌شرط
1. `docs/app-map/ROUTE_CATALOG.csv` و گزارش coverage واقعی موجود باشد.
2. قراردادهای API/مالی مرحلهٔ ۲ تأیید شده باشند یا موارد unresolved مشخص باشند.
3. baseline تصویری از اپ در test/dev environment ثبت شود.
4. مالک فایل‌های مشترک و قواعد agent workflow مشخص باشند.

## 4. فرآیند برای هر صفحه

### A. تعریف
برای هر Route، هدف کاربر، نقطهٔ ورود، پیش‌شرط دسترسی، دادهٔ ورودی، عملیات، خروجی موفق، مسیر بازگشت و وابستگی‌ها را ثبت کنید.

### B. طراحی/رفتار
Screen Spec باید این موارد را تعیین کند:
- hierarchy و CTA اصلی/ثانویه؛
- اجزای reusable؛
- فرم و قواعد validation؛
- Loading، Skeleton، Empty، Error، Offline، Pending، Disabled؛
- تایید عملیات حساس و امکان خروج امن؛
- focus order، semantic labels، متن‌های قابل ترجمه؛
- RTL/LTR و format مبلغ/تاریخ/عدد؛
- حالت‌های responsive، کیبورد و text scale؛
- eventها و navigation resultها.

### C. پیاده‌سازی
- از widget/component موجود استفاده کن؛ اگر کمبود واقعی وجود دارد، component عمومی را با مالک مشخص اضافه کن.
- منطق مالی را از widget جدا نگه دار و از قراردادهای مرحلهٔ ۲ استفاده کن.
- در هر بچ فقط تعداد کمی صفحهٔ مرتبط تغییر کند؛ از redesign یکجای کل اپ بدون baseline پرهیز شود.

### D. بررسی
- flutter analyze برای فایل‌های مجاز؛ تست widget/unit مربوطه؛
- Patrol/مکانیسم تست موجود برای جریان end-to-end در محیط sandbox؛
- screenshots در viewport و localeهای هدف؛
- بررسی semantics/accessibility و بازبینی دستی RTL؛
- ثبت وضعیت و evidence در رجیستری.

## 5. موج‌های اجرا

### Wave 0 — تثبیت سیستم طراحی
خروجی: audit از tokenها و componentهای موجود، فهرست componentهای موازی/ناهماهنگ، تصمیم‌های ثبت‌شده و نمونهٔ طلایی بصری. فایل‌های قفل‌شده بدون هماهنگی تغییر نکنند.

### Wave 1 — هستهٔ ناوبری و shell
صفحه‌ها و shellهای واقعی ورود، ناوبری اصلی، tabها، drawer/menus، headers، sheets و dialogs؛ فقط آن‌هایی که در کاتالوگ وجود دارند. هدف: رفتار back، deep link و route-state قابل‌پیش‌بینی.

### Wave 2 — داشبورد و اطلاعات حساب
صفحه‌های Home، حساب‌ها، کیف پول، موجودی و فعالیت‌ها در صورت وجود. سلسله‌مراتب اطلاعات، freshness، empty/loading/error، و refresh روشن باشد.

### Wave 3 — عملیات مالی
انتقال، تبدیل ارز، درخواست/واریز/برداشت، کارت، QR یا سایر جریان‌های واقعی. تفکیک amount entry، review، authorization، pending، receipt و history. تست در محیط sandbox؛ عملیات واقعی ممنوع.

### Wave 4 — خدمات تکمیلی
قبوض، سرویس‌های خرید، وفاداری، referral، rewards یا هر خدمت واقعاً کشف‌شده. قابلیت‌های صرفاً تبلیغ‌شده اما غیرعملیاتی باید به‌عنوان gap ثبت شوند.

### Wave 5 — هویت و پشتیبانی
Profile، KYC، امنیت، تنظیمات، زبان/تم، پشتیبانی و مستندات، مطابق inventory واقعی. خطاهای مجوز، دسترسی و دادهٔ حساس با دقت بررسی شوند.

### Wave 6 — پوشش باقیمانده و پاکسازی
routeهای فرعی، دیالوگ‌ها، bottom sheetها، حالت‌های خاص، legacy/unreachable code و همهٔ مواردی که در موج‌های قبلی پوشش نیافتند.

### Wave 7 — رگرسیون کل اپ
اجرای سریال تست نهایی، مرور screenshots، تطبیق route catalog، گزارش موارد باز و handoff به مرحلهٔ release hardening.

## 6. پذیرش طراحی
- تمام متن‌ها از localization، نه literalهای پراکنده.
- حداقل‌سازی overflow در متن بلند، زبان RTL، text scaling و عرض کوچک.
- وضعیت تراکنش با متن و semantics قابل‌درک، نه فقط رنگ/آیکن.
- CTAها action واقعی دارند؛ اگر قابل‌اجرا نیست، disabled state و علت روشن دارد.
- بدون no-op action یا موفقیت کاذب.
- شکل/رنگ/انیمیشن در service failure بر data truth غلبه نمی‌کند.
- دکمهٔ swipe/confirm و CTAهای دو مرحله‌ای lifecycle/reset معتبر دارند.
- رسیدها وضعیت را از دادهٔ واقعی می‌گیرند؛ default success برای تراکنش نامعلوم ممنوع.

## 7. معیار تکمیل کل اپ
1. همهٔ موارد رجیستری وضعیت داشته باشند؛ `OUT_OF_SCOPE` تنها با دلیل و تأیید.
2. هر صفحهٔ متعلق به scope، UI status و behavior status و QA status و evidence داشته باشد.
3. برای routeهای قابل دسترس، runtime evidence وجود داشته باشد؛ برای route محافظت‌شده یا blocker، علت روشن ثبت شود.
4. هیچ P0/P1 unresolved بدون owner، mitigation و پذیرش رسمی نماند.
5. coverage summary با عدد و فهرست موارد باز تحویل داده شود.
6. هیچ ادعای «۱۰۰٪» بدون کاتالوگ و شواهد معتبر مطرح نشود.

## 8. خروجی‌های الزامی
- `docs/uiux/SCREEN_UPGRADE_REGISTRY.csv`
- `docs/uiux/SCREEN_STATE_MATRIX.csv`
- `docs/uiux/COMPONENT_ADOPTION_MATRIX.csv`
- `docs/uiux/SCREENSHOT_MANIFEST.csv`
- `docs/uiux/ACCESSIBILITY_I18N_MATRIX.csv`
- `docs/uiux/VISUAL_QA_REPORT.md`
- `docs/uiux/STAGE_3_HANDOFF.md`

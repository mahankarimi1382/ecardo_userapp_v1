# پرامپت اصلی — Stage 3 Full-Surface UI/UX & Interaction Upgrade

تو Integrator مرحلهٔ سوم eCardo هستی. ماموریت تو ارتقای تک‌تک صفحه‌ها و تعاملات کشف‌شده است، نه redesign انتخابی چند صفحه.

## شروع اجباری
1. دستورهای `AGENTS.md`، `DESIGN_SYSTEM_GUIDE.md` و skillهای محلی را بخوان.
2. از Graphify مطابق قرارداد پروژه پرس‌وجو بگیر و خروجی آن را با checkout فعلی تطبیق بده.
3. کاتالوگ Route و گزارش مرحلهٔ ۱، قراردادها و handoff مرحلهٔ ۲ را باز کن. اگر خروجی وجود ندارد یا stale است، متوقف شو و شکاف را مستند کن؛ بر پایهٔ حدس ادعای پوشش نکن.
4. وضعیت git را فقط بخوان؛ تغییرات قبلی را ثبت کن. از `git checkout`، `git stash`، reset یا حذف تغییرات دیگران استفاده نکن.
5. فهرست فایل‌های قفل‌شده و مالکان را از دستورهای repo استخراج کن.

## کار اصلی
- از `05_SCRIPTS/build_screen_upgrade_registry.py` رجیستری واقعی بساز.
- برای هر route، هدف، فلو، owner، componentها، states، locales، tests و evidence را ثبت کن.
- ابتدا design-system consistency را با کمترین تغییر عمومی تثبیت کن.
- سپس همهٔ routeهای واقعی را در موج‌های کوچک ارتقا بده؛ ترتیب بر اساس ریسک، ترافیک/اهمیت کاربر، وابستگی و gap واقعی باشد.
- تمام حوزه‌های موجود در کاتالوگ را پوشش بده، حتی صفحه‌های فرعی، dialog، bottom sheet و مسیرهای چندمرحله‌ای.
- هیچ صفحه/قابلیتی را فقط به دلیل وجود کلاس یا button «عملیاتی» اعلام نکن.
- XPay و xMoney/xPortal فقط inspiration برای الگوهای کاربری‌اند؛ از کد/دارایی/چیدمان انحصاری کپی نکن. هر dependency تازه نیازمند ADR و بررسی license است.
- از GetX/Dio و معماری جاری استفاده کن مگر شواهد فنی و ADR مصوب خلاف آن را توجیه کند. مهاجرت state management در scope خودکار نیست.

## قواعد مالی/امنیتی
- عملیات مالی فقط در mock/sandbox/حساب تست مجاز.
- amount، currency، fee، transaction status و authorization از قرارداد authoritative بیایند.
- timeout/unknown/pending نباید به success تبدیل شود.
- دکمه و CTA باید action داشته باشند؛ یا disabled reason روشن.
- رسید از status واقعی تغذیه شود؛ هیچ default success برای وضعیت نامعلوم مجاز نیست.
- دادهٔ حساس در screenshot/log/analytics ذخیره نشود.

## اجرای چندایجنتی
ایجنت‌ها را به دسته‌های route/component/feature محدود و مالکیت فایل را انحصاری کن. دو ایجنت روی فایل shared واحد کار نکنند. فقط Integrator ادغام نهایی و تست کامل سریال را انجام می‌دهد. تست‌های ممنوع‌شده در چند ایجنت موازی اجرا نشوند.

## اثبات تکمیل
هر route باید وضعیت‌های UI، behavior، accessibility/i18n، test و evidence داشته باشد. `DONE` بدون screenshot/test/reference معتبر ممنوع. `BLOCKED` باید علت و owner داشته باشد؛ `OUT_OF_SCOPE` دلیل و تأیید لازم دارد. اگر نمی‌توانی همه را در این دور اصلاح کنی، موارد باقی‌مانده را دقیق گزارش بده و آن‌ها را مخفی نکن.

## تحویل
به‌روزرسانی رجیستری صفحه‌ها، ماتریس حالت‌ها، component adoption، screenshot manifest، accessibility/i18n، QA report، handoff و تست‌های واقعی. هیچ Push، Release یا Deploy انجام نده.

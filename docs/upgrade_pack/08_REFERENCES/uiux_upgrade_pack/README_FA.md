# بسته جامع ارتقای UI/UX اپلیکیشن eCardo

**دامنه:** اپلیکیشن Flutter مالی eCardo؛ صفحات باقی‌مانده، جریان‌های کاربری، سیستم طراحی، دسترس‌پذیری، بومی‌سازی، تست بصری و عملکرد.

## نکته مهم درباره XPay
در این برنامه فرض شده منظور از XPay، محصول **XPay: Flutter Digital Wallet UI Kit** معرفی‌شده در `afgprogrammer.com` است؛ اگر منظور شما اپ دیگری با نام XPay باشد، آن باید به ماتریس مرجع اضافه شود. این UI kit در صفحه رسمی خود ۴۴ صفحه و ۱۴ ماژول را شرح می‌دهد، اما خودش می‌گوید داده‌های mock دارد و باید به backend واقعی متصل شود. پس مرجع طراحی و پوشش صفحات است، نه کد قابل جایگزینی مستقیم.

## شیوه استفاده
1. ابتدا `01_CURRENT_STATE_AUDIT_FA.md` و `24_FILE_OWNERSHIP_PR_RULES_FA.md` را بخوانید.
2. نسخه دقیق `main`، `pubspec.yaml`، `routes.dart` و `DESIGN_SYSTEM_GUIDE.md` را در checkout محلی ثبت کنید؛ نام مسیرها در CSVها گروه‌بندی محصولی است و جای فهرست routeهای واقعی را نمی‌گیرد.
3. `03_PAGE_INVENTORY_AND_AUDIT_MATRIX.csv` را با ۹۹ route اعلام‌شده در مخزن تطبیق دهید. برای هر route دقیق، نام فایل واقعی، owner و وضعیت را اضافه کنید.
4. از design system موجود eCardo استفاده کنید؛ آن را با XPay عوض یا ناوبری GetX را صرفاً برای شبیه‌شدن به GoRouter بازنویسی نکنید.
5. تسک‌ها را بر اساس `19_TASK_BACKLOG.csv` تقسیم کنید. روی working tree مشترک چند agent هم‌زمان روی فایل‌های یکسان کار نکنند.
6. تست‌ها و golden update را فقط طبق سیاست واقعی `AGENTS.md` و owner مرکزی اجرا کنید؛ اگر فایل‌های راهنمای جاری پروژه اجرای موازی test یا golden update را منع می‌کنند، همان قانون جاری مقدم است.
7. هیچ انتشار، push یا deploy خودکار از این بسته مجاز نیست.

## محتویات
- گزارش وضعیت موجود و بنچمارک XPay/رقبا
- ماتریس پوشش صفحات و شکاف قابلیت‌ها
- استاندارد سیستم طراحی و معماری اطلاعات
- مشخصات UX برای Home، Wallet، Cards، Transfers، Exchange، Crypto، Auth، Activity، Bills/Travel، Profile/Support
- الگوی وضعیت‌های loading/empty/error/offline/pending
- راهنمای RTL، شش زبان و accessibility
- ماتریس golden/widget/integration tests
- بودجه عملکرد، motion و roadmap صدوهشتادروزه
- بک‌لاگ CSV، منابع، ماتریس رقبا، matrix حالت‌های صفحه، قالب Visual Regression، سنجه‌های UX و prompt اجرایی agent

## اصول غیرقابل مذاکره
- ظاهر موفق جایگزین نتیجه واقعی backend نیست؛ مبلغ `pending` هرگز `success` نشان داده نشود.
- هیچ amount، fee، exchange rate، provider eligibility یا crypto address از mock/default برای عملیات واقعی استفاده نشود.
- طراحی الهام‌گرفته از محصولات دیگر باید مستقل پیاده‌سازی شود؛ assets، کد و تصاویر دارای مجوز بدون رعایت license کپی نشوند.
- تغییرات مالی/امنیتی از تغییرات صرفاً بصری جدا و با تست‌های مناسب بررسی شوند.

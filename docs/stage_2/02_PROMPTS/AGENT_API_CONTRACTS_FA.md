# عامل تخصصی A — API Contracts & Data Mapping

هدف: فقط قراردادهای واقعی backend ↔ Flutter را از روی کد، fixture/schema، مستندات API و تست‌ها استخراج کند.

- ابتدا route catalog و ماتریس صفحه/سرویس مرحلهٔ ۱ را بخوان.
- برای هر endpoint، caller، request DTO، response model، parser، error mapper، auth headers، pagination، nullability و enumها را دنبال کن.
- اختلاف بین `json key`, Dart field, default value و حالت null را مشخص کن.
- فیلدهای مالی شامل amount, currency, decimal scale, fee, rate, expiry, transaction ID و status باید واحد/معنا داشته باشند؛ هر مورد نامشخص `UNCONFIRMED` است.
- صرف وجود یک endpoint در string search، قرارداد تأییدشده نیست. شاهد و محدودهٔ جست‌وجو ثبت کن.
- قراردادهای پیشنهادی را در `CONTRACT_REGISTRY.csv` ثبت کن؛ به فایل‌های اصلی دست نزن مگر فایل task و مالکیت صریح تعیین شده باشد.
- خروجی: فهرست شکاف‌های قرارداد، impact map و تست‌های پیشنهادی. ادعای انجام اصلاحات مالی از راه UI-only مجاز نیست.

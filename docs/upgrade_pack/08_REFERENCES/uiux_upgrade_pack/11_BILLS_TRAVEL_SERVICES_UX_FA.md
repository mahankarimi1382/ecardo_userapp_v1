# قبوض، خدمات، سفر و ماژول‌های تجاری

eCardo طبق README خدمات مالی و خدمات تجاری/سفر را ترکیب می‌کند. هر سرویس باید ضمن استفاده از design system مشترک، منطق دامنه‌ای خودش را حفظ کند.

## فهرست اصول
- catalog صفحه باید سرویس‌های فعال واقعی را از قابلیت planned/maintenance جدا کند.
- فرم‌های قبوض، سفر یا خرید باید schema/validation از قرارداد backend داشته باشند.
- قبل از پرداخت، vendor، invoice/booking reference، مبلغ، کارمزد و سیاست cancel/refund روشن باشد.
- هرگونه قیمت/availability، quote expiry و reservation hold باید زمان اعتبار داشته باشد.
- اگر پرداخت pending است، کاربر را به پرداخت دوباره هدایت نکنید؛ ابتدا وضعیت سفارش را بازیابی کنید.
- filter/category/search نتیجهٔ empty و backend failure متفاوت داشته باشند.
- صفحهٔ سرویس غیرفعال باید دلیل و مسیر امن جایگزین نشان دهد.

## تست‌های پیشنهادی
- provider unavailable, stale price, validation errors, no items, long vendor names, cancel, payment return/deep link, pending booking, locale amount/date, offline and retry.

# Activity، رسیدها و اعلان‌ها

## Activity / history
- جست‌وجو بر اساس ref، گیرنده/فرستنده یا مبلغ فقط اگر backend قادر است.
- فیلترها واضح، قابل پاک‌کردن و دارای نتیجهٔ صفر/خطا باشند.
- pagination/infinite scroll باید خطای صفحهٔ دوم را بدون از دست دادن آیتم‌های قبلی مدیریت کند.
- مبالغ دریافتی/پرداختی، ارز، وضعیت و زمان محلی/منطقه زمانی مبهم نباشند.

## Transaction detail
- status و status timestamp، reference، source/destination، amount/fee/total، exchange quote و support action از API واحد و معتبر.
- `unknown/reconciling` یک state رسمی باشد؛ نشان success ندهید تا backend confirmed باشد.
- رسید shareable باید اطلاعات حساس را ماسک کند و فایل export حساس را consent-aware بسازد.

## Notifications
- گروه‌بندی امروز/قدیمی تنها وقتی locale/time-zone درست است.
- tapping اعلان باید به route درست برود و state/session دوباره بررسی شود.
- اعلان تکراری یا stale state را به کاربر به‌عنوان موفقیت جدید نشان ندهید.
- تنظیمات دسته‌بندی notification باید واقعاً به backend/device وصل باشند.

## آزمون‌ها
empty, high-volume list, paging error, filter reset, stale push, duplicate notification, invalid deep link, private receipt share, pending/refunded/reversed transaction.

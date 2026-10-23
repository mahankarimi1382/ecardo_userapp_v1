# Performance و Motion برای UI مالی

## Baseline قبل از بهینه‌سازی
- اندازه‌گیری cold/warm start، route transition، time-to-first-interactive، scroll jank، raster/UI frame, memory/GC، image decode، network wait و rebuild count روی deviceهای هدف.
- هر metric با device model، OS، build mode، network profile و commit SHA ثبت شود.

## اصول
- از `BackdropFilter`/blur، glow، gradient پیچیده، Lottie و animation دائمی در همهٔ cardها استفاده نکنید؛ اثرها فقط در جایی بمانند که ارزش تجربه‌ای دارند.
- listها lazy build شوند و imageها size/cache مشخص داشته باشند.
- chartهای شلوغ در صفحهٔ Home مختصر باشند؛ جزئیات در صفحهٔ اختصاصی.
- skeleton به جای spinner فقط وقتی loading طولانی/ساختارمند است؛ shimmer مداوم مصرف نکند.
- کاهش حرکت (reduced motion) رعایت شود.
- avoid rebuild global state در every tick؛ GetX observerها کوچک و دارای owner باشند.

## Performance gates پیشنهادی
هدف نهایی را بعد از baseline تصویب کنید؛ به‌عنوان شروع پایش: jank در scroll flows حیاتی، startup percentile، frame misses، memory peak و APK download size در CI رصد شوند. اگر بهبود performance ظاهر را خراب کند یا اطلاعات را کم‌رنگ کند، trade-off با اندازه‌گیری مستند شود.

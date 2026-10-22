# ممیزی وضعیت موجود و شکاف‌های UI/UX eCardo

## آنچه از مخزن عمومی قابل مشاهده است
- مخزن: https://github.com/mahankarimi1382/ecardo_userapp_v1
- Releases صفحه در زمان تهیه این بسته، `v1.0.178` را Latest نشان می‌دهد: https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
- ساختار عمومی شامل `lib/`, `assets/`, `test/`, `docs/`, `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md` است.
- اسناد پیشین پروژه GetX/Dio و design system اختصاصی را ذکر می‌کنند. نسخهٔ محلی و وابستگی واقعی باید از checkout دقیق تأیید شوند.

## مواردی که نباید بدون evidence فرض شوند
- تعداد دقیق route/page و تست‌ها؛ گزارش‌های قبلی با هم ناسازگار بودند.
- اینکه یک قابلیت واقعاً به API زنده وصل است یا هنوز mock/stub دارد.
- سازگاری packageهای پیشنهادی با Flutter/Dart فعلی.
- وضعیت فعلی backend، issuer، crypto provider یا analytics زیرساختی.

## شکاف‌هایی که ممیزی باید بررسی کند
1. Visual consistency: رنگ، typography، spacing، radii و icon style پراکنده.
2. Navigation: مسیرهای orphan، back stack، bottom tab state، deep links.
3. Functional correctness: CTAهای no-op، placeholder, mock success، stateهای API ناقص.
4. Financial clarity: مبلغ، ارز، fee، rate، expiry، destination و final status.
5. Error recovery: unknown/pending/retry و timeout.
6. Accessibility: semantics، contrast، text scaling، focus، tap target، screen reader.
7. Localization: missing keys، RTL، string expansion، CJK/Russian overflow، number/date/currency rules.
8. Performance: jank، over-rebuild، image memory، startup، network waiting.
9. Testing: route coverage، widget/integration/golden، device coverage، flaky tests.
10. Supply chain: license، dependency maintenance، bundle size، privacy.

## قالب Finding
`ID / severity / route / file:line / SHA / evidence / reproduction / user impact / fix / regression test / owner / status(PASS|FAIL|BLOCKED)`


## Baseline عمومی دقیق‌تر (بررسی ۲۰ اکتبر ۲۰۲۶)
- Releases page: آخرین تگ قابل مشاهده `v1.0.178`: https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
- `main/pubspec.yaml`: `version: 1.0.180+180`, SDK constraint `^3.9.2`, comment Flutter 3.44.6 / Dart 3.12.2. Dependencies متداول فعلی شامل GetX (`get`), Dio, ScreenUtil, shimmer, lottie, flutter_svg, cached_network_image, flutter_secure_storage, animations, calendar_date_picker2, intl, Firebase core/messaging، local notifications و connectivity_plus است. پیش از تصمیم dependency، pubspec محلی دقیق را بخوانید.
- README عمومی ادعا می‌کند ۹۹ route و ۷۳۱ تست وجود دارد. این اعداد در این نوبت توسط من محلی اجرا نشده‌اند.
- `DESIGN_SYSTEM_GUIDE.md` از `EcardoGlassCard`, `EcardoBalanceHero`, `EcardoSwipeButton`, `EcardoDigitalReceipt`, `EcardoEmptyState`, `EcardoErrorView` و tokenهای اختصاصی یاد می‌کند. نتیجه: مشکل بالقوهٔ اصلی ممکن است عدم ادغام یکنواخت این سیستم در همهٔ صفحات و stateها باشد، نه نبود کتابخانهٔ بیشتر.
- نکات API که باید در تست usage coverage قرار گیرند: اگر `EcardoBalanceHero.actions` داده نشود، default actions ممکن است بی‌عملکرد باشند؛ `EcardoDigitalReceipt.status` default `success` است و باید برای هر تراکنش صریحاً مقدار backend را بگیرد؛ `EcardoSwipeButton` کنترل‌شده است و reset آن باید مدیریت شود؛ `EcardoEmptyState` تنها زمانی action را نشان می‌دهد که label و callback هر دو حاضر باشند. این موارد از راهنمای عمومی آمده‌اند و قبل از تغییر در checkout هدف مجدداً تطبیق داده شوند.

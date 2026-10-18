# پرامپت ایجنت اصلی — بستن ریسک‌های Passcode و Card Issuance

روی checkout محلی فعلی `ecardo_userapp_v1` کار کن؛ گزارش مالک و فایل‌های این بسته را به‌عنوان فرضیه و معیار پذیرش ببین، نه اثبات انجام کار.

## قوانین غیرقابل مذاکره
- هیچ push، tag ریموت، Release، deploy یا تغییر دیتابیس production انجام نده.
- ابتدا baseline ثبت کن: branch، HEAD، `origin/main`، `git status -sb`، `git log origin/main..HEAD`، tagهای محلی/ریموت، pubspec version و وضعیت CURRENT_RELEASE.
- اگر بک‌اند جداست و به آن دسترسی نداری، هر اصلاح وابسته به سرور را BLOCKED اعلام کن؛ موفقیت فرضی گزارش نده.
- در فایل‌های حساس مالی، کوچک‌ترین تغییر امن را انجام بده؛ قبل از merge ایجنت‌ها فایل‌های مشترک را بدون هماهنگی تغییر ندهند.

## تسک‌ها
1. یک state machine مشترک Passcode برای Exchange، Transfer، Cash Out، Withdraw، Make Payment و Create Gift تعریف کن. Setting باید enabled/disabled/unknown باشد.
2. متن 422 را مبنای branching قرار نده. کد خطای ساختاریافته مثل `PASSCODE_REQUIRED`, `PASSCODE_INVALID`, `PASSCODE_NOT_CONFIGURED` پیاده‌سازی/مستند شود.
3. fallback خودکار حداکثر یک بار برای submission اجرا شود؛ invalid code نباید loop popup/retry بسازد. لغو popup و route dispose باید loading را آزاد کنند.
4. پیش از اجرای retry مالی، قرارداد Idempotency را مشخص کن: کلید پایدار برای intent، status query برای نتیجه نامعلوم، policy واضح برای payload fingerprint و passcode. هرگز بعد از timeout/5xx به‌طور کورکورانه کلید جدید نساز.
5. پیش‌اعتبارسنجی موجودی در اپ را صرفاً advisory بدان. بک‌اند باید balance/fee/currency/quote/provider eligibility و reserve/ledger را اتمیک و idempotent اجرا کند.
6. ورودی `wallet` و `irr_wallet` را در مرز API به enum canonical نرمال کن؛ ورودی‌های متناقض را رد کن و usage alias قدیمی را بدون PII اندازه‌گیری کن.
7. بررسی کن provider disabled هم در server list و هم در direct API رد می‌شود. وجود `LicensedIssuerPlaceholder` را از نظر واقعی‌بودن integration و مجوز بررسی و هر ادعای تأییدنشده را به BLOCKED تبدیل کن.
8. تنظیمات public فقط flagهای مجاز را برگردانند؛ کلیدها/مقادیر حساس هرگز به public allowlist نروند. cache و Octane invalidation را با تست پوشش بده.
9. تست‌های `02_REGRESSION_TEST_MATRIX_FA.md` را بر اساس دسترسی موجود اجرا کن. تست‌های backend در نبود دسترسی BLOCKED بمانند.
10. تعداد تست‌ها را از log خام بگیر و با 646/687/713/722 مقایسه کن؛ هر تفاوت را با حذف/جایگزینی تست‌ها توضیح بده.

## خروجی‌های لازم
- `docs/audit/PASSCODE_CARD_RESILIENCE_REVIEW.md`
- `docs/audit/FINANCIAL_RETRY_CONTRACT.md`
- `docs/audit/REGRESSION_EVIDENCE.md`
- `docs/audit/PROVIDER_ELIGIBILITY.md`
- `docs/audit/RELEASE_EVIDENCE.md`

برای هر task: ID، مالک، فایل‌های تغییرکرده، commit محلی، تست، نتیجه، شواهد، ریسک باقیمانده و وضعیت `CONFIRMED / REPRODUCED / VERIFIED_STAGING / BLOCKED / NOT_DONE` ثبت کن.

پایان کار یعنی گزارش محلی آمادهٔ بازبینی. هرگز push یا deploy خودکار نکن.

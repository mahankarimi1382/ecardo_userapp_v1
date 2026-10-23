# Accessibility و شش زبان eCardo

## استانداردهای پایه
- راهنمای Flutter اندازهٔ هدف لمسی 48×48 dp در Android و 44×44 pt در iOS را توصیه می‌کند؛ برای متن کوچک کنتراست حداقل 4.5:1 و متن بزرگ 3:1 است. WCAG 2.2 AA اندازهٔ هدف 24×24 CSS px را با استثناها مشخص می‌کند؛ برای UX موبایل eCardo، هدف بزرگ‌تر بومی پلتفرم ترجیح دارد.
- `TextScaler`/Dynamic Type را پشتیبانی کنید؛ تست روی کوچک‌ترین دستگاه با اندازهٔ فونت بزرگ.
- تمام icon-only buttons semantics/tooltip/label داشته باشند.
- TalkBack/VoiceOver order و announcement برای loading/pending/error تست شود.
- reduced motion و خاموش‌کردن shimmer/animation در صورت تنظیم دستگاه بررسی شود.

## Locale matrix
برای هرکدام از `fa`, `ar`, `en`, `zh`, `tr`, `ru` بررسی کنید:
- RTL/LTR و ترتیب آیکون‌های معنایی (back/forward)؛
- format مبلغ، decimal/group separator و precision ارز؛
- تاریخ محلی/شمسی فقط در جاهایی که محصول آن را تعریف کرده؛
- متن طولانی، plural/select و interpolation placeholder;
- خط‌شکنی labelها، عرض دکمه‌ها، form error و navigation;
- clipboard/address/account IDs باید جهت متن خنثی داشته باشند تا در RTL جابه‌جا نشوند.

## قواعد localization
- تمام متن‌های قابل مشاهده از ARB/منبع واحد باشند؛ string literal در UI فقط برای developer-only diagnostics با دلیل.
- کلیدها و placeholders بین تمام زبان‌ها مقایسه و parse/compile شوند.
- ترجمهٔ مالی با اصطلاح‌نامه ثابت و بازبینی انسانی انجام شود.
- دادهٔ کاربر، نام گیرنده و آدرس‌ها به‌اشتباه ترجمه نشوند.

## تست
- `flutter gen-l10n` و QC ARB.
- widget/golden برای 6 locale × light/dark × text scale standard/large در صفحات حیاتی.
- دستی: TalkBack, VoiceOver, keyboard, contrast, focus, semantics, clipboard address.

# تکمیل سیستم طراحی eCardo بدون بازنویسی بی‌دلیل

## Source of truth موجود
از فایل design guide عمومی، موارد زیر وجود دارند:
- `AppColors` و `AppSpacing`/`AppTextStyles`
- `EcardoGlassCard`, `EcardoBalanceHero`, `EcardoSwipeButton`, `EcardoDigitalReceipt`, `EcardoEmptyState`, `EcardoErrorView`
- screenshot harness در `test/screenshot_harness.dart`

پیش از افزودن هر component، API واقعی را در checkout فعلی بخوانید. نام و constructorهای فوق از سند راهنما هستند و ممکن است بعداً تغییر کرده باشند.

## لایه‌های طراحی
1. Foundation tokens: semantic colors، typography، spacing، shape، elevation، border، icon sizing، breakpoints، motion durations.
2. Components: Button، TextField، AmountField، CurrencySelector، SearchField، SegmentedControl، Banner، Snackbar، Dialog، BottomSheet، ListTile، TransactionStatus، FeeRow، ReceiptRow، Empty/Error/Loading.
3. Patterns: Auth/OTP، transaction review، payment confirmation، retry/reconcile، account switcher، provider unavailable، network/asset selector، identity/KYC، support ticket.
4. Templates: overview dashboard، detail/list، long form، confirmation/review، receipt, security settings.
5. Content design: اصطلاح مالی یکنواخت، پیام خطا، متن‌های fee/quote، privacy copy و localization keys.

## قوانین token
- رنگ یا فاصلهٔ هاردکد جدید نگذارید، مگر استثنای ثبت‌شده.
- رنگ وضعیت همیشه با icon و متن همراه باشد؛ سبز/قرمز به‌تنهایی کافی نیست.
- مقدار balance در privacy mode باید semantics/accessibility را هم پوشش دهد.
- typography باید Dynamic Type/TextScaler را تحمل کند؛ برای جا دادن متن از clamp سراسری سایز استفاده نکنید.
- هر component variants و states: default, pressed, focused, loading, disabled, error, success, dark, RTL, large text, reduced motion.
- animation صرفاً decoration نباشد؛ اگر حذف شود عملکرد از بین نرود.

## Component contract
هر component مشترک نیازمند purpose، API، state matrix، RTL behavior، semantics، test, screenshot و owner است. breaking change فقط با migration plan و impact map.

## الگوهای مالی
- `MoneyAmount`: Decimal/integer minor units بر اساس currency precision؛ نه float/double به‌عنوان source of truth.
- `FeeBreakdown`: principal, network/provider fee, platform fee, conversion spread/tax, total debit, recipient receives.
- `TransactionStatus`: draft, awaiting_auth, submitted, pending, confirmed, failed, reversed, unknown/reconciling.
- `InlineNotice`: severity + icon + text + accessible label.
- `RetryAction`: فقط زمانی فعال که retry امن باشد؛ وضعیت ambiguous باید به status lookup برود.
- `ProviderCard`: country/region eligibility، currencies، limits، availability و maintenance از backend.

## پیشنهاد اجرایی
اول 4 صفحهٔ pilot (Home, Wallet Details, Transfer Review, Transaction Receipt) را با design system موجود اصلاح کنید، تست‌ها را کامل کنید، سپس componentها را به‌تدریج روی بقیه routeها اعمال کنید. همه صفحات را یک‌باره بازنویسی نکنید.

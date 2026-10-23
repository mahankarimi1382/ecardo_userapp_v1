# سنجه‌های UX و آزمایش‌های محصول

## اصل اندازه‌گیری
هیچ هدف عددی را پیش از baseline واقعی قطعی اعلام نکنید. نرخ completion/abandonment و خطاهای backend باید privacy-safe و با cohort مناسب سنجیده شوند.

## Event taxonomy پیشنهادی
- `screen_view` فقط برای نام مسیر طبقه‌بندی‌شده؛ نه دادهٔ شخصی URL.
- `flow_started`, `review_viewed`, `confirmation_submitted`, `flow_completed`, `flow_failed`, `recovery_started`, `recovery_completed`.
- `error_category` باید دسته‌بندی محدود باشد؛ هیچ message/raw payload، PAN، CVV، PIN، OTP، token، account number یا crypto address وارد analytics نشود.
- `duration_bucket` به جای ثبت timingهای قابل‌شناسایی دقیق در جاهایی که کافی است.

## KPIها
- Task completion rate per key journey.
- Median/p90 time to complete.
- Validation error rate per step.
- Abandonment by step (بدون محتوای حساس).
- Recovery success after recoverable failure.
- Duplicate-submit prevention rate / ambiguous state resolution (metrics aggregate).
- Accessibility defects by severity.
- Visual regression blocker count.
- Scroll jank/frame misses/startup metrics by device tier.
- Support contacts correlated with UX categories, not PII.

## آزمایش‌های اولویت‌دار
1. آیا کاربران پیش از تأیید، total debit و amount received را درست توضیح می‌دهند؟
2. آیا `pending` را از `success` تشخیص می‌دهند؟
3. آیا در Exchange نرخ، زمان quote و fee را درک می‌کنند؟
4. آیا در واریز رمزارز asset/network/address را درست می‌خوانند؟
5. آیا برای یافتن تراکنش گذشته فیلتر مناسب را پیدا می‌کنند؟
6. آیا کاربران RTL با جهت آدرس‌ها، کپی و متن‌های mixed-direction دچار خطا می‌شوند؟

## Governance
Consent/legal review، event schema versioning، retention و access control لازم‌اند. UX analytics هرگز نباید برای logging محتویات مالی حساس استفاده شود.

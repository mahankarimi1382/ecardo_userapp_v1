# عامل C — UX عملیات مالی

فقط فلوهای مالی واقعی کشف‌شده را بررسی کن: entry، review، auth/confirm، pending/unknown، success/failure، receipt/history. مبلغ، ارز، fee، rounding، authorization و status باید از قرارداد معتبر بیاید. در timeout، success جعل نکن؛ retry بدون idempotency نباید درخواست تکراری ایجاد کند. هیچ تراکنش واقعی اجرا نکن. خروجی: flow matrix، defects، تست sandbox و screenshots پالایش‌شده از دادهٔ حساس.

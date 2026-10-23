# امنیت، حریم خصوصی و تاب‌آوری موبایل

## امنیت
- tokens/credentials/passcodes/seed/private keys/personal documents را در log، screenshot test artifact، analytics یا exception text نگذار.
- storage حساس باید از پیاده‌سازی/سیاست پروژه پیروی کند؛ انتخاب secure storage جدید با ADR و threat model.
- UI button hidden/disabled جایگزین authorization server-side نیست.
- deep links و notification actions باید permission/session guard داشته باشند.
- clipboard برای address/IBAN/card/account identifiers سیاست واضح و کمینه‌سازی اطلاعات داشته باشد.
- PII از crash reporting و user analytics redact شود؛ access به artifacts تست محدود شود.
- package/repo خارجی پیش از اقتباس از نظر license، maintenance، CVEs و supply chain بررسی شود.

## تاب‌آوری
- request timeout و reconnect status؛ request cancellation هنگام dispose/navigate؛ prevent stale response overwrite.
- backoff و retry محدود فقط برای عملیات مجاز.
- offline banner نباید operation نامطمئن را success جلوه دهد.
- session expires during submit: اگر درخواست ممکن است server-side اجرا شده باشد، ابتدا status reconciliation.
- loading spinner بی‌پایان ممنوع؛ مسیر cancellation/retry/support مشخص باشد.
- idempotent actions و dedup event handling برای notification/ticket/payment.

## Observability امن
مجاز بعد از policy approval: route ID، feature name، error class، latency bucket، recovery outcome، release SHA. ممنوع به‌صورت پیش‌فرض: نام/شماره کاربر، OTP، passcode، full card/account/address, raw transaction payload, seed/private key, raw amount اگر ضرورت و مجوز رسمی ندارد.

## Dependency evaluation
هر package با این scorecard سنجیده شود: license, maintenance, compatibility, CVE/supply chain, API fit, app size, platform support, localization/a11y, testability, migration cost, fallback strategy. موارد نامعلوم `BLOCKED`، نه PASS.

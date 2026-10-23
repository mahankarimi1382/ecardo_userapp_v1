# Wallet, Accounts و Cards — UX spec

## Wallets / accounts
- هر کارت حساب: label، currency/network اگر مربوط است، balance + available/held به‌صورت تفکیک‌شده، وضعیت، last updated.
- account switcher باید حساب/ارز انتخاب‌شده را واضح نشان دهد و در عملیات در حال انجام تغییر حساب را مسدود یا با تأیید امن کنترل کند.
- موجودی unavailable، reserved، pending و spendable با هم یکی نشان داده نشوند.
- create wallet: توضیح custody، recovery model، fee/limits، network، policy و consent قبل از ساخت.
- حذف مستقیم wallet/seed نباشد؛ وضعیت‌های close/freeze/archive و بررسی اثر روی تاریخچه/دارایی تعریف شوند.

## Cards
- Card list: masked PAN فقط، issuer/provider، currency, physical/virtual، status، expiration فقط در صورت نیاز.
- Card detail: freeze/unfreeze، limits، transactions، funding status، support. حساس‌ترین controls تأیید دومرحله‌ای داشته باشند.
- Create card: server-sourced providers/eligibility/fee/currency/initial-load amount؛ submit تک‌بار؛ وضعیت pending پس از timeout.
- عدم collect/store PAN/CVV توسط UI مگر flow و مجوز پردازش کارت به‌طور معتبر تعریف شده باشد؛ از hosted/tokenized issuer flow استفاده کنید.
- اگر provider غیرقابل‌دسترس است، قبل از ورود به review توضیح و جایگزین واقعی نمایش دهید.

## تست‌ها
- double-tap/rapid tap؛ timeout بعد از ایجاد سفارش؛ insufficient balance؛ fee changed؛ provider unavailable؛ account ineligible؛ duplicate response؛ card pending/failed/active.
- رسید همیشه از دادهٔ سرور ساخته شود، نه از assumption UI.

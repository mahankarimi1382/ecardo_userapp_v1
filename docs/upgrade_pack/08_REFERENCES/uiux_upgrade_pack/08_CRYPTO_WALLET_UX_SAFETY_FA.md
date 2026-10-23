# UX ایمن برای Wallet و Crypto

## اصول
- صفحهٔ دریافت دارایی باید فقط پس از دریافت policy معتبر از backend نمایش داده شود.
- `asset + network + token contract + wallet assignment` یک قرارداد واحد است؛ آدرس به‌تنهایی کافی نیست.
- هرگز آدرس static/fallback، `accountNo` بانکی یا mock در QR واقعی استفاده نشود.
- در خطای سرور، policy ناقص یا تخصیص نامعلوم: آدرس/QR/copy/share غیرفعال بمانند.
- network label واضح و پایدار باشد (مثلاً TRON Mainnet)، نه صرفاً TRON/TRC20 مبهم.
- نشان دهید حداقل واریز، confirmation policy و memo/tag مورد نیاز فقط از سرور آمده‌اند.
- پیش از انتقال خروجی، کاربر شبکه، توکن، آدرس و fee را در review تأیید کند.

## Deposit screen
Header asset/network; assigned address; QR; copy button; expiry/permanent policy; minimum amount; confirmation policy; warning about wrong network; transaction history/status.

## Withdraw screen
Recipient address + validation; chain/network match; fee quote; total deduction; estimated arrival if server-supported; security confirmation; transaction pending state.

## Error recovery
- address policy unavailable: do not render QR or copy action.
- wrong network/contract: block submit and explain.
- expired assignment: request a new assignment from backend; don't silently reuse.
- pending scan: distinguish not detected, detected/unconfirmed and credited.
- duplicate chain event: no duplicate credit; show existing transaction reference.

## پذیرش
تست screenshot تنها کافی نیست. testnet transaction باید از رویداد chain تا ledger credit دنبال شود؛ event replay و reorg/confirmation policy (در صورت پشتیبانی زنجیره) پوشش داده شوند.

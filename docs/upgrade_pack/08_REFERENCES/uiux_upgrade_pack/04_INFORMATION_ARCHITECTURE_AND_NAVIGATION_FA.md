# معماری اطلاعات و ناوبری موبایل

## قواعد اصلی
- ناوبری اصلی برای 3–5 مقصد بااولویت باشد؛ تعداد مقصدها را با تحلیل واقعی استفاده تعیین کنید.
- کارهای پرتکرار (موجودی، ارسال/انتقال، exchange، کارت‌ها، فعالیت) بدون پیمایش طولانی قابل کشف باشند.
- مقصدهای کم‌تکرار (قانونی، جزئیات نسخه، راهنما) زیر Settings/Help قرار بگیرند.
- حفظ routeها و deep-linkهای فعلی اولویت دارد؛ معماری اطلاعات را با redirect سازگار اصلاح کنید، نه با حذف route نامعلوم.
- routeهای مالی از notification/deep link مستقیماً به مرحلهٔ تأیید بدون بررسی session/permission وارد نشوند.

## نقشهٔ پیشنهادی مفهومی
- Overview: total/available balance, privacy toggle, quick actions, recent activity, alerts.
- Accounts & Wallets: currencies/accounts, wallet details, activity, deposit/withdraw, crypto network.
- Payments: transfer, request, QR, merchant payment, bills, exchange.
- Cards: card list, card detail, controls, funding, status, limits.
- Activity: searchable transaction list, filters, transaction detail, downloadable/shareable receipt.
- Profile/More: identity/KYC, security, preferences, language, accessibility, support, legal, rewards.

این یک مدل مفهومی است، نه دستور برای تغییر ناوبری فعلی بدون بررسی داده و routes.

## معیار کشف‌پذیری
- از Home به اقدام اصلی حداکثر 1–2 interaction متناسب با هدف.
- Back رفتار قابل پیش‌بینی دارد؛ خروج از review باعث submission ناخواسته نمی‌شود.
- بعد از برگشت از درگاه یا biometric، context و quote منقضی‌شده بررسی می‌شود.
- bottom navigation state را به‌درستی حفظ می‌کند و scroll reset غیرمنتظره ندارد.
- deep link غیرمجاز به مسیر login/re-auth می‌رود و پس از ورود کاربر را امن به مقصد بازمی‌گرداند.

## روش تصمیم
برای هر route، frequency، task criticality، security sensitivity، revenue impact، support contacts و abandonment را اندازه بگیرید. ساختار نهایی باید بر داده/تست کاربر تکیه کند، نه شبیه‌سازی بصری XPay.

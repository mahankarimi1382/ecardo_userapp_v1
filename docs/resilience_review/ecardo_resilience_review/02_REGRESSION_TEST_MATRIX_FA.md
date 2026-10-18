# ماتریس تست رگرسیون eCardo — Passcode، Exchange و Card Issuance

هر ردیف باید در کلاینت و در صورت لزوم در backend staging اجرا و شناسه اجرای تست/شواهد آن ثبت شود. تست‌هایی که اثر مالی دارند فقط در محیط آزمایشی مجازند.

| ID | حوزه | سناریو | انتظار در کلاینت | انتظار در سرور/دفترکل | اولویت |
|---|---|---|---|---|---|
| PASS-001 | تنظیمات | setting فعال و موجود | popup قبل از commit | passcode معتبر الزامی | P0 |
| PASS-002 | تنظیمات | کلید setting حذف شده | unknown؛ refresh/fail closed | عملیات بدون challenge اجرا نشود | P0 |
| PASS-003 | تنظیمات | config timeout | loading محدود + retry قابل کنترل | بدون دور زدن policy | P0 |
| PASS-004 | تنظیمات | مقدار malformed | unknown و telemetry امن | reject یا پاسخ schema versioned | P1 |
| PASS-005 | Passcode | `PASSCODE_REQUIRED` سپس رمز صحیح | یک prompt و حداکثر یک recovery retry | یک اثر مالی | P0 |
| PASS-006 | Passcode | `PASSCODE_INVALID` | خطای inline، بدون loop | تلاش محدود و rate limit | P0 |
| PASS-007 | Passcode | `PASSCODE_NOT_CONFIGURED` | flow ساخت رمز | هیچ transaction ثبت نشود | P0 |
| PASS-008 | Passcode | کاربر popup را لغو می‌کند | state/loading پاک؛ draft حفظ یا لغو امن | بدون اثر مالی | P0 |
| PASS-009 | Passcode | back/close حین prompt | عدم retry خودکار | بدون اثر مالی | P1 |
| PASS-010 | Retry | اولین درخواست timeout، نتیجه موفق سمت سرور | استعلام وضعیت intent | یک ledger entry | P0 |
| PASS-011 | Retry | پاسخ 5xx بعد از commit | operation id حفظ، status query | هیچ debit دوم | P0 |
| PASS-012 | Retry | retry بعد از restart اپ | بازیابی operation id/intention | همان سفارش/تراکنش قبلی | P0 |
| PASS-013 | Concurrency | دو tap یا دو درخواست همزمان | دکمه busy/serialized | یکتایی اتمیک | P0 |
| PASS-014 | Intent | دو عملیات مستقل با body یکسان | دو operation id | هر دو معتبر و مستقل | P0 |
| PASS-015 | Idempotency | همان key با business body متفاوت | خطای واضح | conflict؛ بدون side effect | P0 |
| PASS-016 | Logging | 422 و exception | متن حساس سانسور | لاگ بدون passcode/token | P0 |
| CARD-001 | Balance | موجودی کافی | ادامه مسیر | رزرو/کسر اتمیک | P0 |
| CARD-002 | Balance | موجودی کم | پیام راهنما | reject بدون سفارش مالی | P0 |
| CARD-003 | Balance | موجودی هنگام submit تغییر می‌کند | هندل خطای سرور | race ایمن، بدون negative balance | P0 |
| CARD-004 | Provider | provider غیرفعال در دیتابیس | عدم نمایش در صورت دریافت config تازه | API هم رد کند | P0 |
| CARD-005 | Provider | provider از UI پنهان ولی API مستقیم فراخوانی شود | N/A | `PROVIDER_UNAVAILABLE` | P0 |
| CARD-006 | Provider | issuer 403/5xx/timeout | پیام دقیق و امن | وضعیت سفارش معلوم/قابل استعلام | P0 |
| CARD-007 | Retry | issuer موفق ولی پاسخ به کلاینت گم شود | status query همان order | کارت/شارژ دوباره ایجاد نشود | P0 |
| CARD-008 | Refund | reserve موفق و issuer شکست | وضعیت failure/pending روشن | compensation دقیقاً یک‌بار | P0 |
| CARD-009 | Funding | alias `wallet` | به enum canonical تبدیل شود | رفتار سازگار | P1 |
| CARD-010 | Funding | alias `irr_wallet` | به enum canonical تبدیل شود | رفتار سازگار | P1 |
| CARD-011 | Funding | دو alias متناقض | نمایش خطای قابل اقدام | reject، بدون side effect | P1 |
| CARD-012 | Pricing | quote منقضی/کارمزد تغییر کرده | تأیید دوباره قیمت | price snapshot معتبر | P0 |
| LOC-001 | Localization | خطا در fa/ar/en | متن محلی صحیح و قابل فهم | خطا براساس code نه message | P1 |
| LOC-002 | RTL | popup در فارسی/عربی | focus و layout صحیح | N/A | P1 |
| REL-001 | Release | اجرای test count همان SHA | گزارش دقیق | artifact و source هماهنگ | P0 |
| REL-002 | Android | Release/R8 نصب fresh | عبور از splash و login | N/A | P0 |
| REL-003 | Privacy | crash/log + offline queue | هیچ داده حساس ماندگار نشود | بدون PII غیرضروری | P0 |

## ثبت نتیجه هر تست

- Test ID:
- Commit SHA:
- Environment (unit / integration / emulator / staging):
- Build artifact SHA-256 (برای APK):
- Preconditions/test data:
- Expected:
- Actual:
- Backend correlation ID (غیرحساس):
- Ledger/order reference (آزمایشی و غیرحساس):
- Result: PASS / FAIL / BLOCKED
- Evidence path:

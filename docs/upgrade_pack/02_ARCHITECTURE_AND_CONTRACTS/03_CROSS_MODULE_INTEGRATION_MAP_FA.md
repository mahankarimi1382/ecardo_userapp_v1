# نقشهٔ اتصال ماژول‌ها به یکدیگر

## الگوی مرجع داده

| موجودیت/سرویس | مالک حقیقت | مصرف‌کنندگان | چیزی که مصرف‌کننده نباید بسازد |
|---|---|---|---|
| Session/Auth | Auth backend + session client | همهٔ ماژول‌های محافظت‌شده | مجوز از روی UI یا token منقضی |
| KYC/Eligibility | KYC/compliance service | cards, transfer, withdrawal, crypto, limits | فرض approved از روی cache قدیمی |
| Account/Wallet balance | account/wallet API + ledger backend | home, wallet, transfer, cards, history | balance محاسبه‌شده از تاریخچهٔ ناقص |
| Fee/Quote/Rate | pricing/quote service | transfer, exchange, withdrawal, crypto | نرخ/کارمزد محلی یا بدون expiry |
| Transaction | transaction/ledger service | history, receipt, notifications, support, statements | status مستقل روی چند صفحه |
| Card lifecycle | card issuer/card service | cards, wallet funding, notifications, support | فعال/مسدود نشان دادن قبل از تأیید server |
| Crypto address/network | wallet/provider service | deposit, withdrawal, receive, QR, receipt | address fallback یا network حدسی |
| Notification | notification service + deep-link resolver | all modules, app shell | باز کردن مقصد محافظت‌شده بدون re-auth |
| Support case | ticket/support API | transaction detail, KYC, auth recovery | ساختن ticket تکراری بعد از timeout |
| Preferences | local settings + policy rules | all screens | تعارض locale/theme preference با app startup |

## یکپارچگی جریان‌ها

1. **Auth → همهٔ ماژول‌ها:** session expiry باید submitهای حساس را امن متوقف کند، state مقصد حفظ شود و پس از re-auth فقط در صورت بی‌خطر بودن ادامه دهد.
2. **KYC → عملیات محدودشده:** UI نتیجهٔ eligibility را نشان دهد، اما server دوباره کنترل کند. status KYC تغییرکرده باید invalidate/refetch ایجاد کند.
3. **Transfer/Exchange/Withdrawal → Transaction:** تنها یک transaction identity و status source مشترک؛ receipt/history/notification از همان مرجع تغذیه می‌شوند.
4. **Wallet/Account → Home/History/Cards:** update بعد از transaction با refresh/invalidation contract؛ مقدار قدیمی باید stale باشد، نه متناقض.
5. **Pricing → Review → Submit:** quote ID، expiry و fee breakdown در review و submit یکسان و قابل ردیابی باشند.
6. **Cards → Wallet/Transactions/Notifications:** issue/freeze/unfreeze/funding operation باید در history و notification reflected شود؛ duplicate event handling لازم است.
7. **Crypto wallet → QR/deposit/withdraw:** network, token, address, fee/minimum/confirmation policy یک contract واحد دارند.
8. **Notifications/Deep links → Auth/Routing:** هر deep link authorization و session guard را از نو طی کند؛ payload notification مرجع مبلغ/status نیست.
9. **Support ↔ Transaction/KYC:** case context از شناسه‌های مجاز و redacted استفاده کند؛ اطلاعات محرمانه در متن آزاد یا telemetry منع شود.
10. **Localization/Theme/Accessibility → تمام UI:** state components و dialogs هم ترجمه‌شده و RTL-accessible باشند، نه فقط صفحات اصلی.

## قرارداد invalidation

وقتی یک operation نتیجهٔ authoritative دارد:
- transaction query/cache با transaction reference invalidate/refetch شود؛
- related wallet/account balance refetch یا refresh policy اجرا شود؛
- history/receipt/notification فقط transaction canonical را نمایش دهند؛
- pending/unknown تا وقتی resolve نشده در همهٔ صفحه‌ها یکسان بماند؛
- هیچ consumer از status قدیمی، خودش نتیجهٔ جدید نسازد.

## ثبت تعارض

اگر دو سرویس یا دو صفحه برای یک مفهوم داده‌ای متناقض دارند، issue جدا با owner، source-of-truth پیشنهادی، reproduction، API evidence، test و ریسک ایجاد شود. در UI «همگام‌سازی ظاهری» بدون اصلاح قرارداد ممنوع است.

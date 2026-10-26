# PER_ROUTE_PARITY_2026-10-24.md — پاریتی بک‌اند به تفکیک هر یک از ۱۳۷ روت اپ کاربر

| موضوع | مقدار |
|---|---|
| تاریخ تولید | 2026-10-24 |
| منابع ورودی | `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv` (۱۳۷ ردیف Route یکتا) • `docs/backend-audit/CAPABILITY_STATUS.md` (verdictهای §۲/§۳/§۴/§۷) • `docs/backend-audit/FEATURE_BACKEND_COVERAGE.csv` (۱۰۹ ردیف) • `docs/quality/GATE_ASSESSMENT_2026-10-24.md` (§۲.۵ و §۳) |
| روش | اسکریپت پایتون (پارس CSV + نگاشت صریح هر ۱۳۷ `entity_id` به دامنهٔ ممیزی‌شده و اعمال verdict همان دامنه؛ برای روت‌های بدون ممیزی عمیق مقدار `NOT_AUDITED`). نگاشت موارد مبهم با بازخوانی کد کلاینت ثابت شد: tour/visa/rental و مانند آن از `NetworkService` (بک‌اند اصلی ecardo.ir) مصرف می‌کنند؛ فقط ماژول travel اپ (`travel_api_repository.dart:12` → `https://trip.ecardo.ir/api/v1`) و صفحات قایق/محلی/غذا (دادهٔ درون‌کد MOCK) وابسته به سرویس جدای trip.ecardo.ir هستند |
| معنای مقادیر | `BACKEND_IMPLEMENTED` = verdict دامنهٔ ممیزی‌شده در CAPABILITY_STATUS.md • `API_DECLARED_ONLY` = سرویس جدا خارج از ecardo-backend • `NOT_AUDITED` = دامنه‌ای که در ممیزی‌های عمیق MP-023..MP-027 پوشش داده نشده |
| اثر دیسکی | فقط همین فایل جدید؛ هیچ فایل دیگری تغییر نکرد؛ هیچ دستور git نوشتاری اجرا نشد |

> محدودیت مبنای ممیزی: همهٔ verdictها حاصل **code-inspection** در SHA بک‌اند `04a7ec8601fff2c6a2a8ed67773ddbb6718be415` هستند؛ ستون‌های تست در CSVهای ممیزی همگی `NOT_RUN`اند (`CAPABILITY_STATUS.md:6,117`).

---

## ۱. جدول خلاصهٔ تجمیعی (تعداد روت به تفکیک backend_parity)

| backend_parity | تعداد روت | سهم از ۱۳۷ |
|---|---|---|
| BACKEND_IMPLEMENTED | ۴۹ | ≈۳۶٪ |
| API_DECLARED_ONLY | ۹ | ≈۷٪ |
| NOT_AUDITED | ۷۹ | ≈۵۸٪ |
| **جمع** | **۱۳۷** | ۱۰۰٪ |

**خوانش:** ۴۹ روت (≈۳۶٪) به دامنه‌های ممیزی‌شده با verdict کامل متصل‌اند؛ ۹ روت سفرِ اپ موبایل به سرویس جدای trip.ecardo.ir وابسته‌اند (parity خارج از ecardo-backend)؛ ۷۹ روت (≈۵۸٪) در هیچ‌یک از ممیزی‌های دامنه‌ای MP-023..MP-027 پوشش داده نشده‌اند. در سطح روت هیچ روتِ CLIENT_ONLY یا MOCK_ONLY وجود ندارد — قابلیت‌های چنین وضعیتی زیرقابلیتِ روت‌های BACKEND_IMPLEMENTED هستند (§۴).

---

## ۲. تفکیک روت‌های دامنه‌های ممیزی‌شده

| دامنه | verdict دامنه (CAPABILITY_STATUS) | تعداد روت | entity_id ها |
|---|---|---|---|
| احراز هویت (auth) | BACKEND_IMPLEMENTED | ۱۰ | 004، 005، 006، 007، 008، 009، 010، 011، 043، 044 |
| انتقال وجه (transfer) | BACKEND_IMPLEMENTED | ۵ | 020، 049، 050، 056، 057 |
| تبدیل ارز (exchange) | BACKEND_IMPLEMENTED | ۲ | 023، 053 |
| واریز (deposit) | BACKEND_IMPLEMENTED | ۸ | 013، 016، 021، 024، 046، 047، 051، 079 |
| برداشت (withdraw) | BACKEND_IMPLEMENTED | ۲ | 022، 052 |
| کارت‌ها (cards) | BACKEND_IMPLEMENTED | ۵ | 066، 067، 068، 070، 071 |
| KYC | BACKEND_IMPLEMENTED | ۶ | 037، 041، 042، 045، 083، 084 |
| P2P | BACKEND_IMPLEMENTED | ۱ | 075 |
| قبض (bill) | BACKEND_IMPLEMENTED | ۸ | 059، 060، 061، 062، 063، 064، 065، 069 |
| پروفایل (profile) | BACKEND_IMPLEMENTED | ۱ | 032 |
| اعلان‌ها (notifications) | BACKEND_IMPLEMENTED | ۱ | 035 |
| سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | ۹ | 076، 077، 078، 132، 133، 134، 135، 136، 137 |

---

## ۳. روت‌های با وضعیت غیر از BACKEND_IMPLEMENTED و NOT_AUDITED

همهٔ روت‌های این جدول `API_DECLARED_ONLY` هستند: مصرف‌کنندهٔ سرویس جدای **trip.ecardo.ir** خارج از مخزن ecardo-backend؛ parity آن‌ها فقط در مخزن جدای ecardo-travel قابل تعیین است.

| نام روت | دامنه | verdict | یک خط شاهد |
|---|---|---|---|
| BaseRoute.travel | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |
| BaseRoute.travelHistory | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |
| BaseRoute.travelAccount | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |
| BaseRoute.boatCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| …» (§۷.۳) + شاهد کد: boat_controller.dart:92 — دادهٔ MOCK آینهٔ trip.ecardo.ir |
| BaseRoute.boatVoucher | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |
| BaseRoute.localCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| …» (§۷.۳) + شاهد کد: local_experience_controller.dart:332 — Tagged MOCK |
| BaseRoute.localVoucher | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |
| BaseRoute.diningCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| …» (§۷.۳) + شاهد کد: dining_controller.dart:382 — Tagged MOCK |
| BaseRoute.diningOrderPass | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY | «Travel اپ موبایل \| API_DECLARED_ONLY \| travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend» (§۷.۳) |

---

## ۴. یادداشت صادقانه — قابلیت‌های CLIENT_ONLY / MOCK_ONLY درون روت‌های BACKEND_IMPLEMENTED

هیچ روتی به‌تنهایی CLIENT_ONLY یا MOCK_ONLY نیست؛ اما ۴ قابلیت از این نوع **درون** روت‌های جدول §۲ زندگی می‌کنند و در جمع‌بندی گیت B باید لحاظ شوند:

| قابلیت (CAPABILITY_STATUS) | verdict | روت میزبان | شاهد |
|---|---|---|---|
| گیت امنیتی واریز: پین‌کد/بیومتریک مرحلهٔ تأیید (§۷.۱) | CLIENT_ONLY | BaseRoute.addMoney | add_money_review_step_section.dart:50-97؛ سرور passcode واریز نمی‌سنجد |
| سقف خرید/تغییر PIN/تعویض کارت (§۷.۳) | CLIENT_ONLY | BaseRoute.virtualCardDetails | spending-limits/change-pin/replace در هیچ route بک‌اند نیستند → 404 همیشگی |
| کلید پرداخت اینترنتی کارت (§۷.۳) | CLIENT_ONLY | BaseRoute.virtualCardDetails | toggleOnlinePayments فقط RxBool محلی (virtual_card_details_controller.dart:38-53) |
| پرداخت سندباکس درگاه (§۷.۱) | MOCK_ONLY | — (وب‌محور؛ هیچ روت اپی میزبانش نیست) | payment.php:53-71؛ GAP-007/GAP-019 |

---

## ۵. بلاکرهای باقی‌ماندهٔ گیت B (تجمیع از GATE_ASSESSMENT_2026-10-24.md §۲ و §۳)

گیت B (حقیقت Backend parity — MP-031) هنوز **قابل بستن نیست**. بلاکرهای باقی‌مانده:

1. **جداسازی mock/production ناقص:** GAP-007 (P0 — GatewaySandbox تراکنش واقعی را بدون درگاه و بدون auth با گیتِ فقط setting + token موفق می‌کند) و GAP-019 (P1 — ChinaPaymentController برخلاف test-payment گارد env ندارد) همچنان OPEN هستند؛ الزام build-time guard (قید E11) پیاده نشده و تسک‌های اصلاحی MP-112/MP-113 در backlog وضعیت TODO دارند.
2. **MP-030 (BLOCKED — ورودی انسانی):** تصمیم محصول دربارهٔ passcode انتقال (پیاده‌سازی سمت سرور در برابر حذف فیلد کلاینت — CAPABILITY_STATUS.md §۳.۳ نکتهٔ ۱)، سرنوشت ثابت‌های بلااستفادهٔ api_path.dart:111,123 (transferHistory/exchangeHistory) و جایگزینی نرخ نمایشی fee.ecardo.ir با `/user/exchange/rate` (§۴.۳) گرفته نشده است.
3. **تست‌های قرارداد/یکپارچگی/امنیتی همگی NOT_RUN:** MP-110 و MP-111 روی نبودِ محیط اجرای PHP روی سرور BLOCKED هستند (قانون ۱ AGENTS.md — سرویس‌دهی روی PC شخصی ممنوع)؛ تقدم ران‌تایم روت‌های تکراری `/api/pay/*` نیز فقط با `php artisan route:list` روی سرور تعیین‌پذیر است (SEC-4). verdictهای همین گزارش نیز میراث همان کدخوانی‌اند.
4. **نقص شکلی «آمار per-route parity مفقود» (§۲.۵ گیت B): رفع شد** — همین گزارش PER_ROUTE_PARITY_2026-10-24.md با پیوست کامل ۱۳۷ ردیفی (خواستهٔ MP-031) تولید و ثبت شد؛ سه بلاکر بالا باقی می‌مانند.

---

## پیوست — جدول کامل ۱۳۷ روت (entity_id، route_name، دامنهٔ نگاشت‌شده، backend_parity)

| entity_id | route_name | دامنه | backend_parity |
|---|---|---|---|
| ROUTE-001 | BaseRoute.root | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-002 | BaseRoute.splash | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-003 | BaseRoute.welcome | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-004 | BaseRoute.signIn | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-005 | BaseRoute.twoFactorAuth | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-006 | BaseRoute.emailOtpLogin | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-007 | BaseRoute.email | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-008 | BaseRoute.verifyEmail | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-009 | BaseRoute.forgotPassword | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-010 | BaseRoute.resetPassword | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-011 | BaseRoute.forgotPasswordPinVerification | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-012 | BaseRoute.navigation | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-013 | BaseRoute.wallets | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-014 | BaseRoute.createNewWallet | کیف‌پول — ایجاد — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-015 | BaseRoute.qrCode | QR دریافت — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-016 | BaseRoute.addMoney | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-017 | BaseRoute.makePayment | پرداخت حضوری (make-payment) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-018 | BaseRoute.requestMoney | درخواست پول (request-money) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-019 | BaseRoute.giftCode | گیفت‌کد — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-020 | BaseRoute.transfer | انتقال وجه (transfer) | BACKEND_IMPLEMENTED |
| ROUTE-021 | BaseRoute.cashOut | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-022 | BaseRoute.withdraw | برداشت (withdraw) | BACKEND_IMPLEMENTED |
| ROUTE-023 | BaseRoute.exchange | تبدیل ارز (exchange) | BACKEND_IMPLEMENTED |
| ROUTE-024 | BaseRoute.transactions | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-025 | BaseRoute.services | خدمات (تایل‌ها) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-026 | BaseRoute.referral | معرفی (referral) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-027 | BaseRoute.referredFriends | معرفی (referral) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-028 | BaseRoute.referralTree | معرفی (referral) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-029 | BaseRoute.permissionsSettings | تنظیمات — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-030 | BaseRoute.privacyPolicy | تنظیمات — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-031 | BaseRoute.deviceSessionsSecurity | تنظیمات — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-032 | BaseRoute.profileSettings | پروفایل (profile) | BACKEND_IMPLEMENTED |
| ROUTE-033 | BaseRoute.changePassword | تنظیمات — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-034 | BaseRoute.twoFactorAuthentication | تنظیمات — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-035 | BaseRoute.notifications | اعلان‌ها (notifications) | BACKEND_IMPLEMENTED |
| ROUTE-036 | BaseRoute.supportTickets | پشتیبانی (تیکت) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-037 | BaseRoute.kycHistory | KYC | BACKEND_IMPLEMENTED |
| ROUTE-038 | BaseRoute.addNewTicket | پشتیبانی (تیکت) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-039 | BaseRoute.replayTicket | پشتیبانی (تیکت) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-040 | BaseRoute.giftHistory | گیفت‌کد — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-041 | BaseRoute.idVerification | KYC | BACKEND_IMPLEMENTED |
| ROUTE-042 | BaseRoute.signUpStatus | KYC | BACKEND_IMPLEMENTED |
| ROUTE-043 | BaseRoute.setUpPassword | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-044 | BaseRoute.personalInfo | احراز هویت (auth) | BACKEND_IMPLEMENTED |
| ROUTE-045 | BaseRoute.authIdVerification | KYC | BACKEND_IMPLEMENTED |
| ROUTE-046 | BaseRoute.walletsDetails | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-047 | BaseRoute.addMoneyHistory | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-048 | BaseRoute.makePaymentHistory | پرداخت حضوری (make-payment) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-049 | BaseRoute.transferHistory | انتقال وجه (transfer) | BACKEND_IMPLEMENTED |
| ROUTE-050 | BaseRoute.transferReceivedHistory | انتقال وجه (transfer) | BACKEND_IMPLEMENTED |
| ROUTE-051 | BaseRoute.cashOutHistory | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-052 | BaseRoute.withdrawHistory | برداشت (withdraw) | BACKEND_IMPLEMENTED |
| ROUTE-053 | BaseRoute.exchangeHistory | تبدیل ارز (exchange) | BACKEND_IMPLEMENTED |
| ROUTE-054 | BaseRoute.requestMoneyHistory | درخواست پول (request-money) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-055 | BaseRoute.giftRedeemHistory | گیفت‌کد — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-056 | BaseRoute.createBeneficiary | انتقال وجه (transfer) | BACKEND_IMPLEMENTED |
| ROUTE-057 | BaseRoute.updateBeneficiary | انتقال وجه (transfer) | BACKEND_IMPLEMENTED |
| ROUTE-058 | BaseRoute.noInternetConnection | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-059 | BaseRoute.billPayment | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-060 | BaseRoute.airtime | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-061 | BaseRoute.electricity | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-062 | BaseRoute.internet | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-063 | BaseRoute.dataBundle | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-064 | BaseRoute.cable | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-065 | BaseRoute.toll | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-066 | BaseRoute.virtualCard | کارت‌ها (cards) | BACKEND_IMPLEMENTED |
| ROUTE-067 | BaseRoute.createVirtualCard | کارت‌ها (cards) | BACKEND_IMPLEMENTED |
| ROUTE-068 | BaseRoute.virtualCardDetails | کارت‌ها (cards) | BACKEND_IMPLEMENTED |
| ROUTE-069 | BaseRoute.billPaymentHistory | قبض (bill) | BACKEND_IMPLEMENTED |
| ROUTE-070 | BaseRoute.getCardInfo | کارت‌ها (cards) | BACKEND_IMPLEMENTED |
| ROUTE-071 | BaseRoute.virtualCardTransaction | کارت‌ها (cards) | BACKEND_IMPLEMENTED |
| ROUTE-072 | BaseRoute.paymentLinks | لینک‌های پرداخت — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-073 | BaseRoute.giftCard | گیفت‌کارت (gift-card) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-074 | BaseRoute.maintenanceMode | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-075 | BaseRoute.p2pTrading | P2P | BACKEND_IMPLEMENTED |
| ROUTE-076 | BaseRoute.travel | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-077 | BaseRoute.travelHistory | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-078 | BaseRoute.travelAccount | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-079 | BaseRoute.dynamicPassword | واریز (deposit) | BACKEND_IMPLEMENTED |
| ROUTE-080 | BaseRoute.remittance | حواله (remittance) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-081 | BaseRoute.remittanceHistory | حواله (remittance) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-082 | BaseRoute.remittanceDetails | حواله (remittance) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-083 | BaseRoute.kycSubmitWizard | KYC | BACKEND_IMPLEMENTED |
| ROUTE-084 | BaseRoute.upgradeRequired | KYC | BACKEND_IMPLEMENTED |
| ROUTE-085 | BaseRoute.appUpdate | به‌روزرسانی اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-086 | BaseRoute.localeTransition | پوستهٔ اپ — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-087 | BaseRoute.tourHome | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-088 | BaseRoute.tourMatch | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-089 | BaseRoute.tourMyBookings | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-090 | BaseRoute.tourDetail | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-091 | BaseRoute.tourBook | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-092 | BaseRoute.tourPayment | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-093 | BaseRoute.tourVoucher | تور (tour) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-094 | BaseRoute.escrowHome | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-095 | BaseRoute.escrowDetail | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-096 | BaseRoute.escrowCreate | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-097 | BaseRoute.escrowPayment | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-098 | BaseRoute.escrowShipment | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-099 | BaseRoute.escrowDispute | اسکرو (escrow) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-100 | BaseRoute.visaHome | ویزا (visa) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-101 | BaseRoute.visaDetail | ویزا (visa) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-102 | BaseRoute.visaList | ویزا (visa) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-103 | BaseRoute.visaIntro | ویزا (visa) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-104 | BaseRoute.stockHome | سهام (stock) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-105 | BaseRoute.stockIntro | سهام (stock) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-106 | BaseRoute.stockOrder | سهام (stock) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-107 | BaseRoute.stockConfirm | سهام (stock) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-108 | BaseRoute.stockTracking | سهام (stock) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-109 | BaseRoute.loanHome | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-110 | BaseRoute.loanDetail | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-111 | BaseRoute.loanIntro | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-112 | BaseRoute.loanApplication | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-113 | BaseRoute.loanConfirm | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-114 | BaseRoute.loanTracking | وام (loan) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-115 | BaseRoute.rentalHome | اجارهٔ خودرو (rental) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-116 | BaseRoute.guaranteeHome | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-117 | BaseRoute.guaranteeDetail | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-118 | BaseRoute.guaranteeIntro | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-119 | BaseRoute.guaranteeApplication | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-120 | BaseRoute.guaranteeConfirm | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-121 | BaseRoute.guaranteeTracking | ضمانت‌نامه (guarantee) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-122 | BaseRoute.rentalDetail | اجارهٔ خودرو (rental) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-123 | BaseRoute.rentalVoucher | اجارهٔ خودرو (rental) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-124 | BaseRoute.remittanceTrack | حواله (remittance) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-125 | BaseRoute.licenseStore | لایسنس (license) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-126 | BaseRoute.licenseMyLicenses | لایسنس (license) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-127 | BaseRoute.licenseIntro | لایسنس (license) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-128 | BaseRoute.commercialProjects | سرمایه‌گذاری تجاری (commercial) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-129 | BaseRoute.commercialProjectDetail | سرمایه‌گذاری تجاری (commercial) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-130 | BaseRoute.commercialInvestCheckout | سرمایه‌گذاری تجاری (commercial) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-131 | BaseRoute.commercialMyInvestments | سرمایه‌گذاری تجاری (commercial) — بدون ممیزی عمیق | NOT_AUDITED |
| ROUTE-132 | BaseRoute.boatCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-133 | BaseRoute.boatVoucher | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-134 | BaseRoute.localCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-135 | BaseRoute.localVoucher | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-136 | BaseRoute.diningCatalog | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |
| ROUTE-137 | BaseRoute.diningOrderPass | سفر اپ موبایل (travel → trip.ecardo.ir) | API_DECLARED_ONLY |

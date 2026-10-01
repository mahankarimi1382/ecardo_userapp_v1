# مستند فنی و نقشه راه پیاده‌سازی بک‌اند خدمات مالی تخصصی eCardo
## Specialized Financial Services — Laravel Backend Specification & Architecture Guide

این سند، استانداردها، ساختار ماژولار، الگوهای پایگاه داده، ماشین‌های وضعیت (State Machines)، و قراردادهای دقیق API را برای پیاده‌سازی سرویس‌های مالی تخصصی در ریپازیتوری `ecardo_web_dev` مشخص می‌کند.

---

## ۱. اصول سه‌گانه سراسری معماری مالی (Global Engineering Rules)

کلیه ماژول‌های این بخش مشمول رعایت دقیق سه اصل اساسی زیر در لایه سرور لاراول هستند:

### اصل اول: دفتر کل دوطرفه و قفل ردیف‌ها (Double-Entry Ledger & Lock Order)
- **مرجع پیاده‌سازی:** `FinAegis/core-banking-prototype-laravel` (مجوز Apache-2.0 — الگوی استاندارد کوربنکینگ لاراول).
- **قانون ثبت تراکنش:** هرگونه انتقال، مسدودی یا کسر وجه باید منحصراً از طریق `JournalEntry` دوبل (بدهکار/بستانکار متوازن) به‌صورت **Append-Only** ثبت شود. هیچ تراکنش مالی قابل `UPDATE` یا `DELETE` نیست و هرگونه اصلاح صرفاً از طریق تراکنش معکوس‌کننده (**Reversal Transaction**) صورت می‌گیرد.
- **جلوگیری از Deadlock:** تراکنش‌ها حتماً درون `DB::transaction()` اجرا شده و قفل ردیف‌ها با `lockForUpdate()` انجام می‌پذیرد. ترتیب قفل کردن حساب‌ها و کیف‌پول‌ها **باید همواره بر اساس ID صعودی (`ORDER BY id ASC`)** باشد تا ریسک بن‌بست پایگاه داده به صفر برسد.
- **حسابداری بدون اعشار شناور:** استفاده از انواع داده اعشاری `float` و `double` در محاسبات ارزی و پولی به‌کلی ممنوع است. تمام محاسبات با پکیج `moneyphp/money` (الگوی Money فاولر) بر پایه کوچکترین واحد پول (Minor Units مانند ریال یا سنت) انجام شده و در دیتابیس به‌صورت `BIGINT` یا `DECIMAL(20, 4)` ذخیره می‌گردد. برای مدیریت کیف پول‌ها پکیج `bavix/laravel-wallet` پیشنهاد می‌شود.

### اصل دوم: ماشین‌های وضعیت صریح (Explicit State Machines)
- **مرجع پیاده‌سازی:** `spatie/laravel-model-states` (مجوز MIT).
- **قانون گذار وضعیت:** استفاده از ستون‌های متنی یا Enumهای آزاد بدون کنترل گذار ممنوع است. وضعیت هر پرونده (وام، ضمانت‌نامه، سفارش سهام، درخواست ویزا و لایسنس) باید یک کلاس State مشخص با کلاس‌های گذار صریح (`Transition`) باشد.
- هر گذار باید پیش‌شرط‌های احراز هویت، تسویه مالی و مدارک را بررسی کند. نمونه: گذار از `AwaitingCollateralState` به `AwaitingSigningState` مستلزم ثبت موفقیت‌آمیز رویداد Ledger تودیع وثیقه است.

### اصل سوم: امنیت سه‌لایه در اندپوینت‌های تغییر وضعیت مالی (Three-Tier Mutation Guard)
هر اندپوینت از نوع `POST`/`PUT`/`DELETE` که بر موجودی، تعهدات یا پرونده مالی اثر می‌گذارد، باید از سه لایه امنیتی عبور کند:
1. **مجوز دسترسی دقیق (Sanctum Abilities):** اعتبارسنجی توکن با ability اختصاصی (مانند `financial:apply`, `financial:transact`).
2. **محدودساز نرخ درخواست مبتنی بر ردیس (Per-User Rate Limiter):** جلوگیری از حملات Brute-Force و تراکنش‌های همزمان تکراری.
3. **کلید عدم تکرارپذیری (Idempotency-Key):** 
   - پیاده‌سازی با پکیج `WendellAdriel/laravel-idempotency` (MIT).
   - هدر الزامی `Idempotency-Key: <UUIDv4>`.
   - کلیدها علاوه بر کش ردیس، باید در جدول پایگاه داده با **ایندکس یکتا (`UNIQUE INDEX`)** ذخیره شوند تا در صورت ریستارت ردیس، تراکنش دوبار اعمال نشود.
   - خطاهای کلاینت (`4xx`) نباید کش شوند؛ صرفاً پاسخ‌های معتبر و قطعی کش می‌شوند.

---

## ۲. معماری ماژولار در لاراول (Modular Architecture)

- **فریم‌ورک ماژولار:** `nwidart/laravel-modules` (MIT).
- **محل قرارگیری:** پوشه `modules/Addons/<ModuleName>/`
- **ساختار فایل‌های هر ماژول:**
  ```text
  modules/Addons/Loan/
  ├── Config/
  │   └── config.php
  ├── Database/
  │   ├── Migrations/
  │   └── Seeders/
  ├── Entities/
  │   ├── LoanProduct.php
  │   ├── LoanCase.php
  │   └── States/
  ├── Http/
  │   ├── Controllers/
  │   ├── Requests/
  │   └── Resources/
  ├── Providers/
  │   └── LoanServiceProvider.php
  ├── Routes/
  │   └── api.php
  └── plugin.json
  ```
- **انولوپ استاندارد پاسخ‌ها (JSON Envelope):**
  ```json
  {
    "status": true,
    "message": "عملیات با موفقیت انجام شد.",
    "data": { ... }
  }
  ```

---

## ۳. مشخصات تفصیلی و مراجع تخصصی ماژول‌ها

### ماژول ۱: وام و تسهیلات اعتباری (`modules/Addons/Loan/`)
- **پیشوند روت:** `/api/user/loan`
- **مراجع تخصصی:**
  - `lendflow` (چهار فرمول تسهیلاتی استاندارد: Flat, Declining-Balance, Fixed-Factor, Interest-Only)
  - `zung-loan-schedule` (منطق تولید جدول اقساط Amortization با دوره تنفس Grace Period)
- **چرخه ماشین وضعیت (State Machine):**
  ```text
  DraftState
     │
     ▼
  UnderAssessmentState ──(نقص مدارک)──► ComplementRequiredState
     │                                           │
     ▼                                           │
  OfferedState ◄─────────────────────────────────┘
     │
     ▼
  AwaitingCollateralState
     │
     ▼
  AwaitingSigningState
     │
     ▼
  DisbursedState ──► ActiveRepaymentState ──► CompletedState
                           │
                           ├──► OverdueState
                           └──► DefaultedState
  ```
- **اندپوینت‌ها:**
  - `GET /products`: کاتالوگ طرح‌های تسهیلاتی (فیلدهای: `id`, `name`, `code`, `min_amount`, `max_amount`, `tenure_options`, `base_rate_annual`, `ltv_pct`, `allowed_collateral_types`)
  - `GET /my`: پرونده‌های جاری کاربر
  - `GET /cases/{id}`: پرونده به همراه وثایق، جدول اقساط و لاگ رویدادها
  - `POST /apply`: ثبت درخواست تسهیلات با متغیرهای اعتبارسنجی
  - `POST /cases/{id}/accept-offer`: قفل شرایط آفر مصوب
  - `POST /cases/{id}/collateral/cash`: قفل سپرده نقدی در والت اسکرو
  - `POST /cases/{id}/collateral/crypto`: قفل دارایی رمزارز با مانیتورینگ نسبت LTV
  - `POST /cases/{id}/sign`: امضای الکترونیک متعهد
  - `POST /cases/{id}/installments/{instId}/pay`: کسر قسط از والت و ثبت در لجر
  - `POST /cases/{id}/early-repayment`: تسویه پیش از موعد اصل وام با بخشودگی سود
  - `POST /cases/{id}/cancel`: لغو و آزادسازی وثایق

---

### ماژول ۲: ضمانت‌نامه بانکی و اعتبارات اسنادی (`modules/Addons/Guarantee/`)
- **پیشوند روت:** `/api/user/guarantee`
- **مراجع تخصصی:**
  - سامانه پیام‌رسانی الکترونیک مالی بانک مرکزی (سپام)
  - الگوی Saga با تراکنش‌های جبران‌کننده (Compensation) از `FinAegis`
- **چرخه ماشین وضعیت (State Machine):**
  ```text
  DraftState
     │
     ▼
  UnderReviewState ──► MarginPendingState ──► InIssuanceState (SEPAM)
                             │                       │
                             ▼                       ▼
                        CancelledState          IssuedActiveState
                                                     │
                                                     ├──► ClaimedState (مطالبه ذینفع)
                                                     └──► ExpiredState (مهلت ۳۰ روزه)
                                                                 │
                                                                 ▼
                                                          MarginReleasedState
  ```
- **اندپوینت‌ها:**
  - `GET /instruments`: لیست انواع ضمانت‌نامه (`Bid Bond`, `Performance Bond`, `Advance Payment`, `LC`) به همراه درصد وجه التزام و کارمزد
  - `GET /my`: پرونده‌های کاربر
  - `GET /cases/{id}`: جزئیات پرونده و استعلام وضعیت بانکی
  - `POST /cases`: ایجاد پرونده با فیلدهای ذینفع، مبلغ، ارز و شماره مناقصه
  - `POST /cases/{id}/documents`: پیوست اسناد رسمی و قرارداد پایه
  - `POST /cases/{id}/submit`: ارسال نهایی به کارشناس اعتباری
  - `POST /cases/{id}/margin`: تودیع وجه التزام نقدی در اسکرو پلتفرم
  - `POST /cases/{id}/cancel`: لغو پرونده قبل از صدور نهایی

---

### ماژول ۳: سهام و بازارهای بین‌الملل (`modules/Addons/Stock/`)
- **پیشوند روت:** `/api/user/stock`
- **مراجع تخصصی:**
  - اتصال به هسته کارگزاری Fix Protocol / REST Brokerage Gateway
  - موتور تبدیل ارز لحظه‌ای (FX Snapshot Engine) بدون نرخ‌های اعشاری شناور
- **اندپوینت‌ها:**
  - `GET /markets`: بازارهای فعال (NYSE, NASDAQ, LSE) و نمادهای تحت پوشش به همراه ساعات کار
  - `GET /account`: حساب کارگزاری کاربر، سطح ریسک و ارزش کل دارایی به USD
  - `GET /portfolio`: سبد دارایی‌های تملک‌شده به همراه سود/زیان
  - `GET /fx-quote`: استعلام نرخ تبدیل ارز لحظه‌ای با شناسه انقضا (Quote Lock)
  - `POST /orders`: ثبت سفارش خرید/فروش با پارامترهای:
    ```json
    {
      "symbol_id": 101,
      "side": "BUY",
      "qty": 2.0,
      "type": "MARKET",
      "limit_price": null,
      "pay_currency": "IRR",
      "acknowledged_risk": true
    }
    ```
  - `GET /risk-quiz` و `POST /risk-quiz`: استعلام و ثبت پرسشنامه ارزیابی سطح ریسک سرمایه‌گذار

---

### ماژول ۴: خدمات کنسولی و اخذ ویزا (`modules/Addons/Visa/`)
- **پیشوند روت:** `/api/user/visa`
- **مراجع تخصصی:**
  - پایپلاین پردازش مدارک کنسولی با صف‌های ناهمگام (Laravel Queue Workers)
  - ذخیره‌سازی رمزگذاری‌شده فایل‌های حساس گذرنامه در دیسک خصوصی (S3 Private with Presigned URLs)
- **اندپوینت‌ها:**
  - `GET /catalog`: کشورهای فعال، انواع ویزا (توریستی، تجاری، تحصیلی)، مدارک الزامی، هزینه و زمان تقریبی
  - `GET /requests`: سوابق درخواست‌های کاربر
  - `GET /requests/{caseNo}`: رهگیری گام‌به‌گام در سفارت
  - `POST /requests`: ثبت مشخصات مسافر و تاریخ سفر
  - `POST /requests/{caseNo}/documents`: آپلود اسناد هویتی و عکس متقاضی
  - `POST /requests/{caseNo}/pay`: پرداخت هزینه کنسولی از کیف پول
  - `POST /requests/{caseNo}/submit`: ارسال به کارتابل کارشناسان بین‌الملل
  - `POST /requests/{caseNo}/confirm-delivery`: تأیید تحویل فایل الکترونیک ویزا (e-Visa) توسط مسافر

---

### ماژول ۵: فروشگاه لایسنس‌های نرم‌افزار (`modules/Addons/License/`)
- **پیشوند روت:** `/api/user/licenses`
- **مراجع تخصصی:**
  - صندوق امن کلیدهای لایسنس (Encrypted Vault با کلید متقارن AES-256)
  - تحویل خودکار با زمان‌سنج گارانتی فعال‌سازی ۴۸ ساعته
- **اندپوینت‌ها:**
  - `GET /catalog`: کاتالوگ دسته‌بندی‌شده محصولات نرم‌افزاری
  - `GET /catalog/{slug}`: جزئیات پکیج و نسخه‌ها
  - `POST /orders`: ایجاد سفارش و رزرو کلید لایسنس
  - `POST /orders/{orderId}/pay-wallet`: پرداخت از والت و تحویل آنی کلید رمزگشایی‌شده
  - `POST /orders/{orderId}/pay-crypto`: پرداخت ارزی رمزارز
  - `POST /orders/{orderId}/confirm-activation`: تأیید عملکرد لایسنس
  - `GET /my-licenses`: صندوق لایسنس‌های فعال کاربر
  - `GET /my-orders`: تاریخچه سفارش‌ها
  - `POST /orders/{orderId}/dispute`: ثبت ادعای نقص کلید برای ارجاع به پشتیبانی

---

## ۴. جمع‌بندی و الزامات استقرار (Deployment Checklist)

1. ایجاد ماژول‌ها ذیل `modules/Addons/` با فایل `plugin.json` متناظر.
2. اعمال مایگریشن‌های دیتابیس با نوع داده `BIGINT` برای موجودی‌ها و مبالغ.
3. رجیستر کردن State Machineها بر روی مدل‌های الکوئنت با استفاده از پکیج Spatie.
4. فعال‌سازی میدل‌ویر `WendellAdriel/laravel-idempotency` روی تمامی متدهای ایجاد و پرداخت.
5. نوشتن آزمون‌های واحد و یکپارچگی (PHPUnit Feature Tests) برای شبیه‌سازی سناریوهای مرزی و تراکنش‌های همزمان.

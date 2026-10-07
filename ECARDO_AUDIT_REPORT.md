# گزارش وضعیت واقعی کدهای فلاتر ECARDO

## 1. خلاصه معماری اجرایی
- **نسخه‌های SDK و Build**:
  - نسخه فلاتر: `^3.22.x` (با توجه به SDK دارت `^3.9.2` و نظراتی که به `Flutter 3.44.6` در `pubspec.yaml` اشاره دارد، اگرچه `3.44` وجود ندارد. دارت `3.9.2` به معنی فلاتر `3.29.x` است).
  - نسخه دارت (Dart SDK): `^3.9.2`
  - نسخه برنامه: `1.0.89+89`
- **الگوهای اصلی معماری**:
  - این برنامه به شدت از **GetX** (`get: ^4.7.2`) برای مدیریت وضعیت (State Management)، تزریق وابستگی (`Get.put`، `Get.find`، `GetxService`) و مسیریابی (`GetMaterialApp`، `GetPage`، `Get.to`) استفاده می‌کند.
  - هیچ اثری از `go_router` یا `bloc`/`cubit` در این مخزن وجود ندارد. تمام وضعیت‌ها و مسیریابی‌ها توسط کنترلرها/بایندینگ‌های GetX مدیریت می‌شوند.
- **سلامت مدیریت وضعیت**:
  - استفاده گسترده از متغیرهای `Obx` و `Rx` متعلق به GetX برای رابط کاربری واکنش‌گرا (Reactive UI).
  - **مشکل**: استفاده ترکیبی از `Get.put` و بایندینگ‌های مسیر (`routes_handler.dart`). برخی از نماها مستقیماً از `Get.find` استفاده می‌کنند که اگر بدون بایندینگ مسیر بازدید شوند، باعث کرش کردن برنامه می‌شوند (مثلاً `remittance_details.dart:16`).
- **پیکربندی Build**:
  - متغیر `kDebugMode` به وفور در سراسر برنامه (به ویژه در `NetworkService`، `TokenService`، `FirebaseMessagingService` و کنترل‌کننده‌های خطا) برای ثبت اطلاعات دیباگ (مانند توکن‌ها، درخواست‌های API، خطاها) استفاده شده است.

## 2. کاتالوگ API و شبکه

| # | قابلیت / ماژول | متد HTTP | مسیر Endpoint | فایل فراخوان و خط | وضعیت (متصل / ماک شده / خراب) |
|---|---|---|---|---|---|
| 1 | احراز هویت (ورود) | POST | `/api/auth/user/login` | `network_service.dart:154` | متصل (پایه `https://ecardo.ir`) |
| 2 | احراز هویت (ثبت‌نام) | POST | `/api/auth/user/register` | `network_service.dart:178` | متصل |
| 3 | سفر (پایه) | GET/POST | `/api/v1/` | `travel_api_repository.dart:9` | متصل (`https://trip.ecardo.ir/api/v1`) |
| 4 | کارمزد تبدیل ارز | GET | `/` | `fee_ecardo_rate_source.dart:9` | متصل (`https://fee.ecardo.ir`) |
| 5 | تازه‌سازی توکن (Refresh) | POST | `/api/auth/user/refresh` | `api_path.dart:167` | متصل |
| 6 | پرداخت قبوض | POST | `/user/pay-bill` | `api_path.dart:104` | متصل / محافظ‌های خراب (بدون آیدمپوتنسی/تایم‌اوت، دور زده شده) |
| 7 | رمز پویای OTP | POST | `/pay/generate-otp` | `api_path.dart:45` | خراب (برگشتِ هاردکد `404` که در تست `flow_test_report.md` یافت شد) |
| 8 | هشدار نرخ (Rate Alert) | POST | `ندارد` | `rate_alert_placeholder.dart:71` | ماک شده (فقط UI، اتصال به بک‌اند TODO است) |
| 9 | افزودن/ویرایش حساب پرداخت | POST/PUT | `/user/p2p/payment-accounts` | `add_payment_method_controller.dart:209` | جزئی (لفاف‌های Dio را دور می‌زند، استفاده از `Dio()` خام) |

## 3. ماتریس واقعیت مسیرها و سفرهای کاربر

*(توجه: از GetX به جای GoRouter استفاده شده است. هیچ کنترل‌کننده وضعیت Block/Cubit وجود ندارد، فقط کنترلرهای GetX موجود هستند.)*

| ماژول | ویجت صفحه (Screen) | مسیر (Route) | گارد احراز هویت؟ | اتصال به بک‌اند؟ | یادداشت‌ها / شواهد ماک |
|---|---|---|---|---|---|
| **احراز هویت** | `SignInScreen` | `/sign_in_route` | گیت Splash | `REAL_API` | گارد بیومتریک مبتنی بر UI است (`onTap`). برای `POST_NOTIFICATIONS` گارد صریح در زمان اجرا در اندروید 13+ جا افتاده است. |
| **احراز هویت** | `AuthIdVerification` | `/auth_id_verification_route` | گیت Splash | `REAL_API` | - |
| **سفر (Travel)** | `TravelScreen` | `/travel_route` | خیر (دور زده شده) | `REAL_API` / `MOCKED` | رابط کاربری از رشته‌های ماک شده (مثل `travelMockHotelEspinas`) در `travel_widgets.dart:18` استفاده می‌کند. API به `trip.ecardo.ir` متصل است. |
| **کیف پول** | `WalletsScreen` | `/wallets_route` | بله | `REAL_API` | نرخ‌های لحظه‌ای. |
| **تبدیل ارز** | `ExchangeScreen` | `/exchange_route` | بله | `PARTIAL` | ویژگی هشدار نرخ کاملاً غیرفعال است (`rate_alert_placeholder.dart:71`). |
| **حواله (Remittance)** | `RemittanceDetails` | `/remittance_details_route` | بله | `REAL_API` | مسیر دیپ‌لینک مرده. نبود بایندینگ `GetPage` باعث کرش کردن `Get.find` می‌شود. دقت اعشار روی ۲ هاردکد شده است. |
| **P2P** | `P2PTrading` | `/p2p_trading_route` | بله | `PARTIAL` | صفحات apply_verification و payment_account در P2P از نمونه‌های `Dio()` خام استفاده می‌کنند. |
| **پرداخت قبض**| `BillPaymentScreen`| `/bill_payment_route` | بله | `BROKEN` | فاقد گارد سابمیت دوگانه، گاردهای موجودی و مدیریت وضعیت است. Force unwrap روی `charge!` باعث کرش می‌شود. |

## 4. یافته‌های حیاتی امنیتی و یکپارچگی داده‌ها

- **ذخیره‌سازی داده‌های حساس و توکن‌ها**:
  - کلاس `TokenService` به درستی از `SharedPreferences` به `FlutterSecureStorage` مهاجرت کرده است (در `token_service.dart:17`).
  - رمز عبور و قفل‌های برنامه از `FlutterSecureStorage` با گزینه `encryptedSharedPreferences: true` استفاده می‌کنند.
  - برخی تنظیمات عمومی هنوز در `SharedPreferences` ذخیره می‌شوند (مثلاً `AppUpdateController`).
- **خطر درز اطلاعات شخصی (PII) در لاگر شبکه**:
  - در `network_service.dart:771`، هدرهای HTTP (Authorization) و بدنه درخواست‌ها (مانند رمزهای ورود، داده‌های پرداخت) با استفاده از `_log` و `jsonEncode` لاگ می‌شوند.
  - تابع `_log` قبل از چاپ کردن وضعیت `kDebugMode` را بررسی می‌کند. اگر `kDebugMode` صحیح باشد (در محیط‌های Dev/Staging)، رمزها، توکن‌ها و اطلاعات شخصی در خروجی استاندارد افشا می‌شوند. کد اکنون طول توکن را پنهان می‌کند (`<redacted X chars>`) اما بدنه درخواست‌ها ممکن است همچنان افشا شوند.
- **اسرار هاردکد شده یا نقاط انتهایی (Endpoints) تستی**:
  - آدرس‌های پایه (Base URLs) هاردکد شده‌اند:
    - اصلی: `https://ecardo.ir/api`
    - سفر: `https://trip.ecardo.ir/api/v1`
    - کارمزد: `https://fee.ecardo.ir`
  - هیچ کلید مخفی فایربیس به صورت هاردکد در مخزن وجود ندارد (انتظار می‌رود فایل `firebase-credentials.json` یا پیکربندی google-services ارائه شود).

## 5. کدهای ناقص، ماک شده و رها شده

- **المان‌های کاربری ماک/شبیه‌سازی شده**:
  - **هشدار نرخ (Rate Alert)**: مسیر `rate_alert_placeholder.dart:71` کاملاً ماک شده است. رابط کاربری پیام "به زودی" را نشان می‌دهد و فراخوانی API به عنوان `TODO` مشخص شده است.
  - **ماک‌های سفر**: `travel_widgets.dart:18-29` حاوی متغیرهای صریح ماک شده است (`travelMockHotelEspinas`، `travelMockFlightTehranIstanbul` و غیره) که به ترجمه‌ها نگاشت شده‌اند، احتمالاً برای دور زدن کمبود موجودی در محیط استیجینگ.
- **فایل‌های یتیم و مسیرهای مرده**:
  - ثابت مسیر حذف شده: `BaseRoute.setPasscode` حذف شده است (هرگز از طریق GetPage استفاده نشده بود).
  - مسیرهای مرده: مسیرهای `invoice*` و `replayTicket` (مورد M-6 در اسناد ممیزی) به مسیر ناشناخته `unknownRoute` (همان Splash) سقوط کرده‌اند. `BaseRoute.replayTicket` به صورت درون‌خطی ثبت شده اما به شکل کامل نگاشت نشده است.
- **موارد TODO / FIXME با شدت بالا**:
  - `remittance_details.dart:16` - `TODO(lead): add a RemittanceBinding`.
  - `remittance_controller.dart:694` - اعشار هاردکد شده: `TODO(lead): exchange-rate precision is not exposed`.
  - چندین متغیر با اعمال `force-unwrap` (مانند `double.tryParse(x!)!`) در بخش جزئیات Request Money وجود دارد که در صورت نبود داده باعث کرش‌های مهلک می‌شوند.
  - شش کنترلر (شامل پرداخت قبض، تاییدیه P2P، برداشت) از `dio.Dio()` خام استفاده می‌کنند و `NetworkService` را دور می‌زنند، به این معنی که فاقد حلقه‌های تازه‌سازی توکن 401، کلیدهای آیدمپوتنسی و تایم‌اوت‌های اتصال هستند.

## 6. پنج بلاکر (مسدودکننده) فوری برتر برای مالک محصول (Product Owner)

1. **[P0] پرداخت قبض و دور زدن‌های شبکه (جریان اصلی خراب / امنیتی)**
   - 6 کنترلر (شارژ، برق، اینترنت، تایید P2P، برداشت) یک کلاینت خام `Dio()` ایجاد می‌کنند. این‌ها تازه‌سازی توکن (401)، کلیدهای آیدمپوتنسی (محافظ‌های ارسال دوگانه) و تایم‌اوت‌ها را دور می‌زنند. پرداخت‌های قبوض فاقد بررسی موجودی قبل از ارسال هستند.
2. **[P1] نبود بایندینگ‌های مسیر که باعث کرش می‌شوند (جریان اصلی خراب)**
   - دیپ‌لینک زدن یا هدایت به `/remittance_details_route`، `/kyc_submit_wizard_route` و `/dynamic_password_route` بدون مقداردهی اولیه کنترلر قبلی، باعث کرش‌های مهلک می‌شود زیرا `Get.find` با خطا مواجه می‌شود.
3. **[P1] کرش‌های ناشی از Force-Unwrap در تراکنش‌های مالی (یکپارچگی داده‌ها)**
   - استفاده گسترده از `double.tryParse(...)!` در `VirtualCardDetails` و `RequestMoneyDetails`. اگر بک‌اند `null` یا یک رشته نامعتبر برگرداند، برنامه با یک خطای مهلک روبرو می‌شود.
4. **[P2] خطای 404 در نقطه انتهایی رمز پویا (OTP) (ویژگی خراب)**
   - مسیر `POST /pay/generate-otp` خارج از `ApiPath` هاردکد شده و پاسخ 404 را از سرور دریافت می‌کند، که باعث می‌شود ویژگی "رمز پویا" کاملاً خراب و غیرقابل استفاده باشد.
5. **[P2] هشدار نرخ (ویژگی ناقص)**
   - ویژگی هشدار نرخ کاملاً بصری (`rate_alert_placeholder.dart`) است و از نظر عملکردی هیچ کاری انجام نمی‌دهد (ماک شده است).
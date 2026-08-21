# eCardo — User Application (`ecardo_userapp_v1`)

> **آخرین بهروزرسانی:** 2026-08-21 — شناسایی مجدد کامل سورس (در برابر نسخهٔ قبلی README که مربوط به قبل از ریبرند و چندین fix بود)
> **Version:** 1.0.23+23 | **Flutter** | **Android + iOS + Web**

اپلیکیشن کاربر پلتفرم مالی بینالمللی **eCardo** — کیف پول چندارزی، کارت مجازی، انتقال، رمیتنس، سفر (travel)، P2P، پرداخت قبض و بیشتر.

---

## 1) نمای کلی (Executive Summary)

اپلیکیشن کاربر eCardo یک اپ **فینتک کامل و mature** است:

| شاخص | مقدار |
|-------|-------|
| فایلهای Dart | **513** (`lib/`) |
| خطوط Dart | **~157,000** |
| ماژولهای feature | **26** (`lib/src/presentation/screens/`) |
| فایلهای presentation | **443** |
| فایلهای common | **40** |
| فایلهای network | **6** |
| فایلهای app | **13** |
| فایلهای view/screen | **225** |
| Controller ها | **84** |
| Model ها | **68** |
| Widget های مشترک | **18** |
| فایلهای تست | **7** |
| Asset ها | **290** |
| زبانها (ARB) | **6** (en, ar, fa, zh, ru, tr) — هر زبان ~2,200 کلید |
| فونتهای bundle شده | 8 (شامل Vazirmatn فارسی، LemiFont چینی، NotoSansRU روسی) |
| Package name | `com.ecardo.user` |
| App label | `eCardo` (Android + iOS) |
| Firebase project | `ecardo-app` |

**معماری:** GetX (state + DI + routing) + Dio + `flutter_screenutil` + `shimmer` + `flutter_secure_storage`.
**Base URL:** `https://ecardo.ir/api` (هاردکد، بدون flavor). سرویس نرخ ارز: `https://fee.ecardo.ir/api/v1/rates`. سرویس سفر: `https://trip.ecardo.ir/api/v1`.

---

## 2) وضعیت ریبرند (Qunzo → eCardo) — ✅ کامل

ریبرند از برند قدیمی **Qunzo** به **eCardo** انجام شده است (برخلاف نسخهٔ قبلی README که میگفت فقط ۵٪):

| مورد | مقدار فعلی |
|------|------------|
| `pubspec.yaml` name | `ecardo_user` ✅ |
| Android namespace / applicationId | `com.ecardo.user` ✅ |
| کلاس Dart | `EcardoUser` ✅ |
| Android label | `eCardo` ✅ |
| iOS CFBundleDisplayName / Name | `eCardo` ✅ |
| Firebase projectId | `ecardo-app` ✅ |
| import های Dart | `package:ecardo_user/...` ✅ |
| نسخه | `1.0.23+23` |

---

## 3) Localization — ✅ ۶ زبان

- **6 فایل ARB**: `app_en`, `app_ar`, `app_fa`, `app_zh`, `app_ru`, `app_tr` — هر کدام ~2,200 کلید ترجمه.
- **`supportedLocales`**: en, ar, fa, zh, ru, tr.
- **فونتهای region-aware** bundle شده:
  - Vazirmatn (فارسی/عربی)
  - LemiFont (چینی)
  - NotoSansRU (روسی)
  - Plus Jakarta Sans (لاتین/اصلی)
- **`l10n.yaml`** + `flutter gen-l10n` برای تولید accessor ها.

> ⚠️ **نکته:** در حالی که ARB ها برای هر ۶ زبان موجودند، **استفادهٔ واقعی از تاریخ شمسی محدود است** (فقط در ماژول travel؛ `Jalali.fromDateTime`). سایر ماژولها از `DateFormat` میلادی استفاده میکنند. → بهبود پیشنهادی (بخش ۹).

---

## 4) ماژولهای feature (۲۶)

authentication، home، wallets، add_money، make_payment، request_money، transfer، cash_out، withdraw، exchange، transactions، gift_code، gift_card، payment_links، virtual_card، bill_payment، p2p، qr_code، referral، beneficiary، settings، travel، remittance، kyc_level، dynamic_password، app_update.

**جریانهای اصلی کاربر:**
1. **Onboarding:** Splash → Welcome → Sign Up (Email → Verify Email → Set Up Password → Personal Info → Auth ID Verification → Status).
2. **Auth:** Sign In → (2FA) → Navigation. Biometric re-login.
3. **Dashboard:** Bottom-nav (Home / Transfer / Gift / Settings) + Scanner + Drawer.
4. **Money-in:** Add Money (gateway methods) → webview → success.
5. **Money-out:** Withdraw (bank/crypto), Cash Out (agent).
6. **Transfer / Exchange / Virtual Cards / P2P / Bill Payment / Gift / Referral / Remittance / Travel.**

> ⚠️ Transfer/Gift در bottom-nav بر اساس feature flags backend (`user_transfer`/`user_gift` در `get-settings`) فعال/غیرفعال میشوند.

---

## 5) شبکه و API

- **Dio** با ۲ instance: `_dio` (authenticated) و `_globalDio` (public).
- **Auth:** Bearer token از `flutter_secure_storage` (نه SharedPreferences) ✅ — با migration از نسخهٔ قدیمی.
- **Retry interceptor** برای درخواستهای auth ✅.
- **Timeout handling** (DioException connection/receive) ✅.
- **Base URL هاردکد** — بدون dev/staging/prod flavor.
- **8۰+ endpoint** در `api_path.dart` تحت `/user/...` و `/auth/...`.

### سرویسهای خارجی که اپ مصرف میکند
| سرویس | آدرس | نقش |
|--------|-------|------|
| Backend اصلی | `https://ecardo.ir/api` | همهٔ ماژولها |
| نرخ ارز | `https://fee.ecardo.ir/api/v1/rates` | صفحهٔ exchange (polling 60s) |
| سفر (Travel) | `https://trip.ecardo.ir/api/v1` | هتل/پرواز/eSIM؛ auth از طریق `POST /auth/exchange` با `source_token` |

---

## 6) امنیت (وضعیت فعلی)

### ✅ اصلاح شده (برخلاف README قدیمی)
| مورد | وضعیت |
|------|--------|
| Bearer token | `flutter_secure_storage` (Keystore/Keychain) ✅ |
| Password ذخیرهشده برای biometric | `flutter_secure_storage` (migrated) ✅ |
| `network_security_config.xml` | ✅ موجود (HTTPS-only، trust system CA، pin برای ecardo.ir/trip) |
| `usesCleartextTraffic="false"` | ✅ |
| `READ/WRITE_EXTERNAL_STORAGE` | ✅ با `maxSdkVersion` صحیح |
| `MANAGE_EXTERNAL_STORAGE` | ✅ حذف شده |
| `proguard-rules.pro` | ✅ موجود |
| keystore ها / `key.properties` | ✅ در `.gitignore`؛ فقط `key.properties.example` |
| Release signing | از GitHub Secrets (`SIGNING_KEYSTORE_BASE64` و...) + debug fallback |
| Firebase project | `ecardo-app` ✅ |
| Package name | `com.ecardo.user` ✅ |

### ⚠️ باز (نیاز به اقدام)
| # | یافته | شدت |
|---|-------|------|
| S1 | **`POST_NOTIFICATIONS` permission** در مانیفست نیست (روی main) — Android 13+ نوتیفیکیشن سایلنت fail | **P1** (پچ آماده روی branch `audit/phase1-notifications-cleanup`) |
| S2 | **iOS push entitlement = `development`** (`ios/Runner/Runner.entitlements`) | P1 (تولید push fail میکند) |
| S3 | **بدون certificate pinning** در Dio (فقط network_security_config برای Android) | P2 |
| S4 | **بدون root/emulator detection** و **بدون Play Integrity** | P2 |
| S5 | **بدون obfuscation** در release build (`--obfuscate --split-debug-info`) | P2 |
| S6 | **dark theme غایب** (`themeMode: ThemeMode.light`؛ فقط `light_theme.dart`) | P2 (UX/امنیت صفحه قفل) |

---

## 7) CI/CD

- **2 workflow**: `flutter.yml` (Android APK build + release) و `web.yml`.
- `flutter analyze` اجرا میشود ولی **با `|| true`** — خطاها fail نمیکنند (نیاز به اصلاح: fail-on-error بعد از تأیید clean بودن).
- Release keystore از GitHub Secrets دیکد میشود؛ fallback debug keystore برای همیشه-installable بودن.
- **تستها**: ۷ فایل تست (شامل travel و card_product_model).

---

## 8) تستها

7 فایل تست در `test/`:
- `card_product_model_test.dart`
- `widget_test.dart`
- `travel/travel_bidi_widget_test.dart`
- `travel/travel_controller_idempotency_test.dart`
- `travel/travel_order_status_test.dart`
- `travel/travel_safe_error_test.dart`
- `travel/travel_search_history_test.dart`

> ⚠️ پوشش تست محدود است (بهویژه برای ماژولهای مالی: exchange، transfer، wallet). → بهبود پیشنهادی.

---

## 9) یافتههای باز / بهبودهای پیشنهادی (بهروز — 2026-08-21)

### P1 (مهم)
1. **`POST_NOTIFICATIONS`** در AndroidManifest (پچ آماده روی branch `audit/phase1-notifications-cleanup`؛ merge شود).
2. **iOS push entitlement** → از `development` به `production` (برای release).
3. **`flutter analyze ... || true`** → fail-on-error (بعد از تأیید clean).

### P2 (متوسط)
4. **Dark theme** — ساخت `dark_theme.dart` + `ThemeMode.system`.
5. **تاریخ شمسی در ماژولهای اصلی** (exchange، transactions، home) — فقط travel استفاده میکند. helper آماده: `/home/user/qc/jalali_helper.dart` (تست 7/7 PASS).
6. **Skeleton loader** — فقط home دارد؛ بقیه spinner.
7. **Certificate pinning** در Dio.
8. **Root/emulator detection + Play Integrity** برای اپ مالی.
9. **Obfuscation** در release build.
10. **Deep links / app links** — برای referral و پرداخت redirect (فعلاً وجود ندارد).

### P3 (کم)
11. **Base URL هاردکد** — افزودن flavor / env.
12. **پاجینیشن** در history های بزرگ.
13. **no repository layer** — controller ها مستقیم `NetworkService` صدا میزنند.
14. حذف comment keys (`comment_*`) از باندل.

---

## 10) چکلیست وضعیت نهایی (در برابر README قدیمی)

| ادعای README قدیمی | وضعیت فعلی |
|--------------------|------------|
| نام `qunzo_user` | ✅ `ecardo_user` |
| فقط en/ar | ✅ ۶ زبان |
| token/password در prefs | ✅ secure storage |
| بدون retry | ✅ retry دارد |
| بدون network_security_config | ✅ موجود |
| بدون proguard | ✅ موجود |
| بدون تست | ✅ ۷ تست |
| package `com.qunzo.user` | ✅ `com.ecardo.user` |

---

## 11) اجرا (Build)

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release   # (CI: از GitHub Secrets keystore)
flutter build web
```

**پیشنیاز:** Flutter SDK 3.44.6+ (CI از `subosito/flutter-action` با flutter-version 3.44.6 استفاده میکند)، Dart SDK ^3.9.2.

---

## 12) تاریخچهٔ نسخهها (recent)

| نسخه | خلاصه |
|------|-------|
| **1.0.23+23** | رفع QC blocker های remittance + exchange |
| 1.0.22+22 | رفع collision در FormData/MultipartFile (اندروید) |
| 1.0.21+21 | ۸ bug fix جراحی در remittance + exchange |
| 1.0.20+20 | اصلاح APK Signing Block parsing در CI |
| 1.0.19+19 | اصلاح مسیر keystore نسبت به rootProject |
| 1.0.18+18 | استفاده از release keystore از GitHub Secrets |
| 1.0.17+17 | تولید fallback keystore هنگام configuration |
| 1.0.16+16 | وابستگی صریح task برای ensureDebugKeystore |
| 1.0.15+15 | اطمینان از امضای همیشگی APK (رفع «parsing the package») |
| 1.0.14+14 | جایگزینی GetX `.tr` با AppLocalizations + فعالسازی زبان ترکی |
| 1.0.13+13 | رفع l10n برای string های جدید در exchange |
| 1.0.12+12 | l10n generation + EdgeInsetsDirectional |

---

*این README بر اساس شناسایی مجدد کامل سورس (branch `main`، commit `7f6f37d`) در 2026-08-21 تهیه شده است. جزئیات امنیتی/نسخه ممکن است با تغییرات آینده بهروزرسانی شوند.*

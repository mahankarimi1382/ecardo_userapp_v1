# معماری هدف eCardo — ارتقا بدون بازنویسی اجباری

## قاعده
ابتدا معماری موجود را کشف و تثبیت کن؛ این سند الگوی مرجع است، نه دستور مهاجرت تمام فایل‌ها. با توجه به سابقهٔ پروژه، GetX و Dio نباید صرفاً برای مد روز بودن جایگزین شوند. ساختار فعلی feature/domain/data باید شناسایی و با این لایه‌ها تطبیق داده شود.

## مسیر استاندارد هر درخواست

`Screen / Widget → GetX Controller (یا state owner فعلی) → Use Case / Domain policy → Repository interface → Dio/API data source → Backend`

بازگشت:

`Backend DTO → data mapper → domain model/value object → explicit Result/State → Controller → UI`

- Widget دادهٔ API خام یا منطق حسابداری را تفسیر نکند.
- Controller هماهنگ‌کنندهٔ view state باشد، نه مالک policy پیچیدهٔ پولی.
- repository interface، error mapping و test seam در ساختار سازگار فعلی ایجاد شوند؛ برای هر feature طبقه‌بندی جدا از روی کد واقعی انجام شود.
- API source-of-truth برای fee/rate/eligibility/limits/financial status حفظ شود.
- cache صرفاً stale/last-known را نشان دهد و به‌صراحت stale اعلام شود؛ نباید status تراکنش را به success ارتقا دهد.

## قرارداد state مشترک

برای هر screen/operation حداقل موارد متناسب لازم است:
- `initial`
- `loading`
- `ready`
- `empty` (در موارد لیست/جست‌وجو)
- `submitting`
- `pending`
- `success` (فقط با نتیجهٔ معتبر)
- `failure` (قابل‌تفکیک از validation/auth/network/business-rule)
- `unknown/reconciling` (مخصوص نتیجهٔ عملیات نامعلوم)
- `offline/stale`
- `permissionDenied/authRequired/maintenance`

به‌جای یک enum عظیم و بی‌معنا، از stateهای domain-specific استفاده کن؛ این فهرست چک‌لیست معنایی است.

## قرارداد خطا

یک error envelope داخلی باید حداقل این‌ها را حفظ کند:
- category: validation / authentication / authorization / business-rule / rate-limit / network / timeout / server / parsing / unknown
- stable code از backend (در صورت وجود)
- user-safe localized message key
- field errors و metadata غیرحساس
- retryability و شرط retry امن
- correlation/request ID غیرحساس
- remediation action (login, refresh, edit field, contact support, status lookup)

اصل: HTTP status به‌تنهایی کافی نیست. UI متن خام Exception یا backend stack را به کاربر نشان ندهد. کدهای مالی باید map explicit داشته باشند و fallthrough به success ممنوع است.

## کنترل side effect

- در آغاز درخواست، operation state و idempotency key (اگر endpoint از آن پشتیبانی می‌کند) ثبت شود.
- روی tap دوباره، submit هم‌زمان مسدود شود.
- پس از timeout، اگر سرور ممکن است عملیات را ثبت کرده باشد، ابتدا status lookup/reconciliation انجام شود؛ ارسال عملیات جدید خودکار ممنوع.
- optimistic UI برای موجودی یا status مالی فقط با policy مستند مجاز است؛ در غیر این صورت تا تأیید سرور pending نمایش داده شود.
- navigation به receipt نباید خودش success را القا کند؛ status واقعی تراکنش باید صریح باشد.

## Design System موجود

- `DESIGN_SYSTEM_GUIDE.md` محلی بر این سند مقدم است.
- component APIهای موجود را اول مطالعه کن: glass/balance/swipe/receipt/empty/error patterns و مواردی که واقعاً در کد موجودند.
- CTA بدون callback ممنوع. receipt باید status واقعی دریافت کند، نه default success. کنترل‌های swipe/reset باید cycle عمر درست داشته باشند.
- `app_colors.dart`, `app_spacing.dart`, themes و مسیرهای `common/widgets/design_system/**` در guide فعلی فایل‌های مالکیت‌قفل‌شده‌اند؛ بدون handoff آن‌ها را تغییر نده.

## ADR موردنیاز
ADR لازم است برای: dependency تازه، migration state-management/router, network client replacement, money decimal library, analytics vendor, secure storage/security design, backend contract change, navigation redesign و حذف widget/shared component.

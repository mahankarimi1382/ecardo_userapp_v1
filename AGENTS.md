# AGENTS.md — ریپوی ecardo_userapp_v1 (اپ کاربر، Flutter)

قوانین کلی: `/var/www/fastuser/data/repos/START-HERE.md` (موظف به خواندن)

## قوانین این ریپو
- **ورژن:** هر تغییر = bump در `pubspec.yaml` (مثلاً `1.0.42+42`) و تگ `v1.0.42` برای ریلز
- **بیلد/تست:** فقط GitHub Actions (ورک‌فلوهای `flutter.yml` / `web.yml`): analyze + test روی هر push، بیلد ساین‌شده روی تگ
- **APK:** هرگز به سرور یا داخل گیت نمی‌آید — Actions آن را به ریپوی عمومی `ecardo-apps-releases` mirror می‌کند و وبوک پنل با لینک عمومی آپدیت می‌شود
- **ساختار:** کد در `lib/src/`، ترجمه‌ها در `lib/l10n/`، مستندات در `docs/`
- **هویت کامیت:** `Agent: github-user` (ایجنت گیت‌هاب) یا `Agent: server-user` (ایجنت سرور)

## ورژن فعلی
`1.0.41+41` — آخرین ریلز عمومی: `userapp-v1.0.40` (یک نسخه منتشرنشده جلوتر)

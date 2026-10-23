# شروع سریع مرحلهٔ ۳

```bash
# 1. در ریشهٔ repo و پس از خواندن دستورهای پروژه
python --version
python 05_SCRIPTS/build_screen_upgrade_registry.py \
  --input docs/app-map/ROUTE_CATALOG.csv \
  --output docs/uiux/SCREEN_UPGRADE_REGISTRY.csv

# 2. پس از کار ایجنت‌ها، اعتبارسنجی رجیستری
python 05_SCRIPTS/validate_stage3_evidence.py \
  --registry docs/uiux/SCREEN_UPGRADE_REGISTRY.csv
```

مسیرها فرض پیش‌فرض هستند؛ اگر مرحلهٔ ۱ فایل‌ها را در مسیر دیگری تولید کرده، از مسیر واقعی آن‌ها استفاده کن. هیچ‌یک از این دستورها خود اپلیکیشن را redesign یا deploy نمی‌کند؛ اولی رجیستری قابل‌تکمیل می‌سازد و دومی کیفیت ثبت شواهد را بررسی می‌کند.

قبل از دست‌کاری پروژه:
- `git status --short` را فقط بخوان و تغییرات از قبل موجود را ثبت کن.
- `graphify query "Map all user-facing eCardo routes, flows and design system components"` را مطابق دستورهای repo اجرا کن.
- وضعیت Flutter/Dart و وابستگی‌ها را ثبت کن؛ بی‌اجازه dependencyها را ارتقا نده.
- روی یک بچ کوچک شروع کن و پس از هر بچ map و تست‌ها را به‌روز کن.

# ترتیب اجرای مرحلهٔ ۱ — گام‌به‌گام

## گام 0 — قوانین و گراف

```bash
python -m graphify query "map all eCardo screens routes navigation flows and trace each screen to controller service API tests; identify unmapped and unreachable features"
```
ذخیره کن: دستور، exit code، خلاصهٔ خروجی، وضعیت `graphify-out/graph.json` و هر خطا.

## گام 1 — Snapshot محلی (فقط‌خواندنی)

```bash
python3 02_SCRIPTS/capture_baseline.py --root /path/to/ecardo_userapp_v1 --out /tmp/ecardo-baseline
```

قبل از ادامه، نسخهٔ pubspec، SHA، branch، status و diffهای موجود را در گزارش خلاصه کن. هیچ dirty change را stash/reset نکن.

## گام 2 — اسکن سورس Dart

```bash
python3 02_SCRIPTS/scan_flutter_app.py --root /path/to/ecardo_userapp_v1 --out /tmp/ecardo-scan
```

این گام تعداد و شواهد candidateها را تولید می‌کند؛ هنوز Route catalog نهایی نیست.

## گام 3 — سایر سطوح پروژه

```bash
python3 02_SCRIPTS/inventory_project_surfaces.py --root /path/to/ecardo_userapp_v1 --out /tmp/ecardo-surfaces
```

خروجی شامل فایل‌ها، تست‌های موجود (بدون اجرای آن‌ها)، ARBها، assets، manifestها و workflow trigger candidateها است.

## گام 4 — Reconciliation دستی/معنایی

مقایسه کن:
- Graphify output
- GetPage route candidates
- navigation call candidates
- actual route registry/constants
- shell/tabs/nested navigator/dialog/bottom sheet
- Android/iOS/deep links/notifications/QR entry points
- test files and screenshot harness
- localization ARB inventory
- service/API contracts

برای هر اختلاف record اضافه کن؛ هیچ ابهامی را با حذف از فهرست حل نکن.

## گام 5 — نهایی کردن کاتالوگ‌ها

پنج CSV اصلی را از templateها پر کن. کاتالوگ Route باید canonical ID داشته باشد و duplicateها بررسی شوند. `SOURCE_MAPPED` نیازمند فایل منبع واقعی است؛ `RUNTIME_VERIFIED` نیازمند evidence؛ `PASS` نیازمند test ref.

## گام 6 — اعتبارسنجی schema

```bash
python3 02_SCRIPTS/validate_app_map.py --routes docs/app-map/ROUTE_CATALOG.csv --out docs/app-map/MAP_VALIDATION.json
```
اگر Route catalog خالی باشد، خروجی باید Fail شود؛ اگر warningها وجود دارد، باید review شوند.

## گام 7 — خلاصه و handoff

با `DISCOVERY_SUMMARY_TEMPLATE_FA.md` گزارش را بساز. هیچ redesign وسیعی در این مرحله شروع نشود. مرحلهٔ بعد تنها زمانی آغاز شود که discovery gates پاس شده‌اند یا blockerهایش رسماً پذیرفته شوند.

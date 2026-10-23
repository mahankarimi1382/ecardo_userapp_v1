# eCardo Stage 3 Pack — Full Surface Upgrade

این بسته ابزار اجرای ارتقای تمام صفحات eCardo براساس inventory واقعی است. با مرحله‌های ۱ و ۲ هم‌زنجیر است و باید پس از نقشه‌برداری و یکپارچه‌سازی قراردادها استفاده شود.

## محتویات
- 00_READ_FIRST: پیش‌نیاز، شروع سریع و گیت پذیرش
- 01_ROADMAP: برنامهٔ کامل موج‌های ارتقا
- 02_PROMPTS: Integrator و شش عامل تخصصی
- 03_CATALOGS: ۵۰ تسک، candidate modules، state matrix، accessibility, screenshot و flow templates
- 04_TEMPLATES: Screen Spec و گزارش QA/handoff
- 05_SCRIPTS: ساخت رجیستری از کاتالوگ مرحلهٔ ۱ و اعتبارسنجی evidence
- 06_REFERENCES: دستور استفاده از benchmark و Definition of Done

## اجرای پایه
```bash
python 05_SCRIPTS/build_screen_upgrade_registry.py --input docs/app-map/ROUTE_CATALOG.csv --output docs/uiux/SCREEN_UPGRADE_REGISTRY.csv
python 05_SCRIPTS/validate_stage3_evidence.py --registry docs/uiux/SCREEN_UPGRADE_REGISTRY.csv
```

اسکریپت‌ها به‌تنهایی کامل بودن inventory یا درست‌بودن UI را اثبات نمی‌کنند. بررسی سورس و اجرای برنامه لازم است.

## حفاظت
No push, release, deploy; no real financial transactions; preserve existing worktree and follow `AGENTS.md` and `DESIGN_SYSTEM_GUIDE.md`.

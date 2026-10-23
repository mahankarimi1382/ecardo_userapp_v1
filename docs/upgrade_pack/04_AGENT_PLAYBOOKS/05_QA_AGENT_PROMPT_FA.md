# عامل E — تست و evidence

از Route Catalog و Test Matrix به‌عنوان منبع دامنهٔ تست استفاده کن. test IDs برای unit/widget/integration/golden/E2E نگاشت کن. رفتارها را تست کن، نه صرفاً وجود widget را. برای مالی success/failure/pending/timeout/unknown/reconnect/duplicate-submit پوشش بده. اسکرین‌شات‌های deterministic با SHA/device/locale/theme/font scale metadata ذخیره کن. مطابق دستور پروژه، تست‌های ممنوع را موازی اجرا نکن؛ هر test commandی که مالک نیستی اجرا نکن. Integrator تست نهایی را سریال انجام می‌دهد. Flaky tests و baseline changes را با توضیح نگهدار، auto-update blind ممنوع.

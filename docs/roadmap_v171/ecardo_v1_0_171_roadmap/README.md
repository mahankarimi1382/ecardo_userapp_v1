# بستهٔ ممیزی و نقشهٔ ادامهٔ راه eCardo User App — نسخهٔ 1.0.171

**تاریخ ممیزی منبع عمومی:** 2026-10-17  
**مخزن:** https://github.com/mahankarimi1382/ecardo_userapp_v1  
**نسخهٔ اعلام‌شده در `pubspec.yaml`:** `1.0.171+171`  
**تگ انتشار مشاهده‌شده:** `v1.0.171`  
**کامیت انتشار مشاهده‌شده:** `25028235b92cd9c026454df64c88cef44fda9ce6` (`2502823`)  
**کامیت اصلاحات کد قبلی:** `5a4abe64aba7d156ae1b92c1a84a31783c96cb65` (`5a4abe6`)

## هدف بسته

این بسته برنامهٔ ادامهٔ کار برای نسخهٔ فعلی است، نه ادعای اجرای تسک‌ها یا تأیید مستقل کد. وظیفهٔ آن مشخص‌کردن شکاف‌های باقیمانده، تعریف تسک‌های آمادهٔ واگذاری، معیار پذیرش، قراردادهای مالی/امنیتی، برنامهٔ Elasticsearch و راهنمای اجرای agentها است.

## ترتیب پیشنهادی خواندن

1. [`01_AUDIT_REPORT.md`](01_AUDIT_REPORT.md) — یافته‌های واقعی نسخهٔ فعلی و محدودیت شواهد.
2. [`02_MASTER_ROADMAP.md`](02_MASTER_ROADMAP.md) — فازها و مسیر اجرا.
3. [`03_TASK_BACKLOG.md`](03_TASK_BACKLOG.md) — صف تسک‌ها با شناسه، اولویت، وابستگی و معیار پذیرش.
4. [`04_RELEASE_GATES.md`](04_RELEASE_GATES.md) — معیار توقف/اجازهٔ انتشار.
5. [`05_FINANCIAL_IDEMPOTENCY_CONTRACT.md`](05_FINANCIAL_IDEMPOTENCY_CONTRACT.md) و [`06_OFFLINE_QUEUE_SECURITY.md`](06_OFFLINE_QUEUE_SECURITY.md) — مهم‌ترین قراردادهای اصلاح.
6. [`08_ELASTICSEARCH_BIG_DATA_ROADMAP.md`](08_ELASTICSEARCH_BIG_DATA_ROADMAP.md) و [`09_DATA_GOVERNANCE_AND_RETENTION.md`](09_DATA_GOVERNANCE_AND_RETENTION.md) — طراحی داده و پایش.
7. [`13_AGENT_EXECUTION_GUIDE.md`](13_AGENT_EXECUTION_GUIDE.md) و فایل‌های `templates/` — اجرای تیمی و گزارش شواهد.

## وضعیت شواهد

- **تأییدشده از صفحهٔ عمومی GitHub:** نسخهٔ `1.0.171+171`، تگ `v1.0.171`، commit `2502823` و موفقیت runهای Android #611، Android/tag #612 و Web #228 برای commit `2502823`.
- **گزارش‌شده، ولی شمار دقیق نیازمند استخراج از run جاری:** گزارش قبلی ۶۸۲ تست موفق را اعلام می‌کند. README ریشه هنوز ۶۴۶ را می‌گوید؛ بنابراین در این بسته، ۶۸۲ به عنوان عدد قطعی و مستقل برای نسخهٔ ۱۷۱ پذیرفته نشده است.
- **نیازمند اجرای مستقل:** آزمون روی دستگاه واقعی، بررسی تمام APIهای زنده، تأیید قرارداد idempotency در بک‌اند، تست نفوذ، اعتبارسنجی امضای artifact و آزمون واقعی زیرساخت Elasticsearch.
- **این بسته فقط فایل‌های پیشنهادی را تولید می‌کند.** هیچ تغییری به مخزن GitHub اعمال نشده و هیچ فایلی در پروژهٔ کاربر push نشده است.

## منابع پایه

- Repository: https://github.com/mahankarimi1382/ecardo_userapp_v1
- Release v1.0.171: https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
- Commit 2502823: https://github.com/mahankarimi1382/ecardo_userapp_v1/commit/25028235b92cd9c026454df64c88cef44fda9ce6
- Actions for commit 2502823: https://github.com/mahankarimi1382/ecardo_userapp_v1/actions?query=commit%3A2502823
- Offline queue: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/common/services/offline_request_queue.dart
- Network/idempotency service: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/network/service/network_service.dart
- Token service: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/network/service/token_service.dart
- App lock: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/common/services/app_lock_service.dart
- Elasticsearch ADR: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/docs/architecture/ADR-ELASTICSEARCH-001.md
- Data classification: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/docs/architecture/DATA-CLASSIFICATION.md
- ES runbook: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/docs/operations/ELASTICSEARCH-RUNBOOK.md
- Snapshot drill: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/docs/operations/SNAPSHOT-RESTORE-DRILL.md

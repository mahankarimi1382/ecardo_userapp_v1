---
name: app-discovery-and-route-mapping
description: کشف و نقشه‌برداری جامع اپ
---

# کشف و نقشه‌برداری جامع اپ

برای هر درخواست شناخت/ممیزی اپ، اول گراف و دستورهای محلی را بخوان؛ سورس/route/کلاس/ناوبری را اسکن کن؛ routeها را با runtime و تست reconcile کن؛ حدس و دادهٔ کشف‌شده را جدا ثبت کن. هیچ page را فقط چون در route table نیست حذف‌شده فرض نکن؛ overlays/tabs/deep links را بگرد. خروجی مستند و machine-readable با source path, line, SHA, owner و blockers باشد. Done claim بدون coverage counts ممنوع.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

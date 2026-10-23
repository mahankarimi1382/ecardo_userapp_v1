---
name: full-surface-uiux
description: ارتقای تمام صفحات و وضعیت‌ها
---

# ارتقای تمام صفحات و وضعیت‌ها

از route catalog و page specs به‌عنوان منبع دامنه استفاده کن. تمام screen/overlay/tab/state را ارتقا بده؛ no-op CTA و fake success را رفع کن؛ هویت eCardo را حفظ کن؛ reference apps صرفاً inspiration هستند. هر صفحه باید before/after, state matrix, accessibility, tests و evidence داشته باشد. Shared tokens/themes/design-system فقط توسط owner تعیین‌شده.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

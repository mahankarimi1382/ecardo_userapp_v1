---
name: financial-integration-testing
description: تست انتها به انتهای مالی
---

# تست انتها به انتهای مالی

برای هر جریان happy/validation/auth/limit/duplicate submit/timeout after possible commit/pending/unknown/reconnect/quote expiry را طراحی کن. تست‌ها باید رفتار و اثر را اثبات کنند؛ فقط widget existence کافی نیست. محیط sandbox/mock authoritative و تست deterministic استفاده کن؛ test result را با SHA و exit code ثبت کن.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

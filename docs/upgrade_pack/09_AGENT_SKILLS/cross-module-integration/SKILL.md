---
name: cross-module-integration
description: یکپارچه‌سازی بین ماژول‌ها
---

# یکپارچه‌سازی بین ماژول‌ها

برای هر entity منبع حقیقت واحد تعریف کن؛ producers/consumers, payload/status/ownership, freshness, invalidation, authorization, error mapping, idempotency و tests را trace کن. اگر دو صفحه یک وضعیت متناقض دارند، UI را با value محلی هم‌شکل نکن؛ contract source را پیدا و مشکل را با evidence ثبت کن.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

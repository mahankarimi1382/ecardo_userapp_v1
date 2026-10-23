---
name: fintech-domain-integrity
description: صحت منطق مالی
---

# صحت منطق مالی

Money precision, currency metadata, quote/fees, balance, limits, idempotency, unknown outcomes, reconciliation و transaction statuses را بررسی کن. Backend منبع حقیقت باقی می‌ماند. timeout به success یا failure قطعی تبدیل نشود؛ financial post را کور retry نکن؛ هیچ واقعی/production transaction برای تست اجرا نکن.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

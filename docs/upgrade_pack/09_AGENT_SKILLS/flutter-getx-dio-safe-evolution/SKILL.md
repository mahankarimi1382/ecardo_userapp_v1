---
name: flutter-getx-dio-safe-evolution
description: تکامل امن Flutter/GetX/Dio
---

# تکامل امن Flutter/GetX/Dio

معماری و dependencies موجود را قبل از تغییر بررسی کن. Controller هماهنگ‌کنندهٔ UI باشد، repository/service قرارداد داده را مدیریت کند؛ GetX/Dio را بدون ADR+PoC مهاجرت نده. Cancellation, stale responses, error mapping, auth refresh و lifecycle را تست کن. رعایت file ownership و shared worktree اجباری است.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

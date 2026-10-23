---
name: security-privacy-resilience
description: امنیت و تاب‌آوری
---

# امنیت و تاب‌آوری

تهدیدهای auth/session/PII/secrets/logging/secure storage/deep links/retry/dependency supply-chain را با evidence بررسی کن. داده حساس را در report/screenshot/telemetry نگذار. UI permission جایگزین server authorization نیست. هر risk دارای severity, reproduction, owner, mitigation و regression evidence باشد.

## Required output
- Findings with severity, source evidence, SHA, owner and status.
- Updated catalog/traceability documents.
- Tests and exact command outcomes if this role is authorized to run them.
- Explicit blockers and unknowns; never infer complete coverage from a static scan alone.

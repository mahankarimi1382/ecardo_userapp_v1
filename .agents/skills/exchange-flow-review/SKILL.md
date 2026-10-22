---
name: exchange-flow-review
description: quote/rate/expiry/exchange. Use this skill when improving the eCardo Flutter fintech UI/UX or reviewing a related screen, component, test, or release.
---

# بازبینی تبدیل ارز

## When to use
quote/rate/expiry/exchange.

## Required workflow
1. Read the current repository instructions (`AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, and relevant feature code) before acting.
2. Establish the affected route, users, data/API dependencies, locale/theme variants, and risks. Do not assume names or APIs from old reports; inspect the current checkout.
3. نرخ، زمان quote، مقدار دریافتی، کارمزد، گردکردن و منقضی‌شدن quote را بررسی کن.
4. Make the smallest coherent change. Reuse existing eCardo tokens and components before proposing a new dependency. Do not change backend financial semantics to improve visual appearance.
5. Add/update tests that exercise both the happy path and failure/recovery state. Capture before/after screenshots with route, device, locale, theme, text scale, and commit metadata.
6. Run the relevant project checks and report commands, exact outcomes, artifacts, and anything blocked.

## Guardrails
- Never invent a successful financial state, amount, fee, provider eligibility, address, or transaction result. The backend is authoritative.
- Never expose secrets, seed phrases, OTPs, passcodes, card security data, or raw PII in logs, screenshots, analytics, or test fixtures.
- Do not add a package or replace GetX/Dio/architecture without a written ADR and compatibility PoC.
- Do not push, tag, release, or deploy. Leave remote operations to an explicit human approval.
- If the backend, simulator, device, credentials, or source data are unavailable, label the task BLOCKED rather than claiming success.

## Acceptance criteria
quote منقضی دوباره دریافت و قبل از اجرا تأیید می‌شود.
- All changed tests pass and no unrelated tests are silently skipped.
- The change has no unexplained golden diffs, localization regressions, accessibility blockers, or new analyzer issues.
- The final note identifies files, tests, screenshots, risks, and any follow-up work.

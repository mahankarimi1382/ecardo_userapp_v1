---
name: arabic-rtl-qa
description: صفحات عربی. Use this skill when improving the eCardo Flutter fintech UI/UX or reviewing a related screen, component, test, or release.
---

# QA عربی RTL

## When to use
صفحات عربی.

## Required workflow
1. Read the current repository instructions (`AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, and relevant feature code) before acting.
2. Establish the affected route, users, data/API dependencies, locale/theme variants, and risks. Do not assume names or APIs from old reports; inspect the current checkout.
3. Bidi text، اعداد، علامت ارز، شماره کارت/آدرس، directional icons و mixed-script را تست کن.
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
مختلط فارسی/لاتین/عدد به‌هم نمی‌ریزد.
- All changed tests pass and no unrelated tests are silently skipped.
- The change has no unexplained golden diffs, localization regressions, accessibility blockers, or new analyzer issues.
- The final note identifies files, tests, screenshots, risks, and any follow-up work.

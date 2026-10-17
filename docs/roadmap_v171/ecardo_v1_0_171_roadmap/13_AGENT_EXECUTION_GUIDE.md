# دستورالعمل اجباری Coding Agentها

## قوانین غیرقابل‌مذاکره

1. ابتدا README، AGENTS.md، FILE_OWNERSHIP.md، PRE_PUSH_CHECK.md و taskهای وابسته را بخوان.
2. قبل از تغییر، `git status --short`, `git rev-parse HEAD`, `git branch --show-current`, نسخهٔ Flutter/Dart و وضعیت test baseline را ثبت کن.
3. به‌خاطر scope task، فقط فایل‌های لازم را تغییر بده؛ rename/refactor وسیع بدون ADR ممنوع است.
4. برای تغییر financial/auth/session/network/offline queue یک test regression قبل یا همزمان با اصلاح بنویس.
5. هیچ secret، token، customer record، حقیقی PAN/IBAN یا اطلاعات production را در prompt/log/test fixture وارد نکن.
6. در staging فقط synthetic accounts و synthetic amounts استفاده کن.
7. عملیات GitHub (push/tag/release/webhook) را از دسترسی نوشتن به فایل‌ها جدا بدان. بدون approval صریح، release/push انجام نده.
8. هیچ ادعای `DONE`, `VERIFIED`, `SECURE`, `COMPLIANT` یا `PRODUCTION READY` بدون evidence معتبر ثبت نکن.
9. اگر dependency به backend, credential, device, Apple Team ID یا infra access نیاز دارد، `BLOCKED` بنویس و دقیقاً آن dependency را ذکر کن؛ با mock جای آن را به عنوان integration واقعی جا نزن.
10. تغییر در endpoint، header، schema یا state machine نیازمند contract review با owner backend است.

## چرخهٔ اجرا

```text
READ TASK
  -> VERIFY CURRENT SOURCE AND OWNER
  -> WRITE ACCEPTANCE/TEST PLAN
  -> IMPLEMENT MINIMUM SAFE CHANGE
  -> UNIT TEST
  -> INTEGRATION/CONTRACT TEST WHERE APPLICABLE
  -> ANALYZE/FORMAT
  -> RELEVANT E2E / FAILURE INJECTION
  -> REVIEW SECURITY & PII
  -> UPDATE DOCS/EVIDENCE
  -> OPEN PR
  -> REPORT DONE/PARTIAL/BLOCKED
```

## گزارش پایان هر تسک

از [`templates/AGENT_TASK_REPORT.md`](templates/AGENT_TASK_REPORT.md) استفاده کن و مشخص کن:

- task ID and status
- before/after SHA
- files changed
- behavior change and risk
- test command/output URLs and exact count
- staging/e2e/manual verification
- remaining blockers, risks and follow-ups
- آیا release/push انجام شده یا خیر؛ پیش‌فرض `NO` است

## Parallel agents

- Agent Security: threat/abuse review و negative tests.
- Agent Financial: amount, idempotency, state machine, reconciliation; مالک قرارداد مالی.
- Agent Mobile/UX: presentation, localization, accessibility, device QA.
- Agent CI/Release: workflow permission, signing, artifact provenance.
- Agent Observability: event schema/PII/retention/ES; بدون دسترسی یا evidence ادعای deployment نکند.

یک هماهنگ‌کننده مالک وضعیت taskها و تداخل فایل‌هاست. هر task دارای یک DRI واحد باشد؛ چند agent نباید همزمان یک فایل هسته را ویرایش کنند.

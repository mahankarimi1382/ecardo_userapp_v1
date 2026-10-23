# گزارش نهایی مرحلهٔ کشف eCardo

- تاریخ اجرا:
- مسیر checkout:
- Branch:
- Source HEAD SHA:
- Pubspec version:
- نسخه Flutter/Dart:
- وضعیت working tree پیش از اجرا:
- Operator / Integrator:

## نتیجهٔ کلی
- Gate 1 Integrity: PASS / FAIL / BLOCKED
- Gate 2 Source discovery: PASS / FAIL / BLOCKED
- Gate 3 Traceability: PASS / FAIL / BLOCKED
- Gate 4 Evidence quality: PASS / FAIL / BLOCKED
- Gate 5 Handoff: PASS / FAIL / BLOCKED

## شمارش‌ها

| سنجه | مقدار | منبع و توضیح |
|---|---:|---|
| Dart files scanned | | `BASELINE.json` |
| GetPage route candidates | | اسکنر |
| Confirmed routes after reconciliation | | `ROUTE_CATALOG.csv` |
| Screen/widget candidates | | اسکنر + review |
| Confirmed screens/dialogs/sheets/tabs | | catalog |
| Navigation-call candidates | | اسکنر |
| Business flows mapped | | `FLOW_CATALOG.csv` |
| Source-mapped screens | | catalog status count |
| Runtime-verified screens | | requires evidence |
| Tested routes/flows | | requires test reference |
| P0/P1/P2/P3 gaps | | `GAP_REGISTER.csv` |
| Blocked / unresolved | | include reason |

## Mismatches found

- README vs pubspec:
- AGENTS vs current project:
- Latest GitHub release vs local tag/SHA:
- Documented test count vs actual execution (if any; this phase should not run tests):
- Documented domains/routes vs discovered inventory:

## P0 / P1 findings

| ID | Severity | Evidence | Impact | Recommended first action |
|---|---|---|---|---|
| | | | | |

## Blockers and limits

- 

## Artifacts

- `LOCAL_BASELINE.md/.json`:
- `generated/`:
- `ROUTE_CATALOG.csv`:
- `SCREEN_SERVICE_MATRIX.csv`:
- `FLOW_CATALOG.csv`:
- `GAP_REGISTER.csv`:
- `TRACEABILITY_MATRIX.csv`:
- `EVIDENCE_LEDGER.csv`:
- Validator output:

## Safety declaration

- No app source logic was modified in discovery phase: YES / NO (if NO, explain and get approval)
- No push/tag/release/deploy occurred: YES / NO
- No real financial operation was triggered: YES / NO
- All counts attributed to exact source SHA: YES / NO
- Unresolved items are not represented as complete: YES / NO

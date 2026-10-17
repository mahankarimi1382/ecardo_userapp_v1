# Threat Model — eCardo User App

## دارایی‌ها

- bearer/refresh tokens, session state, local PIN hash/salt
- balances, transaction intent/status, payee/recipient data, cards, bank identifiers
- KYC documents/status, personal identifiers, support attachments
- release signing keystore, Firebase/backend secrets, TLS pin values
- telemetry, traces, API error messages, event correlation IDs

## مرزهای اعتماد

1. Flutter process/device storage ↔ OS Keychain/Keystore
2. Flutter client ↔ API gateway/backend
3. Backend ↔ transactional database/ledger/payment providers
4. Backend outbox/broker ↔ OpenTelemetry Collector ↔ Elasticsearch/Kibana
5. CI runners ↔ GitHub secrets/release mirror/deploy webhook
6. Support/operations users ↔ internal telemetry search

## Threat/mitigation table

| ID | Threat | Impact | Required controls | Evidence |
|---|---|---|---|---|
| TM-01 | Stolen device/app process reads persisted credentials | Account impersonation | Keychain/Keystore policy; biometric/app lock; logout; token rotation | native device tests + secure storage tests |
| TM-02 | Secure-storage deletion failure leaves old credential available after apparent logout | Persistent session restoration | fail-closed UX; server revocation; verify delete failure path | injected failure tests |
| TM-03 | Offline queue persists PII or secrets | Local data exposure | exact endpoint/method+schema allowlist, no sensitive payloads, encrypted storage where needed | negative queue tests |
| TM-04 | Queue endpoint validation accepts unexpected URI/path | Bearer/PII sent to unintended destination or bad replay | relative URL validation, allowlisted host/path, method restriction | adversarial URL tests |
| TM-05 | Client generates new idempotency key after unresolved outcome | Duplicate debit/charge | stable operation ID + backend idempotency + status reconciliation | backend integration fault tests |
| TM-06 | 5xx after transaction commit + user retry | duplicate money movement | server idempotency record in DB, retry same intent | fault injection |
| TM-07 | Logging payload/body includes sensitive nested keys | PII/credential exposure | default deny telemetry schema, recursive redaction, tests | telemetry negative tests |
| TM-08 | CI PR can access write token/deploy actions | Repository/release compromise | least privilege, separate release job, protected env | workflow permission review |
| TM-09 | Inconsistent retention settings keep sensitive logs too long | privacy/compliance exposure | single signed retention registry + automated ILM tests | config test + owner approval |
| TM-10 | ES/telemetry outage causes financial request failure | financial service outage | isolate ES from transaction path; bounded async pipeline | fault injection while making test payment |
| TM-11 | Stale TLS pin breaks all connections after certificate rotation | App outage | dual-pin rotation runbook, monitored rollout, backup pin test | TLS staging test |
| TM-12 | Supply chain/dependency or action compromise | build/release compromise | pinned actions, dependency scanning/SBOM, protected tag | CI artifacts |
| TM-13 | Unauthorized support search reveals personal data | Privacy leak | RBAC, pseudonymous IDs, audit log and support gateway | authorization tests |
| TM-14 | Cold start skips expected app-lock challenge | Unauthorized access to open session | explicit cold-start policy and tests | device tests |

## Decisions requiring business/security owners

- Is PIN required after cold start when token remains valid?
- Does background work need Keychain access before device unlock?
- Which profile fields, if any, are permissible in offline queue storage?
- Which data retention schedule is approved for each data class and jurisdiction?
- Which telemetry can be linked to a pseudonymous user and for how long?

## Mandatory evidence discipline

`CONFIRMED` requires source location and commit. `REPRODUCED` requires a repeatable test or execution. `NOT_FOUND` means not observed within reviewed scope, not proof of absence. `BLOCKED` identifies missing repo, credential, device, test environment or owner decision. Findings must never include production secrets or customer data.

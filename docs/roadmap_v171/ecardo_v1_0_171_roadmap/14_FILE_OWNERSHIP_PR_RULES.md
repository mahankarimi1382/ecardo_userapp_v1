# Workstream & File Ownership

| Workstream | مسیرهای معمول | مالک اصلی | نیاز به reviewer |
|---|---|---|---|
| Auth/session/storage | `lib/src/network/service/token_service.dart`, `lib/src/common/services/session_manager.dart`, `app_lock_service.dart`, login/OTP controllers | Mobile Security | Security reviewer + QA |
| Network/idempotency | `lib/src/network/service/network_service.dart`, transaction controllers | Financial Platform | Backend/API contract owner |
| Offline queue | `lib/src/common/services/offline_request_queue.dart`, related queue tests | Mobile Platform | Security + privacy reviewer |
| Money math/domain | exchange/transfer/withdraw/card controllers, money helpers | Financial Engineering | Backend/ledger owner |
| UI/UX/i18n | screens/widgets/themes/ARB/golden tests | Design Systems | accessibility + locale reviewer |
| Android signing | `android/**`, release keystore properties, native config | Android Release | Release/security owner |
| iOS signing | `ios/**`, export options, entitlements, privacy keys | iOS Release | Apple distribution owner |
| CI/CD | `.github/workflows/**`, release scripts | DevEx | repo admin/security owner |
| Elasticsearch/telemetry docs | `docs/architecture/**`, `docs/operations/**`, `docs/testing/**` | SRE/Data Platform | privacy/security/infra owner |
| Release evidence | `docs/release/**`, `docs/audit/releases/**` | Release Manager | QA + security sign-off |

## PR requirements

- one main task or a tightly coupled set; split unrelated changes.
- include task IDs in title/body.
- include tests added and exact commands/results.
- include API/data/security impact and rollback considerations.
- generated files only when reproducibly generated.
- screenshots/video for UI or flow changes; synthetic data only.
- no direct change in production hostnames/retention/pager contacts without infra owner approval.
- financial/auth/CI/security PRs require named reviewer, not only agent self-approval.
- failing gate cannot be bypassed with `|| true` or by suppressing logs; exception is time-bound and owner-approved.

## Definition of Done

A task is done only when the acceptance criteria are met, automated tests pass, meaningful manual/E2E verification is documented, relevant docs are updated, risks are logged, and the PR is approved/merged. A build green is necessary for relevant changes but insufficient by itself.

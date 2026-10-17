# Architecture Decisions to Record / Confirm

## ADR-FIN-IDEM-002 — Durable financial operation intent

**Status:** Proposed; needs backend + financial owner acceptance.  
**Decision:** client `operationId` persists through retries and app restarts; server DB unique constraint stores the operation state and canonical response.  
**Rejected:** payload hash or five-minute in-memory map as ultimate transaction identity.  
**Consequences:** API contract, schema migration, retention policy and reconciliation endpoint required.

## ADR-OFFLINE-002 — Offline mutation policy

**Status:** Proposed.  
**Decision:** offline queue is non-financial, exact route/method allowlist, schema-only fields, bounded retention and dead-letter handling. Prefer no queued mutation when PII minimization cannot be proven.  
**Rejected:** generic arbitrary method+endpoint+payload queue.  
**Consequences:** some UI changes show pending/offline state and are not assumed successful until server response.

## ADR-RELEASE-002 — Provenance-based release

**Status:** Proposed.  
**Decision:** exact tag/SHA is unit of release evidence; PR/build jobs read-only; release/mirror/webhook jobs guarded by protected environment approval.  
**Rejected:** unconditional write permissions for common build job and implicit production publishing from any version bump on main.  
**Consequences:** require protected release environment and explicit artifact promotion.

## ADR-EL-002 — Telemetry is non-authoritative

**Status:** Existing architectural principle; implementation evidence still needed.  
**Decision:** Elasticsearch is downstream only; no ledger/balance/payment/KYC authority; telemetry failure cannot block financial operations.  
**Consequences:** backend event flow, bounded buffering/drop policy, no direct client ES connection.

## ADR-DATA-RETENTION-002 — Single retention authority

**Status:** Proposed; privacy/legal sign-off required.  
**Decision:** `DATA-CLASSIFICATION.md` or a referenced single registry owns retention durations; all runbooks and ILM templates read from the same approved policy.  
**Rejected:** repeated independent retention numbers.  
**Consequences:** audit each index template/policy and prove actual delete behavior.

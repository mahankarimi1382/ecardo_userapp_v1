# Flow Spec: [FLOW_ID] — [نام جریان]

## Entry conditions
- Required session/role/KYC/permissions:
- Source screen/entry points:

## Domain states
`draft → validation → quote/review → submit → pending/success/failure/unknown → reconciliation`

توالی واقعی را مطابق backend بازنویسی کن؛ این نمودار نمونه است.

## Steps and contracts
| Step | Screen/route | Request/response | Validation | Error branches | Next state |
|---|---|---|---|---|---|

## Financial invariants
- Amount/currency precision:
- Fee/rate source and expiry:
- Idempotency key:
- Unknown result/status lookup:
- Authoritative transaction ID:

## Test vectors
- happy path:
- validation failure:
- auth/session expiry:
- insufficient balance/limit:
- timeout after possible server commit:
- duplicate submit:
- offline/reconnect:
- pending/unknown/reconciliation:

## Done evidence
- Test IDs and results:
- Route/screenshots:
- source paths and SHA:
- unresolved issues:

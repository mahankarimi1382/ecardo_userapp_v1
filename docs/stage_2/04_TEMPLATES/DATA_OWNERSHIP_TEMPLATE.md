# Data ownership and sources of truth

Complete only from source/backend evidence. Do not treat this template as a definition of existing architecture.

| Data item | Candidate authority | Cache allowed? | Freshness/TTL | Client may calculate? | Reconciliation rule | Evidence |
|---|---|---|---|---|---|---|
| User authorization/session | TBD | TBD | TBD | No permission escalation in client | TBD | TBD |
| Balance / available funds | TBD | TBD | TBD | Display formatting only unless contract says otherwise | TBD | TBD |
| Fee / FX quote / expiry | TBD | TBD | TBD | Do not invent or silently recompute | TBD | TBD |
| Transaction lifecycle/status | TBD | TBD | TBD | UI maps; backend authority governs | TBD | TBD |
| Card/KYC state | TBD | TBD | TBD | UI display only | TBD | TBD |
| App settings affecting sensitive actions | TBD | TBD | TBD | No unsafe allow-by-default | TBD | TBD |

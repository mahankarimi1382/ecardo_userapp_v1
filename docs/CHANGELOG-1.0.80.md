## 1.0.80+80 — refund requires eligibility_version

- POST /orders/{id}/refunds sends eligibility_version from prior estimate
- Stale estimate → server 422 ELIGIBILITY_STALE

Agent: server-user

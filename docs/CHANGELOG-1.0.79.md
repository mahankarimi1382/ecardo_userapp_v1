## 1.0.79+79 — eSIM activation artifacts (TRAVEL-ESIM-001)

- Map activation.iccid / activation_code / sm_dp / matching_id into order details
- QR encodes LPA activation code when present
- Confirmation card: ICCID, SM-DP+, selectable LPA + copy
- Backend: GET /sim/orders/{id}/activation (travel-origin)

Agent: server-user

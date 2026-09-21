## 1.0.49+49 — Sprint A/B/C + business P2P/Escrow fix

### Product
- Business card: **P2P Trading** is the live tile; **Escrow Services** is a separate greyed (notBuilt) icon
- Unavailable empty-route tiles resolve to notBuilt (lock badge)

### Stability / security (partial)
- Null-safe amount parsing on add-money success and gift flows
- Clear biometric password from Rx memory after login attempt

### Architecture
- `NotFoundScreen` for unknown routes (no more splash dump)
- `RemittanceBinding` on remittance / history / details
- `KycLevelBinding` on kyc submit wizard

### QC
- `status_label_helper_test.dart`
- Dashboard QC expects P2P Trading + Escrow Services

Agent: external

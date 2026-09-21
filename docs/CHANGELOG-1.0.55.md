## 1.0.55+55

- Splash: full redesign (layered gradient, glass logo, progress ring, tagline)
- Wallet cards: live ≈ equivalent from fee.ecardo.ir (fixes wrong conversion_rate)
- UID pill: FittedBox + thin-space grouping so spacing no longer clips/breaks layout
- Push notifications: unify FCM default channel with local channel (`ecardo_default`),
  create legacy `channel_id`, set default notification icon — fixes silent/missing pushes
  and update notifications not appearing on device
- Fee rates: accept `USD_to_IRR` conversion key casing from API

Agent: external

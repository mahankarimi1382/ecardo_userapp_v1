# Authentication, biometric and session audit — 1.0.90

## Completed in the mobile app

| Priority | Item | Status |
|---|---|---|
| P0 | Central session expiry handler registered before the first route | Done |
| P0 | Idle-session timer registered and protected from parallel expiry | Done |
| P0 | Expired splash credentials cleared before sign-in | Done |
| P0 | PIN lockout clears token and local session | Done in 1.0.88 |
| P1 | Offline queue encrypted and removed on session end | Done in 1.0.89 |
| P1 | Biometric login requires explicit opt-in | Done |
| P1 | App lock works with an enabled biometric unlock even without a PIN | Done |
| P1 | Web deployment workflow removed; Android APK is the only build target | Done |

## Remaining backend work

1. **Token lifecycle (P0):** issue short-lived access tokens, rotate refresh tokens, revoke all active refresh tokens on explicit logout/password reset, and expose a session/device list for user-initiated revocation.
2. **Login abuse controls (P0):** rate-limit login, OTP, password-reset and 2FA verification by account, IP and device; return generic errors to avoid account enumeration; audit successful and failed attempts.
3. **2FA contract (P0):** bind the 2FA challenge to a one-time server-side challenge ID and the pending login, expire it quickly, and invalidate it after success or max failures.
4. **Payment status (P0):** return success only after an authenticated gateway webhook and verify transaction ownership, amount and currency for every status query.
5. **Update metadata (P1):** publish an APK SHA-256 plus signed update metadata. The app already allowlists release URLs but cannot independently verify file integrity yet.

## Regression checks required in CI

- Valid token + enabled biometrics routes only after a successful device prompt and profile request.
- Invalid/expired token clears token, login state, FCM token and offline queue before sign-in.
- Password login does not change the biometric preference.
- PIN lockout and idle expiry execute only once under concurrent events.
- No GitHub Actions workflow builds or deploys Flutter web.

## 1.0.90+90 — authentication and session hardening

- Register session timeout, session-expiry and connectivity services at app startup.
- Make biometric authentication opt-in; password login no longer enables it automatically.
- Clear expired credentials before routing to sign-in and support biometric-only app locks.
- Disable the web build workflow; releases are APK-only.

Agent: github-user

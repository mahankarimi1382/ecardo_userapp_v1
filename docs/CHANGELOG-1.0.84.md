## 1.0.84+84 — passcode: mandatory 4-digit transaction PIN

- Single server passcode (پس‌کد) for transfer / cash-out / make-payment / exchange
- Exactly 4 digits required on generate + change
- Disable removed from settings UI (change only)
- Transfer + cash-out now send verified passcode in API body (was verify-then-discard)
- Shared PasscodeHelper for format + has-passcode semantics
- Dynamic OTP (رمز پویا) remains separate — web payment only

Agent: github-user

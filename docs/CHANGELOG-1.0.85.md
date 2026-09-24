## 1.0.85+85 — passcode complete

- make_payment: verify sheet returns String + body includes passcode
- transfer / cash_out / make_payment aligned on PasscodeHelper
- Generate / change / verify sheets: numeric keypad, max 4 digits, obscure
- Mandatory SetPasscodeScreen after password setup and after login if missing
- Disable UI removed; backend contract documented in BACKEND-AGENT-NOTES
- Dynamic OTP remains web-payment only

Agent: github-user

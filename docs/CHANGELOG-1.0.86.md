## 1.0.86+86 — security model separation

### Systems (do not mix)
- **A** Account password — change-password
- **B** Transaction PIN (رمز انتقال) — `/user/passcode/*`, 4–6 digits
- **C** Google 2FA TOTP — login only
- **D** App Lock PIN — local device only
- **E** Payment OTP / dynamic password — web pro-pay only

### App changes
- Settings → Security: separate tiles for A / B / C / D / E
- New `TransactionPinScreen` (set / change / disable with **account password**)
- 2FA screen stripped of passcode UI
- `PasscodeHelper`: min/max digits from `GET /user/passcode/status`
- `passcodeStatusEndpoint` added
- Verify / generate / change sheets accept 4–6 digits
- App Lock labeled clearly (not transfer PIN)

Agent: github-user

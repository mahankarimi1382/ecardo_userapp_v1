# Notes for backend agent / developers

## Five security systems (client ≥ 1.0.86)

| System | Name | API |
|--------|------|-----|
| A | Account password | `/user/settings/change-password` |
| B | Transaction PIN (رمز انتقال) | `/user/passcode/*` |
| C | Google 2FA TOTP | `/user/settings/2fa/*` (login only) |
| D | App Lock PIN | local only — no server |
| E | Payment OTP | `/pay/generate-otp` (web pro-pay) |

## Transaction PIN (B)

| Endpoint | Body |
|----------|------|
| `GET /user/passcode/status` | → `{ has_passcode, min_digits?, max_digits? }` |
| `POST /user/passcode` | `{ passcode, passcode_confirmation }` 4–6 digits |
| `POST /user/passcode/change` | `{ old_passcode, passcode, passcode_confirmation }` |
| `POST /user/passcode/disable` | `{ password }` — **account password**, not PIN |
| `POST /user/passcode/verify` | `{ passcode }` |
| Money APIs (`transfer`, `cashout`, `payment/make`, `exchange`) | include `passcode` when user has one |

- Store bcrypt hash. Never return real PIN in user JSON.
- Sentinel `null` / `""` / `"0"` = no passcode.

## Exchange: `No query results for model [App\Models\Page].`

Seed missing Page or null-safe lookup; return structured JSON errors.

## Auth roadmap

| Setting | Purpose |
|---------|---------|
| `telegram_login` | enable Telegram path |
| `telegram_login_url` | HTTPS start URL |

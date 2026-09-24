# Notes for backend agent / developers

## Transaction passcode (پس‌کد) — mandatory 4-digit PIN

**Client (user app ≥ 1.0.85):**

- One passcode per user, set at first onboarding stage (after password setup).
- Exactly **4 digits** (`^\d{4}$`). Cannot be disabled from the app UI (change only).
- Used for **transfer**, **cash-out**, **make-payment**, **exchange** and similar money flows.
- Client sends field `passcode` in the POST body after local verify against `POST /user/passcode/verify`.
- **Not** the same as dynamic OTP (`POST /pay/generate-otp`) which is only for web-page payments.

**Backend expectations:**

| Endpoint | Body |
|----------|------|
| `POST /user/passcode` | `{ passcode, passcode_confirmation }` — both 4 digits |
| `POST /user/passcode/change` | `{ old_passcode, passcode, passcode_confirmation }` |
| `POST /user/passcode/verify` | `{ passcode }` |
| `POST /user/transfer` | include `passcode` when user has one |
| `POST /user/cashout` | include `passcode` when user has one |
| `POST /user/payment/make` | include `passcode` when user has one |
| `POST /user/exchange` | include `passcode` when user has one |

- Store hash (never plaintext). Reject non-4-digit on set/change.
- Prefer **rejecting disable** (or no-op) so passcode stays mandatory server-side too.
- User JSON: `passcode` sentinel `"0"` / null / empty = unset; any other value = has passcode (client does not receive the real PIN).

## Exchange: `No query results for model [App\Models\Page].`

**Client impact:** User sees a raw Laravel exception when opening/using Exchange.

**Cause (server):** Some exchange (or related) endpoint calls Eloquent `Page::...`
(CMS page) and the row is missing. Typical Laravel `ModelNotFoundException`.

**Suggested fix:**
1. Find callers of `App\Models\Page` on exchange config / fee / help routes.
2. Seed the required page slug OR make the lookup optional (`first()` + null-safe).
3. Return a structured JSON error (`message`, `code`) instead of uncaught ModelNotFound.

Client as of **1.0.54** maps this string to a generic friendly toast so users are
not shown stack-trace language.

## Auth roadmap (user app)

To enable soft-entry buttons already present on sign-in:

| Setting key | Purpose |
|-------------|---------|
| `telegram_login` | `"1"` enables Telegram button path |
| `telegram_login_url` | HTTPS start URL for Telegram Login Widget / bot |

Recommended endpoints (not yet required by client):
- `POST /auth/user/telegram` — exchange telegram auth payload for access token
- `POST /auth/user/otp/request` + `POST /auth/user/otp/verify` — email OTP login

Until these exist, the client keeps **email + password** as the only working path
and shows a non-blocking toast on Telegram tap.

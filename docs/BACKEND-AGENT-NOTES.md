# Notes for backend agent / developers

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

# Financial E2E / Fault Injection Matrix

تمام تست‌ها باید با synthetic user/accounts انجام شوند؛ از حساب یا payload مشتری واقعی استفاده نشود. برای تست‌های server-side، owner بک‌اند و DB test environment الزامی است.

| ID | Flow | Scenario | انتظار |
|---|---|---|---|
| F-001 | Login | secure storage save موفق | نشست فقط پس از persist امن فعال شود |
| F-002 | Login | secure storage save شکست می‌خورد | توکن در حافظه پاک؛ نشست معتبر ساخته نشود |
| F-003 | Logout | secure delete موفق | token secure + legacy حذف و session پاک شود |
| F-004 | Logout | secure delete شکست می‌خورد | خطا پنهان نشود؛ server revocation/recovery طبق policy انجام شود |
| F-005 | Token migration | فقط legacy key وجود دارد | انتقال امن، سپس legacy پاک؛ نتیجه قابل مشاهده/testable |
| F-006 | App lock | cold start با session فعال | رفتار دقیق بر اساس policy و تست device |
| F-007 | App lock | pause کوتاه | مطابق timeout policy؛ وضعیت حریم خصوصی درست |
| F-008 | App lock | pause طولانی | lock gate قبل از دسترسی به صفحات حساس |
| F-009 | App lock | PIN wrong repeated | backoff/lockout/logout طبق policy؛ counter پایدار |
| F-010 | Transfer | double tap همان intent | یک عملیات backend و یک debit |
| F-011 | Transfer | server commits, response times out | retry/query همان operation ID و نتیجه واحد |
| F-012 | Transfer | server commits, returns 500 | کلید همان intent حفظ؛ هیچ debit دوم |
| F-013 | Transfer | app force close after submit | reopening resolves same pending operation |
| F-014 | Transfer | retry after client TTL | status lookup; new intent ممنوع تا تعیین outcome |
| F-015 | Transfer | more than 50 pending requests | unresolved intents به علت ظرفیت محلی فراموش نشوند |
| F-016 | Transfer | same key, changed amount/recipient | server rejects key/payload mismatch |
| F-017 | Transfer | two new intents with same amount/recipient | دو عملیات مستقل در صورت تأیید صریح جداگانه |
| F-018 | Gateway | duplicate callback/webhook | state transition و ledger effect دقیقاً یک بار |
| F-019 | Card issue | wallet funding source | کلاینت `irr_wallet`; backend contract accepts expected enum |
| F-020 | Card issue | gateway funding source | کلاینت `gateway`; response/pending state correct |
| F-021 | Card issue | 422 validation | خطا به زبان کاربر؛ no duplicate order; no false success |
| F-022 | Passcode | withdraw happy/failure paths | verified passcode reaches expected backend call once |
| F-023 | Passcode | PIN missing | redirect/set PIN, refresh user state, no loop |
| F-024 | Exchange | quote expires before submit | server rejects stale quote; recalculate/review |
| F-025 | Exchange | same request retried after timeout | same intent and locked quote; no double conversion |
| F-026 | Payment return | app killed during external gateway | resume status reconciliation by order/intent ID |
| F-027 | Offline queue | profile update offline | only approved fields queued and securely retained |
| F-028 | Offline queue | absolute URL contains allowed substring | rejected, not queued or sent |
| F-029 | Offline queue | max retries exhausted | DLQ/failed state; queue does not grow unbounded |
| F-030 | Telemetry | ES/collector down while transfer request | transfer result unaffected, telemetry bounded/dropped safely |
| F-031 | Telemetry | request body contains synthetic PAN/JWT/OTP | redacted/rejected before index; incident metric increments |
| F-032 | i18n | fa/ar RTL | amounts, navigation, sliders, forms mirrored correctly |
| F-033 | i18n | ru/zh long or large text | no clipping/overflow in key routes |
| F-034 | Accessibility | TalkBack/VoiceOver on transfer review | controls/amount/status announced correctly |
| F-035 | Release | signed Android artifact | signature verified; no debug keystore |
| F-036 | Release | iOS release | signed artifact, correct Team/profile/entitlements and device smoke |

## Evidence required per test

`test_id`, commit SHA, run URL, test environment, app/build version, backend version, synthetic account ID, request/correlation ID (not token), expected result, actual result, screenshot/log snippet scrubbed of PII, pass/fail, defect link and owner. Never attach raw credentials, full transaction details or real-user data.

# Data Governance, Retention & Telemetry Policy

## 1. یافتهٔ تناقض

در `docs/architecture/DATA-CLASSIFICATION.md` این retentionها ذکر شده‌اند: mobile 14d، API 30d، security 90d، trace 7d. در `docs/operations/ELASTICSEARCH-RUNBOOK.md` این اعداد دیگرند: API 90d، trace 30d، security 180d، metrics 60d. تا زمان تصویب یک ماتریس canonical، هیچ ILM policy را بر مبنای یکی از دو سند به production اعمال نکنید.

## 2. Canonical retention registry — نیازمند تصویب

| Data class | حد پیشنهادی شروع بحث | وضعیت فعلی |
|---|---:|---|
| Mobile diagnostics | 14 روز | PROPOSED — تأیید Legal/Privacy لازم است |
| API operational logs | 30 روز | PROPOSED — با runbook 90 روزه در تعارض است |
| Security audit events | 90 روز | PROPOSED — با runbook 180 روزه در تعارض است |
| Distributed traces | 7 روز | PROPOSED — با runbook 30 روزه در تعارض است |
| Aggregated non-identifying metrics | 30 تا 90 روز بر اساس هزینه/نیاز | PROPOSED — تعریف فیلد و owner لازم است |

این اعداد توصیهٔ فنی برای شروع هستند، نه الزام قانونی یا تصمیم نهایی. مالک داده، هدف پردازش، حوزهٔ قضایی، نیاز audit، risk assessment و هزینهٔ نگهداری باید قبل از تصویب بررسی شوند.

## 3. Classification

- **Restricted:** credentials, tokens, passwords, PIN/OTP, CVV, full PAN, private keys, KYC document images. Never emit to app/backend telemetry.
- **Sensitive personal/financial:** national ID, bank identifiers, phone/email, full name/address, precise travel/booking data, transaction amount/recipient, raw provider payload. Reject or transform to approved minimal derived fields.
- **Confidential operational:** internal hostnames, stack traces, deployment IDs, vendor response metadata. Limit to authenticated internal users and scoped access.
- **Operational low-risk:** service/version, route template (not raw URL), HTTP status, latency bucket, error category, schema version, random trace/correlation ID.
- **Aggregated metrics:** only with minimum grouping thresholds and no re-identification path unless approved.

## 4. Never log

`Authorization`, cookies, refresh/access tokens, passwords, PIN, passcode, OTP, CVV/CVC, full PAN, raw request/response body for financial endpoints, KYC images/documents, secrets from environment, bank account credentials, user-entered support attachment contents.

Do not rely on regex alone. Apply:
1. source-level structured allowlisting;
2. field-level redaction at backend gateway;
3. recursive validation in ingestion pipeline;
4. negative tests using synthetic values;
5. restricted index access and audit logs;
6. deletion procedure for accidental leakage.

## 5. Canonical ownership

`DATA-CLASSIFICATION.md` should own classification and retention. Runbooks must reference it rather than duplicate retention numbers. A CI/doc test should detect any hardcoded retention mismatch between data policy and ILM examples. Policy modifications require an owner and approval record.

## 6. Minimum deletion evidence

For every stream, record the index/data-stream pattern, ILM policy revision, retention start rule, delete action, snapshot retention linkage, exception owner and verification test. On policy rollout, demonstrate the delete threshold in a non-production index using known timestamps; record proof that expired sensitive data is not searchable after expiry.

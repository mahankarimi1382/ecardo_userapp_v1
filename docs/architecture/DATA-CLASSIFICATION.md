# Data Classification, Telemetry Sanitization, and Data Retention Policies

- **Document Version:** 1.0.0
- **Status:** APPROVED
- **Date:** 2026-10-15
- **Task Reference:** Task EL-002, EL-016, EL-021 (Roadmap Sections 25, 28, 29, 30) of `ecardo_userapp_v1_audit_roadmap_fa_FIXED.md`
- **Applicable Frameworks:** OWASP MASVS v2.0 (Storage & Privacy), PCI-DSS v4.0 (Req 3 & 10), Central Bank of Iran e-Banking Security Directives, Cross-Border Data Privacy Standards (UAE PDPL, Turkey KVKK, EU GDPR Alignment)
- **Applicable Services:** Flutter Mobile & Web Client (`ecardo_userapp_v1`), eCardo API Gateway, OpenTelemetry Collector, Elasticsearch Cluster, Kibana Access Portals

---

## 1. Executive Summary & Threat Model Context (Task EL-002)

As a cross-border financial super-platform, eCardo processes high-stakes monetary transactions, personal identity documents, and sensitive authentication credentials. While comprehensive observability is necessary to guarantee site reliability and rapid troubleshooting, aggregating logs into a centralized search cluster creates a high-value attack surface if not rigorously constrained.

### 1.1 Core Threat Model Scenarios
1. **Centralized Log Breach:** Unauthorized access to Elasticsearch or Kibana could compromise credentials or cardholder data if unredacted payloads are indexed.
2. **Side-Channel Credential Scraping:** Intercepting mobile diagnostic dumps or crash breadcrumbs could leak active session tokens or one-time passcodes (OTPs).
3. **Cross-Tenant / Cross-User Leakage:** Support personnel utilizing search tools could inadvertently view transactions belonging to unrelated users without explicit operational justification.
4. **Regulatory Non-Compliance:** Retaining personally identifiable information (PII) beyond legitimate business necessity violates regional data protection mandates and financial licensing standards.

This document establishes the binding **Data Classification Matrix**, the **Forbidden Telemetry Negative Allowlist**, the **Sanitization Engine Architecture**, and **Automated Data Retention Policies**.

---

## 2. Data Classification Matrix

All data processed within the eCardo ecosystem is classified into four distinct security tiers:

| Classification Tier | Description & Scope | Examples | Primary Persistence | Permitted in Telemetry / Elasticsearch? |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Restricted Secrets** | High-risk authentication credentials, cryptographic keys, and raw authentication materials. Compromise leads to immediate account takeover. | Passwords, PINs, OTP codes, 2FA seeds, JWT bearer tokens, private keys, card CVV, full 16-digit PAN. | Android Keystore / iOS Keychain, HashiCorp Vault, PostgreSQL encrypted credentials. | **ABSOLUTELY FORBIDDEN** (Hard drop & security alert) |
| **Tier 2: Confidential Financial & KYC** | Sensitive financial records and personally identifiable information (PII). Subject to banking secrecy and privacy laws. | Bank account numbers (Sheba/IBAN), KYC identity documents (passport/national ID scans), national ID numbers, account balances, transaction amounts. | Transactional Database (PostgreSQL / MySQL) with table-level encryption and strict ACLs. | **PROHIBITED in raw form** (Must be masked, pseudonymized, or omitted) |
| **Tier 3: Internal Operational** | Metadata, sanitized diagnostics, performance metrics, and pseudonymous identifiers needed for platform operations. | Correlation IDs, trace IDs, `pseudonymous_user_id`, masked card suffixes (`last4`), route templates, latency metrics, HTTP status codes. | OpenTelemetry Collector, Elasticsearch Data Streams, Prometheus, Jaeger. | **ALLOWED with Schema Compliance** |
| **Tier 4: Public Metadata** | Non-sensitive, publicly available platform metadata. Zero risk of user re-identification. | Application release version (`1.0.41+41`), OS name/version, country code, public exchange rate snapshots, static UI route names. | Application bundles, public documentation, search indexes, CDNs. | **ALLOWED** |

---

## 3. Forbidden Telemetry Items (The Negative Allowlist)

The following items are **STRICTLY PROHIBITED** from ever entering the client telemetry buffer, the OpenTelemetry Collector, or Elasticsearch Data Streams:

```
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X                    STRICTLY FORBIDDEN IN TELEMETRY / SEARCH                   X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X  1. Passwords, Passcodes, and PINs (PIN1, PIN2, CVV2)                         X
X  2. One-Time Passwords (SMS OTP, Email OTP, TOTP Authenticator Secrets)       X
X  3. Session Credentials (JWT Bearer Tokens, Refresh Tokens, Cookies)         X
X  4. Cardholder Data (Full 16-digit PAN, CVV, Card Expiration, Track Data)     X
X  5. Identity & KYC Artifacts (National ID photos, Passports, Selfies)         X
X  6. Raw Iranian National ID (Melli Code) and International Tax IDs            X
X  7. Raw Banking Payloads (Complete Shaparak, Saman, or Zibal Gateway bodies)  X
X  8. Financial Balances & Unmasked Bank Account / IBAN Numbers                 X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 3.1 Authentication & Security Secrets
- **Plaintext Credentials:** Passwords, passcodes, PINs (PIN1, PIN2/CVV2), and security question answers.
- **Verification Codes:** One-Time Passwords (OTPs) delivered via SMS or email, TOTP secret seeds, and 2FA recovery backup codes.
- **Cryptographic Keys:** Asymmetric private keys, wallet mnemonic seed phrases, and symmetric encryption keys.

### 3.2 Session Credentials & Tokens
- **Authorization Headers:** Any header containing `Authorization: Bearer <token>`, `X-Api-Key`, or session cookies.
- **Session Tokens:** OAuth2 access tokens, refresh tokens, and internal microservice signing tokens.

### 3.3 Cardholder Data (PCI-DSS Strict Scope)
- **Primary Account Numbers (PAN):** Complete 16-digit payment card numbers.
- **Sensitive Authentication Data (SAD):** Card verification values (CVV, CVC, CID, CVV2), full magnetic stripe contents, and EMV chip payloads.
- **Card Expiry Dates:** Card expiration month/year when associated with any card identifier.

### 3.4 Identity & KYC Materials
- **Document Images:** High-resolution scans, captures, or PDF uploads of national ID cards (Kart-e-Melli), passports, birth certificates (Shenasnameh), or driver's licenses.
- **Biometric Media:** Selfie photos, video liveness streams, facial recognition vector embeddings, or fingerprint templates.
- **Government IDs:** Raw, unmasked 10-digit Iranian National Codes (Melli Code), social security numbers, or foreign tax identification numbers.

### 3.5 Raw Banking & Financial Transaction Payloads
- **Gateway Webhooks:** Complete unredacted JSON/XML request and response payloads from banking gateways (e.g., Shaparak, Saman, Parsian, Pasargad, Zibal, Stripe).
- **Core Balances:** Account ledger balances, wallet balances, and fiat currency totals. Telemetry must track flow progress, never ledger state.

---

## 4. Allowed Telemetry Items with Mandatory Sanitization

Telemetry must exclusively capture operational indicators and sanitized diagnostic attributes:

| Data Element | Sanitization & Redaction Rule | Example Permitted Output in Elasticsearch |
| :--- | :--- | :--- |
| **Payment Cards** | Truncate and mask to the **last 4 digits only**. The first 6 digits (BIN) may only be logged in a dedicated banking lookup table, decoupled from user identity. | `"card_suffix_last4": "8821"` |
| **User Identity** | Irreversible HMAC-SHA256 hash using a server-side pepper rotated periodically, or an opaque UUIDv4 pseudonym. Never raw phone, email, or DB primary key. | `"pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3"` |
| **API Endpoints** | Generalized route templates. Query parameters and path variables containing IDs, names, or tokens must be replaced with parameter placeholders. | `"endpoint_template": "/api/v1/cards/:id/transactions"` |
| **Financial Operations** | Operational action taxonomy enum. Zero amounts, zero balance values. | `"flow_type": "sheba_withdrawal"`, `"outcome": "success"` |
| **Network & Performance** | Integer durations in milliseconds, HTTP method, and standard integer status codes. | `"http_status_code": 200`, `"latency_ms": 342` |
| **Distributed Context** | Hexadecimal trace identifiers and opaque UUIDv4 correlation IDs. | `"trace.id": "4bf92f3577b34da6a3ce929d0e0e4736"` |

---

## 5. Multi-Layer Sanitization & Redaction Architecture

To ensure zero-leakage resilience, redaction is enforced across four defense-in-depth layers:

```
+---------------------------------------------------------------------------------------+
| LAYER 1: MOBILE CLIENT INTERCEPTOR (Flutter / Dart)                                  |
|   • Dio HTTP Interceptor strips 'Authorization' & 'Cookie' headers from error logs    |
|   • PII maskers sanitize local form fields before local ring buffer serialization    |
+---------------------------------------------------------------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
| LAYER 2: API GATEWAY INGESTION FILTER (NGINX / Laravel Middleware)                    |
|   • Payload key inspection: drops unrecognized dynamic fields                         |
|   • Rejects requests containing blacklisted regex patterns (HTTP 400 Bad Request)     |
+---------------------------------------------------------------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
| LAYER 3: OPENTELEMETRY COLLECTOR REDACTION PROCESSOR                                 |
|   • Regex scrubbing of span attributes and log body fields                            |
|   • Replaces PAN patterns (Luhn matches) with [REDACTED_PAN]                          |
+---------------------------------------------------------------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
| LAYER 4: ELASTICSEARCH INGEST PIPELINE                                                |
|   • Final server-side safety net prior to document indexing                           |
|   • Grok / Script processor scrubs residual secrets                                   |
+---------------------------------------------------------------------------------------+
```

### 5.1 Canonical Redaction Regex Patterns
The following compiled regex rules are deployed in Layer 2 (Gateway) and Layer 3 (Collector):

1. **Payment Card PAN (Visa, Mastercard, Sheba/Shetab Cards):**
   ```regex
   (?:\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|603799[0-9]{10}|589210[0-9]{10}|627412[0-9]{10})\b)
   ```
2. **Iranian National ID (Melli Code - 10 consecutive digits):**
   ```regex
   (?:\b[0-9]{10}\b)
   ```
3. **Bearer Token / JWT Pattern:**
   ```regex
   (?:ey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9._-]{10,}\.[A-Za-z0-9._-]+)
   ```
4. **Key-Value Secret Matching:**
   ```regex
   (?i)(?:password|passcode|pin|cvv|cvv2|otp|secret|token)\s*[:=]\s*["']?([^"',\s]+)
   ```

---

## 6. Data Retention Policies & Index Lifecycle Management (ILM)

Elasticsearch data streams are strictly governed by automated Index Lifecycle Management (ILM) policies. Under no circumstances may logs be retained indefinitely. In accordance with platform governance mandate **EL-GOV-01**, all services and operations runbooks adhere to a single canonical retention matrix.

### 6.1 Canonical Retention Matrix per Data Stream (EL-GOV-01)

| Data Stream Pattern | Description & Log Content | Retention Period | Storage Lifecycle Phases | Action upon Expiry |
| :--- | :--- | :--- | :--- | :--- |
| **`logs-ecardo.api-prod`** | Structured backend API access logs, microservice transactions, operational errors. | **90 Days** | **Hot:** Days 1–7 (7d duration, rollover at 50GB or 7d, priority 100)<br>**Warm:** Days 8–30 (23d duration, min_age 7d, force merge to 1 segment, compressed, priority 50)<br>**Cold:** Days 31–90 (60d duration, min_age 30d, searchable snapshots, priority 20) | **Hard Delete** at Day 91 |
| **`logs-ecardo.security-prod`** | Security audit trails, auth failures, privilege escalations, password reset triggers. | **180 Days** | **Hot:** Days 1–14 (14d duration, rollover at 50GB or 14d, priority 100)<br>**Warm:** Days 15–60 (46d duration, min_age 14d, single replica, force merge, priority 50)<br>**Cold:** Days 61–180 (120d duration, min_age 60d, snapshot-backed searchable snapshots, priority 20) | **Hard Delete** at Day 181 |
| **`logs-ecardo.mobile-prod`** | Client performance telemetry, sanitized Flutter mobile app diagnostic logs, route views, client network exceptions. | **30 Days** | **Hot:** Days 1–7 (7d duration, rollover at 25GB or 7d, priority 100)<br>**Warm:** Days 8–30 (23d duration, min_age 7d, read-only, force merge to 1 segment, priority 50)<br>**Cold:** Skipped | **Hard Delete** at Day 31 |
| **`traces-ecardo-prod`** | Raw traces, distributed OpenTelemetry APM spans, and tracing metrics. | **14 Days** | **Hot:** Days 1–3 (3d duration, rollover at 25GB or 3d, priority 100)<br>**Warm:** Days 4–14 (11d duration, min_age 3d, read-only, force merge to 1 segment, priority 50)<br>**Cold:** Skipped | **Hard Delete** at Day 15 |

---

### 6.2 Elasticsearch ILM Policy Definitions

#### Policy 1: Client Performance Telemetry (`ecardo-mobile-ilm-policy`) - 30 Days
```json
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "25GB",
            "max_age": "7d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

#### Policy 2: API Operational Logs (`ecardo-api-ilm-policy`) - 90 Days
```json
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "50GB",
            "max_age": "7d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "set_priority": { "priority": 20 }
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

#### Policy 3: Security & Audit Logs (`ecardo-security-ilm-policy`) - 180 Days
```json
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "50GB",
            "max_age": "14d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "14d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "cold": {
        "min_age": "60d",
        "actions": {
          "set_priority": { "priority": 20 }
        }
      },
      "delete": {
        "min_age": "180d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

#### Policy 4: Raw Traces / APM Spans (`ecardo-traces-ilm-policy`) - 14 Days
```json
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "25GB",
            "max_age": "3d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "3d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "delete": {
        "min_age": "14d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

---

## 7. Privacy, Legal Compliance, and Governance (Task EL-021)

### 7.1 Cross-Border Legal Basis and Consent
1. **Legitimate Interest:** Operational log collection (API access status, latency, error monitoring) operates under legitimate interest for securing services, detecting fraudulent access, and maintaining infrastructure availability.
2. **Telemetry Consent in App:** Non-essential client diagnostic telemetry (e.g., UX flow analytics) includes a client-side opt-out toggle within the Flutter application (`Settings -> Privacy -> Share Crash & Performance Diagnostics`). When toggled off, the mobile app stops emitting `screen_view` and `app_launch` telemetry.
3. **Corridor Localization:** Operational logs originating from designated geographical jurisdictions (e.g., UAE, Iran, Turkey) must remain hosted on authorized infrastructure fulfilling national data sovereignty mandates.

### 7.2 Data Subject Rights (Access & Erasure)
1. **Right to Erasure (Right to Be Forgotten):**
   - Telemetry stored in Elasticsearch contains zero direct identifiers (names, national IDs, phone numbers). All user-linked logs utilize `pseudonymous_user_id`.
   - When a user exercises their right to account deletion, the relational database purges the primary user record and deletes the HMAC salt/pepper mapping.
   - Result: All historical operational logs in Elasticsearch are rendered completely anonymous and mathematically untraceable to any physical person, fulfilling GDPR Article 17 and regional erasure requirements without corrupting historical aggregate metrics.
2. **Right to Access:**
   - Because search indexes do not maintain user profile data, access requests are served from the primary PostgreSQL transactional database, not the operational telemetry cluster.

### 7.3 Access Control & Audit Trails (Task EL-015)
1. **Role-Based Access Control (RBAC):**
   - Access to Kibana and Elasticsearch query endpoints is strictly restricted using single sign-on (SSO) with multi-factor authentication (MFA).
   - Support tier agents possess query permissions restricted solely to `correlation_id` searches via internal support APIs. Direct Elasticsearch cluster query access is restricted to on-call SREs and Principal Architects.
2. **Access Logging:**
   - Every search query executed against `logs-ecardo.security-prod` is automatically recorded in an immutable administrative audit log with the operator's ID, timestamp, and query parameters.

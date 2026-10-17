# Event Catalog, ECS Schema Envelope, and Domain Action Specifications

- **Document Version:** 1.0.0
- **Status:** APPROVED
- **Date:** 2026-10-15
- **Task Reference:** Task EL-005, EL-010, EL-012 (Roadmap Sections 24, 27, 30) of `ecardo_userapp_v1_audit_roadmap_fa_FIXED.md`
- **Applicable Services:** `ecardo_userapp_v1` (Flutter iOS/Android/Web), eCardo API Gateway, Outbox Workers, OpenTelemetry Collector, Elasticsearch Cluster

---

## 1. Overview and Engineering Objectives

This document establishes the canonical event specification, JSON Schema envelope, domain action catalog, and ingestion rejection rules for the eCardo observability platform.

Adherence to this contract is strictly enforced across all client and backend emitters to achieve:
1. **Elastic Common Schema (ECS v8.x) Alignment:** Native interoperability with Elasticsearch data streams, Kibana Discover, and OpenTelemetry semantic conventions.
2. **Prevention of Mapping Explosion:** Elasticsearch index mappings must remain deterministic and bounded. Dynamic field generation is forbidden (`dynamic: strict`).
3. **Strict Domain Allowlist:** Only explicitly cataloged actions with closed attribute sets are permitted through the ingestion gateway.
4. **Zero-Trust Input Validation:** Malformed, oversized, or unauthorized event payloads are rejected at the perimeter before consuming storage or queuing resources.

---

## 2. Canonical ECS Event Envelope Standard (Version 1.0.0)

Every event emitted by the Flutter mobile client, API gateway, background worker, or administrative portal MUST wrap its payload in the standardized top-level envelope.

### 2.1 Envelope Field Specification

| Field Path | Type | Constraints / Format | Description |
| :--- | :--- | :--- | :--- |
| `@timestamp` | `string` | ISO-8601 UTC (`YYYY-MM-DDTHH:mm:ss.sssZ`) | Canonical timestamp when the event occurred in UTC. |
| `event.id` | `string` | UUIDv4 (`^[0-9a-fA-F-]{36}$`) or ULID | Globally unique identifier used for downstream deduplication. |
| `event.schema_version` | `string` | SemVer (`^1\.[0-9]+\.[0-9]+$`) | Contract schema version. Currently `1.0.0`. |
| `event.category` | `string` | Enum (`application`, `authentication`, `financial_flow`, `network`, `security`, `session`) | High-level categorization aligned with ECS standard taxonomies. |
| `event.action` | `string` | Enum (Must match registered domain action) | Specific normalized action verb (e.g., `financial_flow_start`). |
| `event.outcome` | `string` | Enum (`success`, `failure`, `unknown`) | Final state or outcome of the action. |
| `service.name` | `string` | Keyword (`^[a-z0-9_-]+$`) | Originating service (e.g., `ecardo-userapp`, `ecardo-api-gateway`). |
| `deployment.environment` | `string` | Enum (`development`, `staging`, `production`) | Deployment environment tier. |
| `app.version` | `string` | SemVer + Build (`1.0.41+41`) | Client application release version. |
| `trace.id` | `string` | 32-hex character string | W3C distributed trace identifier for end-to-end correlation. |
| `correlation_id` | `string` | UUIDv4 (`^[0-9a-fA-F-]{36}$`) | Business transaction correlation ID passed across HTTP boundaries. |
| `source` | `string` | Enum (`mobile`, `api`, `worker`, `admin`) | Origin platform layer emitting the telemetry. |
| `pseudonymous_user_id`| `string` / `null` | SHA-256 Hex (64 chars) or UUIDv4 | Opaque pseudonymous user hash. NEVER raw phone, email, or DB ID. Null for guests. |
| `attributes` | `object` | Closed Schema per `event.action` | Action-specific attributes. Dynamic arbitrary keys are rejected. |
| `error` | `object` / `null` | Structured Error Object | Populated if `event.outcome` is `failure`. |

---

### 2.2 Canonical JSON Schema Definition (Draft 2020-12)

The JSON Schema below validates all incoming telemetry at the ingestion boundary:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://ecardo.ir/schemas/event-envelope-v1.0.0.json",
  "title": "ECardoObservabilityEventEnvelope",
  "type": "object",
  "required": [
    "@timestamp",
    "event",
    "service",
    "deployment",
    "trace",
    "correlation_id",
    "source",
    "pseudonymous_user_id",
    "attributes"
  ],
  "additionalProperties": false,
  "properties": {
    "@timestamp": {
      "type": "string",
      "format": "date-time"
    },
    "event": {
      "type": "object",
      "required": ["id", "schema_version", "category", "action", "outcome"],
      "additionalProperties": false,
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$|^[0-7][0-9A-HJKMNP-TV-Z]{25}$"
        },
        "schema_version": {
          "type": "string",
          "pattern": "^1\\.[0-9]+\\.[0-9]+$"
        },
        "category": {
          "type": "string",
          "enum": ["application", "authentication", "financial_flow", "network", "security", "session"]
        },
        "action": {
          "type": "string",
          "enum": [
            "app_launch",
            "screen_view",
            "financial_flow_start",
            "financial_flow_commit",
            "api_network_error",
            "session_expired"
          ]
        },
        "outcome": {
          "type": "string",
          "enum": ["success", "failure", "unknown"]
        }
      }
    },
    "service": {
      "type": "object",
      "required": ["name"],
      "additionalProperties": false,
      "properties": {
        "name": {
          "type": "string",
          "pattern": "^[a-z0-9_-]{3,64}$"
        }
      }
    },
    "deployment": {
      "type": "object",
      "required": ["environment"],
      "additionalProperties": false,
      "properties": {
        "environment": {
          "type": "string",
          "enum": ["development", "staging", "production"]
        }
      }
    },
    "app": {
      "type": "object",
      "required": ["version"],
      "additionalProperties": false,
      "properties": {
        "version": {
          "type": "string",
          "maxLength": 32
        }
      }
    },
    "trace": {
      "type": "object",
      "required": ["id"],
      "additionalProperties": false,
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^[0-9a-fA-F]{32}$"
        }
      }
    },
    "correlation_id": {
      "type": "string",
      "pattern": "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    },
    "source": {
      "type": "string",
      "enum": ["mobile", "api", "worker", "admin"]
    },
    "pseudonymous_user_id": {
      "type": ["string", "null"],
      "pattern": "^[0-9a-fA-F]{64}$|^[0-9a-fA-F-]{36}$"
    },
    "attributes": {
      "type": "object"
    },
    "error": {
      "type": ["object", "null"],
      "additionalProperties": false,
      "properties": {
        "type": { "type": "string", "maxLength": 64 },
        "code": { "type": "string", "maxLength": 64 },
        "message_sanitized": { "type": "string", "maxLength": 512 }
      }
    }
  }
}
```

---

## 3. Allowed Domain Action Specifications

Only the 6 core actions specified below are authorized for client and API ingestion. Payloads specifying unregistered actions are rejected immediately.

### 3.1 Action: `app_launch`
- **Category:** `application`
- **Trigger:** Invoked when Flutter finishes cold initialization or resumes from background.
- **Allowed Attributes Schema:**
  ```json
  {
    "launch_type": { "type": "string", "enum": ["cold", "warm"] },
    "duration_ms": { "type": "integer", "minimum": 0, "maximum": 60000 },
    "os_name": { "type": "string", "enum": ["android", "ios", "web", "windows", "macos", "linux"] },
    "os_version": { "type": "string", "maxLength": 32 },
    "device_manufacturer": { "type": "string", "maxLength": 32 }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:14:22.102Z",
    "event": {
      "id": "e3b0c442-98fc-4c14-9afe-044298fc4c14",
      "schema_version": "1.0.0",
      "category": "application",
      "action": "app_launch",
      "outcome": "success"
    },
    "service": { "name": "ecardo-userapp" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "source": "mobile",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "launch_type": "cold",
      "duration_ms": 1140,
      "os_name": "android",
      "os_version": "14",
      "device_manufacturer": "Samsung"
    },
    "error": null
  }
  ```

---

### 3.2 Action: `screen_view`
- **Category:** `application`
- **Trigger:** Fired by the Flutter Navigator observer upon transition to a named route.
- **Allowed Attributes Schema:**
  ```json
  {
    "screen_name": { "type": "string", "maxLength": 64 },
    "previous_screen_name": { "type": ["string", "null"], "maxLength": 64 },
    "transition_duration_ms": { "type": "integer", "minimum": 0, "maximum": 10000 }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:14:25.881Z",
    "event": {
      "id": "7d2b86c2-0b2a-4a7b-a367-27b0f69a5382",
      "schema_version": "1.0.0",
      "category": "application",
      "action": "screen_view",
      "outcome": "success"
    },
    "service": { "name": "ecardo-userapp" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "source": "mobile",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "screen_name": "/wallet/exchange",
      "previous_screen_name": "/home",
      "transition_duration_ms": 18
    },
    "error": null
  }
  ```

---

### 3.3 Action: `financial_flow_start`
- **Category:** `financial_flow`
- **Trigger:** User opens a financial form/flow (e.g., initiates a card transfer or remittance).
- **Hard Restriction:** MUST NOT contain transaction amounts, source account numbers, destination account numbers, or card PANs.
- **Allowed Attributes Schema:**
  ```json
  {
    "flow_type": { 
      "type": "string", 
      "enum": ["c2c_transfer", "internal_wallet_transfer", "sheba_withdrawal", "currency_exchange", "crypto_deposit"] 
    },
    "flow_session_id": { "type": "string", "pattern": "^[0-9a-fA-F-]{36}$" },
    "source_currency": { "type": "string", "pattern": "^[A-Z]{3,4}$" },
    "target_currency": { "type": ["string", "null"], "pattern": "^[A-Z]{3,4}$" }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:15:02.110Z",
    "event": {
      "id": "2c943809-5481-4ef4-9a8c-9c0211516e49",
      "schema_version": "1.0.0",
      "category": "financial_flow",
      "action": "financial_flow_start",
      "outcome": "success"
    },
    "service": { "name": "ecardo-userapp" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "5fa23d11-4cb0-4107-ba71-f51bce1687aa",
    "source": "mobile",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "flow_type": "sheba_withdrawal",
      "flow_session_id": "5fa23d11-4cb0-4107-ba71-f51bce1687aa",
      "source_currency": "IRR",
      "target_currency": null
    },
    "error": null
  }
  ```

---

### 3.4 Action: `financial_flow_commit`
- **Category:** `financial_flow`
- **Trigger:** Backend executes the state transition or client receives completion response. Emitted primarily by backend outbox workers to guarantee audit veracity.
- **Hard Restriction:** NEVER includes balance values, unmasked bank account numbers, or card CVVs. Masked `card_suffix_last4` is permitted.
- **Allowed Attributes Schema:**
  ```json
  {
    "flow_type": { 
      "type": "string", 
      "enum": ["c2c_transfer", "internal_wallet_transfer", "sheba_withdrawal", "currency_exchange", "crypto_deposit"] 
    },
    "flow_session_id": { "type": "string", "pattern": "^[0-9a-fA-F-]{36}$" },
    "gateway_provider": { "type": "string", "enum": ["internal", "shaparak", "saman", "parsian", "zibal", "stripe"] },
    "duration_ms": { "type": "integer", "minimum": 0, "maximum": 300000 },
    "card_suffix_last4": { "type": ["string", "null"], "pattern": "^[0-9]{4}$" }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:15:05.412Z",
    "event": {
      "id": "18f9da43-85dc-4e20-b4d2-f67f2e1a3d90",
      "schema_version": "1.0.0",
      "category": "financial_flow",
      "action": "financial_flow_commit",
      "outcome": "success"
    },
    "service": { "name": "ecardo-payment-service" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "5fa23d11-4cb0-4107-ba71-f51bce1687aa",
    "source": "api",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "flow_type": "sheba_withdrawal",
      "flow_session_id": "5fa23d11-4cb0-4107-ba71-f51bce1687aa",
      "gateway_provider": "saman",
      "duration_ms": 3210,
      "card_suffix_last4": "8821"
    },
    "error": null
  }
  ```

---

### 3.5 Action: `api_network_error`
- **Category:** `network`
- **Trigger:** Captured by the Flutter HTTP / Dio client interceptor when an API call fails or times out.
- **Hard Restriction:** Path parameters containing user IDs, card IDs, or query string auth parameters MUST be generalized to route templates (e.g., `/api/v1/wallets/:id/balance`).
- **Allowed Attributes Schema:**
  ```json
  {
    "http_method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"] },
    "endpoint_template": { "type": "string", "maxLength": 128 },
    "http_status_code": { "type": ["integer", "null"], "minimum": 100, "maximum": 599 },
    "error_type": { "type": "string", "enum": ["timeout", "connection_refused", "dns_failure", "ssl_handshake", "http_4xx", "http_5xx"] },
    "latency_ms": { "type": "integer", "minimum": 0, "maximum": 60000 }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:16:10.021Z",
    "event": {
      "id": "e4a1a457-36bb-49e0-827c-9b8826d9e034",
      "schema_version": "1.0.0",
      "category": "network",
      "action": "api_network_error",
      "outcome": "failure"
    },
    "service": { "name": "ecardo-userapp" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "a18b2c4d-98e7-4100-b6a2-938217bbcc44",
    "source": "mobile",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "http_method": "POST",
      "endpoint_template": "/api/v1/cards/:id/block",
      "http_status_code": 504,
      "error_type": "timeout",
      "latency_ms": 10002
    },
    "error": {
      "type": "DioException.connectionTimeout",
      "code": "GATEWAY_TIMEOUT",
      "message_sanitized": "The connection to upstream gateway timed out after 10000ms"
    }
  }
  ```

---

### 3.6 Action: `session_expired`
- **Category:** `session`
- **Trigger:** Triggered when the mobile application discards active session state due to token expiry, refresh failure, or background inactivity bounds (15-minute lock).
- **Allowed Attributes Schema:**
  ```json
  {
    "reason": { 
      "type": "string", 
      "enum": ["inactivity_timeout", "token_revoked", "refresh_failed", "biometric_lockout", "explicit_logout"] 
    },
    "session_duration_seconds": { "type": "integer", "minimum": 0, "maximum": 2592000 }
  }
  ```
- **Example Valid Event:**
  ```json
  {
    "@timestamp": "2026-10-15T08:31:00.005Z",
    "event": {
      "id": "cf149b16-47b2-4d56-a19e-e62744e8bc1a",
      "schema_version": "1.0.0",
      "category": "session",
      "action": "session_expired",
      "outcome": "success"
    },
    "service": { "name": "ecardo-userapp" },
    "deployment": { "environment": "production" },
    "app": { "version": "1.0.41+41" },
    "trace": { "id": "4bf92f3577b34da6a3ce929d0e0e4736" },
    "correlation_id": "b07e4d81-893c-41b4-b52e-5f11100aa765",
    "source": "mobile",
    "pseudonymous_user_id": "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    "attributes": {
      "reason": "inactivity_timeout",
      "session_duration_seconds": 900
    },
    "error": null
  }
  ```

---

## 4. Explicit Malformed Event Rejection Rules

The Ingestion API (`POST /api/telemetry/events`) strictly validates every event. If any event in a batch violates the rules below, the gateway acts according to the rejection matrix:

```
Incoming Telemetry Batch
          |
          v
+-------------------------------+       Fail       +---------------------------------------------+
| Check 1: Envelope Structure   | ---------------> | Reject: HTTP 422 (ERR_MALFORMED_ENVELOPE)   |
+-------------------------------+                  +---------------------------------------------+
          | Pass
          v
+-------------------------------+       Fail       +---------------------------------------------+
| Check 2: Timestamp Skew Check | ---------------> | Reject: HTTP 422 (ERR_TIMESTAMP_SKEW)       |
+-------------------------------+                  +---------------------------------------------+
          | Pass
          v
+-------------------------------+       Fail       +---------------------------------------------+
| Check 3: Registered Action    | ---------------> | Reject: HTTP 422 (ERR_UNREGISTERED_ACTION)  |
+-------------------------------+                  +---------------------------------------------+
          | Pass
          v
+-------------------------------+       Fail       +---------------------------------------------+
| Check 4: PII / Secret Scan    | ---------------> | Reject: HTTP 400 (ERR_PROHIBITED_DATA)      |
+-------------------------------+                  +---------------------------------------------+
          | Pass
          v
+-------------------------------+       Fail       +---------------------------------------------+
| Check 5: Size & Batch Limits  | ---------------> | Reject: HTTP 413 (ERR_PAYLOAD_TOO_LARGE)    |
+-------------------------------+                  +---------------------------------------------+
          | Pass
          v
[ Route to OpenTelemetry Collector Pipeline ]
```

### 4.1 Rejection Matrix and Error Codes

| Error Code | HTTP Status | Trigger Condition | Remediation / System Action |
| :--- | :--- | :--- | :--- |
| `ERR_MALFORMED_ENVELOPE` | `422 Unprocessable Entity` | Missing required top-level envelope fields (`@timestamp`, `event.id`, `correlation_id`). | Batch or single item dropped. Client logs schema parsing error. |
| `ERR_TIMESTAMP_SKEW` | `422 Unprocessable Entity` | `@timestamp` is more than 7 days in the past OR more than 10 minutes in the future. | Dropped. Prevents corrupting historical ILM partitions or future time-series data. |
| `ERR_UNREGISTERED_ACTION` | `422 Unprocessable Entity` | `event.action` is not one of the 6 authorized actions in Section 3. | Dropped. Client app build version must be upgraded to register new domain actions. |
| `ERR_SCHEMA_VERSION_MISMATCH`| `422 Unprocessable Entity` | `event.schema_version` does not start with `1.` (major version mismatch). | Dropped. Ingestion endpoint supports backward-compatible minor revisions only. |
| `ERR_PROHIBITED_DATA` | `400 Bad Request` | Payload contains forbidden string tokens (e.g. `password`, `cvv`, `pin`, `private_key`, 16-digit PAN pattern). | Hard drop. Security incident metric incremented; IP rate-limit penalized. |
| `ERR_PAYLOAD_TOO_LARGE` | `413 Payload Too Large` | Single event exceeds 8 KB OR total batch exceeds 64 KB uncompressed. | Rejected. Client ring buffer must reduce batch size. |
| `ERR_MAPPING_EXPLOSION` | `422 Unprocessable Entity` | `attributes` contains unregistered keys not defined in the action schema. | Dynamic fields stripped or event rejected. |

---

## 5. Elasticsearch Index Template and Component Mappings

To strictly enforce typing and eliminate Elasticsearch mapping explosions, the following explicit index template is configured in the cluster:

```json
{
  "index_patterns": ["logs-ecardo.*"],
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo-log-policy",
      "index.mapping.total_fields.limit": 200,
      "index.refresh_interval": "5s",
      "number_of_shards": 2,
      "number_of_replicas": 1
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "@timestamp": { "type": "date" },
        "event": {
          "properties": {
            "id": { "type": "keyword" },
            "schema_version": { "type": "keyword" },
            "category": { "type": "keyword" },
            "action": { "type": "keyword" },
            "outcome": { "type": "keyword" }
          }
        },
        "service": {
          "properties": {
            "name": { "type": "keyword" }
          }
        },
        "deployment": {
          "properties": {
            "environment": { "type": "keyword" }
          }
        },
        "app": {
          "properties": {
            "version": { "type": "keyword" }
          }
        },
        "trace": {
          "properties": {
            "id": { "type": "keyword" }
          }
        },
        "correlation_id": { "type": "keyword" },
        "source": { "type": "keyword" },
        "pseudonymous_user_id": { "type": "keyword" },
        "attributes": {
          "dynamic": "false",
          "properties": {
            "launch_type": { "type": "keyword" },
            "duration_ms": { "type": "long" },
            "os_name": { "type": "keyword" },
            "os_version": { "type": "keyword" },
            "device_manufacturer": { "type": "keyword" },
            "screen_name": { "type": "keyword" },
            "previous_screen_name": { "type": "keyword" },
            "transition_duration_ms": { "type": "long" },
            "flow_type": { "type": "keyword" },
            "flow_session_id": { "type": "keyword" },
            "source_currency": { "type": "keyword" },
            "target_currency": { "type": "keyword" },
            "gateway_provider": { "type": "keyword" },
            "card_suffix_last4": { "type": "keyword" },
            "http_method": { "type": "keyword" },
            "endpoint_template": { "type": "keyword" },
            "http_status_code": { "type": "short" },
            "error_type": { "type": "keyword" },
            "latency_ms": { "type": "long" },
            "reason": { "type": "keyword" },
            "session_duration_seconds": { "type": "long" }
          }
        },
        "error": {
          "properties": {
            "type": { "type": "keyword" },
            "code": { "type": "keyword" },
            "message_sanitized": { "type": "text" }
          }
        }
      }
    }
  }
}
```

---

## 6. Schema Evolution and Governance Protocol

1. **Semantic Versioning:**
   - **Patch (`1.0.x`):** Non-breaking documentation updates or minor attribute description clarifications.
   - **Minor (`1.x.0`):** Adding a new optional attribute to an existing action or registering a new action. Backward compatible.
   - **Major (`x.0.0`):** Renaming or deleting an existing field, changing data types, or altering mandatory envelope structures. Requires dual-version ingestion support in API gateways for a minimum of 60 days.
2. **Pull Request Protocol:** Any modification to this catalog requires explicit review and approval by the Observability Guild and the Principal Security Architect.

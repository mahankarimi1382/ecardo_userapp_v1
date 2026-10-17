# eCardo Mobile Client Documentation Portal

Welcome to the engineering, architecture, operations, testing, and product documentation portal for **eCardo User App (`ecardo_userapp_v1`)**.

---

## 1. Active Release Dossier & Pre-Release Verification
Official release readiness certification, cryptographic signing verification, and audit gate matrices:

| Document | Description | Target Release / Gate |
| :--- | :--- | :--- |
| **[CURRENT_RELEASE.md](CURRENT_RELEASE.md)** | **Canonical Active Release Line Dossier (REL-DOC-01):** Unambiguous reference for active release `v1.0.172+172` (commit `98e8993`) and reference `v1.0.171+171` build (commit `2502823`). Documents 687 automated tests (100% green), static analysis verdict, SharedPreferences R8 NoSuchMethodError fix, Universal FAT APK packaging, FLAG_SECURE removal, full re-audit compliance, and CI runs (#611, #612, #228). | **Active Release v1.0.172+172 / v1.0.171** |
| **[RELEASE_CHECKLIST.md](audit/RELEASE_CHECKLIST.md)** | **Production Release Verification Checklist:** Line-by-line verification of P0 hard gates (G-01 through G-08) and build/packaging requirements (B-01 through B-04), synchronized with active release line `v1.0.172+172` (and reference `v1.0.171+171`), Universal FAT APK, and 687 test count. | **Gates G-01–G-08, B-01–B-04** |
| **[RELEASE_EVIDENCE.md](audit/RELEASE_EVIDENCE.md)** | **Production Release Evidence & Verification Dossier (Archived Baseline v1.0.170):** Historical evidence archive for commit `5a4abe6`, version `1.0.170+170`, 682 tests baseline. Active release governance is maintained in `CURRENT_RELEASE.md`. | **Archived Release v1.0.170** |

---

## 2. Audit & Baseline Reports (`docs/audit/`)
Complete artifacts produced from the deep codebase audit and verification against `ecardo_userapp_v1_audit_roadmap_fa.md`:

| Document | Description |
| :--- | :--- |
| **[BASELINE.md](audit/BASELINE.md)** | Baseline metrics, Flutter/Dart environment diagnostics, 99 routes and 40 modules inventory. |
| **[FINDINGS.md](audit/FINDINGS.md)** | Line-by-line verification matrix for all P0/P1 audit findings across security, auth, and network. |
| **[TASKS.md](audit/TASKS.md)** | Master backlog of prioritized remediation tasks (All P0 and P1 tasks verified & implemented). |
| **[THREAT_MODEL.md](audit/THREAT_MODEL.md)** | Threat model and defense-in-depth security posture evaluated against OWASP MASVS v2.0. |
| **[FINANCIAL_FLOWS.md](audit/FINANCIAL_FLOWS.md)** | Specification of financial state machines, precision math, idempotency, and gateway verifications. |
| **[MARKET_READINESS.md](audit/MARKET_READINESS.md)** | Regional readiness matrix across Iran, UAE, Turkey, Russia, China, and Global corridors. |
| **[DX_ROADMAP.md](audit/DX_ROADMAP.md)** | Product excellence roadmap covering tasks DX-001 through DX-020 from Annex 2. |

---

## 3. Architecture Decision Records (`docs/adr/`)
Formal decision records capturing core technical choices, trade-offs, and invariants:

| ADR | Title & Scope |
| :--- | :--- |
| **[0001](adr/0001-secure-session-storage.md)** | Secure Session Storage & Keystore/Keychain Migration |
| **[0002](adr/0002-money-and-currency-model.md)** | Scaled Integer Money Model, ISO 4217 Decimals & Rate Drift Locking |
| **[0003](adr/0003-environment-configuration.md)** | Fail-Closed Environment Configuration & Secret Isolation |
| **[0004](adr/0004-localization-and-formatting.md)** | Dual-Font Typography (Vazirmatn), Shamsi Calendar & RTL Physical Geometry |
| **[0005](adr/0005-payment-provider-abstraction.md)** | Payment Provider Abstraction, Server Truth & Idempotency Key Retention |

---

## 4. Master Architecture, Observability & Domain Specifications
Enterprise architecture, telemetry data pipelines, search boundaries, and domain specifications:

| Document | Title & Scope | Domain / Category |
| :--- | :--- | :--- |
| **[MASTER_ARCHITECTURE.md](MASTER_ARCHITECTURE.md)** | Master Architecture Blueprint across financial, travel, commercial, and identity domains. | Enterprise Architecture |
| **[DOMAIN_INVENTORY.md](DOMAIN_INVENTORY.md)** | Comprehensive inventory of all 40 modules, 99 routes, and controller dependencies. | Domain Mapping |
| **[SUB_SERVICES_COMPREHENSIVE_BLUEPRINT.md](SUB_SERVICES_COMPREHENSIVE_BLUEPRINT.md)** | Service architecture blueprint for sub-services, micro-apps, and shared modules. | Modular Services |
| **[MASTER_UPGRADE_PLAN_COMMERCIAL_TRAVEL.md](MASTER_UPGRADE_PLAN_COMMERCIAL_TRAVEL.md)** | Master upgrade plan for commercial and travel service modernization. | Platform Upgrades |
| **[BACKEND_IMPLEMENTATION_SPEC.md](financial/BACKEND_IMPLEMENTATION_SPEC.md)** | Backend API specification, state transitions, and database schemas for financial transactions. | Financial Backend |
| **[ADR-ELASTICSEARCH-001.md](architecture/ADR-ELASTICSEARCH-001.md)** | Architectural Role, Non-Financial Boundary, and Graceful Degradation of Elasticsearch (EL-003, EL-017). | Observability Architecture |
| **[OBSERVABILITY-DATA-FLOW.md](architecture/OBSERVABILITY-DATA-FLOW.md)** | End-to-End Telemetry Pipeline, Transactional Outbox, Sampling & Circuit Breaking (EL-008, EL-010, EL-011). | Telemetry Pipeline |
| **[EVENT-CATALOG.md](architecture/EVENT-CATALOG.md)** | Canonical ECS Schema Envelope, Domain Action Catalog & Malformed Rejection Rules (EL-005, EL-012). | Event Architecture |
| **[DATA-CLASSIFICATION.md](architecture/DATA-CLASSIFICATION.md)** | Data Classification Matrix, Forbidden Telemetry Items & ILM Retention Policies (EL-002, EL-021). | Data Governance |
| **[travel/ARCHITECTURE.md](travel/ARCHITECTURE.md)** | Travel domain subsystem architecture, state machines, and booking lifecycle. | Travel Architecture |
| **[travel/API_CONTRACT.md](travel/API_CONTRACT.md)** | Complete REST API contracts for flight, hotel, tour, visa, and rental services. | Travel API Contracts |
| **[travel/SCREEN_MAP.md](travel/SCREEN_MAP.md)** | Screen navigation flows, dynamic transitions, and travel service routing. | Screen Navigation |

---

## 5. SRE Operations & Disaster Recovery (`docs/operations/`)
Production runbooks, disaster recovery drills, incident response playbooks, and update operations:

| Document | Title & Scope | Application Domain |
| :--- | :--- | :--- |
| **[ELASTICSEARCH-RUNBOOK.md](operations/ELASTICSEARCH-RUNBOOK.md)** | SRE Runbook for Cluster Maintenance, ILM 4-Phase Policies, Shard Sizing & Alert SOPs (EL-018, EL-022). | SRE Operations |
| **[SNAPSHOT-RESTORE-DRILL.md](operations/SNAPSHOT-RESTORE-DRILL.md)** | Off-Cluster S3 Snapshot Backup Protocol, RTO (<2h) / RPO (<1h) SLAs & Verification Drill (EL-013, EL-022). | Disaster Recovery |
| **[TELEMETRY-INCIDENTS.md](operations/TELEMETRY-INCIDENTS.md)** | Incident Playbooks: Ingest Lag, Disk Flood Watermark & Accidental PII Eradication (EL-018). | Incident Response |
| **[travel/OPERATIONS.md](travel/OPERATIONS.md)** | Travel operations runbook, partner API health monitoring, and exception handling. | Travel Operations |
| **[travel/HANDOFF.md](travel/HANDOFF.md)** | Operations handoff guide for travel service maintenance. | Operational Handoff |
| **[APP_UPDATE_SETUP.md](APP_UPDATE_SETUP.md)** | In-App update setup, forced/flexible update policy, and backend API integration. | App Lifecycle |

---

## 6. Testing & Quality Assurance (`docs/testing/`)
Automated test documentation, security test suites, flow validations, and integration reports:

| Document | Title & Scope | Verification Focus |
| :--- | :--- | :--- |
| **[TELEMETRY-SECURITY-TESTS.md](testing/TELEMETRY-SECURITY-TESTS.md)** | Negative Security Test Suite for Data Leakage Prevention (Synthetic Luhn PAN, OTP, JWT, Passwords) (EL-016). | Telemetry Security |
| **[OBSERVABILITY-LOAD-TESTS.md](testing/OBSERVABILITY-LOAD-TESTS.md)** | Peak Burst Load (5,000 req/s), ES Network Drop Fault Injection & Buffer Drop Policy (EL-017). | Stress & Fault Injection |
| **[travel/TESTING.md](travel/TESTING.md)** | Travel subsystem testing guide, mock service harnesses, and verification strategies. | Travel Domain Tests |
| **[flow_test_report.md](flow_test_report.md)** | Flow-to-flow validation report and live backend REST probe audit. | Navigation & REST Flows |
| **[app_flow_audit.md](app_flow_audit.md)** | Comprehensive audit of user application flows, transitions, and screen state. | UI State Machines |

---

## 7. Product & Design System Specifications (`docs/design/`)
Product design, research, user journeys, and accessibility specifications from Annex 2:

| Document | Scope & Target Task |
| :--- | :--- |
| **[PRODUCT_PRINCIPLES.md](design/PRODUCT_PRINCIPLES.md)** | Five core product principles & eCardo brand positioning (DX-004) |
| **[COMPETITIVE_REVIEW.md](design/COMPETITIVE_REVIEW.md)** | Benchmark of Revolut, Wise, Nubank, BluBank & market gap analysis (DX-002) |
| **[RESEARCH.md](design/RESEARCH.md)** | Target personas (Maryam, Reza, Alex) & usability task metrics (DX-003) |
| **[JOURNEYS.md](design/JOURNEYS.md)** | Step-by-step user journey maps for auth, exchange, Sheba withdraw, and P2P (DX-009) |
| **[CONTENT_GUIDELINES.md](design/CONTENT_GUIDELINES.md)** | Tone of voice, 3-part plain-language error copy, and multilingual terminology (DX-008) |
| **[VISUAL_SPEC.md](design/VISUAL_SPEC.md)** | Neofintech dark theme palette, glass tokens, easing curves & haptics (DX-005) |
| **[COMPONENT_CATALOG.md](design/COMPONENT_CATALOG.md)** | Comprehensive component catalog and state matrix for core widgets (DX-007) |
| **[ACCESSIBILITY_AUDIT.md](design/ACCESSIBILITY_AUDIT.md)** | WCAG 2.2 AA compliance audit (9:1 contrast, 48dp touch targets, TalkBack/VoiceOver) (DX-010) |

---

## 8. Quality Gates & Release Verification
- **Release Evidence Dossier:** Refer to [`docs/audit/RELEASE_EVIDENCE.md`](audit/RELEASE_EVIDENCE.md) for full static analyzer and test execution evidence.
- **Pre-Release Checklist:** Refer to [`docs/audit/RELEASE_CHECKLIST.md`](audit/RELEASE_CHECKLIST.md) for verified P0 release gates (G-01–G-08) and packaging requirements (B-01–B-04).
- **Pull Request Template:** [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md) enforces the mandatory 15-question review checklist from Section 20 of Annex 2.
- **CI Pipelines:** [`.github/workflows/flutter.yml`](../.github/workflows/flutter.yml) guarantees code formatting check, static analysis, unit/widget tests, and obfuscated split-APK builds.

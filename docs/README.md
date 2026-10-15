# eCardo Mobile Client Documentation Portal

Welcome to the engineering and product documentation portal for **eCardo User App (`ecardo_userapp_v1`)**.

---

## 1. Audit & Baseline Reports (`docs/audit/`)
Complete artifacts produced from the deep codebase audit and verification against `ecardo_userapp_v1_audit_roadmap_fa.md`:

| Document | Description |
| :--- | :--- |
| **[BASELINE.md](audit/BASELINE.md)** | Baseline metrics, Flutter/Dart environment diagnostics, 99 routes and 40 modules inventory. |
| **[FINDINGS.md](audit/FINDINGS.md)** | Line-by-line verification matrix for all P0/P1 audit findings across security, auth, and network. |
| **[THREAT_MODEL.md](audit/THREAT_MODEL.md)** | Threat model and defense-in-depth security posture evaluated against OWASP MASVS v2.0. |
| **[FINANCIAL_FLOWS.md](audit/FINANCIAL_FLOWS.md)** | Specification of financial state machines, precision math, idempotency, and gateway verifications. |
| **[MARKET_READINESS.md](audit/MARKET_READINESS.md)** | Regional readiness matrix across Iran, UAE, Turkey, Russia, China, and Global corridors. |
| **[RELEASE_CHECKLIST.md](audit/RELEASE_CHECKLIST.md)** | Pre-release verification checklist, signing keys protocol, and rollback procedures. |
| **[TASKS.md](audit/TASKS.md)** | Master backlog of prioritized remediation tasks (All P0 and P1 tasks verified & implemented). |
| **[DX_ROADMAP.md](audit/DX_ROADMAP.md)** | Product excellence roadmap covering tasks DX-001 through DX-020 from Annex 2. |

---

## 2. Architecture Decision Records (`docs/adr/`)
Formal decision records capturing core technical choices, trade-offs, and invariants:

| ADR | Title & Scope |
| :--- | :--- |
| **[0001](adr/0001-secure-session-storage.md)** | Secure Session Storage & Keystore/Keychain Migration |
| **[0002](adr/0002-money-and-currency-model.md)** | Scaled Integer Money Model, ISO 4217 Decimals & Rate Drift Locking |
| **[0003](adr/0003-environment-configuration.md)** | Fail-Closed Environment Configuration & Secret Isolation |
| **[0004](adr/0004-localization-and-formatting.md)** | Dual-Font Typography (Vazirmatn), Shamsi Calendar & RTL Physical Geometry |
| **[0005](adr/0005-payment-provider-abstraction.md)** | Payment Provider Abstraction, Server Truth & Idempotency Key Retention |

---

## 3. Product & Design System Specifications (`docs/design/`)
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

## 4. Quality Gates & Release Verification
- **Pull Request Template:** [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md) enforces the mandatory 15-question review checklist from Section 20 of Annex 2.
- **CI Pipelines:** [`.github/workflows/flutter.yml`](../.github/workflows/flutter.yml) guarantees code formatting check, static analysis, unit/widget tests, and obfuscated split-APK builds.

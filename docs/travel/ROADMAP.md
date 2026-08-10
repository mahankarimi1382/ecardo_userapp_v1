# Travel UX Roadmap

Updated: July 28, 2026.

Status values: `ready`, `backend-needed`, `research`, `done`.

## Phase 0 — Safety and Observability

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-CORE-001 | Unknown statuses never appear completed | Flutter/API | Raw status | High | done |
| TRAVEL-CORE-002 | Structured user-safe errors and support reference | Flutter/API | Error envelope | High | done |
| TRAVEL-CI-001 | Analyzer/build failures fail CI | CI | None | High | done |
| TRAVEL-SEC-001 | Rotate embedded deploy credential and use secret storage | CI/ops | Repository admin | Critical | done |

## Phase 1 — Communication Foundation

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-UX-001 | Search criteria remain visible and editable | Flutter | None | Low | done |
| TRAVEL-UX-003 | Empty/errors explain impact and recovery | Flutter/API | Error codes | Medium | done |
| TRAVEL-UX-004 | Only tapped offer shows detail loading | Flutter | None | Low | done |
| TRAVEL-UX-005 | Checkout shows current and next step | Flutter | None | Low | done |
| TRAVEL-UX-006 | User reviews product, people, rules, wallet, total | Flutter/API | Structured data | High | done |
| TRAVEL-UX-007 | Expired holds offer re-search/re-reserve | Flutter/API | Reservation state | High | done |
| TRAVEL-UX-008 | Booking timeline separates paid, pending, issued, failed | Flutter/API | Events/status | High | backend-needed |
| TRAVEL-UX-009 | Contextual support includes safe reference | Flutter/API | Support metadata | Medium | backend-needed |
| TRAVEL-UX-010 | Purchased page groups lifecycle states and refreshes | Flutter | Status fix | Medium | done |
| TRAVEL-I18N-001 | All Travel copy localized and translation completeness measured | Flutter/content | Translators | Medium | done |

## Phase 2 — Search and Comparison

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-BE-001 | City/airport/country suggestions | Backend | Catalog indexing | Medium | backend-needed |
| TRAVEL-UX-002 | Result count, basic sort/filter, active chips | Flutter/API | Search metadata | Medium | done |
| TRAVEL-UX-011 | Rich cards show relevant normalized facts | Flutter/API | Offer completeness | Medium | done |
| TRAVEL-UX-012 | Room and fare policies appear at selection | Flutter/API | Structured policies | High | backend-needed |
| TRAVEL-UX-013 | Comparable room/fare options and persistent selection | Flutter | Normalized variants | Medium | backend-needed |
| TRAVEL-UX-014 | Round trip, infant, cabin, flexible dates | Flutter/API | Search schema | High | backend-needed |
| TRAVEL-UX-015 | Hotel map/list with price pins | Flutter/API | Map + coordinates | Medium | research |
| TRAVEL-UX-016 | Sold-out alternatives and notify-me | Flutter/API | Notification contract | Medium | backend-needed |

## Phase 3 — Travelers and Contact

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-BE-002 | Backend-driven traveler/contact schema | Backend | Provider normalization | High | backend-needed |
| TRAVEL-UX-017 | Per-passenger forms and validation | Flutter/API | TRAVEL-BE-002 | High | backend-needed |
| TRAVEL-UX-018 | Lead guest assigned per hotel room | Flutter/API | TRAVEL-BE-002 | High | backend-needed |
| TRAVEL-UX-019 | Notification recipient and authorization contact | Flutter/API | TRAVEL-BE-002 | High | backend-needed |
| TRAVEL-UX-020 | Saved traveler CRUD | Flutter/API | Traveler endpoints | Medium | backend-needed |
| TRAVEL-UX-021 | Special requests clearly marked not guaranteed | Flutter/API | Request fields | Medium | backend-needed |

## Phase 4 — Lifecycle, Cancellation, and Recovery

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-BE-003 | Cancellation eligibility and estimate | Backend | Supplier rules | Critical | backend-needed |
| TRAVEL-BE-004 | Order events/timeline contract | Backend | State machine | High | backend-needed |
| TRAVEL-UX-022 | Penalty, refund amount, destination, consent | Flutter/API | TRAVEL-BE-003 | Critical | backend-needed |
| TRAVEL-UX-023 | Refund request receipt and progress timeline | Flutter/API | TRAVEL-BE-004 | High | backend-needed |
| TRAVEL-UX-024 | Verified purchase recovery by reference/contact | Flutter/API | Recovery contract | High | backend-needed |
| TRAVEL-UX-025 | Change-date/edit request becomes approval workflow | Flutter/API | Change contract | High | research |
| TRAVEL-UX-026 | SMS/push/share/download lifecycle actions | Flutter/API | Notifications | Medium | backend-needed |

## Phase 5 — eSIM and Retention

| ID | Outcome | Area | Dependency | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| TRAVEL-ESIM-001 | Install QR and SM-DP+/activation data | Flutter/API | Artifact contract | High | backend-needed |
| TRAVEL-ESIM-002 | Install/activate/troubleshoot lifecycle | Flutter/API | Events/support | High | backend-needed |
| TRAVEL-RET-001 | Recent searches and favorites | Flutter/API | Storage policy | Low | research |
| TRAVEL-RET-002 | Verified reviews and summaries | Backend/content | Review source | Medium | research |
| TRAVEL-RET-003 | Price alerts | Backend | Notification system | Medium | research |

## Sequencing Rule

Do not market cancellation protection, scarcity, automatic reservation,
installments, insurance, free transport, discounts, or refund timing until
business operations and backend contracts can honor them.

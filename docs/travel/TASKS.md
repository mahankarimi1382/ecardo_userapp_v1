# Travel Implementation Tasks

Updated: July 28, 2026.

## Implementation Status

### Completed Frontend Work

- [x] `TRAVEL-CORE-002`: frontend errors use safe operation-scoped copy and preserve only sanitized support references.
- [x] `TRAVEL-CORE-001`: unknown/raw order statuses are preserved and cannot unlock confirmed artifact actions.
- [x] `TRAVEL-CORE-001`: payment-received, supplier-pending, confirmed/issued, failed, cancelled, refund, expired, and unknown states have separate presentation.
- [x] `TRAVEL-UX-001`: hotel and flight results retain search summaries and do not clear previous successful results after a failed re-search.
- [x] `TRAVEL-UX-003`: search, reservation, payment, refund, order-empty, and expired-reservation states use scoped safe recovery copy/actions where frontend can know the state.
- [x] `TRAVEL-UX-004`: offer detail loading is scoped to the selected card.
- [x] `TRAVEL-UX-005`: checkout uses a staged review/payment flow and preserves idempotent reservation/payment behavior.
- [x] `TRAVEL-UX-006`: checkout requires explicit review acknowledgement before reservation/payment.
- [x] `TRAVEL-UX-007`: expired reservations show reference, retry path, and a safe no-payment-attempted message for the current app session.
- [x] `TRAVEL-UX-010`: purchased bookings are grouped, refreshable, show last-updated state, and keep QR before download.
- [x] `TRAVEL-UX-002`: hotel and flight results show counts, safe sort/filter controls, and active chips.
- [x] `TRAVEL-UX-012`: room/fare cancellation summaries are highlighted only when backend/provider policy fields are present.
- [x] `TRAVEL-UX-016`: no-match flight results can surface backend-provided upcoming alternatives with edit-search recovery; notify-me remains backend-blocked.
- [x] Travel localization keys are complete for English, Persian, Arabic, Russian, and Chinese.
- [x] Reservation, payment, and refund retries preserve stable idempotency keys.
- [x] Focused lifecycle, safe-error, idempotency, and RTL/LTR tests pass.
- [x] Add SnappTrip/Flytoday-style journey communication for search, comparison, review, payment, and post-purchase recovery.
- [x] Add recent successful hotel/flight searches and backend-fact-only offer comparison.
- [x] Select nested localized backend values using the active application language.
- [x] Add one-way/round-trip flight search, return-flight pairing, cabin selection, infant fares, and combined authoritative checkout totals.
- [x] Add per-passenger identity forms and required notification phone/email confirmation before flight reservation.
- [x] Add per-room hotel occupancy in the web-preview workflow and shared models.

### Backend-Blocked Work

- [x] `TRAVEL-BE-001`: normalized hotel-city and flight-airport suggestions are exposed by the master catalog and used by both clients; eSIM country suggestions remain a later enhancement.
- [x] `TRAVEL-BE-002`: flight checkout uses the backend passenger/contact contract and persists encrypted order traveler snapshots; reusable saved-traveler CRUD remains a later enhancement.
- [ ] `TRAVEL-BE-003`: cancellation eligibility, penalties, and estimate versions require backend eligibility endpoints.
- [ ] `TRAVEL-BE-004`: authoritative order event timelines require backend order-event payloads.
- [ ] `TRAVEL-ESIM-001`: install QR / SM-DP+ / activation code artifacts require secure backend eSIM artifact data.
- [ ] `TRAVEL-UX-016`: notify-me for sold-out inventory requires a backend notification/consent contract.

## Definition of Done

Every task must:

- Explain current step, next step, and recovery.
- Disable duplicate actions and show scoped progress.
- Use backend-authoritative facts.
- Preserve safe state on back navigation.
- Localize visible text and pass RTL/LTR.
- Emit analytics without personal/document data.
- Add repository/model tests and relevant widget tests.
- Pass strict analysis, Android build, and web smoke test.

## First Sprint

### TRAVEL-CORE-001 — Safe Order Status

Problem: unknown backend values become `completed`.

Work:

- Add raw status and `unknown` presentation.
- Separate payment received, supplier pending, confirmed/issued, failed,
  cancelled, refund requested, and refunded where backend data allows.
- Replace status switches in order and confirmation screens.

Files: `travel_models.dart`, `travel_api_repository.dart`,
`travel_orders_screen.dart`, `travel_confirmation_screen.dart`.

Acceptance:

- Unknown status never enables confirmed artifact/cancellation behavior.
- Raw status is retained for support and tests.
- Existing known statuses remain correctly presented.

### TRAVEL-UX-001 — Search Summary and Edit

Problem: results lose visible search context.

Work:

- Add compact hotel/flight criteria summary to results.
- Edit returns to search with current values.
- Preserve results while editing; replace only after a successful new search.

Acceptance:

- City/route, dates, and occupancy/passengers are visible.
- Cancel edit restores unchanged results.
- Empty/error state still shows criteria.

### TRAVEL-UX-003 — Actionable Empty and Error States

Problem: failures are generic or silent.

Work:

- Normalize controller error state by operation.
- Add retry, edit search, alternative/upcoming, refresh order, and support
  actions where relevant.
- State whether a reservation or payment is known to exist.

Acceptance:

- No raw exception is shown.
- Search, offer detail, reservation, payment, order load, and refund have
  distinct messages and recovery.
- Request/support ID is shown when supplied.

### TRAVEL-UX-004 — Scoped Offer Loading

Problem: result selection has no clear local feedback.

Work:

- Track loading offer ID.
- Show progress/disable only the selected card.
- Allow retry or open summary details when authoritative detail fails.

### TRAVEL-UX-005 — Checkout Progress

Problem: checkout is a long page without a journey model.

Work:

- Introduce Selection → Travelers/Guest → Review → Payment.
- Preserve state when moving backward.
- Keep reserve/pay idempotency behavior.

### TRAVEL-UX-006 — Final Review Gate

Problem: payment lacks an explicit last verification.

Review must show product, dates/route, selected room/fare, people/contact,
important rules, authoritative amount, currency, wallet, expiry, and consent.

Acceptance:

- Pay is unavailable until required data and acknowledgement are valid.
- Price/rule changes return the user to an explainable review state.

### TRAVEL-UX-007 — Reservation Expiry Recovery

Problem: expiry silently clears the hold.

Work:

- Show expired state with reference and whether money was charged.
- Offer re-search, revalidate/re-reserve, or return to order when backend says a
  transaction exists.
- Do not reuse an expired reservation ID.

### TRAVEL-UX-010 — Purchased Page Lifecycle

Work:

- Group pending/action-needed, upcoming/active, completed, cancelled/refunded.
- Add pull-to-refresh and last-updated state.
- Keep QR visible before PDF for issued artifacts.
- Provide clear pending artifact explanation.

## Backend-Dependent Specifications

### TRAVEL-BE-002 — Traveler and Contact Contract

Must support per-product required fields, per-passenger records, lead guest per
room, buyer, notification recipient, validation rules, and saved traveler CRUD.
Store the contact authorized for later changes/cancellation.

Edge cases: infant ownership rules, missing passport for domestic journeys,
mixed nationalities, duplicated passengers, document expiry, non-Latin names,
and room occupancy mismatch.

### TRAVEL-BE-003 — Cancellation Eligibility

Must return eligibility, deadline, penalty, net refund, currency, destination,
supplier review requirement, estimate validity/version, localized policy, and
known processing estimate only when operationally supported.

Acceptance:

- Client cannot submit against a stale estimate without explicit reconfirmation.
- Ineligible responses include a safe reason and support path.
- Submission returns request ID and initial timeline event.

### TRAVEL-BE-004 — Order Events

Define events for created, hold active/expired, payment processing/received,
supplier confirming, issued, inventory unavailable, funds restored, cancel
requested/reviewed, refund approved/rejected/sent, and completed.

Each event needs timestamp, public type, safe localized content, action set, and
support reference. Internal provider errors must not leak.

## Later Tasks

- `TRAVEL-UX-002`: result count, basic sorting/filtering, active chips. Done for current frontend search result data.
- `TRAVEL-BE-001`: normalized destination/airport suggestions.
- `TRAVEL-UX-012`: room-level and fare-level cancellation summaries. Done where backend/provider policy fields are present; richer penalties remain backend-dependent.
- `TRAVEL-UX-014`: round trip, infant, and cabin search are complete; flexible-date pricing remains backend-dependent.
- `TRAVEL-UX-016`: alternatives and notify-me for sold-out inventory. Alternatives are shown from backend-provided upcoming data; notify-me remains backend-dependent.
- `TRAVEL-UX-019`: notification recipient phone/email confirmation is complete for flight checkout.
- `TRAVEL-UX-022`: cancellation estimate and consent UI.
- `TRAVEL-UX-023`: refund timeline and refund destination.
- `TRAVEL-UX-024`: secure order recovery by reference and verified contact.
- `TRAVEL-ESIM-001`: install QR and activation artifacts.

## Task Template

New task entries must include:

- Problem and user outcome.
- Current behavior and evidence.
- Proposed interaction.
- Flutter files and backend changes.
- Localization keys and analytics.
- Empty, loading, error, expiry, offline, and duplicate-action cases.
- Acceptance criteria and test matrix.
- Deployment, compatibility, and rollback notes.

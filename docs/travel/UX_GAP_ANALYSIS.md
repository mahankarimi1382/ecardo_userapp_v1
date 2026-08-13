# Travel UX Gap Analysis

Updated: July 28, 2026.

## Priority Definition

- P0: trust, payment safety, lifecycle clarity, or major conversion blocker.
- P1: strong comparison and completion improvement.
- P2: retention, optimization, or advanced discovery.

## Discovery and Search

Current:

- Manual city, airport, and destination entry.
- No recent/popular choices or input suggestions.
- Flight supports one-way, adult, and child only.
- Hotel occupancy is aggregated rather than assigned per room.

Needed:

- P1 autocomplete, recent searches, popular destinations, airport codes/names.
- P1 round trip, infant, cabin, and optional flexible date.
- P0 per-room guest assignment and child ages when supplier rules require them.
- Clear validation beside the relevant field, not a generic failure after submit.

## Results and Comparison

Current:

- No editable search summary, result count, sorting, filtering, or active chips.
- No hotel map.
- Result cards expose only part of the decision information.
- Offer detail loading blocks navigation without a card-level loading state.

Needed:

- P0 summary/edit search, result count, actionable empty state.
- P0 scoped loading for the tapped result.
- P1 sort/filter state with reset and active chips.
- P1 richer cards using only normalized backend facts.
- P2 map/list mode.

## Details and Selection

Current:

- Rich provider data can render, but large generic maps are difficult to scan.
- No anchored sections, room comparison, fare comparison, or persistent selected
  option summary.

Needed:

- P1 structured sections and progressive disclosure.
- P1 policy summaries beside room/fare selection.
- P1 persistent selection and total.
- Never infer “free cancellation,” scarcity, discount, or baggage allowance.

## Traveler, Guest, and Contact

Current:

- Beneficiary is self or another name.
- `TravelTraveler` contains only name, passport, and nationality.
- No lead guest per room or passenger records.
- No notification-recipient confirmation.

Needed:

- P0 backend-driven traveler schema with localized validation.
- P0 per-passenger and per-room responsibility.
- P0 contact recipient and consent.
- P1 saved traveler CRUD after a supported contract exists.

## Review, Reservation, and Payment

Current:

- No progress stepper or dedicated final review.
- Reservation countdown exists.
- Expiry clears the reservation with weak explanation.
- Wallet shortage routing is functional.
- Generic boolean errors do not explain whether money was charged.

Needed:

- P0 Search → Selection → Travelers → Review → Payment step model.
- P0 final review of product, rules, names, contact, total, and wallet.
- P0 expiry screen with re-search/re-reserve action.
- P0 distinct failed-before-charge, processing, charged-pending, and confirmed
  states based on backend truth.
- Duplicate actions disabled with scoped progress and stable idempotency.

## Post-Purchase

Current:

- QR and detailed PDF are available in confirmation and purchased pages.
- Orders are a flat list with six local statuses.
- Unknown backend status becomes `completed`.

Needed:

- P0 safe raw status plus lifecycle timeline.
- P0 refresh/retry and “what happens next.”
- P1 tabs or filters for upcoming, pending, completed, cancelled/refunded.
- P1 search by reference and contextual support.
- P1 destination-use instructions for vouchers and eSIM.

## Cancellation and Refund

Current:

- User chooses a reason and sends a request.
- Copy warns that review and penalties may apply.
- Eligibility, penalty, amount, deadline, SLA, and stages are absent.

Needed:

- P0 eligibility/estimate endpoint before confirmation.
- P0 authoritative penalty, net amount, currency, expiry, and required consent.
- P0 submission receipt with request ID.
- P1 refund timeline, latest update, support route, and wallet settlement state.

## Communication Quality

Common deficiencies:

- Silent catches in controller methods.
- Raw exception strings can reach UI.
- Hard-coded English in voucher/refund code.
- Loading is often global rather than scoped.
- Empty states do not preserve criteria or suggest a next action.

Every state should answer:

1. What is happening?
2. Did availability, reservation, or money change?
3. What happens next and approximately when, if the backend says so?
4. What can the user do now?
5. How can support identify this transaction?

## Accessibility, Localization, and Web

- Replace hard-coded strings with ARB keys.
- Measure untranslated keys; generated locale files existing is not proof of
  translated content.
- Preserve explicit LTR for references, codes, times, and monetary values.
- Verify keyboard navigation, focus, narrow layouts, text scaling, semantics,
  contrast, and screen-reader labels.
- Web smoke tests must cover CORS, MIME types, direct route load, refresh,
  Firefox, and Chromium.

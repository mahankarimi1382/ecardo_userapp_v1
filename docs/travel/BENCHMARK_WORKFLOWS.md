# Travel Workflow Benchmark

Updated: August 3, 2026.

## Sources Reviewed

- `https://www.snapptrip.com/`
- `https://www.snapptrip.com/flights`
- `https://www.flytoday.ir/flight`
- `https://www.flytoday.ir/hotel`
- Flytoday public application description and public support material.

The benchmark covers public discovery, search, comparison, detail, passenger or
guest review, payment review, purchase recovery, and cancellation/refund
communication. Authenticated supplier operations and payment completion were
not treated as facts unless supported by eCardo's backend contract.

## Shared Workflow Pattern

1. Explain what the user must choose before search.
2. Preserve and expose editable criteria.
3. Show result count, sorting, filtering, and comparable decision facts.
4. Put room/fare rules next to the selection they affect.
5. Collect or confirm the responsible traveler/guest and notification contact.
6. Provide a final review of product, people, rules, total, and payment method.
7. Distinguish reservation, payment received, supplier confirmation, and issued
   artifact states.
8. Keep reference, ticket/voucher, purchase history, refresh, support, and
   cancellation recovery accessible after payment.

## Implemented Adaptation

- Search, compare, review, and pay journey guidance across hotel and flight.
- Recent hotel and flight searches stored locally from real successful searches.
- Up to three backend offers can be compared without inferred facts.
- Backend localized maps are selected using the active app language.
- Hotel room, property, flight, fare, baggage, policy, and price rendering uses
  only normalized backend payloads.
- Existing staged checkout, review acknowledgement, stable idempotency,
  lifecycle status, issued-artifact gating, booking refresh, and refund request
  behavior remain in the same journey.

## Intentionally Not Fabricated

- Destination suggestions without a suggestions endpoint.
- Price calendars, price alerts, sold-out notifications, or auto-reservation
  without authoritative contracts and consent.
- Passenger/passport schemas, cancellation estimates, refund timelines, review
  summaries, map inventory, or eSIM installation artifacts without backend data.
- Discounts, free cancellation, installments, insurance, transport, scarcity,
  refund timing, or supplier guarantees not returned by eCardo.

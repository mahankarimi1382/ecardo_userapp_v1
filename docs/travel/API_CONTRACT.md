# Travel API Contract

Updated: July 28, 2026.

## Boundary and Authority

Flutter calls only:

```text
https://trip.ecardo.ir/api/v1
```

Supplier URLs, credentials, payloads, and internal cost fields stay behind the
gateway. The backend is authoritative for availability, price, currency,
reservation deadline, rules, cancellation, refunds, and lifecycle status.

## Common Behavior

Expected success envelope:

```json
{"status":"success","data":{},"meta":{}}
```

Expected error envelope:

```json
{
  "status": "error",
  "error": {"code": "BUSINESS_RULE_FAILED", "message": "Safe user message"},
  "request_id": "support-reference"
}
```

Locale-aware calls send:

```text
locale=en
X-Locale: en
```

Authenticated calls send:

```text
Authorization: Bearer <travel-token>
```

State-changing purchase/refund calls send a stable:

```text
Idempotency-Key: <client-generated-key>
```

## Deployed Endpoints

### Bootstrap

`GET /travel/bootstrap`

Returns locale, currency, service presentation, `data_mode`, and capabilities.
On July 28, 2026, hotel and flight were catalog services with search,
offer-details, and catalog-checkout capability.

### Discovery

- `POST /travel/services/{service}/search`
- `GET /travel/services/{service}/offers/{offerId}`

Hotel search currently sends city, check-in, check-out, rooms, adults, and
children. Flight sends origin, destination, departure date, adults, and
children. Empty flight criteria are used for upcoming discovery.

Offer responses are normalized into product, attributes, policies, actions,
pricing components, total, rating, features, and metadata.

### Authentication

`POST /auth/exchange`

Request:

```json
{"source_token":"<main-ecardo-token>"}
```

The returned token is cached until shortly before expiry.

### Reservation

- `POST /catalog-orders`
- `POST /offer-orders`

Catalog requests include service, offer, dates when applicable, room and guest
counts, selected room, and beneficiary metadata. Live offer orders use the
normalized offer ID and booking criteria.

Flutter rejects the reservation if returned `payable_amount` or `currency`
differs from the displayed expected total. It uses backend `payment_due_at`;
if omitted, current code applies a 15-minute fallback.

### Payment

`POST /orders/{order}/pay`

The current client accepts:

- `paid_pending_admin_approval`
- `booked`
- `voucher_generated`
- `completed`

This must evolve into a richer lifecycle. Wallet capture does not always mean
the supplier artifact has been issued. Required distinctions include payment
received, supplier confirmation, issued, inventory lost with funds safe or
restored, failed, cancelled, and refunded.

### Orders

- `GET /orders`
- `GET /orders/{order}`

The app maps normalized order data into `TravelOrder`. If the detail request
after payment fails, it returns a minimal local fallback containing the payment
response. UI must label this as pending/unverified rather than inventing detail.

### Refunds

- `POST /orders/{order}/refunds`
- `GET /refunds/{refund}`

Flutter submits a reason, optional note, and idempotency key. The existing UI
does not call the refund-detail route or expose an authoritative estimate.

## Current Status Mapping Risk

Current local statuses:

```text
pending, confirmed, active, completed, refunded, failed
```

Multiple raw states map to `pending`. Unknown raw values map to `completed`,
which can falsely imply success. Preserve `raw_status` and introduce an
`unknown` or backend-driven presentation before expanding workflows.

## Proposed Contracts

These are not deployed contracts until backend route inspection confirms them.

### Suggestions

`GET /travel/services/{service}/suggestions?q=&locale=`

Return stable ID, primary/secondary label, code, type, country, and optional
coordinates. Include recent/popular groups separately from search matches.

### Structured Travelers and Contacts

- `GET|POST /travelers`
- `PATCH|DELETE /travelers/{traveler}`

Passenger/guest fields must be driven by product, route, nationality, and
supplier needs. Do not hardcode passport-only rules.

Reservation should persist:

- Passenger or guest assignment.
- Lead guest per room.
- Buyer and notification recipient.
- Contact used to authorize later changes/cancellation.
- Explicit rule acknowledgement.
- Special requests marked as requests, never guarantees.

### Cancellation Eligibility and Estimate

`GET /orders/{order}/cancellation-eligibility`

Recommended response:

```json
{
  "eligible": true,
  "expires_at": "2026-08-01T10:00:00Z",
  "penalty": {"amount": "100", "currency": "USD"},
  "refundable": {"amount": "400", "currency": "USD"},
  "refund_destination": "original_wallet",
  "requires_supplier_review": true,
  "estimated_completion_at": null,
  "policy_summary": "backend-authoritative localized text",
  "version": "eligibility-version"
}
```

Refund submission must include the eligibility version or quote ID so changed
rules cannot be silently accepted.

### Timeline and Recovery

- `GET /orders/{order}/events`
- `POST /travel/order-recovery`

Events should contain stable type, timestamp, localized-safe presentation,
support reference, and actions. Recovery may accept booking reference plus a
verified contact challenge. It must not expose a booking from reference alone.

### Sold-Out Recovery

Future contracts may support notification when inventory returns or alternative
dates/offers. Automatic purchase requires explicit price ceiling, expiry,
consent, idempotency, wallet safeguards, and cancellation behavior; do not
implement it as a client-only feature.

## Parsing Rules

- Treat absent optional fields as absent, not as false facts.
- Parse strings/numbers defensively.
- Ignore unknown optional fields.
- Keep raw status and request/support IDs.
- Never show supplier HTML without sanitizing/normalizing it server-side.
- Never send passport, phone, or personal data in analytics.

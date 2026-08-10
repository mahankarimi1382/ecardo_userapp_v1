# SnappTrip Workflow Research

Research date: July 28, 2026.

## Method and Limits

The public SnappTrip website was inspected as a product benchmark, including:

- `https://www.snapptrip.com/`
- `https://www.snapptrip.com/flights`
- Public hotel result and hotel detail pages.
- `https://www.snapptrip.com/tracking`
- `https://www.snapptrip.com/policy`

This document distinguishes visible public behavior from proposed eCardo work.
Authenticated payment completion, supplier-side operations, and every inventory
variant could not be independently verified. SnappTrip can change after the
research date.

The goal is to learn interaction patterns, not copy branding or design.

## Hotel Journey Observed

### Discovery

- City or hotel autocomplete reduces typing and invalid destinations.
- Popular destinations appear before or during search.
- A date-range calendar keeps check-in/check-out in one task and requires
  explicit confirmation.
- Results preserve and expose an editable summary of city, dates, and occupancy.

### Results

- Cards communicate image, property type/stars, location, total or discounted
  price, guest rating/review count, and policy/deal chips.
- Users can search by hotel name.
- Filters cover total stay price, discounted inventory, availability, free
  cancellation, stars, property type, facilities, and guest score.
- Sorting and mobile filter/sort sheets keep comparison accessible.
- A map action shows geographic placement and visible price markers.

### Detail and Selection

- Long details are divided into overview, amenities, rooms, location, rules,
  and reviews.
- Progressive disclosure avoids showing every amenity at once.
- Room options have their own price and cancellation terms.
- The CTA reflects selected room quantity/state.
- Review content summarizes recurring strengths and weaknesses.

### Checkout

- Guest responsibility is explicit, including a lead guest for each room.
- A dedicated review step precedes payment.
- Voucher access is immediate after successful payment.

## Flight Journey Observed

### Search and Comparison

- One-way and round-trip are explicit.
- Passenger groups include adults, children, and infants.
- A price calendar highlights cheaper dates.
- Results default toward price comparison and also support duration and
  departure-time sorting.
- Filters include departure time, airline, duration, price, flight type, and
  cabin class.
- Public guidance describes sold-out notification and automatic-reservation
  options, but availability may depend on route or experiment. Automatic buying
  is not suitable for eCardo without price ceilings, consent, and wallet safety.

### Detail and Checkout

- Before selection, users can inspect baggage, flight number, airports,
  terminals, duration, fare class, charter/system distinction, and
  refundability/penalties.
- Passenger data is collected per traveler.
- The user chooses or confirms the notification recipient.
- A final review precedes add-ons, promotion, and payment.
- Successful purchase produces immediate ticket access and a recoverable link.
- Public marketing also mentions cancellation protection, installments,
  insurance, airport transport, coupons, and loyalty benefits. These are
  business promises, not generic UX patterns, and must not appear in eCardo
  unless operationally supported.

## Tracking and Recovery Observed

The public tracking page supports product type, tracking code, and mobile
number. It can recover voucher details and expose cancellation. Invalid input
receives explicit feedback.

eCardo normally has authenticated users, but the underlying pattern is useful:
allow users to recover a purchase by reference and verified contact when the
normal list, session, or device history is insufficient.

The benchmark also reinforces that payment received and ticket issued can be
different states. eCardo should explicitly communicate supplier confirmation,
inventory loss, and whether funds are held, restored, or refunded.

## Cancellation Patterns Observed

- Hotel rules depend on property, dates, and deadline.
- Flight penalties depend on airline, fare/class, and charter/system rules.
- Some policy text describes supplier review and processing windows.

These are examples of good rule communication, not values eCardo may promise.
eCardo must render only backend-authoritative eligibility, deadlines, penalty,
amount, reason, and timing.

## Adaptation Matrix

| Pattern | Current eCardo | Proposed adaptation | Dependency | Priority |
| --- | --- | --- | --- | --- |
| Autocomplete/popular destinations | Manual text | Suggestions, recent and popular values | Suggestion API | P1 |
| Editable search summary | Missing | Sticky/compact summary and edit action | Flutter | P0 |
| Result count/sort/filter | Missing | Count, basic sort, active chips, reset | Search metadata/API | P0/P1 |
| Hotel map | Coordinates only | Map/list switch with price pins | Map SDK + geo data | P2 |
| Structured detail sections | Partial | Anchors and progressive disclosure | Flutter | P1 |
| Room/fare comparison | Single selection flow | Comparable options and persistent summary | Normalized offers | P1 |
| Full traveler forms | Name beneficiary only | Passenger/guest schema and validation | Backend | P0 |
| Notification recipient | Missing | Confirm email/mobile recipient | Backend | P0 |
| Final review | Missing | Rules, travelers, total, wallet, consent | Flutter/API | P0 |
| Immediate artifact | QR/PDF exists | Clear pending/confirmed behavior and recovery | Order lifecycle | P0 |
| Tracking by reference | List only | Authenticated recovery, optional verified fallback | Backend | P1 |
| Cancellation estimate | Generic request | Eligibility, penalty, net refund, deadline | Backend | P0 |
| Refund progress | Pending status only | Timeline with updates and support path | Events API | P0/P1 |
| Paid but not issued | Collapsed pending | Explicit funds-safe and supplier-confirming states | State machine | P0 |
| Sold-out recovery | Upcoming fallback | Alternatives and opt-in notification | Backend notification | P1 |
| Reviews | Rating only | Review summaries and verified reviews | Content backend | P2 |

## Principles to Carry Forward

1. Preserve the user's search context throughout the journey.
2. Explain why an option is suitable, not only what it costs.
3. Put rules next to the decision they affect.
4. Show scoped progress during network work.
5. Provide a recovery action for every empty, failed, expired, and pending state.
6. Require a final review before irreversible payment.
7. Keep artifacts and support accessible after purchase.

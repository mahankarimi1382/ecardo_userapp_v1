# Current Travel Workflows

Updated: July 28, 2026.

## Shared Runtime

`TravelBinding` registers `TravelController`, which calls `TravelRepository`.
The runtime implementation is `TravelApiRepository`. Most feature screens use
`Get.to`, while Dashboard, History, and Account are named Travel root routes.

The main-app authentication token is exchanged for a short-lived Travel token.
Search and purchase requests are sent only to `trip.ecardo.ir`.

## Hotel

1. `HotelSearchScreen` collects city, check-in, check-out, room count, adults,
   and children.
2. `TravelController.searchHotels` calls
   `POST /travel/services/hotel/search`.
3. `HotelResultsScreen` renders the returned catalog offers.
4. Tapping an offer calls
   `GET /travel/services/hotel/offers/{offerId}` before opening details.
5. `HotelDetailsScreen` renders gallery, description, amenities, rooms,
   pricing, policies, coordinates, and provider-neutral attributes when present.
6. The user selects a room and beneficiary, then opens
   `TravelCheckoutScreen`.
7. Checkout calls `POST /catalog-orders` or `POST /offer-orders`.
8. The backend returns the authoritative amount and `payment_due_at`.
9. Flutter shows the reservation countdown and matching-currency wallet.
10. `POST /orders/{order}/pay` captures wallet funds.
11. Confirmation and purchased pages expose QR, detailed voucher, PDF, and
    cancellation/refund request where status permits.

Current recovery: search errors preserve previous successful results and expose
safe retry/edit actions; detail loading is scoped to the selected offer and
falls back to its summary; expired reservations require an explicit restart;
reservation and payment retries preserve stable idempotency keys.

## Flight

1. `FlightSearchScreen` collects one-way/round-trip, origin, destination,
   departure/return dates, cabin, adults, children, and infants. It also loads
   upcoming flights.
2. Search calls `POST /travel/services/flight/search`.
3. `FlightResultsScreen` displays exact results or upcoming-flight fallback.
4. Tapping a result loads the normalized offer details. A round trip preserves
   the outbound selection and repeats comparison for the reversed return route.
5. `FlightDetailsScreen` renders airline, flight number, airports, times,
   cabin, baggage, fare components, segments, and cancellation data when
   present.
6. Checkout collects every passenger's identity/document fields, confirms a
   booking notification phone or email, reviews both legs and the combined
   backend-authoritative total, then reserves and pays through the shared wallet
   flow.
7. Confirmation and purchased pages expose QR, ticket/voucher PDF, and
   refund request.

Current limitations: no flexible-date price calendar or backend airport
autocomplete; reusable saved passenger CRUD is not yet connected.

## eSIM

1. `EsimIntroScreen` explains the service.
2. `EsimPackagesScreen` accepts a destination code and calls the normalized
   service search.
3. The user selects a package and uses the shared checkout.
4. The order page displays generic activation information.

Current limitations: no install QR, SM-DP+ address, activation code, compatible
device check, installation status, or activation lifecycle.

## Wallet Shortage

1. Checkout selects a wallet matching the offer currency.
2. If sufficient, the user can pay.
3. If insufficient, the UI offers Add Money and Exchange.
4. Exchange preselects the target currency and suggests a funded source wallet.
5. Returning to checkout refreshes wallets and user state.
6. If the required wallet does not exist, the user is sent to Create Wallet.

## Purchased Bookings

1. `TravelOrdersScreen` lists orders, optionally filtered by product type.
2. Tapping an order opens `TravelConfirmationScreen`.
3. The screen presents state, reference, product details, total, QR, PDF, and
   refund/cancel action when allowed by the current local status.
4. Refund submission calls `POST /orders/{order}/refunds`, then reloads the
   order.

The list is grouped by lifecycle, searchable, refreshable, and records the last
successful refresh. Authoritative event timelines, refund estimates, and refund
progress stages remain backend-dependent.

## State and Recovery Risks

- Backend events are not yet available for a timestamped lifecycle timeline.
- Unknown backend states remain visible and cannot unlock confirmed actions.
- Order loading failures preserve the last successful list and show safe retry.
- Upcoming-flight and offer-detail failures use safe fallback behavior.
- Reservation and payment failures expose operation-scoped safe recovery copy.
- An omitted `payment_due_at` receives a client fallback of 15 minutes.
- Paid-order detail reload failure returns a minimal local fallback order.
- Saved traveler and combined activity repository methods throw
  `UnsupportedError`.

# Normalized Travel API Contract

## Public Boundary

Flutter uses the first-party eCardo Travel gateway:

```text
https://trip.ecardo.ir/api/v1
```

`trip.ecardo.ir` is the public Cloudflare edge boundary. The private origin, provider URLs, provider credentials, retries, and provider-specific response formats must never be embedded in Flutter.

## Standard Envelope

Successful responses use:

```json
{
  "status": "success",
  "data": {},
  "meta": {}
}
```

Errors use:

```json
{
  "status": "error",
  "error": {
    "code": "BUSINESS_RULE_FAILED",
    "message": "The offer is no longer purchasable."
  },
  "request_id": null
}
```

Flutter maps these normalized eCardo responses into Travel domain models. Supplier response formats remain behind the gateway.

The current hotel design is aligned to the deployed Tehran catalog and sends the normalized city code `THR`. A future destination selector should pass the user's selected normalized city code.

## Deployed Contract

### Authentication

`POST /auth/exchange`

Exchanges the authenticated main eCardo token for a short-lived Travel token.

```json
{
  "source_token": "<main-ecardo-token>"
}
```

Authenticated Travel requests use:

```text
Authorization: Bearer <travel-token>
```

### Hotel Catalog

- `GET /hotels?locale=en&city=THR`
- `GET /hotels/{hotel}?locale=en`
- `GET /hotel-offers?locale=en&city=THR`
- `GET /hotel-offers/{offer}?locale=en`

Normalized hotel offer:

```json
{
  "id": "offer_public_id",
  "code": "HOTEL-OFFER-001",
  "version": 1,
  "hotel": {
    "id": "hotel_public_id",
    "name": "Hotel name",
    "city": "Tehran",
    "country_code": "IR",
    "star_rating": 5,
    "amenities": ["wifi", "breakfast"]
  },
  "room_name": "Deluxe room",
  "board_type": "breakfast",
  "price": {
    "amount": "4800000",
    "currency": "IRR"
  },
  "inclusions": ["Breakfast"],
  "restrictions": [],
  "cancellation_policy": {},
  "requires_admin_confirmation": true,
  "valid_until": "2026-08-31T23:59:59Z",
  "catalog_revision": "catalog-revision",
  "is_demo": false
}
```

Supplier cost fields and provider credentials are intentionally absent.

### Traveler Profile

- `GET /me/traveler-profile`
- `PUT /me/traveler-profile`

The deployed endpoint represents the authenticated user's primary traveler profile. The redesigned saved-traveler list requires a future multi-traveler contract.

### Hotel Booking

`POST /offer-orders`

Required header:

```text
Idempotency-Key: <stable-client-key>
```

Request:

```json
{
  "offer_id": "offer_public_id",
  "check_in_date": "2026-08-12",
  "check_out_date": "2026-08-14",
  "room_count": 1,
  "adult_count": 2,
  "child_count": 1
}
```

Response includes the authoritative payable amount:

```json
{
  "id": "order_public_id",
  "order_number": "ECT-2026-0001",
  "status": "pending_payment",
  "payable_amount": "4800000",
  "currency": "IRR",
  "approval_status": "pending"
}
```

Flutter sends search criteria but does not calculate or override the authoritative total.

### Wallet Payment

`POST /orders/{order}/pay`

Required header:

```text
Idempotency-Key: <stable-payment-key>
```

The backend captures funds from the main eCardo wallet transactionally. Repeated idempotency keys must return the existing result and must never debit the wallet twice.

Current successful payment state:

```json
{
  "id": "order_public_id",
  "status": "paid_pending_admin_approval",
  "paid_amount": "4800000",
  "currency": "IRR"
}
```

This is not yet a confirmed voucher. Flutter displays a pending-confirmation state until the authorized supplier purchase is confirmed and a voucher is issued.

### Orders

- `GET /orders`
- `GET /orders/{order}`

Orders may include quote, request, state transition, booking, and voucher relationships. Flutter maps them into normalized order presentation and does not inspect provider data.

### Refunds

- `POST /orders/{order}/refunds`
- `GET /refunds/{refund}`

These routes are deployed but are not yet exposed in the redesigned Flutter UI.

## Deployed Operator Flow

The following routes are backend/admin-only and must not be called by the customer Flutter app:

- `GET /operator/orders/pending-approval`
- `POST /operator/orders/{order}/confirm-booking`
- `POST /operator/orders/{order}/reject`
- `POST /operator/bookings/{booking}/voucher`

## Gateway Expansion Required

The following normalized customer capabilities are not present in the inspected deployed contract and remain mock-backed in Flutter:

- Flight search, offers, booking, ticketing, and order artifacts
- eSIM destinations, packages, purchase, installation, and activation
- Multiple saved travelers
- Combined Travel and main-wallet activity history
- Redesigned bootstrap/configuration and backend-controlled content
- General offer revalidation endpoint

Recommended future routes:

- `GET /travel/bootstrap`
- `POST /travel/services/{service}/search`
- `GET /travel/services/{service}/offers/{offer}`
- `POST /travel/services/{service}/offers/{offer}/revalidate`
- `GET|POST|PATCH /travelers`
- `GET /activity`

These routes must continue returning normalized eCardo schemas regardless of the selected downstream provider.

## Repository Mapping

- `TravelApiRepository`: deployed `trip.ecardo.ir` hotel catalog, token exchange, order history, hotel booking, and wallet payment.
- `MockTravelRepository`: flight, eSIM, saved travelers, and combined activity until normalized gateway endpoints are exposed.
- `HybridTravelRepository`: selects the live or mock implementation by capability.

Live hotel catalog and order history never display fake fallback records. Booking creation verifies the returned authoritative amount and currency before wallet capture. Booking creation and wallet payment never fall back to a mock success.

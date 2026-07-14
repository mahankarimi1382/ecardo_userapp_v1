# Task: Add Backend-Driven IRR Virtual Cards to the Main Flutter User App

You are working in the actual/main Flutter user application repository for `ecardo.ir`.

Implement the IRR virtual-card UI and API integration described below. A reference patch named `ecardo-irr-virtual-card.patch` may be available, but it was generated from an older Qunzo user-app source. Do not blindly overwrite newer code. Inspect the current repository, adapt the implementation to its architecture, preserve existing card providers, and resolve differences cleanly.

## Backend State

The production backend already supports the following authenticated user endpoints. The app's existing API client may already prepend `/api`; endpoint constants should follow the repository's established convention.

- `GET /user/card-products`
- `GET /user/card-products/{product}`
- `POST /user/card-orders`
- `GET /user/card-orders/{order}`
- `POST /user/cards/{card}/irr-topup`
- Existing routes remain available:
  - `GET /user/cards`
  - `GET /user/cards/{card}`
  - `POST /user/cards/balance/topup/{id}`
  - `POST /user/cards/update-status/{card_id}`
  - `GET /user/cards/transactions/{card_id}`

The IRR product is intentionally disabled in production until configured by an administrator, so `GET /user/card-products` may legitimately return an empty data list.

## Product Contract

Each card product can include:

```json
{
  "id": 1,
  "name": "Ecardo IRR Card",
  "code": "ecardo-irr",
  "currency": "IRR",
  "funding_mode": "both",
  "minimum_initial_load": 1000000,
  "maximum_initial_load": 4500000000,
  "minimum_topup": 1000000,
  "maximum_topup": 4500000000,
  "creation_fee": 0,
  "topup_fee_type": "percentage",
  "topup_fee": "0",
  "physical_card_fee": 0,
  "maximum_cards_per_user": 1,
  "kyc_required": true,
  "image": null,
  "terms": "...",
  "maintenance_message": null,
  "application_fields": [
    {
      "name": "national_id",
      "label": "National ID",
      "type": "text",
      "required": false
    }
  ],
  "gateways": [
    {
      "id": 3,
      "name": "MELLI",
      "gateway_code": "melli",
      "charge": "1.00000000",
      "charge_type": "percentage",
      "minimum_deposit": "1000000.00000000",
      "maximum_deposit": "4500000000.00000000",
      "currency": "IRR"
    }
  ],
  "capabilities": {
    "can_create_virtual": true,
    "can_request_physical": false,
    "can_fund_from_irr_wallet": true,
    "can_fund_from_gateway": true
  }
}
```

Treat numeric JSON values defensively because Laravel may serialize decimals as either strings or numbers.

## Create Order

Send `POST /user/card-orders` with:

```json
{
  "card_product_id": 1,
  "funding_source": "irr_wallet",
  "wallet_id": 123,
  "gateway_method_id": null,
  "amount": 1000000,
  "request_physical": false,
  "name": "User Name",
  "email": "user@example.com",
  "phone_number": "...",
  "address": "...",
  "country": "...",
  "city": "...",
  "state": "...",
  "postal_code": "...",
  "application_data": {
    "national_id": "..."
  }
}
```

Rules:

- `funding_source` is `irr_wallet` or `gateway`.
- For `irr_wallet`, send an IRR wallet belonging to the current user.
- For `gateway`, send a gateway ID returned by the selected product.
- Send `amount` as an integer number of Iranian rials, not tomans.
- Render `application_fields` dynamically. Support at least `text`, `number`, `date`, and `boolean`.
- Only show the physical-card option when `can_request_physical` is true.

The response includes:

```json
{
  "data": {
    "order": {
      "id": 1,
      "operation": "create",
      "status": "payment_pending",
      "requested_amount": 1000000,
      "fee_amount": 0,
      "payable_amount": 1000000,
      "currency": "IRR",
      "card_id": null,
      "transaction_reference": "TRX...",
      "failure_message": null
    },
    "redirect_url": "https://..."
  }
}
```

- Wallet-funded orders normally complete immediately and may return no redirect URL.
- Gateway-funded orders return `redirect_url`; open it using the app's existing payment WebView.
- After the WebView returns, refresh card and/or order data.
- Display pending, provisioning, active/completed, cancelled, and provisioning-failed states gracefully.

## Card Contract

Do not branch only on provider names such as Stripe or BSI. Prefer the generic backend contract:

```json
{
  "id": 10,
  "card_product_id": 1,
  "currency": "IRR",
  "provider": "licensed_issuer_placeholder",
  "display_number": null,
  "amount": "1000000",
  "display": {
    "title": "Ecardo IRR Card",
    "subtitle": "Internal IRR prepaid profile; licensed issuer pending.",
    "balance_label": "Balance",
    "currency_decimals": 0,
    "show_pan": false,
    "show_expiry": false,
    "show_cvc": false
  },
  "capabilities": {
    "can_topup": true,
    "can_freeze": false,
    "can_view_transactions": false,
    "can_request_physical": false,
    "can_reveal_pan": false
  },
  "funding": {
    "mode": "both",
    "default_source": "irr_wallet",
    "default_gateway_method_id": 3,
    "gateways": []
  },
  "actions": {
    "topup_endpoint": "/api/user/cards/10/irr-topup",
    "status_endpoint": "/api/user/cards/update-status/internal-1",
    "transactions_endpoint": "/api/user/cards/transactions/internal-1"
  }
}
```

Requirements:

- Add nullable `display`, `capabilities`, `funding`, and `actions` models.
- Use generic rendering when these fields are present.
- Hide PAN, CVC, expiry, freeze, transaction history, and physical-card actions according to capabilities.
- Never invent or locally derive a fake card number, CVC, or expiry.
- Keep existing Stripe/BSI behavior working for legacy cards.
- Format IRR with zero fractional digits.
- Use backend-provided action endpoints where practical, but normalize `/api` carefully so it is not duplicated by the API client's base URL.

## IRR Top-Up

Send `POST /user/cards/{card}/irr-topup`:

```json
{
  "funding_source": "irr_wallet",
  "wallet_id": 123,
  "gateway_method_id": null,
  "amount": 1000000
}
```

Use the same wallet/gateway selection and WebView behavior as card creation.

## UX and Compatibility

- Preserve the existing virtual-card creation flow for legacy providers.
- Add an IRR product section only when products are returned by the backend.
- If no IRR products are returned, the current legacy experience must remain unchanged.
- Reuse the app's current wallet endpoint/model and filter wallets by currency code `IRR`.
- Follow the current repository's state-management, networking, localization, theme, and widget conventions.
- Avoid hard-coded gateway names and future issuer names.
- Keep backend-driven fields/capabilities so future issuer changes generally require backend changes only.
- Add user-friendly validation and loading/error states.

## Reference Files

The older reference implementation changed these paths:

- `lib/src/network/api/api_path.dart`
- `lib/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart`
- `lib/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart`
- `lib/src/presentation/screens/virtual_card/model/card_product_model.dart`
- `lib/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart`
- `lib/src/presentation/screens/virtual_card/model/virtual_cards_model.dart`
- `lib/src/presentation/screens/virtual_card/view/create_virtual_card/create_virtual_card.dart`
- `lib/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/create_new_card_holder_section.dart`
- `lib/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/irr_card_order_section.dart`
- `lib/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart`
- `lib/src/presentation/screens/virtual_card/view/virtual_card_details/virtual_card_details.dart`
- `lib/src/presentation/screens/virtual_card/view/virtual_card_screen.dart`

The main repository may organize these concerns differently. Adapt rather than forcing these exact paths.

## Validation

After implementation:

1. Run the configured Dart formatter on changed files.
2. Run `flutter analyze`.
3. Run relevant Flutter tests if present.
4. Build the intended target, preferably a non-release build first.
5. Report:
   - Changed files.
   - Any contract assumptions.
   - Analyzer/test/build results.
   - Whether the reference patch applied directly or required adaptation.

Do not change backend code as part of this task.

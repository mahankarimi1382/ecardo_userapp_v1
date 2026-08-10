# Travel Decisions

Updated: July 28, 2026.

## D-001 — First-Party Gateway

Flutter calls only `trip.ecardo.ir`. Provider integration and normalization stay
server-side.

## D-002 — Backend Authority

Price, availability, rules, deadlines, cancellation, refunds, scarcity, and
status come from the backend. The client does not infer or market them.

## D-003 — Reserve Then Pay

Catalog checkout creates a timed order, verifies authoritative amount/currency,
then pays that order. Payment must be idempotent.

## D-004 — Payment Is Not Issuance

Wallet capture and supplier artifact issuance are separate lifecycle events.
The UI must not show a confirmed ticket/voucher until backend status supports it.

## D-005 — Full App Web Preview

The preview is a copy of the current app, not a separate minimal Flutter
product. Android-authoritative changes live in `/root/ecardo_userapp_v1`.

## D-006 — Conservative Web Debugging

Experimental web hot reload is disabled when the injected DWDS client prevents
startup. A stable preview is more valuable than debugging features that blank
the app.

## D-007 — Local Web Resources

Use local Flutter web resources when external CanvasKit/CDN speed or access is
unreliable.

## D-008 — Web-Safe Platform Initialization

Unsupported Firebase messaging/local-notification initialization is skipped on
web rather than allowed to crash startup.

## D-009 — Honest Artifacts

QR/PDF vouchers may contain only known eCardo/backend product and order data.
Missing supplier facts are omitted.

## D-010 — Benchmark Principles, Not Cloning

SnappTrip research informs communication, comparison, review, recovery, and
lifecycle patterns. eCardo does not copy its branding, text, or proprietary
visual design.

## D-011 — Communication Before Expansion

Status safety, errors, expiry, final review, and refund clarity precede advanced
filters, maps, loyalty, alerts, or promotional features.

## D-012 — Contact Is Operational Data

The notification recipient and contact authorized for later changes must be
explicit and persisted by the backend, subject to privacy and security rules.

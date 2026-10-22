# سیستم طراحی هدف eCardo

## قانون صفر
منبع اصلی tokenها و کامپوننت‌های فعلی را پیدا کنید. یک design system جدید از کنار پروژه نسازید؛ ابتدا موارد موجود را audit کنید و به‌صورت تدریجی کامل کنید.

## لایه‌ها
1. Foundation: semantic color, type scale, spacing, radius, elevation, stroke, icon size, breakpoints, motion, focus ring.
2. Components: button, icon button, amount field, text field, selection field, currency/network picker, fee row, status badge, receipt row, transaction tile, card, balance hero, list skeleton, empty/error/offline state, dialog/bottom sheet, navigation.
3. Patterns: auth/OTP, transaction review, result/reconciliation, account switch, provider eligibility, card creation, QR receive, crypto network selection, KYC, support.
4. Templates: dashboard, list+filter, detail, form, review, receipt, settings, support, service module.
5. Content: vocabulary, errors, fees, security warnings, loading/retry copy and localization rules.

## Design tokens required
- semantic colors: surface, onSurface, primary, onPrimary, success, warning, danger, info, border, focus, disabled.
- typography tokens with explicit scale; honor TextScaler.
- spacing scale and screen edge/safe area rules.
- shape/radius and elevation scales.
- motion durations/easing, reduced-motion behavior.
- component density/breakpoint rules.

## Required component states
Default, pressed, focused, disabled, loading, error, success, pending, offline, stale, permission denied, dark, RTL, large text, reduced motion.

## Financial component contracts
- `MoneyAmount`: amount as integer minor units/Decimal + currency precision, not `double` source-of-truth.
- `FeeBreakdown`: principal, platform/provider/network fee, FX spread, tax where applicable, total debit, receiver amount.
- `TransactionStatus`: draft, awaiting_auth, submitted, pending, confirmed, failed, reversed, unknown/reconciling.
- `ProviderAvailability`: availability, region/currency support, limits, maintenance and backend reason code.
- `CryptoAddress`: address, chain ID/network, asset/token contract, validity, assigned wallet ID, expiry and server-issued policy. No fallback address.

## Merge rules
هر مؤلفهٔ جدید باید API، examples، semantics، RTL, theme states، tests و owner داشته باشد. تغییر token باید screenshot diff و migration plan داشته باشد.

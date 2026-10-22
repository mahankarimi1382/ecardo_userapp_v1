# معماری اطلاعات، صفحات و مشخصات UX

## حوزه‌های کامل صفحه
- Home/dashboard/quick actions/portfolio
- Accounts & wallets: list, detail, switch, create, close/archive, privacy hide balance
- Cards: list/detail/create/freeze/unfreeze/limits/funding/provider errors
- Money flows: local transfer, external transfer, P2P, request money, exchange, withdrawal, cash out, gift, merchant payment, bills
- Crypto: asset selector, network selector, receive address, QR, deposit status, withdrawal quote/review, confirmations, unsupported network
- Activity: transaction history, filters, detail, receipt, export/share, disputes/support
- Auth: welcome, login, registration, OTP, reset, passcode setup, passcode verify, biometric, session expiry, lockout
- KYC: eligibility, document capture/upload, review, rejected, retry, consent
- Service modules: mobile top-up, bills, travel/online services, invoice/payment where real features exist
- Profile/settings: identity, language, theme, notification, privacy, security, help, legal
- System states: loading, empty, stale, offline, permission denied, provider unavailable, maintenance, timeout, unknown transaction, reconciliation

## مشخصات اجباری برای هر route
`route_id, actual_route, screen_file, controller/state, service/API, entry conditions, user goal, primary action, secondary actions, money/data shown, states, errors, recovery, locale/theme variants, analytics (privacy safe), accessibility, tests, owner, screenshot refs`.

## الگوی Task Flow
1. Intent/selection
2. Input/validation
3. Server quote/eligibility when relevant
4. Review with destination/amount/fee/total/expiry
5. Explicit confirm and secure auth
6. Submission state
7. backend-confirmed result or pending/reconciling
8. receipt/history and safe support path

## قانون مهم
وجود صفحه یا دکمه به معنی تکمیل قابلیت نیست. هر CTA باید outcome واقعی، error handling و test داشته باشد؛ یا با دلیل واضح disabled شود.

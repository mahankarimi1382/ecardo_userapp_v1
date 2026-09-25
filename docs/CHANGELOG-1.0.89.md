## 1.0.89+89 — API alignment fixes (P2P PATCH + offline queue + bill type)

Critical fixes from audit of incomplete loops (app ↔ backend):

1. **NetworkService.patch()** added — real HTTP PATCH support.
2. **P2P updateAdStatus** and **updateOrderPaymentMethod** now use real `patch()` instead of `post` + `_method: 'PATCH'` (was causing 405 Method Not Allowed on server).
3. **OfflineRequestQueue whitelist** corrected to real endpoints (`/user/settings/profile`, `/setup-fcm`, `/change-language/`, …). Previous prefixes matched nothing, so offline POSTs never queued.
4. **Bill type cable → cables** — aligned with backend `BillType::Cables` enum (two call sites in CableController).
5. **Typo** `/tool_route` → `/toll_route`.
6. Removed dead code: `getTransactionsTypesAndStatusEndpoint`, `BaseRoute.setPasscode`.

Agent: server-user

## 1.0.90+90 — KYC block navigation fixes (whole-app block vs single feature)

Follow-up to the server-side fix in `ecardo-api` (`AccountStatusChecker` now
answers `403 + meta.error_code=KYC_LEVEL_REQUIRED` instead of wiping the
session and returning 401). The client already spoke that contract; these are
the two navigation defects that only became reachable once the server stopped
logging the user out.

1. **Primary CTA no longer routes through a guarded screen.** It was
   `Get.offAllNamed(BaseRoute.navigation)` followed by a 300 ms-delayed
   `Get.toNamed(BaseRoute.idVerification)`. That both depended on a screen the
   server blocks for an unverified user (so it immediately 403'd again) and
   raced with the home screen's own in-flight request. It is now a single
   `Get.offAllNamed(BaseRoute.idVerification)`.
2. **"I'll do it later" and the back arrow are hidden on an app-wide block.**
   `KycErrorHandler` now passes `block_type` in `Get.arguments`
   (`level_required` | `feature_required`), and `UpgradeRequiredScreen` drops
   the escape hatch for `level_required`. Previously the button did
   `Get.back()`, which returned the user to the home screen, whose dashboard
   request 403'd and pushed the same screen again — an endless bounce. A
   `KYC_FEATURE_REQUIRED` block (or a KYC-locked home tile) still keeps the
   button, because there the rest of the app does work.
3. **Current level no longer claims a never-verified user is level 1.** The
   fallback was `_currentLevel ?? 1` while the server sends `current_level=0`
   and the level table has a real `0 = Unverified` row. The fallback is now `0`.
4. `service_tiles.dart` passes `block_type: feature_required` explicitly so the
   tile gate's behaviour does not depend on the screen's default.

No new l10n keys: the checked-in `app_localizations*.dart` files are stale by
design and CI regenerates them with `flutter gen-l10n` (see `l10n.yaml`), so
only existing keys are used and all six locales stay covered.

Agent: server-user

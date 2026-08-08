# KYC Multi-Level Changes (v1.3 - multicountry)

## Changes to the Flutter user app

### New files
- `lib/src/common/model/kyc_badge_model.dart` — KycBadge and KycNextLevel models.
- `lib/src/common/widgets/kyc_rank_badge.dart` — KYC rank badge widget shown next to the notification bell (gray/green/gold + pulsing dot when pending/rejected).

### Modified files
- `lib/src/common/model/user_model.dart`
  - Added `kycLevel? int` and `kycBadge? KycBadge` fields to `UserData`.
  - Added `kyc_badge_model.dart` import.
  - Parses the new `kyc_level` and `kyc_badge` keys from `/auth/user/get` response.
- `lib/src/presentation/screens/home/view/sub_sections/tool_bar_section.dart`
  - Added the KYC rank badge next to the notification bell. Tapping it opens the KYC status screen.
- `lib/src/presentation/screens/home/view/sub_sections/other_services_section.dart`
  - Added feature gating via `kycBadge.features` list (server-driven). Features that the user is not allowed to use (e.g. withdraw/exchange/gift for level 1) show a localized toast ("تکمیل احراز هویت") and route the user to the KYC screen.
  - Each service tile now has an optional `feature` key (e.g. `"cashout"`, `"withdraw"`, `"exchange"`, `"transfer"`, `"gift"`, `"request_money"`, `"payment"`, `"add_money"`).
- `lib/l10n/app_fa.arb` / `app_en.arb`
  - Added new localization keys:
    - `otherServicesKycPending`
    - `otherServicesKycUpgradeRequired`
    - `kycRankBasic`, `kycRankStandard`, `kycRankMerchant`
    - `kycStatusNotSubmitted`, `kycStatusPending`, `kycStatusVerified`, `kycStatusFailed`

### Backend contract
The backend now returns extra fields in `/api/auth/user/get`:
- `kyc_level: int` (1=Basic, 2=Standard, 3=Merchant)
- `kyc_badge: object { level, name, color, icon, description, kyc_status, features[], badge_pulse, next_level }`

### Backward compatibility
- If `kyc_badge` is null (old backend versions, e.g. staging before deploy), the badge defaults to a gray "user" icon and no features are blocked.
- Existing screens and flows do not break because the new fields are optional.

### Behavior summary
| Level | Color | Icon | Allowed |
|---|---|---|---|
| 1 | gray | person | add_money, transfer, payment, request_money |
| 2 | green | verified_user | all except business |
| 3 | gold | business_center | all features ×5 limits |

When `kyc_status = pending` the badge shows an amber pulsing dot. When `kyc_status = failed` it shows a red pulsing dot.

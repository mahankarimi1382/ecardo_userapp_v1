# Local repository baseline

Captured UTC: `2026-10-23T18:13:53.556419+00:00`
Repository root: `C:\Users\Lenovo\Desktop\Ecardo\ecardo_userapp_v1`
Pubspec version: `1.0.181+181`

## Counts

- Files scanned: 4775
- Dart files: 921
- Test/integration Dart files: 109

## Git state

### Inside Work Tree

command: `git rev-parse --is-inside-work-tree`

- Available: `True`
- Exit code: `0`
```text
true

```

### Branch

command: `git branch --show-current`

- Available: `True`
- Exit code: `0`
```text
main

```

### Head Sha

command: `git rev-parse HEAD`

- Available: `True`
- Exit code: `0`
```text
dd11e5302e604f56fbafaba3da7faeeb23aa70a4

```

### Head Short

command: `git rev-parse --short=12 HEAD`

- Available: `True`
- Exit code: `0`
```text
dd11e5302e60

```

### Last Commit

command: `git log -1 --format=%H%n%cI%n%s`

- Available: `True`
- Exit code: `0`
```text
dd11e5302e604f56fbafaba3da7faeeb23aa70a4
2026-10-22T12:20:40+03:30
fix(ci): resolve widget test timeouts, layout overflows, and button unbounded constraints

```

### Status Short

command: `git status --short`

- Available: `True`
- Exit code: `0`
```text
M lib/src/app/bindings/app_bindings.dart
 M lib/src/app/constants/app_colors.dart
 M lib/src/app/routes/routes_handler.dart
 M lib/src/commercial/controllers/commercial_controller.dart
 M lib/src/commercial/screens/commercial_projects_screen.dart
 M lib/src/commercial/screens/equity_project_detail_screen.dart
 M lib/src/commercial/widgets/equity_project_card.dart
 M lib/src/commercial/widgets/investment_calculator_sheet.dart
 M lib/src/common/services/client_error_reporter.dart
 M lib/src/common/widgets/button/common_button.dart
 M lib/src/common/widgets/design_system/ecardo_balance_hero.dart
 M lib/src/helper/dynamic_decimals_helper.dart
 M lib/src/network/response/api_response.dart
 M lib/src/network/response/api_response_handler.dart
 M lib/src/network/response/status.dart
 M lib/src/network/service/network_service.dart
 M lib/src/presentation/screens/authentication/forgot_password/controller/forgot_password_pin_verification_controller.dart
 M lib/src/presentation/screens/authentication/forgot_password/view/sub_sections/forgot_password_pin_verification.dart
 M lib/src/presentation/screens/authentication/sign_in/controller/email_otp_login_controller.dart
 M lib/src/presentation/screens/authentication/sign_in/view/sub_sections/email_otp_login_screen.dart
 M lib/src/presentation/screens/authentication/sign_in/view/sub_sections/two_factor_auth.dart
 M lib/src/presentation/screens/authentication/sign_up/controller/verify_email_controller.dart
 M lib/src/presentation/screens/authentication/sign_up/view/set_passcode/set_passcode_screen.dart
 M lib/src/presentation/screens/authentication/sign_up/view/verify_email/verify_email_screen.dart
 M lib/src/presentation/screens/exchange/controller/exchange_controller.dart
 M lib/src/presentation/screens/exchange/service/exchange_validation_service.dart
 M lib/src/presentation/screens/exchange/view/exchange_screen.dart
 M lib/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart
 M lib/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart
 M lib/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart
 M lib/src/presentation/screens/exchange/widgets/exchange_swap_card.dart
 M lib/src/presentation/screens/gift_code/view/sub_sections/gift_redeem_section.dart
 M lib/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart
 M lib/src/presentation/screens/make_payment/controller/make_payment_controller.dart
 M lib/src/presentation/screens/make_payment/view/make_payment_history/make_payment_history.dart
 M lib/src/presentation/screens/make_payment/view/make_payment_screen.dart
 M lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_amount_step_section.dart
 M lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_review_step_section.dart
 M lib/src/presentation/screens/request_money/controller/request_money_controller.dart
 M lib/src/presentation/screens/request_money/view/received_request/received_request.dart
 M lib/src/presentation/screens/request_money/view/received_request/sub_sections/accept_request_dropdown.dart
 M lib/src/presentation/screens/request_money/view/received_request/sub_sections/received_request_details.dart
 M lib/src/presentation/screens/request_money/view/request_money_history/request_money_history.dart
 M lib/src/presentation/screens/request_money/view/request_money_history/sub_sections/request_money_history_details.dart
 M lib/src/presentation/screens/request_money/view/request_money_screen.dart
 M lib/src/presentation/screens/request_money/view/sub_sections/request_money_amount_step_section.dart
 M lib/src/presentation/screens/request_money/view/sub_sections/request_money_review_step_section.dart
 M lib/src/presentation/screens/request_money/view/sub_sections/request_money_section.dart
 M lib/src/presentation/screens/request_money/view/sub_sections/request_money_success_step_section.dart
 M lib/src/presentation/screens/request_money/view/sub_sections/request_money_wallet_section.dart
 M lib/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/change_passcode_bottom_sheet.dart
 M lib/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/generate_passcode_bottom_sheet.dart
 M lib/src/presentation/screens/transfer/controller/transfer_controller.dart
 M lib/src/presentation/screens/transfer/controller/transfer_history_controller.dart
 M lib/src/presentation/screens/transfer/controller/transfer_received_history_controller.dart
 M lib/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart
 M lib/src/presentation/screens/transfer/view/sub_sections/transfer_review_step_section.dart
 M lib/src/presentation/screens/transfer/view/transfer_history/transfer_history.dart
 M lib/src/presentation/screens/transfer/view/transfer_received_history/transfer_received_history.dart
 M lib/src/presentation/screens/transfer/view/transfer_screen.dart
 M lib/src/presentation/screens/transfer/view/widgets/transfer_amount_input_card.dart
 M lib/src/presentation/screens/transfer/view/widgets/transfer_path_card.dart
 M lib/src/presentation/screens/travel/boat/screens/boat_voucher_screen.dart
 M lib/src/presentation/screens/travel/bookings/travel_checkout_screen.dart
 M lib/src/presentation/screens/travel/bookings/travel_confirmation_screen.dart
 M lib/src/presentation/screens/travel/bookings/travel_orders_screen.dart
 M lib/src/presentation/screens/travel/dining/screens/dining_order_pass_screen.dart
 M lib/src/presentation/screens/travel/flights/flight_screens.dart
 M lib/src/presentation/screens/travel/hotels/hotel_voucher_screen.dart
 M lib/src/presentation/screens/travel/local/screens/local_voucher_screen.dart
 M lib/src/presentation/screens/travel/shared/travel_widgets.dart
 M lib/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart
 M lib/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/irr_card_order_section.dart
 M lib/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_virtual_card.dart
 M lib/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart
 M lib/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart
 M lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart
 M lib/src/presentation/widgets/verify_passcode_bottom_sheet.dart
 M pubspec.lock
 M test/exchange_modular_services_test.dart
 M test/kyc_tier_upgrade_card_test.dart
 M test/offline_request_queue_test.dart
 M test/test_output/screens/cash_out_review__dark.png
 M test/test_output/screens/cash_out_review__light.png
 M test/test_output/screens/make_payment_review__dark.png
 M test/test_output/screens/make_payment_review__light.png
 M test/travel/taxi_service_test.dart
?? .agents/skills/app-discovery-and-route-mapping/
?? .agents/skills/cross-module-integration/
?? .agents/skills/financial-integration-testing/
?? .agents/skills/fintech-domain-integrity/
?? .agents/skills/flutter-getx-dio-safe-evolution/
?? .agents/skills/full-surface-uiux/
?? .agents/skills/localization-accessibility-performance/
?? .agents/skills/security-privacy-resilience/
?? docs/app-map/
?? docs/stage_1/
?? docs/stage_2/
?? docs/stage_3/
?? docs/upgrade_pack/
?? lib/src/commercial/screens/commercial_project_details_screen.dart
?? lib/src/presentation/screens/transfer/view/widgets/tx_flow_shimmer_skeleton.dart
?? lib/src/presentation/screens/transfer/view/widgets/tx_history_shimmer_skeleton.dart
?? test/commercial_and_card_completion_test.dart
?? test/exchange_flow_resilience_test.dart
?? test/financial_domain_integrity_test.dart
?? test/transfer_flow_upgrade_test.dart
?? test/travel/travel_ui_ux_flow_upgrade_test.dart
?? test/workstream_b_api_resilience_test.dart
?? test/workstream_f_security_i18n_perf_test.dart
?? tools/app_map_scanner.py
?? tools/domain_status.py
?? tools/format_unified_catalog.py
?? tools/generate_screenshot_index.py

```

### Diff Stat

command: `git diff --stat`

- Available: `True`
- Exit code: `0`
```text
lib/src/app/bindings/app_bindings.dart             |   14 +
 lib/src/app/constants/app_colors.dart              |    5 +-
 lib/src/app/routes/routes_handler.dart             |    6 +-
 .../controllers/commercial_controller.dart         |   18 +
 .../screens/commercial_projects_screen.dart        |  513 +++++---
 .../screens/equity_project_detail_screen.dart      |  261 +++-
 .../commercial/widgets/equity_project_card.dart    |  201 ++-
 .../widgets/investment_calculator_sheet.dart       |  109 +-
 lib/src/common/services/client_error_reporter.dart |   40 +-
 lib/src/common/widgets/button/common_button.dart   |    4 +-
 .../widgets/design_system/ecardo_balance_hero.dart |   13 +-
 lib/src/helper/dynamic_decimals_helper.dart        |    9 +
 lib/src/network/response/api_response.dart         |   43 +-
 lib/src/network/response/api_response_handler.dart |  117 +-
 lib/src/network/response/status.dart               |    3 +-
 lib/src/network/service/network_service.dart       |  387 +++++-
 ...orgot_password_pin_verification_controller.dart |    9 +-
 .../forgot_password_pin_verification.dart          |  541 +++++---
 .../controller/email_otp_login_controller.dart     |    2 +-
 .../view/sub_sections/email_otp_login_screen.dart  |   63 +-
 .../sign_in/view/sub_sections/two_factor_auth.dart |  446 ++++---
 .../controller/verify_email_controller.dart        |    9 +-
 .../view/set_passcode/set_passcode_screen.dart     |  482 +++++---
 .../view/verify_email/verify_email_screen.dart     |   25 +-
 .../exchange/controller/exchange_controller.dart   |   73 +-
 .../service/exchange_validation_service.dart       |   18 +-
 .../screens/exchange/view/exchange_screen.dart     |   45 +-
 .../sub_sections/exchange_amount_step_section.dart |  206 ++--
 .../sub_sections/exchange_review_step_section.dart |   44 +-
 .../exchange_success_step_section.dart             |    8 +-
 .../exchange/widgets/exchange_swap_card.dart       |   56 +-
 .../view/sub_sections/gift_redeem_section.dart     |   31 +-
 .../view/widgets/kyc_tier_upgrade_card.dart        |  847 ++++++++++---
 .../controller/make_payment_controller.dart        |  128 +-
 .../make_payment_history/make_payment_history.dart |    3 +-
 .../make_payment/view/make_payment_screen.dart     |   17 +-
 .../make_payment_amount_step_section.dart          |  496 ++++----
 .../make_payment_review_step_section.dart          |  539 +++++---
 .../controller/request_money_controller.dart       |  102 +-
 .../view/received_request/received_request.dart    |    3 +-
 .../sub_sections/accept_request_dropdown.dart      |  181 +--
 .../sub_sections/received_request_details.dart     |  211 ++--
 .../request_money_history.dart                     |    3 +-
 .../request_money_history_details.dart             |  214 ++--
 .../request_money/view/request_money_screen.dart   |   37 +-
 .../request_money_amount_step_section.dart         |  250 ++--
 .../request_money_review_step_section.dart         |  395 ++++--
 .../view/sub_sections/request_money_section.dart   |   30 +-
 .../request_money_success_step_section.dart        |   10 +-
 .../sub_sections/request_money_wallet_section.dart |    4 +-
 .../sub_sections/change_passcode_bottom_sheet.dart |  221 +++-
 .../generate_passcode_bottom_sheet.dart            |  190 ++-
 .../transfer/controller/transfer_controller.dart   |   56 +-
 .../controller/transfer_history_controller.dart    |   13 +
 .../transfer_received_history_controller.dart      |   13 +
 .../sub_sections/transfer_amount_step_section.dart |   22 +-
 .../sub_sections/transfer_review_step_section.dart |   13 +-
 .../view/transfer_history/transfer_history.dart    |  381 +++---
 .../transfer_received_history.dart                 |  381 +++---
 .../screens/transfer/view/transfer_screen.dart     |   41 +-
 .../view/widgets/transfer_amount_input_card.dart   |  147 ++-
 .../transfer/view/widgets/transfer_path_card.dart  |   75 +-
 .../travel/boat/screens/boat_voucher_screen.dart   |    5 +-
 .../travel/bookings/travel_checkout_screen.dart    |   36 +-
 .../bookings/travel_confirmation_screen.dart       |    5 +
 .../travel/bookings/travel_orders_screen.dart      |   15 +-
 .../dining/screens/dining_order_pass_screen.dart   |   49 +-
 .../screens/travel/flights/flight_screens.dart     |   56 +-
 .../travel/hotels/hotel_voucher_screen.dart        |   11 +-
 .../travel/local/screens/local_voucher_screen.dart |    9 +-
 .../screens/travel/shared/travel_widgets.dart      |  620 ++++++++--
 .../virtual_card_details_controller.dart           |  222 +++-
 .../sub_sections/irr_card_order_section.dart       |  165 ++-
 .../provider/bsicards/bsicards_virtual_card.dart   |   11 +-
 .../provider/generic/generic_card_provider.dart    |   24 +-
 .../view/widgets/common_virtual_card_view.dart     |   25 +-
 .../widgets/virtual_card_security_controls.dart    | 1293 +++++++++++++++++---
 .../widgets/verify_passcode_bottom_sheet.dart      |   48 +-
 pubspec.lock                                       |  480 ++++----
 test/exchange_modular_services_test.dart           |  185 +++
 test/kyc_tier_upgrade_card_test.dart               |  112 ++
 test/offline_request_queue_test.dart               |    2 +
 test/test_output/screens/cash_out_review__dark.png |  Bin 68121 -> 68597 bytes
 .../test_output/screens/cash_out_review__light.png |  Bin 76277 -> 76121 bytes
 .../screens/make_payment_review__dark.png          |  Bin 58868 -> 69517 bytes
 .../screens/make_payment_review__light.png         |  Bin 55767 -> 81779 bytes
 test/travel/taxi_service_test.dart                 |   10 +-
 87 files changed, 8559 insertions(+), 3648 deletions(-)
warning: in the working copy of 'lib/src/presentation/screens/authentication/forgot_password/view/sub_sections/forgot_password_pin_verification.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/authentication/sign_in/view/sub_sections/two_factor_auth.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/authentication/sign_up/view/set_passcode/set_passcode_screen.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_amount_step_section.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_review_step_section.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/request_money/view/received_request/sub_sections/accept_request_dropdown.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/request_money/view/received_request/sub_sections/received_request_details.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/request_money/view/request_money_history/sub_sections/request_money_history_details.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/request_money/view/sub_sections/request_money_amount_step_section.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/request_money/view/sub_sections/request_money_review_step_section.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/change_passcode_bottom_sheet.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/generate_passcode_bottom_sheet.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/transfer/view/transfer_history/transfer_history.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/src/presentation/screens/transfer/view/transfer_received_history/transfer_received_history.dart', LF will be replaced by CRLF the next time Git touches it
```

### Staged Diff Stat

command: `git diff --cached --stat`

- Available: `True`
- Exit code: `0`
```text


```

### Nearest Tag

command: `git describe --tags --always --dirty`

- Available: `True`
- Exit code: `0`
```text
v1.0.181-dirty

```

### Local Tags Recent

command: `git tag --sort=-creatordate`

- Available: `True`
- Exit code: `0`
```text
v1.0.181
v1.0.180
v1.0.178
v1.0.177
v1.0.175
v1.0.174
v1.0.173
v1.0.172
v1.0.171
v1.0.170
v1.0.169
v1.0.166
v1.0.161
v1.0.160
v1.0.159
v1.0.158
v1.0.157
v1.0.156
v1.0.155
v1.0.154
v1.0.153
v1.0.152
v1.0.151
v1.0.150
v1.0.149
v1.0.148
v1.0.147
v1.0.146
v1.0.145
v1.0.144
v1.0.143
v1.0.142
v1.0.141
v1.0.140
v1.0.139
v1.0.126
v1.0.137
v1.0.136
v1.0.135
v1.0.134
v1.0.133
v1.0.132
v1.0.130
v1.0.129
v1.0.128
v1.0.127
v1.0.125
v1.0.124
v1.0.123
v1.0.122
v1.0.121
v1.0.120
v1.0.119
v1.0.118
v1.0.117
v1.0.116
v1.0.115
v1.0.114
v1.0.113
v1.0.112
v1.0.111
v1.0.110
v1.0.109
v1.0.108
v1.0.101
v1.0.100
v1.0.99
v1.0.98
v1.0.97
v1.0.96
v1.0.95
v1.0.94
v1.0.93
v1.0.92
v1.0.91
v1.0.90
v1.0.89
v1.0.88
v1.0.87
v1.0.86
v1.0.83
v1.0.82
v1.0.81
v1.0.80
v1.0.79
v1.0.78
v1.0.77
v1.0.76
v1.0.75
v1.0.74
v1.0.73
v1.0.72
v1.0.71
v1.0.70
v1.0.69
v1.0.68
v1.0.67
v1.0.66
v1.0.65
v1.0.64
v1.0.63
v1.0.62
v1.0.61
v1.0.60
v1.0.59
v1.0.58
v1.0.57
v1.0.56
v1.0.55
v1.0.54
v1.0.53
v1.0.52
v1.0.51
v1.0.50
v1.0.49
v1.0.48
v1.0.46
v1.0.45
v1.0.44
v1.0.43
v1.0.42
v1.0.41
v1.0.40
v1.0.39
v1.0.38
v1.0.37
v1.0.36
v1.0.35
v1.0.34
v1.0.33
v1.0.32
v1.0.31
v1.0.30
v1.0.29
v1.0.28
v1.0.27
v1.0.26
v1.0.25
v1.0.24
v1.0.23
v1.0.22
v1.0.20
v1.0.14
v1.0.13
v1.0.10

```

## Tool versions

### flutter

command: `flutter --version`

- Available: `True`
- Exit code: `None`
```text

[WinError 2] The system cannot find the file specified
```

### dart

command: `dart --version`

- Available: `True`
- Exit code: `None`
```text

[WinError 2] The system cannot find the file specified
```

### python

command: `python3 --version`

- Available: `True`
- Exit code: `9009`
```text

Python was not found; run without arguments to install from the Microsoft Store, or disable this shortcut from Settings > Apps > Advanced app settings > App execution aliases.
```

## Limits

- This is a metadata baseline, not a source audit and not proof that tests pass.
- Git status and diffs may list pre-existing changes; preserve them and do not reset/stash/checkout.
- Remote state is deliberately not fetched; compare public remote/release evidence separately.
- No environment variables or secrets are read or emitted.

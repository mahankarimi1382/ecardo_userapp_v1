# Visual regression و test plan

## لایه‌های تست
1. Unit: formatters, state mapping, field validators, pure UI logic.
2. Widget: component states, tap outcomes, errors, semantics, RTL and dark theme.
3. Golden: critical screens/component states with fixed fonts/locale/DPR.
4. Integration: multi-page journeys with controllable backend fixtures.
5. Native E2E: simulator/device flows for keyboard, biometric, permissions, navigation and release build.
6. Accessibility scanner + manual screen-reader review.
7. Performance profile: cold start, scroll jank, memory, route transition, web frame/profile as applicable.

## Minimum visual matrix
- screens: every P0/P1 route and its success/error/empty/pending state.
- locales: all supported locales, plus longest strings.
- themes: light/dark.
- text scale: default and large.
- screens: small Android, common Android, tablet/responsive and iOS representative where available.

## Commands (adjust to repository instructions)
```bash
flutter --version
dart --version
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed <changed-dart-files>
flutter analyze
flutter test --reporter expanded
flutter test test/<relevant_widget_or_golden_test>.dart
flutter test integration_test/<journey_test>.dart -d <device_id>
flutter build apk --release
```
Never assume the command succeeded; store exit code, stdout/stderr, SHA and artifact metadata. Do not auto-update goldens to make CI green without visual review.

# تست، accessibility، عملکرد، localization و CI — 50 مخزن پیشنهادی

این فهرست برای اکتشاف و مقایسه است، نه توصیه به clone/ادغام مستقیم. همهٔ مخازن در این مرحله به‌صورت آنلاین و commit-by-commit ممیزی نشده‌اند؛ هنگام انتخاب باید existence، آخرین commit/release، license، امنیت وابستگی، پشتیبانی پلتفرم و سازگاری با Flutter/Dart فعلی کنترل شود.

| # | مخزن | کاربرد | نوع استفاده | تصمیم اولیه |
|---:|---|---|---|---|
| 1 | [`leancodepl/patrol`](https://github.com/leancodepl/patrol) | native-aware Flutter E2E | Candidate | PoC در شاخه جدا |
| 2 | [`eBay/golden_toolkit`](https://github.com/eBay/golden_toolkit) | golden/screenshot test helpers | Candidate | PoC در شاخه جدا |
| 3 | [`Betterment/alchemist`](https://github.com/Betterment/alchemist) | golden tests | Candidate | PoC در شاخه جدا |
| 4 | [`flutter/flutter`](https://github.com/flutter/flutter) | flutter_test and accessibility guidelines | Core | PoC در شاخه جدا |
| 5 | [`flutter/packages`](https://github.com/flutter/packages) | integration_test package source | Core | PoC در شاخه جدا |
| 6 | [`felangel/mocktail`](https://github.com/felangel/mocktail) | mocking | Candidate | PoC در شاخه جدا |
| 7 | [`dart-lang/mockito`](https://github.com/dart-lang/mockito) | mocking | Candidate | PoC در شاخه جدا |
| 8 | [`felangel/bloc_test`](https://github.com/felangel/bloc_test) | BLoC tests if BLoC used | Reference | مرجع/بررسی |
| 9 | [`rrousselGit/riverpod`](https://github.com/rrousselGit/riverpod) | Riverpod test patterns | Reference | مرجع/بررسی |
| 10 | [`VeryGoodOpenSource/very_good_test_runner`](https://github.com/VeryGoodOpenSource/very_good_test_runner) | test runner | Candidate | PoC در شاخه جدا |
| 11 | [`VeryGoodOpenSource/very_good_analysis`](https://github.com/VeryGoodOpenSource/very_good_analysis) | static analysis | Candidate | PoC در شاخه جدا |
| 12 | [`VeryGoodOpenSource/very_good_cli`](https://github.com/VeryGoodOpenSource/very_good_cli) | repo hygiene | Candidate | PoC در شاخه جدا |
| 13 | [`jonasbark/flutter_gherkin`](https://github.com/jonasbark/flutter_gherkin) | BDD E2E reference | Candidate | PoC در شاخه جدا |
| 14 | [`mobile-dev-inc/Maestro`](https://github.com/mobile-dev-inc/Maestro) | mobile UI automation | Tool | PoC در شاخه جدا |
| 15 | [`appium/appium`](https://github.com/appium/appium) | mobile automation | Tool | PoC در شاخه جدا |
| 16 | [`fastlane/fastlane`](https://github.com/fastlane/fastlane) | mobile release automation | Tool | PoC در شاخه جدا |
| 17 | [`shorebirdtech/shorebird`](https://github.com/shorebirdtech/shorebird) | Flutter deployment/patching; policy review | Tool | PoC در شاخه جدا |
| 18 | [`invertase/melos`](https://github.com/invertase/melos) | monorepo validation | Tool | PoC در شاخه جدا |
| 19 | [`dart-lang/dart_style`](https://github.com/dart-lang/dart_style) | formatting | Core | PoC در شاخه جدا |
| 20 | [`dart-lang/linter`](https://github.com/dart-lang/linter) | lint rules | Core | PoC در شاخه جدا |
| 21 | [`dart-lang/sdk`](https://github.com/dart-lang/sdk) | Dart runtime/tests | Core | PoC در شاخه جدا |
| 22 | [`dart-lang/coverage`](https://github.com/dart-lang/coverage) | coverage collection | Core | PoC در شاخه جدا |
| 23 | [`dart-lang/pub`](https://github.com/dart-lang/pub) | dependency tooling | Core | PoC در شاخه جدا |
| 24 | [`flutter/devtools`](https://github.com/flutter/devtools) | profiling and diagnostics | Core | PoC در شاخه جدا |
| 25 | [`flutter/cocoon`](https://github.com/flutter/cocoon) | CI orchestration reference | Core | PoC در شاخه جدا |
| 26 | [`getsentry/sentry-dart`](https://github.com/getsentry/sentry-dart) | crash/error reporting | Candidate | PoC در شاخه جدا |
| 27 | [`firebase/flutterfire`](https://github.com/firebase/flutterfire) | Crashlytics/analytics plugins | Candidate | PoC در شاخه جدا |
| 28 | [`DataDog/dd-sdk-flutter`](https://github.com/DataDog/dd-sdk-flutter) | RUM/crash monitoring | Candidate | PoC در شاخه جدا |
| 29 | [`open-telemetry/opentelemetry-dart`](https://github.com/open-telemetry/opentelemetry-dart) | telemetry SDK reference | Candidate | PoC در شاخه جدا |
| 30 | [`google/osv-scanner`](https://github.com/google/osv-scanner) | dependency vulnerability scanning | Tool | PoC در شاخه جدا |
| 31 | [`aquasecurity/trivy`](https://github.com/aquasecurity/trivy) | security scanning | Tool | PoC در شاخه جدا |
| 32 | [`ossf/scorecard`](https://github.com/ossf/scorecard) | supply chain security | Tool | PoC در شاخه جدا |
| 33 | [`renovatebot/renovate`](https://github.com/renovatebot/renovate) | dependency updates | Tool | PoC در شاخه جدا |
| 34 | [`dependabot/dependabot-core`](https://github.com/dependabot/dependabot-core) | dependency updates | Tool | PoC در شاخه جدا |
| 35 | [`actions/checkout`](https://github.com/actions/checkout) | GitHub Actions primitive | CI | PoC در شاخه جدا |
| 36 | [`actions/setup-java`](https://github.com/actions/setup-java) | GitHub Actions Java setup | CI | PoC در شاخه جدا |
| 37 | [`subosito/flutter-action`](https://github.com/subosito/flutter-action) | Flutter setup in Actions | CI | PoC در شاخه جدا |
| 38 | [`dart-lang/setup-dart`](https://github.com/dart-lang/setup-dart) | Dart setup | CI | PoC در شاخه جدا |
| 39 | [`github/codeql`](https://github.com/github/codeql) | static security analysis | CI | PoC در شاخه جدا |
| 40 | [`flutter/accessibility`](https://github.com/flutter/accessibility) | accessibility docs reference; verify repo availability | Reference | مرجع/بررسی |
| 41 | [`w3c/wcag`](https://github.com/w3c/wcag) | WCAG standards | Standard | PoC در شاخه جدا |
| 42 | [`w3c/aria-practices`](https://github.com/w3c/aria-practices) | accessible interaction examples | Standard | PoC در شاخه جدا |
| 43 | [`google/material-design-icons`](https://github.com/google/material-design-icons) | accessible icon semantics reference | Design reference | مرجع/بررسی |
| 44 | [`flutter/website`](https://github.com/flutter/website) | official accessibility/i18n docs | Core | PoC در شاخه جدا |
| 45 | [`localizely/flutter-intl-vscode`](https://github.com/localizely/flutter-intl-vscode) | localization tooling | Tool | PoC در شاخه جدا |
| 46 | [`intlify/intlify`](https://github.com/intlify/intlify) | i18n tooling reference | Reference | مرجع/بررسی |
| 47 | [`apollographql/apollo-client`](https://github.com/apollographql/apollo-client) | GraphQL testing/reference | Reference | مرجع/بررسی |
| 48 | [`storybookjs/storybook`](https://github.com/storybookjs/storybook) | component visual review | Tool | PoC در شاخه جدا |
| 49 | [`chromaui/chromatic`](https://github.com/chromaui/chromatic) | visual regression tool integration | Tool | PoC در شاخه جدا |
| 50 | [`microsoft/playwright`](https://github.com/microsoft/playwright) | web/Flutter Web browser automation support | Tool | PoC در شاخه جدا |

## قانون پذیرش
- ابتدا license و فعال‌بودن مخزن را بررسی کنید.
- نمونهٔ UI را برای الگو بخوانید؛ منطق مالی، احراز هویت و ذخیره‌سازی را بدون review وارد نکنید.
- هر dependency تازه باید در ADR با دلیل، حجم، نگهداری، platform support، privacy و تست جایگزین ثبت شود.
- برای Flutter، نسخهٔ سازگار با Flutter/Dart واقعی پروژه را از pub.dev و changelog مخزن بررسی کنید.

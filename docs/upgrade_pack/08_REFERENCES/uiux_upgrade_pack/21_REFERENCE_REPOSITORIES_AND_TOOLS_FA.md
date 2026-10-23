# کاتالوگ مخازن و ابزارهای UI/UX برای eCardo

این فهرست shortlist تحقیق است، نه تأیید خودکار سازگاری/امنیت/license یا توصیه به نصب همهٔ موارد. قبل از استفاده، آخرین commit/release، مجوز، maintenance، SDK constraints، issueها، حجم dependency و privacy را بررسی کنید. eCardo design-system و GetX خود را دارد؛ هدف اکثراً الگو/ابزار تست/ویجت گزینشی است، نه مهاجرت معماری.

## نمونه‌ها و بنچمارک‌های مالی
1. XPay UI Kit (commercial, 44 screens): https://afgprogrammer.com/ui-kits/flutter-xpay-fintech-digital-wallet-ui-kit — coverage/reference; mock only.
2. Xpay Wallet UI Kit: https://ui8.net/arino-labs/products/xpay---wallet-apps-ui-kit — commercial Figma reference; license check.
3. Finance App Flutter: https://github.com/Finance-App-Open-Source/finance-app-flutter — reference UI only.
4. Nexo finance Flutter sample: https://github.com/Chere3/nexo — design-system/feature structure reference; verify current state.
5. Fintech Flutter app sample: https://github.com/yucezis/fintech-flutter-app — feature/UI patterns; verify code and license.
6. Flutter Bank App: https://github.com/murodaliismoilov/flutter-bank-app — educational screen reference.
7. Bank App UI: https://github.com/julvikramsupandi/flutter-bank-app-ui — educational visual reference.
8. Bank App UI: https://github.com/THARINDUnirmal/flutter-bank-app-ui — educational template; verify quality/license.
9. Finance Dashboard: https://github.com/prathik0007/flutter-finance-dashboard — dashboard inspiration.
10. Finance UI: https://github.com/feMoraes0/finance-ui — visual learning only.
11. Finance UI Design: https://github.com/amine-zergan/finance_ui_design — low maturity/one commit reported in search; inspect only.
12. Wise: https://wise.com/ — live-product benchmarking; don't copy branding/assets.
13. Revolut: https://www.revolut.com/ — live-product benchmarking; market features vary.
14. Monzo: https://monzo.com/features/pots — budgeting metaphor.
15. N26: https://n26.com/ — account/card UX.
16. PayPal: https://www.paypal.com/ — send/request/payment status.

## Core Flutter & architecture
17. Flutter: https://github.com/flutter/flutter
18. Flutter samples: https://github.com/flutter/samples
19. Flutter packages monorepo: https://github.com/flutter/packages
20. GetX (current state-management reference): https://github.com/jonataslaw/getx
21. Dio: https://github.com/cfug/dio
22. BLoC reference (do not migrate solely for this): https://github.com/felangel/bloc
23. Riverpod reference (do not migrate solely for this): https://github.com/rrousselGit/riverpod
24. Very Good CLI: https://github.com/VeryGoodOpenSource/very_good_cli
25. Very Good templates: https://github.com/VeryGoodOpenSource/very_good_templates
26. Very Good Analysis: https://github.com/VeryGoodOpenSource/very_good_analysis
27. Very Good infinite list: https://github.com/VeryGoodOpenSource/very_good_infinite_list
28. Responsive Framework: https://github.com/Codelessly/ResponsiveFramework
29. Flutter ScreenUtil: https://github.com/OpenFlutter/flutter_screenutil — already mentioned in app; benchmark rather than replace.
30. Flex Color Scheme: https://github.com/rydmike/flex_color_scheme
31. shadcn_flutter: https://github.com/nank1ro/flutter-shadcn-ui — evaluate selectively, don't overlay current DS wholesale.
32. GetWidget: https://github.com/ionicfirebaseapp/getwidget — component ideas; ensure design identity.
33. Flutter UI Challenges: https://github.com/TheAlphamerc/flutter_ui_challenges — educational patterns.

## Components, charts, forms, visuals
34. fl_chart: https://github.com/imaNNeo/fl_chart
35. flutter_animate: https://github.com/gskinner/flutter_animate
36. Rive Flutter: https://github.com/rive-app/rive-flutter
37. Lottie Flutter: https://github.com/xvrh/lottie-flutter
38. flutter_svg: https://github.com/dnfield/flutter_svg
39. flutter_staggered_grid_view: https://github.com/letsar/flutter_staggered_grid_view
40. flutter_slidable: https://github.com/letsar/flutter_slidable
41. modal_bottom_sheet: https://github.com/jamesblasco/modal_bottom_sheet
42. Pinput: https://github.com/Tkko/pinput
43. flutter_form_builder: https://github.com/flutter-form-builder-ecosystem/flutter_form_builder
44. reactive_forms: https://github.com/joanpablo/reactive_forms
45. formz: https://github.com/felangel/formz
46. skeletonizer: https://github.com/Milad-Akarie/skeletonizer
47. shimmer: https://github.com/hnvn/flutter_shimmer
48. cached_network_image: https://github.com/Baseflow/flutter_cached_network_image
49. hugeicons_flutter: https://github.com/HugeIcons/hugeicons_flutter
50. google fonts catalog: https://github.com/google/fonts
51. flutter markdown (built into packages repo): https://github.com/flutter/packages
52. adaptive scaffold package (Flutter packages): https://github.com/flutter/packages

## Testing, accessibility, localization & QA
53. Patrol: https://github.com/leancodepl/patrol
54. Golden Toolkit: https://github.com/eBay/golden_toolkit
55. Alchemist: https://github.com/Betterment/alchemist
56. Flutter integration tests guide: https://docs.flutter.dev/testing/integration-tests
57. Flutter accessibility docs: https://docs.flutter.dev/ui/accessibility
58. Flutter localization docs: https://docs.flutter.dev/ui/internationalization
59. WCAG 2.2: https://www.w3.org/TR/WCAG22/
60. Material icons: https://github.com/google/material-design-icons
61. Flutter Launcher Icons: https://github.com/fluttercommunity/flutter_launcher_icons
62. Flutter Native Splash: https://github.com/jonbhanson/flutter_native_splash
63. Flutter Local Notifications: https://github.com/MaikuB/flutter_local_notifications
64. Flutter Secure Storage: https://github.com/juliansteenbakker/flutter_secure_storage
65. Flutter community plus plugins: https://github.com/fluttercommunity/plus_plugins
66. Firebase FlutterFire: https://github.com/firebase/flutterfire
67. Sentry Dart: https://github.com/getsentry/sentry-dart
68. OpenTelemetry Dart: https://github.com/open-telemetry/opentelemetry-dart
69. Talker: https://github.com/Frezyx/talker
70. Accessibility guidelines built into Flutter: https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html

## Rule for adoption
Create a short ADR for any package added or architectural shift. Score: maintenance, license, security, API compatibility, accessibility, bundle impact, platform support, test quality and ownership cost. Prefer current native Flutter capability when sufficient.

# سیستم‌های طراحی، کامپوننت‌ها و layout — 50 مخزن پیشنهادی

این فهرست برای اکتشاف و مقایسه است، نه توصیه به clone/ادغام مستقیم. همهٔ مخازن در این مرحله به‌صورت آنلاین و commit-by-commit ممیزی نشده‌اند؛ هنگام انتخاب باید existence، آخرین commit/release، license، امنیت وابستگی، پشتیبانی پلتفرم و سازگاری با Flutter/Dart فعلی کنترل شود.

| # | مخزن | کاربرد | نوع استفاده | تصمیم اولیه |
|---:|---|---|---|---|
| 1 | [`flutter/flutter`](https://github.com/flutter/flutter) | framework and Material/Cupertino widgets | Core | PoC در شاخه جدا |
| 2 | [`flutter/samples`](https://github.com/flutter/samples) | official sample apps | Core reference | مرجع/بررسی |
| 3 | [`flutter/packages`](https://github.com/flutter/packages) | official plugin/package monorepo | Core | PoC در شاخه جدا |
| 4 | [`flutter/website`](https://github.com/flutter/website) | official documentation | Core | PoC در شاخه جدا |
| 5 | [`flutter/devtools`](https://github.com/flutter/devtools) | performance and diagnostics UI | Tooling | PoC در شاخه جدا |
| 6 | [`flutter/cocoon`](https://github.com/flutter/cocoon) | Flutter CI orchestration | Tooling | PoC در شاخه جدا |
| 7 | [`flutter/animations`](https://github.com/flutter/animations) | official motion examples | Motion reference | مرجع/بررسی |
| 8 | [`flutter/gallery`](https://github.com/flutter/gallery) | official gallery/reference app | Reference | مرجع/بررسی |
| 9 | [`flutter/games`](https://github.com/flutter/games) | official Flutter games/examples | Reference | مرجع/بررسی |
| 10 | [`flutter/engine`](https://github.com/flutter/engine) | rendering engine source | Advanced reference | مرجع/بررسی |
| 11 | [`jonataslaw/getx`](https://github.com/jonataslaw/getx) | current eCardo state/navigation reference | Current stack | PoC در شاخه جدا |
| 12 | [`rydmike/flex_color_scheme`](https://github.com/rydmike/flex_color_scheme) | ColorScheme and theme extensions | Candidate | PoC در شاخه جدا |
| 13 | [`Codelessly/ResponsiveFramework`](https://github.com/Codelessly/ResponsiveFramework) | responsive layouts | Candidate | PoC در شاخه جدا |
| 14 | [`OpenFlutter/flutter_screenutil`](https://github.com/OpenFlutter/flutter_screenutil) | screen scaling patterns | Current stack review | PoC در شاخه جدا |
| 15 | [`nank1ro/flutter-shadcn-ui`](https://github.com/nank1ro/flutter-shadcn-ui) | headless/shadcn-inspired components | Candidate | PoC در شاخه جدا |
| 16 | [`forui/forui`](https://github.com/forui/forui) | component system for Flutter | Candidate | PoC در شاخه جدا |
| 17 | [`ionicfirebaseapp/getwidget`](https://github.com/ionicfirebaseapp/getwidget) | Flutter widget catalog | Reference | مرجع/بررسی |
| 18 | [`VeryGoodOpenSource/very_good_analysis`](https://github.com/VeryGoodOpenSource/very_good_analysis) | Dart lint rules | Candidate | PoC در شاخه جدا |
| 19 | [`fluttercommunity/flutter_lints`](https://github.com/fluttercommunity/flutter_lints) | Flutter lint baseline | Candidate | PoC در شاخه جدا |
| 20 | [`fluttercommunity/flutter_launcher_icons`](https://github.com/fluttercommunity/flutter_launcher_icons) | app icon generation | Tooling | PoC در شاخه جدا |
| 21 | [`jonbhanson/flutter_native_splash`](https://github.com/jonbhanson/flutter_native_splash) | native splash generation | Tooling | PoC در شاخه جدا |
| 22 | [`dnfield/flutter_svg`](https://github.com/dnfield/flutter_svg) | SVG rendering | Candidate | PoC در شاخه جدا |
| 23 | [`Baseflow/flutter_cached_network_image`](https://github.com/Baseflow/flutter_cached_network_image) | image loading/cache | Candidate | PoC در شاخه جدا |
| 24 | [`letsar/flutter_staggered_grid_view`](https://github.com/letsar/flutter_staggered_grid_view) | staggered grids | Candidate | PoC در شاخه جدا |
| 25 | [`letsar/flutter_slidable`](https://github.com/letsar/flutter_slidable) | slidable rows | Candidate | PoC در شاخه جدا |
| 26 | [`jamesblasco/modal_bottom_sheet`](https://github.com/jamesblasco/modal_bottom_sheet) | bottom-sheet interactions | Candidate | PoC در شاخه جدا |
| 27 | [`google/material-design-icons`](https://github.com/google/material-design-icons) | Material icon source | Asset reference | مرجع/بررسی |
| 28 | [`google/fonts`](https://github.com/google/fonts) | font source and metadata | Asset reference | مرجع/بررسی |
| 29 | [`microsoft/fluentui-system-icons`](https://github.com/microsoft/fluentui-system-icons) | Fluent icon reference | Asset reference | مرجع/بررسی |
| 30 | [`microsoft/fluentui-emoji`](https://github.com/microsoft/fluentui-emoji) | emoji asset reference | Asset reference | مرجع/بررسی |
| 31 | [`shadcn-ui/ui`](https://github.com/shadcn-ui/ui) | web component composition ideas | Web reference | مرجع/بررسی |
| 32 | [`radix-ui/primitives`](https://github.com/radix-ui/primitives) | accessible primitive behavior | Web reference | مرجع/بررسی |
| 33 | [`tailwindlabs/headlessui`](https://github.com/tailwindlabs/headlessui) | headless component behavior | Web reference | مرجع/بررسی |
| 34 | [`mui/material-ui`](https://github.com/mui/material-ui) | component API conventions | Web reference | مرجع/بررسی |
| 35 | [`ant-design/ant-design`](https://github.com/ant-design/ant-design) | enterprise design patterns | Web reference | مرجع/بررسی |
| 36 | [`chakra-ui/chakra-ui`](https://github.com/chakra-ui/chakra-ui) | tokens and component variants | Web reference | مرجع/بررسی |
| 37 | [`adobe/spectrum-web-components`](https://github.com/adobe/spectrum-web-components) | design token and accessibility patterns | Web reference | مرجع/بررسی |
| 38 | [`carbon-design-system/carbon`](https://github.com/carbon-design-system/carbon) | design-system governance | Web reference | مرجع/بررسی |
| 39 | [`salesforce-ux/design-system`](https://github.com/salesforce-ux/design-system) | enterprise design system | Web reference | مرجع/بررسی |
| 40 | [`Shopify/polaris`](https://github.com/Shopify/polaris) | commerce UI patterns | Web reference | مرجع/بررسی |
| 41 | [`primer/react`](https://github.com/primer/react) | product UI patterns | Web reference | مرجع/بررسی |
| 42 | [`primer/css`](https://github.com/primer/css) | design tokens/CSS patterns | Web reference | مرجع/بررسی |
| 43 | [`microsoft/fluentui`](https://github.com/microsoft/fluentui) | cross-platform design patterns | Web reference | مرجع/بررسی |
| 44 | [`microsoft/fast`](https://github.com/microsoft/fast) | web component foundations | Web reference | مرجع/بررسی |
| 45 | [`elastic/eui`](https://github.com/elastic/eui) | data-dense UI patterns | Web reference | مرجع/بررسی |
| 46 | [`PatternFly/patternfly`](https://github.com/PatternFly/patternfly) | admin/product design system | Web reference | مرجع/بررسی |
| 47 | [`govuk-frontend/govuk-frontend`](https://github.com/govuk-frontend/govuk-frontend) | content and form clarity | Web reference | مرجع/بررسی |
| 48 | [`nhsuk/nhsuk-frontend`](https://github.com/nhsuk/nhsuk-frontend) | accessible form patterns | Web reference | مرجع/بررسی |
| 49 | [`mantinedev/mantine`](https://github.com/mantinedev/mantine) | component/API patterns | Web reference | مرجع/بررسی |
| 50 | [`storybookjs/storybook`](https://github.com/storybookjs/storybook) | component catalogue and review | Design ops | PoC در شاخه جدا |

## قانون پذیرش
- ابتدا license و فعال‌بودن مخزن را بررسی کنید.
- نمونهٔ UI را برای الگو بخوانید؛ منطق مالی، احراز هویت و ذخیره‌سازی را بدون review وارد نکنید.
- هر dependency تازه باید در ADR با دلیل، حجم، نگهداری، platform support، privacy و تست جایگزین ثبت شود.
- برای Flutter، نسخهٔ سازگار با Flutter/Dart واقعی پروژه را از pub.dev و changelog مخزن بررسی کنید.

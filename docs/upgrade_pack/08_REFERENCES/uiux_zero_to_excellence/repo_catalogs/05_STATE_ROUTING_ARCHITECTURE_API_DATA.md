# State، مسیریابی، معماری و API/Data — 50 مخزن پیشنهادی

این فهرست برای اکتشاف و مقایسه است، نه توصیه به clone/ادغام مستقیم. همهٔ مخازن در این مرحله به‌صورت آنلاین و commit-by-commit ممیزی نشده‌اند؛ هنگام انتخاب باید existence، آخرین commit/release، license، امنیت وابستگی، پشتیبانی پلتفرم و سازگاری با Flutter/Dart فعلی کنترل شود.

| # | مخزن | کاربرد | نوع استفاده | تصمیم اولیه |
|---:|---|---|---|---|
| 1 | [`jonataslaw/getx`](https://github.com/jonataslaw/getx) | current state/navigation stack | Current stack | PoC در شاخه جدا |
| 2 | [`rrousselGit/riverpod`](https://github.com/rrousselGit/riverpod) | provider/state comparison | Candidate/reference | مرجع/بررسی |
| 3 | [`felangel/bloc`](https://github.com/felangel/bloc) | state management | Candidate/reference | مرجع/بررسی |
| 4 | [`rrousselGit/provider`](https://github.com/rrousselGit/provider) | Provider state model | Reference | مرجع/بررسی |
| 5 | [`mobxjs/mobx.dart`](https://github.com/mobxjs/mobx.dart) | reactive state | Reference | مرجع/بررسی |
| 6 | [`flutter_hooks/flutter_hooks`](https://github.com/flutter_hooks/flutter_hooks) | widget lifecycle helpers | Reference | مرجع/بررسی |
| 7 | [`fluttercommunity/get_it`](https://github.com/fluttercommunity/get_it) | service locator | Current/reference | مرجع/بررسی |
| 8 | [`Milad-Akarie/injectable`](https://github.com/Milad-Akarie/injectable) | DI code generation | Candidate | PoC در شاخه جدا |
| 9 | [`Milad-Akarie/auto_route_library`](https://github.com/Milad-Akarie/auto_route_library) | typed routing | Reference | مرجع/بررسی |
| 10 | [`flutter/packages`](https://github.com/flutter/packages) | go_router official package | Core | PoC در شاخه جدا |
| 11 | [`fluttercommunity/beamer`](https://github.com/fluttercommunity/beamer) | URL-based routing | Reference | مرجع/بررسی |
| 12 | [`flutter_modular/flutter_modular`](https://github.com/flutter_modular/flutter_modular) | modular architecture | Reference | مرجع/بررسی |
| 13 | [`Stacked-Org/stacked`](https://github.com/Stacked-Org/stacked) | MVVM architecture | Reference | مرجع/بررسی |
| 14 | [`felangel/equatable`](https://github.com/felangel/equatable) | value equality | Candidate | PoC در شاخه جدا |
| 15 | [`rrousselGit/freezed`](https://github.com/rrousselGit/freezed) | immutable models | Candidate | PoC در شاخه جدا |
| 16 | [`google/json_serializable.dart`](https://github.com/google/json_serializable.dart) | JSON code generation | Candidate | PoC در شاخه جدا |
| 17 | [`google/built_value.dart`](https://github.com/google/built_value.dart) | immutable/value types | Reference | مرجع/بررسی |
| 18 | [`cfug/dio`](https://github.com/cfug/dio) | HTTP client | Current stack | PoC در شاخه جدا |
| 19 | [`dart-lang/http`](https://github.com/dart-lang/http) | HTTP package source | Core | PoC در شاخه جدا |
| 20 | [`trevorwang/retrofit.dart`](https://github.com/trevorwang/retrofit.dart) | typed REST client | Candidate | PoC در شاخه جدا |
| 21 | [`lejard-h/chopper`](https://github.com/lejard-h/chopper) | HTTP client/codegen | Candidate | PoC در شاخه جدا |
| 22 | [`gql-dart/gql`](https://github.com/gql-dart/gql) | GraphQL primitives | Candidate | PoC در شاخه جدا |
| 23 | [`ZinoKader/ferry`](https://github.com/ZinoKader/ferry) | GraphQL client | Candidate | PoC در شاخه جدا |
| 24 | [`zino-app/graphql_flutter`](https://github.com/zino-app/graphql_flutter) | GraphQL Flutter | Candidate | PoC در شاخه جدا |
| 25 | [`dart-lang/web_socket_channel`](https://github.com/dart-lang/web_socket_channel) | WebSocket support | Candidate | PoC در شاخه جدا |
| 26 | [`rikulo/socket.io-client-dart`](https://github.com/rikulo/socket.io-client-dart) | Socket.IO client | Candidate | PoC در شاخه جدا |
| 27 | [`fluttercommunity/plus_plugins`](https://github.com/fluttercommunity/plus_plugins) | connectivity/platform plugins | Current ecosystem | PoC در شاخه جدا |
| 28 | [`fluttercommunity/flutter_workmanager`](https://github.com/fluttercommunity/flutter_workmanager) | background work | Candidate | PoC در شاخه جدا |
| 29 | [`fluttercommunity/flutter_local_notifications`](https://github.com/fluttercommunity/flutter_local_notifications) | local notifications | Candidate | PoC در شاخه جدا |
| 30 | [`Frezyx/talker`](https://github.com/Frezyx/talker) | logging and diagnostics | Candidate | PoC در شاخه جدا |
| 31 | [`simonbengtsson/flutter_secure_storage`](https://github.com/simonbengtsson/flutter_secure_storage) | secure storage reference; verify canonical repo | Security | PoC در شاخه جدا |
| 32 | [`juliansteenbakker/flutter_secure_storage`](https://github.com/juliansteenbakker/flutter_secure_storage) | secure storage | Current candidate | PoC در شاخه جدا |
| 33 | [`Baseflow/flutter_cache_manager`](https://github.com/Baseflow/flutter_cache_manager) | cache lifecycle | Candidate | PoC در شاخه جدا |
| 34 | [`isar/isar`](https://github.com/isar/isar) | local database; check maintenance/license | Database | PoC در شاخه جدا |
| 35 | [`isar-community/isar`](https://github.com/isar-community/isar) | community fork of Isar | Database | PoC در شاخه جدا |
| 36 | [`simolus3/drift`](https://github.com/simolus3/drift) | SQLite persistence | Candidate | PoC در شاخه جدا |
| 37 | [`tekartik/sqflite`](https://github.com/tekartik/sqflite) | SQLite plugin | Candidate | PoC در شاخه جدا |
| 38 | [`hivedb/hive`](https://github.com/hivedb/hive) | NoSQL local storage; maintenance check | Database | PoC در شاخه جدا |
| 39 | [`objectbox/objectbox-dart`](https://github.com/objectbox/objectbox-dart) | local database | Database | PoC در شاخه جدا |
| 40 | [`sembast/sembast.dart`](https://github.com/sembast/sembast.dart) | local database | Database | PoC در شاخه جدا |
| 41 | [`fluttercommunity/shared_preferences`](https://github.com/fluttercommunity/shared_preferences) | preferences ecosystem reference | Persistence | PoC در شاخه جدا |
| 42 | [`dart-lang/async`](https://github.com/dart-lang/async) | Dart async utilities | Core | PoC در شاخه جدا |
| 43 | [`dart-lang/collection`](https://github.com/dart-lang/collection) | collection utilities | Core | PoC در شاخه جدا |
| 44 | [`emilienkia/fpdart`](https://github.com/emilienkia/fpdart) | functional programming | Candidate | PoC در شاخه جدا |
| 45 | [`dart-lang/dartz`](https://github.com/dart-lang/dartz) | functional programming | Reference | مرجع/بررسی |
| 46 | [`flutter/flutter`](https://github.com/flutter/flutter) | framework source | Core | PoC در شاخه جدا |
| 47 | [`flutter/samples`](https://github.com/flutter/samples) | architecture examples | Reference | مرجع/بررسی |
| 48 | [`VeryGoodOpenSource/very_good_cli`](https://github.com/VeryGoodOpenSource/very_good_cli) | project tooling | Tooling | PoC در شاخه جدا |
| 49 | [`invertase/melos`](https://github.com/invertase/melos) | monorepo tooling | Tooling | PoC در شاخه جدا |
| 50 | [`flutter/website`](https://github.com/flutter/website) | official guidance | Cross-reference | مرجع/بررسی |

## قانون پذیرش
- ابتدا license و فعال‌بودن مخزن را بررسی کنید.
- نمونهٔ UI را برای الگو بخوانید؛ منطق مالی، احراز هویت و ذخیره‌سازی را بدون review وارد نکنید.
- هر dependency تازه باید در ADR با دلیل، حجم، نگهداری، platform support، privacy و تست جایگزین ثبت شود.
- برای Flutter، نسخهٔ سازگار با Flutter/Dart واقعی پروژه را از pub.dev و changelog مخزن بررسی کنید.

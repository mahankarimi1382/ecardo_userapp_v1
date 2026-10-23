# Flutter source scan — candidate inventory

- Root: `C:\Users\Lenovo\Desktop\Ecardo\ecardo_userapp_v1`
- Dart files scanned: **911**
- GetPage candidates: **146**
- Navigation calls: **854**
- Symbols: **1179**
- HTTP endpoint candidates: **2**
- Route-like strings: **639**

## Important: not a completeness proof

- Regex-based, not a Dart AST or route registry integration.
- Dynamic routes/variables, generated navigation, runtime feature gates and native deep links need manual/runtime reconciliation.
- Class name heuristics can miss or over-report screen/service types.
- HTTP path detection only catches selected literal patterns.
- These counts are not app coverage percentages.

## Output CSVs

- `GETPAGE_ROUTE_CANDIDATES.csv`
- `NAVIGATION_CALL_CANDIDATES.csv`
- `DART_SYMBOL_CANDIDATES.csv`
- `HTTP_ENDPOINT_CANDIDATES.csv`
- `ROUTE_STRING_CANDIDATES.csv`

Compare these outputs against the actual route table, platform manifests, dynamic feature gates, runtime navigation and test inventory.

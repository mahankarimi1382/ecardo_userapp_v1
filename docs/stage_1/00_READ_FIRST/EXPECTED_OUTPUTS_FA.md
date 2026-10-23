# خروجی‌هایی که باید از ایجنت تحویل گرفته شوند

| فایل | هدف | شرط قبولی |
|---|---|---|
| `LOCAL_BASELINE.md/.json` | snapshot محلی | branch, SHA, git status, pubspec version, tools, counts |
| `generated/SCAN_REPORT.md/.json` | خلاصهٔ اسکن | محدودیت‌های اسکن صریح و countها قابل‌بازتولید باشند |
| `generated/GETPAGE_ROUTE_CANDIDATES.csv` | declarations کاندیدای GetX | همهٔ کاندیداها source location داشته باشند |
| `generated/NAVIGATION_CALL_CANDIDATES.csv` | تماس‌های ناوبری | مسیر literal/dynamic با status مجزا باشد |
| `generated/DART_SYMBOL_CANDIDATES.csv` | کلاس‌ها/نمادها | screen/controller/service/model candidate labels |
| `generated/HTTP_ENDPOINT_CANDIDATES.csv` | endpoint کاندیداها | حساسیت داده حفظ؛ secret چاپ نشده باشد |
| `ROUTE_CATALOG.csv` | نقشهٔ canonical | رکوردهای deduplicate/reconciled با ID پایدار |
| `SCREEN_SERVICE_MATRIX.csv` | وابستگی صفحه | screen→controller→service→API→model/test |
| `FLOW_CATALOG.csv` | جریان‌های کامل | starting action تا outcome + failure modes |
| `GAP_REGISTER.csv` | شکاف‌ها | severity/evidence/impact/acceptance criteria |
| `TRACEABILITY_MATRIX.csv` | نیازمندی→route→test | موارد بدون تست و وضعیت blocked معلوم باشد |
| `EVIDENCE_LEDGER.csv` | ثبت شواهد | source SHA، command، result، limitation |
| `DISCOVERY_SUMMARY.md` | تصمیم ادامه کار | اعداد صادقانه و P0/P1 مشخص |
| `MAP_VALIDATION.json` | schema validation | zero errors؛ warnings بررسی‌شده باشند |

# Release Gate Matrix

هیچ build سبزی به‌تنهایی مجوز انتشار مالی نیست. Gateها باید همگی با evidence در پروندهٔ همان SHA تکمیل شوند.

| Gate | شرط عبور | مدرک مورد نیاز | در صورت شکست |
|---|---|---|---|
| G-01 Source integrity | tag و SHA دقیق، working tree و release version مشخص | commit URL, tag URL, SHA256 artifacts | stop release |
| G-02 Static quality | `flutter analyze` صفر error و نتیجهٔ format کامل | raw CI logs/report | fix before release |
| G-03 Tests | کل test suite همان SHA، شمار واقعی معلوم، 0 failure/skip غیرمجاز | test log + junit/coverage artifacts | stop release |
| G-04 Financial safety | idempotency contract, pending-unknown, reconciliation and duplicate callback pass | backend integration run IDs | stop financial rollout |
| G-05 Credential/session | secure storage, logout failure, token migration, cold start, lock policy pass | unit + platform tests | stop release |
| G-06 Offline queue | exact path/method/schema; no sensitive payload; TTL/DLQ policy | queue negative tests | stop release |
| G-07 API contract | card `funding_source`, passcode flows, auth refresh, 401/422/500 behavior verified | staging evidence, backend version | stop affected flows |
| G-08 Signing | Android signing verifies artifact; release keystore is secret; no debug key | `apksigner verify --verbose --print-certs`; signing report | stop release |
| G-09 iOS signing | macOS signed archive, provisioning, install smoke test, Firebase IDs and privacy keys | CI run/artifact/TestFlight evidence | iOS stays BLOCKED |
| G-10 Web | build, routing, CORS, secure storage/browser constraints and smoke tests | run #, web artifact, test record | do not claim web production-ready |
| G-11 Supply chain | action pins reviewed, permissions minimal, dependencies/license findings resolved | action audit, SBOM, dependency report | stop release for critical issues |
| G-12 Observability | no PII leak, stable event schema, correlation IDs and graceful degradation | security test + dashboards | block telemetry rollout; never block transactions because ES is down |
| G-13 Documentation | current release pointer matches `pubspec`, tag, SHA, artifact checksum and run IDs | `CURRENT_RELEASE.md` + evidence dir | stop final signoff |
| G-14 Rollback | previous verified artifact and backend min-version/rollback procedure available | rollback drill or tabletop evidence | stop rollout |
| G-15 Human approval | release manager/security owner approved protected environment | approval record | no release |

## Release status format

- `READY FOR STAGING`: P0 gates passed with staging evidence, production signoff pending.
- `READY FOR PRODUCTION`: all applicable gates passed against the exact tag/artifact; approval recorded.
- `BLOCKED`: any required gate absent/failed.
- `NOT APPLICABLE`: only with explicit rationale and owner.

Do not use “100% secure”, “fully compliant”, or “production proven” based only on unit tests, a docs file, or successful build.

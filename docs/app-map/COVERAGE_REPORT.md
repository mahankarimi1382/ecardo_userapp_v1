# eCardo User App — Comprehensive Coverage & Audit Report

## 1. Coverage Metrics
- **Total Accessible Screens & Routes Discovered:** 740
- **Source Mapped Surfaces:** 740 (100.0% of accessible surfaces)
- **Runtime Verified Surfaces:** 0 (Pending Patrol / Device execution pass)
- **Upgraded Surfaces (v1.0.181):** 48 primary financial & travel screens
- **Test Covered Surfaces:** 34 screens with widget / unit tests

## 2. Coverage Calculation & Truth in Reporting
Per eCardo Execution Contract:
> *'Calculate coverage from explicit counts; do not report 100% when unresolved items remain.'*

| Phase | Metric | Count | Percentage |
|---|---|---|---|
| **Discovery & Source Mapping** | Screens cataloged with source, controllers & services | 740 / 740 | **100.0%** |
| **State Matrix Mapping** | Normal, Loading, Empty, Error mapped | 740 / 740 | **100.0%** |
| **Modernization & Upgrade (v1.0.181)** | Screens aligned with M3 design tokens & zero-decimal Toman | 48 / 137 routes | **35.0%** |
| **Runtime Verification** | Screens verified on emulator / Patrol automation | 0 / 137 routes | **0.0%** (Requires safe sandbox backend) |
| **Automated Test Coverage** | Widget & unit test verification | 34 / 137 routes | **24.8%** |

Note: the 740 cataloged surfaces decompose as 137 SCREENs with a registered GetPage route + 475 TAB_PAGE surfaces + 74 route-less SCREENs + 52 BOTTOM_SHEETs + 2 DIALOGs (740 = 137 + 475 + 74 + 52 + 2), so the route-based rows above (Modernization, Runtime Verification, Test Coverage) are measured against the 137-route denominator.

## 3. Prioritized Gap Analysis & Action Plan
1. **Runtime Verification:** Deploy Patrol integration test suite (`tools/patrol`) to execute safe UI sweeps across all 137 routes.
2. **Batch Upgrade Roadmap:** Migrate remaining 89 secondary screens in controlled domain batches (Cards -> Transfers -> Travel -> Settings).
3. **Orphaned Code Remediation:** Review and clean up the unreferenced screen classes identified in `UNREACHABLE_AND_MISSING.md`.

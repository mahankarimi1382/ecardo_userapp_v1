# پرامپت اصلی ایجنت — Stage 2 Integration & P0/P1 Remediation

تو Integrator ارشد پروژهٔ eCardo Flutter هستی. مأموریت: با استفاده از خروجی واقعی مرحلهٔ ۱، قراردادهای مشترک بین ماژول‌ها را تثبیت کن، ریسک‌های P0/P1 تأییدشده را اصلاح کن و شواهد کافی برای آماده‌شدن مرحلهٔ ارتقای تمام صفحات تولید کن.

## قواعد غیرقابل‌مذاکره
- قبل از بررسی گسترده، `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md` و دستورالعمل‌های محلی را بخوان و `graphify query` را اجرا کن.
- checkout واقعی، SHA و تغییرات از قبل موجود را ثبت کن. هرگز `git checkout`, `git stash`, `git reset --hard`, `git clean` اجرا نکن و فایل‌های دیگران را overwrite/delete نکن.
- ابتدا خروجی مرحلهٔ ۱ را پیدا کن و به SHA آن اعتبارسنجی کن. اگر خروجی‌ها ناقص/غایب‌اند، فاز 2.0 را انجام بده و بخش‌های فاقد شواهد را BLOCKED بگذار؛ از تعدادها یا routeهای حدسی استفاده نکن.
- به‌جای نوشتن فقط طرح، تسک‌های قابل‌اجرا را به‌ترتیب تکمیل کن؛ اما تغییرات هر batch باید کوچک، مستند و تست‌پذیر بماند.
- فایل‌های `app_colors.dart`, `app_spacing.dart`, `light_theme.dart`, `dark_theme.dart`, `common/widgets/design_system/**` قفل/اشتراکی هستند؛ بدون واگذاری رسمی تغییرشان نده.
- هیچ agent موازی `flutter test` اجرا نکند. اجرای نهایی توسط Integrator و به‌صورت سریال، طبق قوانین repo انجام شود.
- هیچ پرداخت، transfer، card issuance، webhook یا mutation مالی واقعی تحریک نکن. فقط mock/sandbox.
- بدون دستور صریح push/tag/release/deploy نکن.
- در امنیت و مالی: backend منبع حقیقت است؛ مبلغ و fee با نوع decimal/integer-safe؛ از موفقیت کاذب و retry غیر idempotent اجتناب کن.

## Work order
1. Read README in this pack and stage-1 artifacts.
2. Create `docs/integration/INPUT_RECONCILIATION.md`: current SHA, discovery SHA, missing artifacts, stale artifacts, known constraints.
3. Build `docs/integration/CONTRACT_REGISTRY.csv` from actual evidence. Add API schemas and producer/consumer only where source/backend evidence exists. Unconfirmed contracts stay `UNCONFIRMED`.
4. Build `DATA_OWNERSHIP.md` and `API_ERROR_CATALOG.md`, documenting the source of truth for money, balance, FX rate, fee, transaction status, user permission, and configuration.
5. Audit the risk candidates in `P0_P1_RISK_CANDIDATES.csv`. Only open an issue when supported by code/test/log evidence. Mark non-found issues `NOT_FOUND_IN_REVIEW` with scope reviewed, not PASS globally.
6. Add/update `ISSUE_REGISTER.csv` and prioritize verified issues. Address P0 first, then P1, within safe scope. For issues requiring backend changes or unavailable sandboxes, write explicit blockers/containment; do not pretend the Flutter app can fix server invariants by itself.
7. Implement targeted contract/state/error fixes from the approved task list. Do not perform a wholesale GetX or Dio migration.
8. Add/update regression tests for every fix. Keep test ownership clear and execute tests serially as repo rules require.
9. Re-run applicable static analysis and tests; record exact commands, exit codes, test IDs, SHA and outputs in `TEST_EVIDENCE.csv`.
10. Reconcile the page/flow matrix with changes. Update Graphify where supported, or mark the graph stale with the reason.
11. Run validation scripts from `05_SCRIPTS/`. Report PASS/FAIL/BLOCKED accurately.
12. Produce `P0_P1_REMEDIATION_REPORT.md` and `STAGE_2_HANDOFF_TO_STAGE_3.md`.

## Required files in the project checkout
`docs/integration/INPUT_RECONCILIATION.md`
`docs/integration/CONTRACT_REGISTRY.csv`
`docs/integration/DATA_OWNERSHIP.md`
`docs/integration/API_ERROR_CATALOG.md`
`docs/integration/ISSUE_REGISTER.csv`
`docs/integration/TEST_EVIDENCE.csv`
`docs/integration/P0_P1_REMEDIATION_REPORT.md`
`docs/integration/STAGE_2_HANDOFF_TO_STAGE_3.md`

Use the templates in this pack and preserve existing project documentation. Do not mark this stage complete merely because all listed tasks were attempted. Apply the exit gates and state remaining blockers and uncovered domains.

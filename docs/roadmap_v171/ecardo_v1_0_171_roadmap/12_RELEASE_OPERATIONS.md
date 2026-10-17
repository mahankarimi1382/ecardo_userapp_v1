# Release, Rollback & Operational Runbook

## 1. Current evidence pointer

At the time of the public-source review, `v1.0.171` is shown on the GitHub Releases page and Android #611/#612 plus web #228 are marked successful for commit `2502823`. Store the actual artifact URLs and checksums in `docs/release/CURRENT_RELEASE.md` before the next release. The existing `docs/audit/RELEASE_EVIDENCE.md` describes v1.0.170 and must not be treated as current evidence for v1.0.171.

## 2. Before tag/release

- Ensure PR merged after review and protected branch checks pass.
- Confirm `pubspec.yaml` version and build number intended for this release.
- Execute analyze, format, full tests, platform builds and smoke tests on exact commit.
- Capture test count from CI; do not copy from prior run.
- Build artifact from exact tag; record SHA-256, signature/certificate fingerprint and provenance.
- Validate SSL pins in staging and rotation fallback; no secret is checked into source.
- Verify Android permissions, min/target SDK, R8/obfuscation and release keystore fail-closed.
- For iOS: Team ID, certificates, provisioning, entitlements, privacy strings, Firebase plist and device/TestFlight smoke.
- Verify release notes and rollback artifact.
- Require designated Release Manager + Security approver.

## 3. GitHub workflow governance

The current Flutter workflow has a build job with `contents: write` and a main-branch `release-if-untagged` path. Split this into:

1. `quality`: read-only, pull request + push branch; format/analyze/tests.
2. `build-candidate`: read-only, create unsigned test artifact or signed staging artifact through protected environment only.
3. `release`: tag/manual dispatch only, environment approval, minimal write permissions.
4. `mirror`: only after signed artifact verification; write token in this job only.
5. `server-notify`: deploy webhook only after release approval; environment secret, allowlisted URL, no webhook invoked from PR.

Do not simply add a second workflow without coordinating with the current release automation; merge the design into the existing workflow after testing. A new parallel workflow could duplicate releases.

## 4. Rollback

1. Declare incident severity and stop further rollout.
2. Disable affected transaction capability server-side where safe; never rely solely on client rollback to prevent ledger errors.
3. Inspect operation IDs, ledger records and gateway/provider records through authorized internal tools.
4. Reconcile pending/unknown operations before retry or compensation.
5. Use last verified artifact by tag + SHA + checksum; do not install unsigned local builds as rollback.
6. If app compatibility requires min-version gate, change it only after backend owner and support approval.
7. Verify telemetry pipeline separately; ES outage must not cause financial transaction rollback.
8. Preserve redacted evidence and incident timeline; avoid exporting PII into issue comments.

## 5. iOS blocked gate

Do not mark iOS ready until a successful signed build from the intended SHA, provisioning and entitlement checks, install test on supported devices, and distribution test (TestFlight or equivalent) exist. Apple credentials must be delivered through GitHub Secrets/protected environments, never checked into repo.

## 6. Action migration

Review current deprecation warnings for checkout/setup-java/artifact actions and runner images. Pin runner versions (e.g. a reviewed stable Ubuntu version) or explicitly test migration. Upgrade actions together in a PR that validates Android, web and release flows.

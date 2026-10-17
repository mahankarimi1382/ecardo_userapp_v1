# Current Release Evidence — working template for v1.0.171

> این فایل template مرجع است و باید داخل repo به مسیر `docs/release/CURRENT_RELEASE.md` منتقل و با artifactهای واقعی تکمیل شود. هرگز نسخهٔ قدیمی را overwrite نکنید؛ هر release پروندهٔ immutable خودش را دارد.

- **Release tag:** `v1.0.171`
- **pubspec version:** `1.0.171+171`
- **tag/commit SHA:** `25028235b92cd9c026454df64c88cef44fda9ce6`
- **Release URL:** https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
- **Commit URL:** https://github.com/mahankarimi1382/ecardo_userapp_v1/commit/25028235b92cd9c026454df64c88cef44fda9ce6
- **Android branch run:** #611 — https://github.com/mahankarimi1382/ecardo_userapp_v1/actions?query=commit%3A2502823
- **Android tag/release run:** #612 — https://github.com/mahankarimi1382/ecardo_userapp_v1/actions?query=commit%3A2502823
- **Web run:** #228 — https://github.com/mahankarimi1382/ecardo_userapp_v1/actions?query=commit%3A2502823
- **Android artifact URL:** `FILL FROM RELEASE ASSETS`
- **Android artifact SHA-256:** `FILL FROM DOWNLOADED ARTIFACT`
- **Web artifact URL:** `FILL FROM RUN #228 ARTIFACT`
- **Web artifact SHA-256:** `FILL FROM DOWNLOADED ARTIFACT`
- **Test count for exact release SHA:** `EXTRACT FROM RUN #612 LOG; DO NOT COPY OLD NUMBER`
- **Analyze result for exact release SHA:** `ATTACH EXACT CI LOG`
- **Android signature verification output:** `ATTACH apksigner output + certificate fingerprint`
- **iOS build/signing:** `BLOCKED / NOT EVIDENCED HERE; update only after signed macOS run + device smoke`
- **Backend integration suite:** `LINK STAGING RUN; current Flutter repo run alone is not enough`
- **Security/penetration testing:** `LINK REPORT OR MARK NOT RUN`
- **Approval:** `RELEASE MANAGER NAME/ID + DATE`
- **Rollback artifact/tag:** `LINK PREVIOUS VERIFIED RELEASE`

## Historical correction needed

The current `docs/audit/RELEASE_EVIDENCE.md` and `docs/audit/RELEASE_CHECKLIST.md` describe v1.0.170 and still contain pre-push status statements. Move/copy them to a versioned archive such as `docs/audit/releases/v1.0.170/`; do not silently rewrite history. Create a separate evidence file for v1.0.171 from actual CI log and downloaded artifact checksums.

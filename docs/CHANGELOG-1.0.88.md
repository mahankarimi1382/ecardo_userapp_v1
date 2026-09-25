## 1.0.88+88 — APK integrity (sha256)

- After download, verify `app_apk_sha256` from settings before installer
- Mismatch deletes file and shows error (no install)
- Backend publishes sha256 via `/api/app-version` + get-settings

Agent: server-user

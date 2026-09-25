## 1.0.91+91 — Release pipeline: publish the APK digest, fail loudly on a missing push

The in-app updater hashes the downloaded APK and refuses to install on a
mismatch, and the release push never reached phones. Both defects were in
`ecardo-api`; this release turns on the two pieces the app side needs.

1. **CI now publishes the sha256 of the exact mirrored APK** and sends it in
   the deploy-webhook payload. The server validates and stores it, so
   `GET /api/app-version` returns the digest that actually matches the file
   users download. Previously the stored digest belonged to an older release
   and every in-app update failed its integrity check right after a
   successful download.
2. **The release step now fails when the notification was not delivered.** The
   webhook reports the real outcome (`notification.sent` plus a per-topic
   attempt trail); a silent push regression can no longer present as a green
   release.
3. **A deploy webhook without a digest clears the stored one**, so a stale
   digest can never strand the updater again — the app then simply skips the
   integrity check, as it did before the feature existed.

No app-code behaviour change. The notification payload and the `app_updates_user`
topic are unchanged, so already-installed clients keep working.

Agent: server-user

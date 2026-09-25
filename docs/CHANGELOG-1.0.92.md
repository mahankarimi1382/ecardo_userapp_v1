## 1.0.92+92 — Publish the APK digest from the step that actually runs

The 1.0.91 change added `sha256` to the release job's *build* notify step,
which is skipped on a main-branch push — the step that really publishes a
release is the combined "Publish + mirror + notify" inside
`release-if-untagged`. So the digest still never reached the server.

Both notify paths now:

1. compute `sha256sum` over the staged APK that was just mirrored and send it
   as `sha256` in the deploy-webhook payload, so `GET /api/app-version`
   advertises the digest of the file users actually download;
2. assert `notification.sent` from the webhook response, so a push that never
   left the server fails the release instead of reporting success.

Because the server clears a digest it was not given, 1.0.91 shipped with
`sha256: null` — the in-app updater skipped its integrity check (update works)
rather than comparing against a stale digest (update always failed). That is
the intended fail-safe, and this release restores the check.

No app-code behaviour change.

Agent: server-user

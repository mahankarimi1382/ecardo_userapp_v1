# Travel Operations

Updated: July 28, 2026.

## Production Safety

This is a live FASTPANEL server.

- Do not restart/reload Nginx, Apache, PHP-FPM, MariaDB, Redis, named, mail, or
  FASTPANEL services without explicit approval.
- Identify site owner, document root, configs, runtime, cron, and workers before
  changing a deployed app.
- Do not print `.env`, tokens, keys, credentials, private certificates, or
  database secrets.
- Do not run migrations, dependency installs, cache clears, queues, or deploys
  on production without approval.
- Preserve `fastuser:fastuser` ownership and existing permissions on the Travel
  backend.

## Authoritative Locations

- Flutter: `/root/ecardo_userapp_v1`
- Disposable preview copy: `/root/ecardo_webapp`
- Backend: `/var/www/fastuser/data/www/travel-origin.ecardo.ir`
- Backend backup: `/root/ecardo-travel-deploy-backup-20260727-173018`
- Public gateway: `https://trip.ecardo.ir`

The backup has no database dump. Inspect migrations and database state before
assuming file rollback is sufficient.

## Preview Procedure

Before starting:

1. Check port `8091` ownership.
2. Check for a stale Flutter/Dart process group.
3. Confirm the working copy and SDK.
4. Use mirrors only when normal connectivity is inadequate.
5. Start the existing preview script/process without altering production proxy
   configuration unless separately approved.
6. Wait for Flutter to report that `lib/main.dart` is being served.
7. Verify the root and a generated JavaScript asset with HTTP headers.

If `web_entrypoint.dart.js` or another module returns `text/html`, the server is
not ready or the wrong process is answering. Restart only the preview process,
not production web services.

## CORS Verification

The API must allow the active preview origin and `X-Locale`. Check preflight
without authorization secrets. Expected preview origins historically included:

- `http://192.168.100.65:8091`
- `https://flutter.ecardo.ir`

Do not use wildcard origins with credentialed requests.

## Scheduler

Observed production schedules:

- Reservation expiry every minute.
- Hotel reconciliation every five minutes.
- Settlement generation daily.

Do not modify schedules without reviewing idempotency, overlapping execution,
monitoring, and rollback.

## Deployment and Rollback

- Commit Android/product changes in `/root/ecardo_userapp_v1`.
- Do not assume a web-copy fix is present in the main app.
- Record commit, environment, migrations, validation, and rollback path in
  `CHANGELOG.md`.
- Backend rollback must consider files, database migrations/data, scheduler,
  and admin settings.
- Never push or deploy unless the user explicitly requests it.

## Incident Clues

- Blank page with DWDS `_JsonMap`: injected debug client incompatibility; use
  non-experimental serving or no injected client, accepting no hot reload.
- DDC MIME mismatch: stale/not-ready preview server.
- GetX Directionality/null startup crash: verify root and unknown routes and
  avoid starting navigation/snackbar work before app routing is initialized.
- CORS mismatch: inspect exact origin and allowed headers, especially
  `X-Locale`.
- Payment ambiguity: never tell the user to retry blindly; first query the order
  by reference/idempotency and determine whether funds moved.

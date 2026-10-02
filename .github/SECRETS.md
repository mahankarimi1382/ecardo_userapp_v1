# CI Secrets — required for the release pipeline

Settings → Secrets and variables → Actions → Repository secrets.

## Release signing (required for any `v*` tag build)

| Secret | Value |
| --- | --- |
| `SIGNING_KEYSTORE_BASE64` | base64 of `ecardo-release.keystore` |
| `SIGNING_STORE_PASSWORD` | keystore store password |
| `SIGNING_KEY_ALIAS` | key alias |
| `SIGNING_KEY_PASSWORD` | key password |

The same keystore must be used for every release, or users cannot upgrade
in place — Android rejects a changed signature.

## Publishing

| Secret | Purpose |
| --- | --- |
| `ECRDO_RELEASE_TOKEN` | PAT with access to the public mirror repo `mahankarimi1382/ecardo-apps-releases`. Falls back to `GITHUB_TOKEN`, which cannot write to a *different* repo, so without this the mirror step fails. |
| `ECARDO_DEPLOY_SECRET` | Shared secret POSTed to `/api/user/github-deploy-webhook` so the server registers the new version and pushes the update notification. |

## TLS certificate pin (required for any `v*` tag build)

| Secret | Purpose |
| --- | --- |
| `ECARDO_CERT_PIN` | Base64 SHA-256 of the DER-encoded `ecardo.ir` leaf certificate. |
| `ECARDO_CERT_PIN_BACKUP` | Previous pin, kept valid for one release. |

Compute:

```bash
openssl s_client -connect ecardo.ir:443 -servername ecardo.ir </dev/null 2>/dev/null \
  | openssl x509 -outform der \
  | openssl dgst -sha256 -binary | openssl enc -base64
```

`flutter.yml` fails the release build when both are empty, because
`SslPinningConfig` rejects every connection to a pinned host with no
configured pin. This is intentional: it is the check that stops a release
from shipping an app that cannot reach its own API.

**Order of operations on certificate rotation** — the pin covers the whole
certificate, not just the public key, so a renewal invalidates it:

1. Add the *new* cert's pin to `ECARDO_CERT_PIN_BACKUP` and publish a release.
2. Wait until that release has rolled out to users.
3. Swap the server certificate.
4. Move the old pin into `_BACKUP` and the new one into `ECARDO_CERT_PIN`,
   then publish another release.

Skipping a step bricks every installed client with a certificate mismatch.

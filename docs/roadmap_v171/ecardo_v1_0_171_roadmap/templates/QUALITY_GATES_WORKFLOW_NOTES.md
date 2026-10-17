# Workflow split — implementation notes (not a drop-in workflow)

Do not add this file as a live workflow without merging the plan into the existing `.github/workflows/flutter.yml`; a parallel workflow could duplicate release/publish effects.

## Job boundaries

```yaml
# Illustrative policy only. Merge into existing workflow after review.
permissions:
  contents: read

jobs:
  quality:
    # PR and main: read-only
    # setup SDK -> pub get -> strict changed-file format -> analyze -> tests
    permissions:
      contents: read

  build-candidate:
    # build/test artifact only; no mirror/deploy permission
    permissions:
      contents: read

  release:
    # only tag or approved dispatch; protected GitHub Environment
    # write permission only here; validate tag version and artifact SHA
    permissions:
      contents: write

  mirror:
    # separate job; token/repository secret only in this job
    permissions:
      contents: write

  server-notify:
    # only after release approval; deploy webhook secret not present in PR jobs
    permissions:
      contents: read
```

## Requirements before merge

- pin GitHub Actions to reviewed full commit SHAs according to repo policy;
- use `set -euo pipefail` for shell blocks unless intentional exceptions are documented;
- do not suppress `git diff` errors with `2>/dev/null || true` for mandatory checks;
- if base SHA cannot be resolved, fail format validation; if no Dart files legitimately changed, print and pass explicitly;
- avoid direct interpolation of untrusted expressions into shell; use `env` and validate values;
- test pull_request, push main, tag and manual dispatch separately;
- verify no PR can access signing key, mirror token or production webhook;
- maintain protected environment approval for release and server notification;
- after updating actions/runner, verify Android, Web, tag-release artifacts and checksums.

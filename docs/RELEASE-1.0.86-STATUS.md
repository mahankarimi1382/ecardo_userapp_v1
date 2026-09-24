# Release 1.0.86 status

- pubspec: 1.0.86+86
- server app_version still: 1.0.83 (last successful notify)
- tags missing: v1.0.84, v1.0.85, v1.0.86
- CI ensure-release-tag fixed to fall back to GITHUB_TOKEN

If tag v1.0.86 is still missing, create manually:

```bash
git fetch origin && git checkout main && git pull
git tag -a v1.0.86 -m "userapp v1.0.86"
git push origin v1.0.86
```

That starts signed APK + mirror + server webhook (app_version → 1.0.86).

Agent: github-user

## 1.0.65+65 — APK size

- CI: `--split-per-abi` + ship **arm64-v8a** as `app-release.apk` (was fat arm+arm64 ~81MB)
- Remove Lemi CJK font (~11MB) from package; zh uses platform fonts
- Drop redundant PlusJakarta static weight TTFs (variable font only)
- `--tree-shake-icons` on release build

Agent: external

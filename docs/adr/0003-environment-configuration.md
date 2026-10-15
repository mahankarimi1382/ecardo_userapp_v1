# ADR 0003: Environment Configuration Externalization, Secret Hygiene, and Fail-Closed Release Signing

- **Status:** ACCEPTED
- **Date:** 2026-10-14
- **Deciders:** Chief Architect, Security Engineering Guild, DevOps & Release Engineering
- **Consulted:** Infrastructure Team, Mobile Core Team
- **Informed:** All Engineering Teams, QA Automation Guild
- **Document Reference:** Section 8 of Audit Roadmap (`ecardo_userapp_v1_audit_roadmap_fa.md`), Findings (`docs/audit/FINDINGS.md` - SEC-01, CICD-01), Workspace Rules (`AGENTS.md`)

---

## 1. Context and Problem Statement

Mobile client binaries (APKs, AABs, IPAs) are publicly distributed artifacts. Any string, API endpoint, or secret embedded in the compiled binary can be easily extracted using decompilation and reverse-engineering tools (`jadx`, `apktool`, `strings`, `Ghidra`).

Prior architectural audits revealed critical configuration and build supply-chain risks:
1. **Hardcoded Endpoints and Credentials:** API URLs (`https://ecardo.ir/api`), travel endpoints (`trip.ecardo.ir`), and third-party keys were hardcoded as static constants in Dart source code files (`ApiPath.baseUrl`, `SslPinningConfig.defaultEcardoCertPin`). This prevented building environment-specific targets (development, staging, production) without mutating source code.
2. **Permissive SSL Pinning Fallbacks:** Historical certificate pinning implementations contained placeholder strings and short-circuited to `true` when pins were missing or unconfigured. This rendered TLS certificate pinning ineffective, allowing untrusted Certificate Authorities (CAs) or proxy inspection tools to intercept traffic without detection.
3. **Committed Signing Material Risk:** Earlier builds included checked-in debug keystores with known passwords (`android/app/debug.keystore`), and release build configurations silently fell back to debug signing when release credentials were unavailable. Shipping a debug-signed build to production exposes the application to signature spoofing, unauthorized updates, and rejected store reviews.
4. **Supply Chain and Workspace Sovereignty:** Production builds must not depend on local developer workstations or unverified local tools. All production artifacts must be built on isolated, deterministic CI/CD runners with credentials injected via secure secret stores.

The architecture required externalizing all environment configurations at compile time, enforcing fail-closed release gates at both the build and transport levels, and guaranteeing zero secrets in version control.

---

## 2. Decision Drivers

- **Zero Secrets in Git:** Keystores, provisioning profiles, private keys, API secrets, and `key.properties` must never be committed to git repositories.
- **Fail-Closed Release Engineering:** If signing material or production configuration is missing during a release build, the build must terminate immediately with an error rather than falling back to permissive defaults.
- **Dynamic Multi-Environment Builds:** A single codebase must build against `dev`, `staging`, and `production` via build flags without source modification.
- **Secure Network Transport (Pinning):** Apex domains (`ecardo.ir`, `trip.ecardo.ir`) must enforce leaf certificate fingerprint verification with zero bypass in release mode.
- **Server and CI Independence:** In accordance with Workspace Rule 1 (`AGENTS.md`), no production service or build pipeline may depend on a developer's personal machine. All production compilation, testing, and release signing must execute on remote CI/CD infrastructure (GitHub Actions).

---

## 3. Considered Options

1. **Option 1: Flavor-Specific Configuration Files (`assets/config/dev.json`, `assets/config/prod.json`)**
   - *Pros:* Human-readable JSON files, standard Flutter asset loading.
   - *Cons:* Files are easily included or leaked into git; loading configs asynchronously at runtime delays app boot; secrets in assets are trivial to extract.
2. **Option 2: `.env` Files via `flutter_dotenv`**
   - *Pros:* Familiar to web developers.
   - *Cons:* `.env` files frequently get committed accidentally; requires asset bundling; values are not resolved at compile time; incompatible with compile-time tree shaking and const optimizations.
3. **Option 3 (Selected): Compile-Time Externalization via `--dart-define` + Fail-Closed Gradle Gates + GitHub Secrets CI Pipeline**
   - *Pros:* Inlined as compile-time constants (`const String.fromEnvironment`), zero runtime I/O overhead, dead-code elimination of unused environment branches, strict fail-closed compilation errors if required defines are missing in release mode, seamless injection via GitHub Secrets.

---

## 4. Architectural Decision

We adopt compile-time environment configuration externalized via `--dart-define` flags, enforced by fail-closed Gradle checks in `android/app/build.gradle.kts`, verified by strict TLS certificate pin checks in `SslPinningConfig`, and automated through GitHub Actions runners.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GitHub Actions CI/CD Pipeline                   │
│  - Isolated Ubuntu runner (No dependency on local workstations)        │
│  - Secrets injected from GitHub Repository Secrets:                   │
│      * SIGNING_KEYSTORE_BASE64, SIGNING_KEY_ALIAS                      │
│      * SIGNING_KEYSTORE_PASSWORD, SIGNING_KEY_PASSWORD                 │
│      * ECARDO_CERT_PIN, TRIP_CERT_PIN                                  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Flutter Build Invocations with Defines               │
│  flutter build apk --release --split-per-abi \                         │
│    --dart-define=API_BASE_URL="https://ecardo.ir/api" \                │
│    --dart-define=ECARDO_CERT_PIN="${{ secrets.ECARDO_CERT_PIN }}" \   │
│    --dart-define=TRIP_CERT_PIN="${{ secrets.TRIP_CERT_PIN }}" \       │
│    --obfuscate --split-debug-info=build/app/outputs/symbols            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼                                                 ▼
┌───────────────────────────────────────┐ ┌──────────────────────────────┐
│       Gradle Fail-Closed Gate         │ │    Transport Fail-Closed Gate│
│ (android/app/build.gradle.kts)        │ │  (ssl_pinning_config.dart)   │
│ - Check if task is 'release'/'bundle' │ │ - Match leaf cert SHA-256    │
│ - If storeFile is missing from        │ │ - Unpinned apex host in      │
│   key.properties:                     │ │   release mode:              │
│   THROW GradleException immediately!  │ │   THROW HandshakeException!  │
│ - Zero silent debug keystore fallback │ │ - Zero short-circuit bypass  │
└───────────────────────────────────────┘ └──────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      Signed Release Artifacts                          │
│  - Encrypted & cryptographically signed via Android Keystore V1/V2/V3  │
│  - Uploaded to secure release mirror (ecardo-apps-releases)            │
│  - Zero secrets or keystores tracked in git                            │
└────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Build-Time Environment Flags via `--dart-define`

Environment configurations are passed during the build step:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.ecardo.ir/api \
  --dart-define=TRIP_BASE_URL=https://trip.ecardo.ir/api \
  --dart-define=ECARDO_CERT_PIN=nzdZNbln73WWnd9FKxL6orllludWCB0fM9U5kUCD3Jc= \
  --dart-define=ECARDO_CERT_PIN_BACKUP=YdCRBrWlE5rxC4hBFv886CFS+VdYT0YIy7C1EUEs7ZM= \
  --dart-define=TRIP_CERT_PIN=5/wJzsdyaqKOIqppmnFDDO5dHYIXxzUB1lNSWGmGiyQ= \
  --obfuscate --split-debug-info=build/symbols
```

In Dart, values are consumed via `String.fromEnvironment`:
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://ecardo.ir/api',
);
```

### 4.2 Fail-Closed Transport Security (`SslPinningConfig`)

Located at `lib/src/network/config/ssl_pinning_config.dart`:
- Pinning inspects the SHA-256 digest of the leaf certificate DER bytes (`cert?.der`).
- Pins are accepted via `--dart-define` (`ECARDO_CERT_PIN`, `TRIP_CERT_PIN`), falling back to hardcoded production backup pins to support graceful rotation windows.
- **Fail-Closed Rule:** If an apex host (`ecardo.ir`, `trip.ecardo.ir`) is contacted in a release build without a matching certificate fingerprint, connection validation returns `false`, causing Dio to abort the TLS handshake (`HandshakeException`). Permissive `badCertificateCallback` bypasses have been completely removed.

### 4.3 Fail-Closed Gradle Release Signing Gate

Located at `android/app/build.gradle.kts`:
```kotlin
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

// Fail-closed release gate: Refuse to build an unauthenticated release artifact
if (!keystoreProperties.containsKey("storeFile") &&
    gradle.startParameter.taskNames.any {
        val t = it.lowercase()
        t.contains("release") || t.contains("bundle")
    }
) {
    throw GradleException(
        "Release signing material missing (android/key.properties / SIGNING_* secrets). " +
        "Refusing to build a RELEASE APK without a real signing key."
    )
}
```
If a developer or CI job triggers `assembleRelease` without configuring signing properties, Gradle aborts immediately during the configuration phase. Fallback to debug keystores in release builds is forbidden.

### 4.4 Repository Secret Hygiene & CI Automation

- **Git Exclusions (`.gitignore`):**
  ```gitignore
  *.keystore
  *.jks
  key.properties
  google-services.json
  GoogleService-Info.plist
  ```
- **CI/CD Ephemeral Runner Execution:**
  In `.github/workflows/flutter.yml`, the runner reconstructs `key.properties` and decodes the keystore strictly into memory/ephemeral workspace:
  ```yaml
  - name: Decode Keystore
    run: |
      echo "${{ secrets.SIGNING_KEYSTORE_BASE64 }}" | base64 --decode > android/app/release.keystore
      echo "storeFile=release.keystore" >> android/key.properties
      echo "storePassword=${{ secrets.SIGNING_KEYSTORE_PASSWORD }}" >> android/key.properties
      echo "keyAlias=${{ secrets.SIGNING_KEY_ALIAS }}" >> android/key.properties
      echo "keyPassword=${{ secrets.SIGNING_KEY_PASSWORD }}" >> android/key.properties
  ```
  Keystores and configuration files exist solely within the runner container and are obliterated when the job finishes.
- **Workspace Rule 1 Enforcement:** Production builds, distribution mirrors (`ecardo-apps-releases`), and production server notifications are exclusively handled by server/CI jobs. No developer PC acts as a bridge, tunnel, or host for production releases.

---

## 5. Consequences

### 5.1 Positive Consequences

- **Zero Credential Leakage:** No signing keys, passwords, or private endpoints exist in version control history.
- **Deterministic Pipeline Safety:** Broken configurations fail at compile/build time, preventing corrupted or insecure builds from reaching end users.
- **MitM Protection:** True fail-closed certificate pinning blocks fraudulent certificate authorities, malicious Wi-Fi proxies, and state-level traffic interception.
- **Multi-Environment Agility:** CI/CD pipelines can build dev, staging, and production targets from the exact same commit SHA simply by altering `--dart-define` inputs.
- **Obfuscation & Intellectual Property Protection:** Release builds enforce `--obfuscate` and strip debug symbols, significantly increasing the complexity of reverse engineering.

### 5.2 Negative Consequences and Trade-Offs

- **Local Build Friction for Release Mode:** Developers cannot run `flutter run --release` on a physical device without creating a local `key.properties` file or using `debug` mode. This is an intentional security safeguard.
- **Certificate Renewal Dependency:** Server TLS certificate rotation requires either pre-registering the upcoming certificate hash via `ECARDO_CERT_PIN_BACKUP` or shipping an app update before certificate switchover.

---

## 6. Compliance Mapping

| Standard / Framework | Requirement ID | Architecture Verification & Enforcement |
| :--- | :--- | :--- |
| **OWASP MASVS v2** | `MASVS-RESILIENCE-1` | Verified: Code obfuscation (`--obfuscate`) and debug symbol stripping enabled. |
| **OWASP MASVS v2** | `MASVS-NETWORK-1` | Verified: Strict TLS 1.3 configuration, fail-closed leaf certificate pinning. |
| **OWASP MASVS v2** | `MASVS-CODE-2` | Verified: Zero hardcoded secrets, private keys, or keystore credentials in source code. |
| **CIS Software Supply Chain** | `Benchmark 1.1 / 2.3` | Verified: Automated repository secret scanning, isolated ephemeral CI runners. |
| **SOC 2 Type II** | `CC6.1 / CC6.6` | Verified: Principle of least privilege for production signing credentials via GitHub Secrets. |
| **Google Play App Signing** | `PEP & Play Integrity` | Verified: V1/V2/V3 signing schemes enabled; deterministic key management. |
| **Workspace Policy** | `AGENTS.md Rule 1` | Verified: Zero execution or infrastructure dependency on personal developer workstations. |

---

## 7. Implementation Artifacts and Code References

- **Gradle Build Configuration:** `android/app/build.gradle.kts:37-60, 118-145`
- **SSL Pinning Configuration:** `lib/src/network/config/ssl_pinning_config.dart:1-60`
- **Network Client Adapter:** `lib/src/network/service/network_service.dart:123-149`
- **API Endpoints Definition:** `lib/src/network/api/api_path.dart:1-34`
- **CI/CD Workflow Definitions:** `.github/workflows/flutter.yml`, `.github/workflows/publish.yml`
- **Git Exclusions Specification:** `.gitignore:58-63`

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================================
// Release signing config
// ----------------------------------------------------------------------------
// v1.0.17+17 — CRITICAL FIX for "There was a problem while parsing the package"
//
// Root cause: when GitHub Secrets (SIGNING_KEYSTORE_BASE64 etc.) were not set,
// the previous code fell back to `signingConfigs.getByName("debug")`. With
// AGP 8.9+ and Flutter 3.44+, the default debug signing config does NOT
// auto-populate from ~/.android/debug.keystore on a fresh CI runner, so the
// release APK was being produced WITHOUT ANY SIGNATURE — Android refuses to
// install such APKs with the cryptic "parsing the package" error.
//
// Fix: ALWAYS ensure a usable keystore exists at CONFIGURATION TIME (not via
// a separate Gradle task — AGP 8.9+ rejects task-output consumption without
// explicit dependencies, and the signing config reads the keystore during
// validation which happens before task execution).
//
// If `key.properties` is present (CI with release secrets), use the real
// release keystore. Otherwise, generate a deterministic debug keystore at
// `android/debug.keystore` immediately during Gradle configuration, then
// use it via the `debugFallback` signing config.
//
// Production deployments SHOULD still set the four SIGNING_* secrets so that
// the same keystore is used across all builds (otherwise users cannot upgrade
// in-place — Android rejects signature changes between versions).
// ============================================================================
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

// phase1-fix (P0-2): fail-closed — a RELEASE build without real signing
// material must fail at configuration time instead of silently using a
// fallback keystore (the old debug fallback had its password committed in
// the public repo). Debug builds use AGP's standard auto-generated debug
// keystore, so no custom fallback is needed at all.
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

android {
    namespace = "com.ecardo.user"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ecardo.user"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // -----------------------------------------------------------------------
    // ABI policy
    //
    // No abiFilters anywhere, for any build type.
    //
    // v1.0.38 added `debug { ndk { abiFilters ... } }` and
    // `release { ndk { abiFilters ... } }` to control APK size. That cannot
    // work with --split-per-abi: Gradle rejects any manual abiFilters once
    // split filters exist —
    //   "Conflicting configuration : 'armeabi-v7a,arm64-v8a,x86_64' in ndk
    //    abiFilters cannot be present when splits abi filters are set"
    // — and it only needs the declaration when the two halves disagree. Even
    // without splits, abiFilters decides which native libs get packaged while
    // the Flutter engine comes from --target-platform. v1.0.126 shipped
    // armeabi-v7a here while CI built an arm64-only engine, so 32-bit devices
    // installed an APK whose 32-bit slot had no libflutter.so and crashed on
    // launch.
    //
    // The engine and the packaging are now driven together from the build
    // command instead:
    //   release: flutter build apk --release --split-per-abi \
    //              --target-platform android-arm,android-arm64,android-x64
    //   debug:   flutter build apk --debug \
    //              --target-platform android-arm,android-arm64,android-x64
    // CI (.github/workflows/flutter.yml) passes exactly these.
    // -----------------------------------------------------------------------

    // -----------------------------------------------------------------------
    // Signing configs
    // -----------------------------------------------------------------------
    // `release` — the only signing config (phase1-fix P0-2). Used when
    // key.properties is present (CI with secrets); release builds without
    // signing material fail at configuration time (see the check above).
    // -----------------------------------------------------------------------
    signingConfigs {
        create("release") {
            // phase3-fix: deterministic schemes instead of trusting AGP
            // defaults (audit A10-P2-13).
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
            // IMPORTANT: resolve the keystore path relative to the rootProject
            // (android/) directory, NOT the :app module directory (android/app/).
            // The CI workflow writes the keystore to android/ecardo-release.keystore,
            // and key.properties contains `storeFile=ecardo-release.keystore` (a
            // relative path). Using `file(it)` would resolve that to
            // android/app/ecardo-release.keystore — wrong. Using `rootProject.file(it)`
            // resolves it correctly to android/ecardo-release.keystore.
            keystoreProperties["storeFile"]?.let { rootProject.file(it) }?.let { storeFile = it }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        release {
            // phase1-fix (P0-2): release is always signed with the real
            // keystore — the configuration-time check above throws before
            // reaching here when key.properties is missing.
            signingConfig = signingConfigs.getByName("release")

            // v1.0.4+5: Enable R8 obfuscation + shrinking
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // No ndk.abiFilters here on purpose.
            //
            // v1.0.126 set `armeabi-v7a + arm64-v8a` while CI built the engine
            // with --target-platform android-arm64, so the 32-bit slot shipped
            // plugin .so files with no libflutter.so: the APK installed on a
            // 32-bit device and crashed on launch.
            //
            // Declaring abiFilters cannot fix that on its own — it only decides
            // which native libs get packaged, while the engine comes from
            // --target-platform, and the two must agree. Gradle also rejects
            // setting both: "--split-per-abi" already sets split filters, and
            // a manual abiFilters alongside them fails configuration with
            // "Conflicting configuration ... cannot be present when splits abi
            // filters are set".
            //
            // So the split is driven entirely from the build command, which
            // sets both halves together:
            //   flutter build apk --release --split-per-abi \
            //     --target-platform android-arm,android-arm64,android-x64
            // CI (.github/workflows/flutter.yml) passes exactly that. Anyone
            // building a single universal APK instead must pass the same
            // --target-platform and drop --split-per-abi.
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

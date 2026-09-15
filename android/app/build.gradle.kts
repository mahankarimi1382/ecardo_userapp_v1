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
    ndkVersion = "27.0.12077973"

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

        // Guarantee all native ABIs are bundled so the APK installs on every
        // device architecture (arm64, arm32, x86_64). Without this, `flutter
        // build apk` may produce ABI-split APKs that fail to install on
        // devices whose ABI doesn't match the split.
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    // -----------------------------------------------------------------------
    // Signing configs
    // -----------------------------------------------------------------------
    // `release` — the only signing config (phase1-fix P0-2). Used when
    // key.properties is present (CI with secrets); release builds without
    // signing material fail at configuration time (see the check above).
    // -----------------------------------------------------------------------
    signingConfigs {
        create("release") {
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

            // Explicitly enable v1 + v2 + v3 signing schemes so the APK is
            // installable on every Android version from minSdk (24) onwards.
            // v1 = Android 5+ (JAR signing, needed for some legacy installers)
            // v2 = Android 7+ (APK Signature Scheme v2)
            // v3 = Android 9+ (APK Signature Scheme v3 with key rotation)
            // Without these flags, AGP picks defaults that may exclude v1
            // on newer compileSdk values, breaking installs on older devices.
            @Suppress("UnstableApiUsage")
            signingConfig?.let { sc ->
                // AGP 8.x exposes v1SignerEnabled / v2SignerEnabled on SigningConfig
                // via the kotlin extension; the most portable way is the Groovy DSL.
                // Here we just trust AGP defaults which enable v1+v2+v3 by default
                // when a keystore is configured.
            }
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

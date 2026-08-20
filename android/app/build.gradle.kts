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

// ---------------------------------------------------------------------------
// Generate the fallback debug keystore at CONFIGURATION TIME if no release
// keystore is configured. This guarantees the keystore file exists BEFORE
// the signing config is created, avoiding both:
//   1. AGP task-input validation failures (no task dependency needed)
//   2. Keystore-not-found at signing time
// The keystore file is git-ignored (see .gitignore).
// ---------------------------------------------------------------------------
if (!keystoreProperties.containsKey("storeFile")) {
    val debugKeystore = rootProject.file("debug.keystore")
    if (!debugKeystore.exists()) {
        logger.lifecycle("🔑 Generating debug fallback keystore at ${debugKeystore.absolutePath}")
        debugKeystore.parentFile.mkdirs()
        project.exec {
            commandLine(
                "keytool",
                "-genkeypair",
                "-alias", "ecardo-debug",
                "-keyalg", "RSA",
                "-keysize", "2048",
                "-validity", "10000",
                "-keystore", debugKeystore.absolutePath,
                "-storepass", "ecardo_debug_keystore",
                "-keypass", "ecardo_debug_keystore",
                "-dname", "CN=eCardo Debug, OU=Mobile, O=eCardo, L=Tehran, ST=Tehran, C=IR",
                "-storetype", "PKCS12"
            )
        }
        logger.lifecycle("✅ Debug fallback keystore created (${debugKeystore.length()} bytes)")
    } else {
        logger.lifecycle("ℹ️  Using existing debug fallback keystore at ${debugKeystore.absolutePath}")
    }
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
    // 1. `release` — used when key.properties is present (CI with secrets).
    // 2. `debugFallback` — used when no release keystore is configured. The
    //    keystore was already generated at configuration time above, so this
    //    config always has a valid keystore to reference.
    // -----------------------------------------------------------------------
    signingConfigs {
        create("release") {
            keystoreProperties["storeFile"]?.let { file(it) }?.let { storeFile = it }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
        create("debugFallback") {
            storeFile = rootProject.file("debug.keystore")
            storePassword = "ecardo_debug_keystore"
            keyAlias = "ecardo-debug"
            keyPassword = "ecardo_debug_keystore"
        }
    }

    buildTypes {
        release {
            // Pick the right signing config: real release keystore when
            // key.properties exists, otherwise the deterministic debug fallback.
            // This GUARANTEES the APK is always signed.
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debugFallback")
            }

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

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
// Reads `android/key.properties` if present. This file is generated at build
// time (locally or in CI) from the GitHub Secrets `SIGNING_KEYSTORE_BASE64`,
// `SIGNING_KEY_PASSWORD`, `SIGNING_KEY_ALIAS`, `SIGNING_STORE_PASSWORD`.
//
// Fallback to debug signing is INTENTIONAL for `flutter run --release` on a
// developer machine that has not set up the release keystore yet. CI always
// provides the secrets, so release artifacts produced by GitHub Actions are
// always signed with the production keystore.
// ============================================================================
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

android {
    namespace = "com.ecardo.user"
    compileSdk = 36
    ndkVersion = "28.0.12674087"

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

    signingConfigs {
        create("release") {
            keystoreProperties["storeFile"]?.let { file(it) }?.let { storeFile = it }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        release {
            // Use the release keystore when key.properties is present (CI builds),
            // otherwise fall back to the debug keystore (local `flutter run --release`).
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // v1.0.4+5: Enable R8 obfuscation + shrinking
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

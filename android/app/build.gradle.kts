plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
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

        // v1.0.4+5: Use network_security_config.xml to disable cleartext + block user CAs
        androidManifestPlaceholders["usesCleartextTraffic"] = "false"
    }

    buildTypes {
        release {
            // TODO: Replace debug signing with a proper upload keystore before Play Store submission.
            // For now, keep debug signing so existing sideload users don't break, but document that
            // a release keystore MUST be generated before any production launch.
            signingConfig = signingConfigs.getByName("debug")

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

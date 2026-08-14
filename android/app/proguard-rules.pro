# eCardo User App — ProGuard / R8 Rules
# v1.0.4+5 — security audit fix
#
# This file configures R8 obfuscation and shrinking for release builds.
# Combined with `--obfuscate --split-debug-info` in the Flutter build,
# this makes reverse-engineering significantly harder.

# ---------- Flutter ----------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ---------- GetX (state management) ----------
-keep class get.** { *; }
-dontwarn get.**

# ---------- Dio (HTTP) ----------
-keep class dio.** { *; }
-dontwarn dio.**
-keepattributes Signature
-keepattributes *Annotation*

# ---------- Firebase ----------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# ---------- flutter_secure_storage ----------
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ---------- flutter_local_notifications ----------
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ---------- Models (kept for JSON serialization) ----------
# Keep all model classes in the app (they're used by reflection-like JSON parsing)
-keep class com.ecardo.user.** { *; }
-keep class com.ecardo.ecardo_user.** { *; }

# Keep enum values (used in switch statements and JSON parsing)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ---------- Kotlin Metadata ----------
-keep class kotlin.Metadata { *; }
-keepattributes Kotlin

# ---------- Gson / JSON (if used by any plugin) ----------
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# ---------- WebViews (in-app browser for payment gateways) ----------
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# ---------- Camera (mobile_scanner + camerawesome) ----------
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ---------- open_filex (APK install via FileProvider) ----------
-keep class com.skypixel.open_filex.** { *; }
-dontwarn com.skypixel.open_filex.**
# androidx FileProvider — used by open_filex to share the APK URI
-keep class androidx.core.content.FileProvider { *; }

# ---------- package_info_plus ----------
-keep class dev.britannio.package_info_plus.** { *; }
-dontwarn dev.britannio.package_info_plus.**

# ---------- path_provider ----------
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# ---------- permission_handler ----------
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

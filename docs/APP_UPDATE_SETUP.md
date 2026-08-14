# eCardo App Update System — Cross-App Setup Guide

This document explains how to roll out the new in-app self-update system
to the **merchant** and **agent** apps. The user app (`ecardo_userapp_v1`)
is already wired up; the same pattern applies to the other two apps with
only a handful of config changes.

---

## Architecture overview

The system is **parameterized** so the same Dart code can drive all three
apps without hard-coding package names. The only per-app differences are:

1. `AppUpdateConfig` (Dart) — controls SharedPreferences keys, APK file name.
2. FCM topic name (Dart) — each app subscribes to its own topic.
3. `applicationId` (Android) — each app has a different package name.
4. `ECARDO_DEPLOY_SECRET` value (GitHub Actions) — different per app.
5. `app_type` field in the deploy webhook payload (GitHub Actions).
6. Release keystore — each app SHOULD use its own keystore for security
   isolation, but they MAY share one if you accept the risk.

Everything else (the controller, the screen, the manifest entries, the
FileProvider, the FCM message handler) is identical across apps.

---

## Step-by-step: roll out to the merchant app

> Replace "merchant" with "agent" for the agent app. The steps are the
> same; only the topic name and config constant change.

### 1. Android — `android/app/build.gradle.kts`

Copy the `build.gradle.kts` from this repo verbatim. Then change:

```kotlin
namespace = "com.ecardo.merchant"          // was com.ecardo.user
applicationId = "com.ecardo.merchant"      // was com.ecardo.user
```

### 2. Android — `AndroidManifest.xml`

Copy the manifest verbatim. The `${applicationId}` placeholder is used
for the FileProvider authority, so it will automatically resolve to
`com.ecardo.merchant.fileprovider` without any manual edit.

### 3. Android — `res/xml/file_paths.xml`

Copy this file verbatim. No changes needed.

### 4. Android — `proguard-rules.pro`

Copy verbatim.

### 5. GitHub Actions — `.github/workflows/flutter.yml`

Copy the workflow verbatim, then change:

```yaml
env:
  ECARDO_DEPLOY_SECRET: ${{ secrets.ECARDO_DEPLOY_SECRET }}
run: |
  ...
  -F "app_type=merchant" \    # was "user"
```

### 6. Dart — `lib/main.dart`

Register the controller with the merchant config:

```dart
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';

Future<void> _initializeServices() async {
  ...
  // Use the merchant config
  Get.put<AppUpdateController>(
    AppUpdateController(config: AppUpdateConfig.merchant),
    permanent: true,
  );
  // Tell FCM service which topic to subscribe to
  FirebaseMessagingService.configure(updateTopic: 'app_updates_merchant');
  ...
}
```

### 7. GitHub Secrets — set up the same four secrets

In the merchant repo: Settings → Secrets and variables → Actions → New
repository secret. Add:

- `SIGNING_KEYSTORE_BASE64`
- `SIGNING_STORE_PASSWORD`
- `SIGNING_KEY_ALIAS`
- `SIGNING_KEY_PASSWORD`
- `ECARDO_DEPLOY_SECRET`

(Use a DIFFERENT deploy secret than the user app for security isolation.
The backend webhook should accept all three secrets and map them to the
correct `app_type`.)

### 8. Backend — broadcast FCM to the right topic

When the admin publishes a new merchant-app version, the backend should:

1. Update the `app_version`, `app_update_link`, `app_force_update`
   settings rows in the merchant database.
2. Send an FCM data message to the `app_updates_merchant` topic:

```json
{
  "message": {
    "topic": "app_updates_merchant",
    "data": {
      "type": "app_update",
      "version": "1.0.8",
      "force": "0",
      "url": "https://ecardo.ir/storage/apks/merchant/...apk"
    },
    "android": { "priority": "high" }
  }
}
```

Firebase Admin SDK example (Node.js):

```javascript
await admin.messaging().send({
  topic: 'app_updates_merchant',
  data: {
    type: 'app_update',
    version: newVersion,
    force: isForceUpdate ? '1' : '0',
    url: downloadUrl,
  },
  android: { priority: 'high' },
});
```

Firebase Admin SDK example (PHP — if backend is Laravel):

```php
$factory = (new Factory)->withServiceAccount(__DIR__.'/firebase-credentials.json');
$messaging = $factory->createMessaging();
$messaging->send([
    'topic' => 'app_updates_merchant',
    'data' => [
        'type' => 'app_update',
        'version' => $newVersion,
        'force' => $isForceUpdate ? '1' : '0',
        'url' => $downloadUrl,
    ],
    'android' => ['priority' => 'high'],
]);
```

---

## Topic name summary

| App       | FCM topic                | `AppUpdateConfig` constant |
|-----------|--------------------------|----------------------------|
| User      | `app_updates_user`       | `AppUpdateConfig.user`     |
| Merchant  | `app_updates_merchant`   | `AppUpdateConfig.merchant` |
| Agent     | `app_updates_agent`      | `AppUpdateConfig.agent`    |

---

## Backend webhook contract (for all three apps)

`POST /api/{user|merchant|agent}/github-deploy-webhook`

Form-data fields:

| Field      | Description                                           |
|------------|-------------------------------------------------------|
| `secret`   | The per-app deploy secret                             |
| `app_type` | `user`, `merchant`, or `agent`                        |
| `version`  | Semantic version string (e.g. `1.0.8`)                |
| `apk`      | The APK file                                          |

The backend should:

1. Validate `secret` against the per-app expected value.
2. Store the APK at a stable URL (e.g.
   `https://ecardo.ir/storage/apks/{app_type}/latest.apk`).
3. Update the `app_version`, `app_update_link`, `app_force_update`
   settings rows in the matching database.
4. Broadcast an FCM data message to the matching topic
   (`app_updates_{app_type}`) so all installed clients wake up and
   re-fetch settings.

The expected success response body is:

```json
{ "status": "success", "message": "Successfully deployed" }
```

(The GitHub Actions workflow greps for `Successfully deployed` in the
response body to decide whether the deploy step succeeded.)

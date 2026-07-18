import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPuzlpFKROdqTzLbkvi2QQf1OBU0UsEx8',
    appId: '1:292987494106:android:3f1e8b21e46ceb2c138fe3',
    messagingSenderId: '292987494106',
    projectId: 'ecardo-app',
    storageBucket: 'ecardo-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgFfu2VI5eHHsXsy_FlI0bXHy3-hzp6uo', // Keeps old until iOS config provided
    appId: '1:279734428004:ios:f06064424e537a53949a71', // Keeps old until iOS config provided
    messagingSenderId: '292987494106',
    projectId: 'ecardo-app',
    storageBucket: 'ecardo-app.firebasestorage.app',
    iosBundleId: 'com.qunzo.user',
  );

}
